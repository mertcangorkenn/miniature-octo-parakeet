import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:quran_app/bricks/my_widgets/my_button.dart';
import 'package:quran_app/src/profile/controllers/user_controller.dart';
import 'package:quran_app/src/profile/views/signin_page.dart';
import 'package:quran_app/src/quran/controller/surah_controller.dart';
import 'package:quran_app/src/quran/model/surah.dart';
import 'package:quran_app/src/quran/view/surah_detail_page.dart';
import 'package:quran_app/src/quran/widget/confirm_delete_favorite.dart';
import 'package:quran_app/src/quran/widget/shimmer/surah_card_shimmer.dart';
import 'package:quran_app/src/quran/widget/surah_item.dart';
import 'package:quran_app/src/settings/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unicons/unicons.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    // final surahFavoriteC = Get.put(SurahFavoriteController());
    final surahC = Get.put(SurahController());
    final userC = Get.put(UserControllerImpl());

    if (userC.user.id != null) {
      if (surahC.surahFavorites.isEmpty) {
        surahC.fetchSurahFavorites(userC.user.id!);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Favoriler",
          style: AppTextStyle.bigTitle,
        ),
        actions: [
          Obx(
            () => userC.user.email == null
                ? const SizedBox()
                : IconButton(
                    onPressed: () {
                      Get.dialog(ConfirmDeleteFavorite(
                        message:
                            "Favorilerden tümünü kaldırmak\n istediğinizden emin misiniz?",
                        onCancel: () => Get.back(),
                        onDelete: () {
                          surahC.removeAllFromFavorite(userC.user.id!);
                        },
                      ));
                    },
                    icon: const Icon(
                      UniconsLine.trash,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: true,
        elevation: 1,
      ),
      body: Obx(
        () => userC.user.email == null
            ? FadeIn(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/illustration/cannot-access-state.svg",
                        width: 190,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Bir sorun var...",
                        style: AppTextStyle.bigTitle,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Önce giriş yapalım, sonra bu özelliği \nkeşfedebilir ve keyfini çıkarabilirsiniz.",
                        style: AppTextStyle.normal.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      MyButton(
                        width: MediaQuery.of(context).size.width * 0.7,
                        text: "Giriş Yap",
                        onPressed: () => Get.to(SignInPage()),
                      ),
                    ],
                  ),
                ),
              )
            : surahC.isFavoriteLoaded.value
                ? ListView(
                    children: const [
                      SurahCardShimmer(amount: 5),
                    ],
                  )
                : surahC.surahFavorites.isEmpty
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/illustration/empty-state-list-1.svg",
                              width: 200,
                            ),
                            const SizedBox(height: 40),
                            Text(
                              "Favori yok",
                              style: AppTextStyle.bigTitle,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Henüz favori bir sureniz yok.",
                              style: AppTextStyle.normal.copyWith(
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await Future.delayed(
                              const Duration(milliseconds: 1500));
                          surahC.fetchSurahFavorites(userC.user.id!);
                        },
                        backgroundColor: Theme.of(context).cardColor,
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 3,
                        triggerMode: RefreshIndicatorTriggerMode.onEdge,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            itemBuilder: (ctx, i) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FadeInDown(
                                    child: Slidable(
                                      closeOnScroll: true,
                                      startActionPane: ActionPane(
                                        extentRatio: 0.3,
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              print(userC.user.id.toString());
                                              Get.dialog(ConfirmDeleteFavorite(
                                                message:
                                                    "\"${surahC.surahFavorites.toList()[i].name}\" suresini favorilerden kaldırmak istediğine emin misin?",
                                                onCancel: () => Get.back(),
                                                onDelete: () {
                                                  surahC
                                                      .removeFromFavorite(
                                                        userC.user.id!,
                                                        surahC.surahFavorites
                                                            .toList()[i],
                                                      )
                                                      .then((value) =>
                                                          Get.back());
                                                },
                                              ));
                                            },
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            icon: UniconsLine.trash,
                                            autoClose: true,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          const SizedBox(width: 16),
                                        ],
                                      ),
                                      endActionPane: ActionPane(
                                        extentRatio: 0.3,
                                        motion: const ScrollMotion(),
                                        children: [
                                          const SizedBox(width: 16),
                                          SlidableAction(
                                            onPressed: (context) {
                                              Get.dialog(ConfirmDeleteFavorite(
                                                message:
                                                    "\"${surahC.surahFavorites.toList()[i].name}\" suresini favorilerden kaldırmak istediğine emin misin?",
                                                onCancel: () => Get.back(),
                                                onDelete: () {
                                                  surahC
                                                      .removeFromFavorite(
                                                        userC.user.id!,
                                                        surahC.surahFavorites
                                                            .toList()[i],
                                                      )
                                                      .then((value) =>
                                                          Get.back());
                                                },
                                              ));
                                            },
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            icon: UniconsLine.trash,
                                            autoClose: true,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        highlightColor: Colors.white12,
                                        splashColor: Colors.white12,
                                        onTap: () {
                                          surahC.setRecenlySurah(surahC
                                              .surahFavorites
                                              .toList()[i]);
                                          Get.to(
                                            SurahDetailPage(
                                              surah: surahC.surahFavorites
                                                  .toList()[i],
                                            ),
                                            routeName: 'surah-detail',
                                          );
                                        },
                                        child: SurahItem(
                                          number: surahC.surahFavorites
                                              .toList()[i]
                                              .number,
                                          name: surahC.surahFavorites
                                              .toList()[i]
                                              .name!,
                                          numberOfVerses: surahC.surahFavorites
                                              .toList()[i]
                                              .numberOfVerses,
                                          nameOriginal: surahC.surahFavorites
                                              .toList()[i]
                                              .nameOriginal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (ctx, i) {
                              return const SizedBox(height: 10);
                            },
                            itemCount: surahC.surahFavorites.length,
                          ),
                        ),
                      ),
      ),
    );
  }
}
