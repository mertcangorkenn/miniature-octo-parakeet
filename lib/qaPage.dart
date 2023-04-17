import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'helper/ads.dart';
import 'list.dart';

class QAPage extends StatefulWidget {
  const QAPage({Key? key}) : super(key: key);

  @override
  State<QAPage> createState() => _QAPageState();
}

class _QAPageState extends State<QAPage> {
  BannerAd? myBanner;
  List soru = [];
  NativeAd? _ad;
  bool isAdLoaded = false;
  List cevap = [];
  @override
  void initState() {
    qa.forEach((key, value) {
      soru.add(key);
      cevap.add(value);
    });

    myBanner = AdsHelper.banner();
    myBanner!.load().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: Text("Soru Cevap"),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) {
          if (index % 10 == 9 && index != 0)
            return Column(
              children: [
                Divider(
                  color: Colors.black,
                  endIndent: 16,
                  indent: 16,
                ),
                getAd(),
                Divider(
                  color: Colors.black,
                  endIndent: 16,
                  indent: 16,
                ),
              ],
            );
          return Divider(
            color: Colors.black,
            endIndent: 16,
            indent: 16,
          );
        },
        itemCount: soru.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(soru[index]),
            subtitle: Text(cevap[index]),
          );
        },
      ),
    );
  }
}
