import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:quran_app/helper/ads.dart';

import 'package:quran_app/src/home/view/home_page.dart';
import 'package:quran_app/src/prayer_time/views/qiblat_page.dart';
import 'package:quran_app/src/quran/view/favorite_page.dart';
import 'package:quran_app/src/quran/view/surah_page.dart';
import 'package:quran_app/src/routes.dart';
import 'package:quran_app/src/settings/controller/settings_controller.dart';
import 'package:quran_app/src/settings/theme/app_theme.dart';
import 'package:quran_app/src/wrapper.dart';
import 'package:unicons/unicons.dart';
import 'package:wiredash/wiredash.dart';

import 'hadeeth/pages/categories_page.dart';

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final _navigatorKey = GlobalKey<NavigatorState>();

  final settingC = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wiredash(
        projectId: "kuran-g5yio1q",
        secret: "Hi3mkhddtGGJA5cTJZAsM5HpUTQKCnFJ",
        options: const WiredashOptionsData(
          locale: Locale('tr', 'TR'),
        ),
        navigatorKey: _navigatorKey,
        theme: WiredashThemeData(
          brightness:
              settingC.isDarkMode.value ? Brightness.dark : Brightness.light,
        ),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
          title: "Kuranı Kerim Meali",
          darkTheme: AppTheme.dark,
          theme: AppTheme.light,
          // home: SignInPage(),
          home: Wrapper(),
          // home: HomePage(),
          // home: UploadAvatarPage(),
          // home: MainPage(),
          // initialRoute: "/",
          getPages: Routes.pages,
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final box = Get.find<GetStorage>();
  BannerAd? myBanner;
  int _index = 0;
  bool isPaused = false;
  final List<Widget> _pages = [
    HomePage(),
    SurahPage(),
    // PrayerTimePage(),
    HadeethCategoriesPage(),
    QiblatPage(),
    // SettingsPage(),
    const FavoritePage(),
    // ProfilePage(),
  ];

  interstitalAdCheck() async {
    if (box.hasData("interstitialAd")) {
      if (box.read("interstitialAd") == 6) {
        AdsHelper.loadInterstitialAd();
        await box.write("interstitialAd", 1);
      } else {
        var count = box.read("interstitialAd");
        await box.write("interstitialAd", count + 1);
      }
    } else {
      await box.write("interstitialAd", 1);
    }
  }

  @override
  void initState() {
    myBanner = AdsHelper.banner();
    myBanner!.load().then((value) {
      setState(() {});
    });
    AdsHelper.loadOpenAd();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      isPaused = true;
    }
    if (state == AppLifecycleState.resumed && isPaused) {
      print("Resumed==========================");
      AdsHelper.showOpenAd();
      AdsHelper.loadOpenAd();
      isPaused = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          myBanner != null
              ? Container(
                  alignment: Alignment.center,
                  child: AdWidget(ad: myBanner!),
                  width: myBanner!.size.width.toDouble(),
                  height: myBanner!.size.height.toDouble(),
                )
              : Container(),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [AppShadow.card],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 10,
                  activeColor: Theme.of(context).primaryColor,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  color: Colors.grey,
                  tabMargin: const EdgeInsets.only(top: 4),
                  textStyle: AppTextStyle.normal.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                  tabs: const [
                    GButton(
                      icon: UniconsLine.home_alt,
                      text: "Anasayfa",
                    ),
                    GButton(
                      icon: UniconsLine.book_open,
                      text: "Kuran",
                    ),
                    GButton(
                      icon: UniconsLine.books,
                      text: 'Hadisler',
                    ),
                    GButton(
                      icon: UniconsLine.compass,
                      text: 'Kıble',
                    ),
                    GButton(
                      icon: UniconsLine.heart,
                      text: 'Favoriler',
                    ),
                  ],
                  selectedIndex: _index,
                  onTabChange: (index) {
                    setState(() {
                      _index = index;
                    });
                    interstitalAdCheck();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
