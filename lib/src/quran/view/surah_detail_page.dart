import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:like_button/like_button.dart';
import 'package:quran_app/helper/ads.dart';
import 'package:quran_app/src/profile/controllers/user_controller.dart';
import 'package:quran_app/src/profile/views/signin_page.dart';
import 'package:quran_app/src/quran/controller/audio_player_controller.dart';
import 'package:quran_app/src/quran/controller/surah_controller.dart';
import 'package:quran_app/src/quran/model/surah.dart';
import 'package:quran_app/src/quran/model/translations.dart';
import 'package:quran_app/src/quran/model/verse.dart';
import 'package:quran_app/src/quran/widget/shimmer/surah_detail_page_shimmer.dart';
import 'package:quran_app/src/quran/widget/surah_card.dart';
import 'package:quran_app/src/quran/widget/tafsir_view.dart';
import 'package:quran_app/src/quran/widget/verse_item.dart';
import 'package:quran_app/src/settings/theme/app_theme.dart';
import 'package:quran_app/src/widgets/app_loading.dart';
import 'package:quran_app/src/widgets/forbidden_card.dart';
import 'package:unicons/unicons.dart';

// ignore: must_be_immutable
class SurahDetailPage extends StatefulWidget {
  SurahDetailPage({Key? key, required this.surah}) : super(key: key);
  final Surah surah;

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final controller = Get.find<SurahController>();

  final userC = Get.put(UserControllerImpl());

  final audioPlayerController = Get.put(AudioPlayerController());

  Widget tafsirView = const SizedBox();

  int authorId = 105;
  List<Author> authorList = [];
  Author? author;

  var audioPlayer = AudioPlayer();
  BannerAd? myBanner;

  @override
  void initState() {
    myBanner = AdsHelper.banner();
    myBanner!.load().then((value) {
      setState(() {});
    });
    authorList = controller.listOfAuthor.toList();
    audioPlayer.onPlayerStateChanged.listen((event) {
      audioPlayerController.playerState.value = event;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // controller.resetVerses();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kuran",
          style: AppTextStyle.bigTitle,
        ),
        actions: [
          LikeButton(
            likeBuilder: (bool isLiked) {
              return Icon(
                Get.isDarkMode && isLiked
                    ? Icons.favorite
                    : !Get.isDarkMode && isLiked
                        ? Icons.favorite
                        : Get.isDarkMode || !isLiked
                            ? UniconsLine.heart
                            : UniconsLine.heart,
                color: isLiked && Get.isDarkMode ? Colors.redAccent : Colors.white,
              );
            },
            circleColor: CircleColor(
              start: Colors.white,
              end: !Get.isDarkMode ? Theme.of(context).primaryColor : Colors.redAccent,
            ),
            bubblesColor: BubblesColor(
              dotPrimaryColor: !Get.isDarkMode ? Theme.of(context).primaryColor : Colors.red,
              dotSecondaryColor: Colors.white,
            ),
            isLiked: controller.isFavorite(widget.surah),
            onTap: (isLiked) async {
              if (userC.user.id != null) {
                if (controller.isFavorite(widget.surah)) {
                  final result = await controller.removeFromFavorite(106, widget.surah);
                  return !result;
                } else {
                  final result = await controller.addToFavorite(106, widget.surah);
                  return result;
                }
              } else {
                // Get.to(const FavoritePage(), routeName: '/favorite');
                Get.dialog(ForbiddenCard(
                  onPressed: () {
                    Get.back();
                    Get.to(SignInPage(), routeName: '/login');
                  },
                ));
                return false;
              }
            },
          ),
          const SizedBox(width: 10),
        ],
        centerTitle: true,
        elevation: 1,
      ),
      body: FutureBuilder(
        future: controller.fetchSurahByID(widget.surah.number, authorId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          } else if (!snapshot.hasData) {
            return const SurahDetailPageShimmer();
          } else {
            print(controller.verses[1].translation!.author);
            return Obx(() {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          SurahCard(
                            number: widget.surah.number,
                            name: "${widget.surah.name}",
                            numberOfVerses: widget.surah.numberOfVerses,
                            originalName: widget.surah.nameOriginal,
                            function: () {
                              if (audioPlayerController.playerState.value == PlayerState.playing) {
                                audioPlayer.pause();
                              } else if (audioPlayerController.playerState.value == PlayerState.paused) {
                                audioPlayer.resume();
                              } else {
                                audioPlayer.play(UrlSource(controller.audioUrl.first));
                              }
                            },
                            icon: audioPlayerController.playerState.value == PlayerState.playing ? Icon(Icons.pause) : Icon(Icons.play_arrow_rounded),
                          ),
                          // const SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: DropdownButton<Author>(
                              value: author ?? authorList[10],
                              items: authorList.map((item) => DropdownMenuItem(value: item, child: Text(item.name!.toString()))).toList(),
                              hint: Text("Meal Yazarı Seç"),
                              onChanged: (a) {
                                setState(() {
                                  author = a!;
                                  authorId = a.id!;
                                });
                              },
                            ),
                          ),
                          if (!snapshot.hasData) const SurahDetailPageShimmer(),
                          for (var verse in controller.verses)
                            FadeInDown(
                              from: 50,
                              child: VerseItem(
                                surahName: verse.surahName,
                                verseNumber: verse.verseNumber,
                                verse: verse.verse,
                                transcription: verse.transcription,
                                textTranslation: verse.translation!.text,
                                author: verse.translation!.author,
                                onTapSeeTafsir: () {
                                  if (controller.showTafsir.value) {
                                    controller.showTafsir.value = false;
                                  }

                                  controller.showTafsir.value = true;
                                  _buildTafsirView(verse);
                                },
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: myBanner != null
                        ? Container(
                            alignment: Alignment.center,
                            child: AdWidget(ad: myBanner!),
                            width: myBanner!.size.width.toDouble(),
                            height: myBanner!.size.height.toDouble(),
                          )
                        : Container(),
                  ),
                  if (controller.showTafsir.value) tafsirView,
                ],
              );
            });
          }
        },
      ),
    );
  }

  _buildTafsirView(Verse verse) {
    tafsirView = TafsirView(
        surahId: verse.surahId,
        verseId: verse.verseNumber,
        closeShow: () {
          controller.showTafsir.value = false;
          controller.resetWords();
          controller.resetTranslations();
        });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
