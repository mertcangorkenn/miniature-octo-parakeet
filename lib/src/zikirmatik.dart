import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart';
import '../helper/ads.dart';
import '../list.dart';

class ZikirmatikScreen extends StatefulWidget {
  @override
  State<ZikirmatikScreen> createState() => _ZikirmatikScreenState();
}

class _ZikirmatikScreenState extends State<ZikirmatikScreen> {
  List zikirr = [];

  List anlami = [];
  BannerAd? myBanner;

  @override
  void initState() {
    myBanner = AdsHelper.banner();
    myBanner!.load().then((value) {
      setState(() {});
    });
    zikir.forEach((key, value) {
      zikirr.add(key);
      anlami.add(value);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: myBanner != null
          ? Container(
              height: 50,
              child: AdWidget(
                ad: myBanner!,
              ),
            )
          : Container(),
      appBar: AppBar(
        title: Text('Zikirmatik'),
      ),
      body: ValueListenableBuilder(
          valueListenable: Hive.box('zikirmatik').listenable(),
          builder: (context, Box box, widget) {
            return ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  endIndent: 16,
                  indent: 16,
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                );
              },
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ZikirPage(
                              index: index,
                            ),
                          ),
                        );
                      },
                      trailing: SizedBox(
                        width: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Text((box.get('counter$index') ?? 0).toString(),
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Get.isDarkMode
                                            ? Colors.white.withOpacity(0.5)
                                            : Colors.black)),
                                CircularProgressIndicator(
                                  strokeWidth: 5,
                                  backgroundColor: Colors.grey.withOpacity(0.5),
                                  value: double.parse(
                                          (box.get('counter${index}') ?? 0)
                                              .toString()) /
                                      41,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.green),
                                ),
                              ],
                            ),
                            Text((box.get('round$index') ?? 0).toString(),
                                style: TextStyle(
                                    color: Get.isDarkMode
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black)),
                          ],
                        ),
                      ),
                      title: Text(
                        zikirr[index],
                        style: TextStyle(
                            fontSize: 20,
                            color: Get.isDarkMode
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black),
                      ),
                    ),
                  ],
                );
              },
              itemCount: zikirr.length,
            );
          }),
    );
  }
}

class ZikirPage extends StatefulWidget {
  ZikirPage({Key? key, required this.index}) : super(key: key);
  int index;
  @override
  State<ZikirPage> createState() => _ZikirPageState();
}

bool isVibrate = true;
bool sound = true;

class _ZikirPageState extends State<ZikirPage> {
  BannerAd? myBanner;
  @override
  void initState() {
    myBanner = AdsHelper.banner();
    myBanner!.load().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List zikirr = [];
    List anlami = [];
    return Scaffold(
      bottomNavigationBar: myBanner != null
          ? Container(
              alignment: Alignment.center,
              child: AdWidget(ad: myBanner!),
              width: myBanner!.size.width.toDouble(),
              height: myBanner!.size.height.toDouble(),
            )
          : Container(
              height: 0,
              width: 0,
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.refresh),
        onPressed: () async {
          await Hive.box("zikirmatik").put('counter${widget.index}', 0);
          await Hive.box("zikirmatik").put('round${widget.index}', 0);
        },
      ),
      appBar: AppBar(
        title: Text('Zikirmatik'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('zikirmatik').listenable(),
        builder: (context, Box box, wid) {
          zikir.forEach((key, value) {
            zikirr.add(key);
            anlami.add(value);
          });

          int counter = box.get('counter${widget.index}', defaultValue: 0);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                    height: 352,
                    child: Scrollbar(
                      isAlwaysShown: true,
                      child: ListView(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            zikirr[widget.index],
                            style: TextStyle(
                                fontSize: 30,
                                color: Get.isDarkMode
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            anlami[widget.index],
                            style: TextStyle(
                                fontSize: 20,
                                color: Get.isDarkMode
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black),
                          ),
                        ],
                      ),
                    )),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    if (await Vibration.hasVibrator() == true &&
                        isVibrate == true) {
                      Vibration.vibrate();
                    }
                    Hive.box("zikirmatik").put(
                        "counter${widget.index}",
                        Hive.box("zikirmatik").get("counter${widget.index}",
                                defaultValue: 0) +
                            1);
                    if (Hive.box("zikirmatik").get("counter${widget.index}") ==
                        41) {
                      Hive.box("zikirmatik").put("counter${widget.index}", 0);
                      Hive.box("zikirmatik").put(
                          "round${widget.index}",
                          Hive.box("zikirmatik").get("round${widget.index}",
                                  defaultValue: 0) +
                              1);
                    }
                    if (sound == true) {
                      AudioPlayer().play(AssetSource('click.mp3'));
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 132,
                        height: MediaQuery.of(context).size.width - 132,
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          backgroundColor: Colors.grey.withOpacity(0.5),
                          value: double.parse(
                                  (box.get('counter${widget.index}') ?? 0)
                                      .toString()) /
                              41,
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          sound
                              ? Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          sound = false;
                                        });
                                      },
                                      icon: Icon(Icons.volume_up)),
                                )
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      sound = true;
                                    });
                                    print("object");
                                  },
                                  icon: Icon(Icons.volume_off)),
                          Text('${box.get('counter${widget.index}') ?? 0}',
                              style: TextStyle(
                                  fontSize: 50,
                                  color: Get.isDarkMode
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black)),
                          Container(
                            width: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black,
                                borderRadius: BorderRadius.circular(10)),
                            width: 4,
                            height: 50,
                          ),
                          Container(
                            width: 10,
                          ),
                          Text(
                              (box.get("round${widget.index}") ?? 0).toString(),
                              style: TextStyle(
                                  fontSize: 50,
                                  color: Get.isDarkMode
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black)),
                          isVibrate
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isVibrate = false;
                                    });
                                  },
                                  icon: Icon(Icons.vibration))
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isVibrate = true;
                                    });
                                    print("object");
                                  },
                                  icon: Icon(Icons.mobile_off)),
                        ],
                      ),
                    ],
                  ),
                ), /*
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text((box.get("round${widget.index}") ?? 0).toString(),
                        style: TextStyle(
                            fontSize: 50,
                            color: Colors.black.withOpacity(0.5))),
                    isVibrate
                        ? Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isVibrate = false;
                                  });
                                },
                                icon: Icon(Icons.vibration)),
                          )
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                isVibrate = true;
                              });
                              print("object");
                            },
                            icon: Icon(Icons.mobile_off)),
                  ],
                ),
                ElevatedButton(
                  child: Text(
                    'Sıfırla',
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  onPressed: () async {
                    await box.put('counter${widget.index}', 0);
                    await box.put('round${widget.index}', 0);
                  },
                ),*/
              ],
            ),
          );
        },
      ),
    );
  }
}
