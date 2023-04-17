import 'dart:convert';
import 'dart:io';

import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:quran_app/bricks/my_widgets/dotted_loading_indicator.dart';
import 'package:quran_app/bricks/my_widgets/notebook_icon.dart';
import 'package:quran_app/list.dart';
import 'package:quran_app/name_page.dart';
import 'package:quran_app/qaPage.dart';
import 'package:quran_app/src/articles/controllers/article_controller.dart';
import 'package:quran_app/src/articles/views/articles_page.dart';
import 'package:quran_app/src/articles/widgets/article_card.dart';
import 'package:quran_app/src/articles/widgets/article_card_shimmer.dart';
import 'package:quran_app/src/home/controller/home_controller.dart';
import 'package:quran_app/src/prayer_time/controllers/prayer_time_controller.dart';
import 'package:quran_app/src/prayer_time/views/prayer_time_page.dart';
import 'package:quran_app/src/prayer_time/widgets/prayer_time_card.dart';
import 'package:quran_app/src/prayer_time/widgets/prayer_time_card_shimmer.dart';
import 'package:quran_app/src/profile/controllers/user_controller.dart';
import 'package:quran_app/src/profile/views/profile_page.dart';
import 'package:quran_app/src/quran/controller/surah_controller.dart';
import 'package:quran_app/src/quran/view/surah_detail_page.dart';
import 'package:quran_app/src/quran/view/surah_page.dart';
import 'package:quran_app/src/settings/controller/settings_controller.dart';
import 'package:quran_app/src/settings/theme/app_theme.dart';
import 'package:quran_app/src/widgets/app_card.dart';
import 'package:quran_app/src/zikirmatik.dart';
import 'package:scroll_edge_listener/scroll_edge_listener.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unicons/unicons.dart';

import '../../../helper/ads.dart';
import '../../../husna_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

int rnd = new Random().nextInt(49) + 1;

class _HomePageState extends State<HomePage> {
  final userC = Get.put(UserControllerImpl());

  final homeC = Get.put(HomeController());

  final prayerTimeC = Get.put(PrayerTimeControllerImpl());

  final _settingsController = Get.put(SettingsController());

  final surahC = Get.put(SurahController());

  final articleC = Get.put(ArticleController());
  AppUpdateInfo? _updateInfo;
  BannerAd? myBanner;
  List name = [];
  List meaning = [];
  List isim = [];
  List<List> isimAnlam = [];
  List erkek = [];
  List<List> erkekAnlam = [];
  List soru = [];
  List cevap = [];

  int rnd99 = new Random().nextInt(99);
  int rnd3157 = new Random().nextInt(1265);
  int rnd460 = new Random().nextInt(460);
  @override
  void initState() {
    // TODO: implement initState
    qa.forEach((key, value) {
      soru.add(key);
      cevap.add(value);
    });
    data.forEach((key, value) {
      name.add(key);
      meaning.add(value);
    });
    myBanner = AdsHelper.square();
    myBanner!.load().then((value) {
      setState(() {});
    });
    names.forEach((Map element) {
      isim.add(element.values.first);
      List anlamlar = element.values.toList();
      final val = anlamlar.remove(element.values.first);
      isimAnlam.add(anlamlar);
    });
    erkekIsimleri.forEach((Map element) {
      erkek.add(element.values.first);
      List anlamlar = element.values.toList();
      final val = anlamlar.remove(element.values.first);
      erkekAnlam.add(anlamlar);
    });
    super.initState();
    randomAyetCek();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });

      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        print("update available");

        InAppUpdate.performImmediateUpdate().catchError((e) {});
      } else {
        print("update not available");
      }
    }).catchError((e) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              rnd = new Random().nextInt(49) + 1;
            });
            await Future.delayed(const Duration(milliseconds: 1500));

            prayerTimeC.getLocation().then((_) {
              prayerTimeC.cT.restart(duration: prayerTimeC.leftOver.value);
            });

            articleC.loadArticleforHome();
          },
          backgroundColor: Theme.of(context).cardColor,
          color: Theme.of(context).primaryColor,
          strokeWidth: 3,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          child: ScrollEdgeListener(
            edge: ScrollEdge.start,
            edgeOffset: 300,
            continuous: false,
            debounce: const Duration(milliseconds: 100),
            dispatch: false,
            listener: () {
              setState(() {
                rnd = new Random().nextInt(49) + 1;
              });
            },
            child: ListView(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(() => ProfilePage()),
                            child: Obx(
                              () => (userC.user.photoUrl != null)
                                  ? Hero(
                                      tag: "avatar",
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.network(
                                          userC.user.photoUrl.toString(),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (ctx, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }

                                            return Center(
                                              child: SizedBox(
                                                height: 36,
                                                child:
                                                    DottedCircularProgressIndicatorFb(
                                                  currentDotColor:
                                                      _settingsController
                                                              .isDarkMode.value
                                                          ? Theme.of(context)
                                                              .backgroundColor
                                                              .withOpacity(0.3)
                                                          : Theme.of(context)
                                                              .primaryColor
                                                              .withOpacity(0.3),
                                                  defaultDotColor:
                                                      _settingsController
                                                              .isDarkMode.value
                                                          ? Theme.of(context)
                                                              .backgroundColor
                                                          : Theme.of(context)
                                                              .primaryColor,
                                                  numDots: 7,
                                                  dotSize: 3,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : Hero(
                                      tag: "avatarIcon",
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1),
                                          // color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        height: 50,
                                        width: 50,
                                        child: Icon(
                                          Icons.person,
                                          // size: 30,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Selamun Aleyküm,",
                                style: AppTextStyle.small.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  userC.user.name ?? "Allah'ın Güzel Kulları",
                                  style: AppTextStyle.title,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ZikirmatikScreen()));
                        },
                        child: Image.asset(
                          "assets/tasbih.png",
                          width: 30,
                          height: 30,
                          color:
                              Theme.of(context).iconTheme.color ?? Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_settingsController.isDarkMode.value) {
                            final box = Get.find<GetStorage>();
                            var primaryColorName = box.read('primaryColor');

                            if (primaryColorName != null) {
                              _settingsController.setTheme(primaryColorName);
                            } else {
                              var listColor = _settingsController.listColor;
                              var listColorName =
                                  _settingsController.listColorName;
                              var primaryColor =
                                  _settingsController.primaryColor.value;

                              for (var i = 0; i <= 4; i++) {
                                if (listColor[i] == primaryColor) {
                                  _settingsController
                                      .setTheme(listColorName[i]);
                                }
                              }
                            }
                          } else {
                            _settingsController.setDarkMode(true);
                          }
                        },
                        child: Icon(
                          _settingsController.isDarkMode.value
                              ? UniconsLine.moon
                              : UniconsLine.sun,
                          color:
                              Theme.of(context).iconTheme.color ?? Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                FadeInRight(
                  from: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(
                      () => prayerTimeC.isLoadLocation.value
                          ? const PrayerTimeCardShimmer()
                          : GestureDetector(
                              onTap: () => Get.to(
                                PrayerTimePage(),
                              ),
                              child: Hero(
                                tag: 'prayer_time_card',
                                child: PrayerTimeCard(prayerTimeC: prayerTimeC),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: myBanner != null
                        ? Container(
                            alignment: Alignment.center,
                            child: AdWidget(ad: myBanner!),
                            width: myBanner!.size.width.toDouble(),
                            height: myBanner!.size.height.toDouble(),
                          )
                        : Container(),
                  ),
                ),
                const SizedBox(height: 10),
                FadeInLeft(
                  from: 50,
                  child: AppCard(
                    vPadding: 16,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        UniconsLine.book_open,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Son Okuma",
                                        style: AppTextStyle.small.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Obx(
                                    () => Text(
                                      surahC.recenlySurah.name != null
                                          ? "Kuran"
                                          : "Biraz bekler misin?",
                                      style: AppTextStyle.bigTitle.copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(
                                    () => surahC.recenlySurah.name != null
                                        ? Text(
                                            surahC.recenlySurah.name!
                                                    .toString() +
                                                " Suresi",
                                            style: AppTextStyle.normal,
                                          )
                                        : Text(
                                            "Son zamanlarda Kuran okumadığını görüyorum. Kabir karanlık ve sorunlar zor",
                                            style: AppTextStyle.small,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(child: Icon3DFb13(), width: 100),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            if (surahC.recenlySurah.name != null) {
                              Get.to(
                                SurahDetailPage(
                                  surah: surahC.recenlySurah,
                                ),
                              );
                            } else {
                              Get.to(SurahPage());
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [AppShadow.card],
                            ),
                            child: Center(
                              child: Obx(
                                () => Text(
                                  surahC.recenlySurah.name != null
                                      ? "Tekrar Oku"
                                      : "Kuran Oku",
                                  style: AppTextStyle.normal.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Günün Ayeti - Hadisi - Sözü - Fihristi",
                        style: AppTextStyle.bigTitle.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.to(() => const ArticlesPage()),
                        child: Text(
                          "Tümünü Gör",
                          style: AppTextStyle.small.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                cekildi == false
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: ArticleCardShimmer(),
                      )
                    : FadeInRight(
                        from: 50,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: ArticleCard(
                              title: jsonoRandomAyet['title'],
                              content: jsonoRandomAyet['text'],
                              author: "Günün Ayeti",
                            ),
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Esmaül Hüsna",
                        style: AppTextStyle.bigTitle.copyWith(
                          fontSize: 15,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.to(() => const HusnaPage()),
                        child: Text(
                          "Tüm İsimleri Gör",
                          style: AppTextStyle.small.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FadeInRight(
                  from: 50,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ArticleCard(
                        title: name[rnd],
                        content: meaning[rnd],
                        author: "Allah'ın Güzel İsimleri ",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Günün İsmi",
                        style: AppTextStyle.bigTitle.copyWith(
                          fontSize: 15,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.to(() => const NamePage()),
                        child: Text(
                          "Tüm İsimleri Gör",
                          style: AppTextStyle.small.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FadeInRight(
                  from: 50,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          //width: 320,
                          //height: height,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            // vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [AppShadow.card],
                            border: Get.isDarkMode
                                ? null
                                : Border.all(
                                    color: Colors.grey.shade100,
                                  ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(36),
                                      child: Image.asset(
                                        "assets/icon/icon.png",
                                        width: 30,
                                      )),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Kız - Erkek İsmi",
                                      style: AppTextStyle.small,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {}, icon: Icon(Icons.share))
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Kadın İsmi:",
                                style: AppTextStyle.bigTitle,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isim[rnd3157],
                                style: AppTextStyle.title,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isimAnlam[rnd3157]
                                    .toString()
                                    .replaceAll("[ ", "")
                                    .replaceAll("[", "")
                                    .replaceAll("]", ""),
                                style: AppTextStyle.normal,
                                //maxLines: 2,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Erkek İsmi:",
                                style: AppTextStyle.bigTitle,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                erkek[rnd3157],
                                style: AppTextStyle.title,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                erkekAnlam[rnd3157]
                                    .toString()
                                    .replaceAll("[ ", "")
                                    .replaceAll("[", "")
                                    .replaceAll("]", ""),
                                style: AppTextStyle.normal,
                                //maxLines: 2,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        )),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Günün Sorusu",
                        style: AppTextStyle.bigTitle.copyWith(
                          fontSize: 15,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.to(() => const QAPage()),
                        child: Text(
                          "Tüm Soruları Gör",
                          style: AppTextStyle.small.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FadeInRight(
                  from: 50,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ArticleCard(
                        title: soru[rnd460],
                        content: cevap[rnd460]
                            .toString()
                            .replaceAll("[ ", "")
                            .replaceAll("[", "")
                            .replaceAll("]", ""),
                        author: "İslami Soru ve Cevaplar",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    height: 350,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          "assets/random_image/1 copy ${0 + rnd}.jpg",
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        )),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map jsonoRandomAyet = new Map();
  bool cekildi = false;

  void randomAyetCek() async {
    var response = await http.get(Uri.parse(
      "https://jovial-curran.45-158-12-188.plesk.page/api/v1/random?apikey=123",
    ));
    jsonoRandomAyet = json.decode(response.body)['ayet'];

    jsonoRandomAyet['text'] = jsonoRandomAyet['ayet'];
    jsonoRandomAyet['title'] = jsonoRandomAyet['ayetNo'];
    setState(() {
      cekildi = true;
    });
  }

  Image img() {
    int min = 0;
    int max = 50;
    Random rnd = new Random();
    int r = min + rnd.nextInt(max - min);
    String image_name = "assets/random_image/1 copy $r.jpg";
    return Image.asset(
        "assets/random_image/1 copy ${min + rnd.nextInt(50 - 0)}.jpg");
  }
}
