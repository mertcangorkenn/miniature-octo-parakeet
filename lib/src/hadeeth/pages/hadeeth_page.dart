import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quran_app/src/hadeeth/api/fetch_hadeeth.dart';
import 'package:quran_app/src/hadeeth/model/hadeeth_model.dart';
import 'package:quran_app/src/settings/theme/app_theme.dart';
import 'package:quran_app/src/widgets/app_loading.dart';
import 'package:share_plus/share_plus.dart';

import '../../../helper/ads.dart';

class HadeethPage extends StatefulWidget {
  HadeethPage({Key? key, required this.title, required this.id})
      : super(key: key);
  String title;
  int id;
  @override
  State<HadeethPage> createState() => _HadeethPageState();
}

class _HadeethPageState extends State<HadeethPage> {
  BannerAd? myBanner;
  @override
  void initState() {
    myBanner = AdsHelper.banner();
    myBanner!.load().then((value) {
      setState(() {});
    });
    AdsHelper.loadOpenAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: myBanner == null
            ? Container()
            : Container(
                width: double.parse(myBanner!.size.width.toString()),
                height: double.parse(myBanner!.size.height.toString()),
                child: AdWidget(ad: myBanner!)),
        appBar: AppBar(
          title: Text("Hadis"),
          actions: [
            FutureBuilder<HadeethModel>(
                future: fetchHadeeth(widget.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: snapshot.data!.hadeeth));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Hadis kopyalandı")));
                            },
                            icon: Icon(Icons.copy)),
                        IconButton(
                            onPressed: () {
                              Share.share(snapshot.data!.hadeeth);
                            },
                            icon: Icon(Icons.share))
                      ],
                    );
                  } else {
                    return Container();
                  }
                })
          ],
        ),
        body: FutureBuilder<HadeethModel>(
          future: fetchHadeeth(widget.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    FadeInRight(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Hadis",
                              style: AppTextStyle.bigTitle,
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(10),
                                    child: Text(snapshot.data!.grade.substring(
                                        1, snapshot.data!.grade.length - 1)),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    FadeInRight(
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            child: Text(snapshot.data!.title))),
                    FadeInRight(
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          child: Text(snapshot.data!.attribution.substring(
                              1, snapshot.data!.attribution.length - 1)),
                        ),
                      ),
                    ),
                    FadeInRight(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Açıklama",
                          style: AppTextStyle.bigTitle,
                        ),
                      ),
                    ),
                    FadeInRight(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          child: Text(snapshot.data!.explanation)),
                    )
                  ],
                ),
              );
            } else {
              return Center(child: AppLoading());
            }
          },
        ));
  }
}
