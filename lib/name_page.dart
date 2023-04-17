import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'helper/ads.dart';
import 'list.dart';

class NamePage extends StatefulWidget {
  const NamePage({Key? key}) : super(key: key);

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  List erkekIsim = [];
  List erkekIsimAnlam = [];
  List kizIsim = [];
  List kizIsimAnlam = [];
  BannerAd? myBanner;
  @override
  void initState() {
    myBanner = AdsHelper.banner();
    myBanner!.load().then((value) {
      setState(() {});
    });
    names.forEach((Map element) {
      kizIsim.add(element.values.first);
      List anlamlar = element.values.toList();
      final val = anlamlar.remove(element.values.first);
      kizIsimAnlam.add(anlamlar);
    });
    erkekIsimleri.forEach((Map element) {
      erkekIsim.add(element.values.first);
      List anlamlar = element.values.toList();
      final val = anlamlar.remove(element.values.first);
      erkekIsimAnlam.add(anlamlar);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          title: Text("İsimler"),
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Kız İsimleri",
              ),
              Tab(
                text: "Erkek İsimleri",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.black,
                  endIndent: 16,
                  indent: 16,
                );
              },
              itemCount: kizIsim.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(kizIsim[index]),
                  subtitle: Text(kizIsimAnlam[index]
                      .toString()
                      .replaceAll("[ ", "")
                      .replaceAll("[", "")
                      .replaceAll("]", "")),
                );
              },
            ),
            ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.black,
                  endIndent: 16,
                  indent: 16,
                );
              },
              itemCount: erkekIsim.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(erkekIsim[index]),
                  subtitle: Text(erkekIsimAnlam[index]
                      .toString()
                      .replaceAll("[ ", "")
                      .replaceAll("[", "")
                      .replaceAll("]", "")),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
