import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'helper/ads.dart';
import 'list.dart';

class HusnaPage extends StatefulWidget {
  const HusnaPage({Key? key}) : super(key: key);

  @override
  State<HusnaPage> createState() => _HusnaPageState();
}

class _HusnaPageState extends State<HusnaPage> {
  List<String> name = [];
  List<String> meaning = [];
  BannerAd? myBanner;
  @override
  void initState() {
    // TODO: implement initState
    myBanner = AdsHelper.banner();
    myBanner!.load().then((value) {
      setState(() {});
    });
    data.forEach((key, value) {
      name.add(key);
      meaning.add(value);
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
          title: const Text('Esma-ül Hüsna'),
        ),
        body: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.black,
            endIndent: 16,
            indent: 16,
          ),
          itemCount: 99,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(name[index]),
              subtitle: Text(meaning[index]),
            );
          },
        ));
  }
}
