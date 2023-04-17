// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:adhan/adhan.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:quran_app/src/prayer_time/formatters/result_formatter.dart';
import 'package:quran_app/src/prayer_time/models/prayer_time.dart';
import 'package:quran_app/src/widgets/app_permission_status.dart';
import 'package:unicons/unicons.dart';

const api = "https://waktusholat.org/api/docs/today";

class _CurrentLocation {
  double latitude;
  double longitude;

  _CurrentLocation({this.latitude = 0, this.longitude = 0});
}

const String _kLocationServicesDisabledMessage =
    'Konum servisleri devre dışı';
const String _kPermissionDeniedMessage = 'İzin reddedildi.';
const String _kPermissionDeniedForeverMessage =
    "Bu özelliği kullanmak için lütfen ayarlarda bu uygulamanın konum iznini etkinleştirin.";
const String _kPermissionGrantedMessage = 'İzin verildi.';

abstract class PrayerTimeController extends GetxController {
  Future<LocationResultFormatter> handleLocationPermission();
  Future<bool> openAppSetting();
  Future<void> getLocation();
  void getPrayerTimesToday(double latitude, double longitude);
  void getAddressLocationDetail(double latitude, double longitude);
}

class PrayerTimeControllerImpl extends PrayerTimeController {
  var currentLocation = _CurrentLocation().obs;
  var prayerTimesToday = PrayerTime().obs;
  var prayerTimesNextDay = PrayerTime().obs;
  var nextPrayer = Prayer.none.obs;
  var currentPrayer = Prayer.none.obs;
  var currentAddress = Placemark().obs;
  var leftOver = 0.obs;
  var sensorIsSupported = false.obs;
  var qiblahDirection = 0.0.obs;

  final cT = CountDownController();

  /// Load location state
  var isLoadLocation = false.obs;

  @override
  Future<LocationResultFormatter> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // check if service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationResultFormatter(false, _kLocationServicesDisabledMessage);
    }

    // check permission location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationResultFormatter(false, _kPermissionDeniedMessage);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationResultFormatter(false, _kPermissionDeniedForeverMessage);
    }

    return LocationResultFormatter(true, _kPermissionGrantedMessage);
  }

  @override
  Future<bool> openAppSetting() async {
    final opened = await Geolocator.openAppSettings();
    if (opened) {
      log("Opened location setting");
    } else {
      log("Error opening location setting");
    }

    return opened;
  }

  @override
  Future<void> getLocation() async {
    // enabled load location state
    isLoadLocation.value = true;
    final handlePermission = await handleLocationPermission();

    if (!handlePermission.result) {
      Get.bottomSheet(
        AppPermissionStatus(
          icon: UniconsLine.map_marker_slash,
          title: "Konum Erişimine İzin Ver",
          message: handlePermission.error.toString(),
          onPressed: () {
            final prayerC = Get.find<PrayerTimeControllerImpl>();
            prayerC.openAppSetting().then((value) {
              if (!value) {
                Get.snackbar("Hay Aksi!", "Ayarlar açılamıyor");
              }
            });
          },
        ),
      );
    } else {
      final location = await Geolocator.getCurrentPosition();
      var loc = _CurrentLocation(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      currentLocation(loc);
      getPrayerTimesToday(location.latitude, location.longitude);
      getAddressLocationDetail(location.latitude, location.longitude);

      // disabled load location state
      isLoadLocation.value = false;

      getQiblah(location.latitude, location.longitude);
    }
  }

  @override
  void getPrayerTimesToday(double latitude, double longitude) {
    log(latitude.toString());
    log(longitude.toString());

    final myCoordinates = Coordinates(latitude, longitude);
    final dateComponents = DateComponents(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

    final params = CalculationMethod.turkey.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);
    final prayerTimesNext = PrayerTimes(myCoordinates, dateComponents, params);
    final sunnahTimes = SunnahTimes(prayerTimes);

    log("---Today's Prayer Times in Your Local Timezone(${prayerTimes.fajr.timeZoneName})---");

    log(prayerTimes.fajr.toString());
    log(prayerTimes.sunrise.toString());
    log(prayerTimes.dhuhr.toString());
    log(prayerTimes.asr.toString());
    log(prayerTimes.maghrib.toString());
    log(prayerTimes.isha.toString());
    log(sunnahTimes.middleOfTheNight.toString());
    log(sunnahTimes.lastThirdOfTheNight.toString());

    var result = PrayerTime(
      shubuh: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhur: prayerTimes.dhuhr,
      ashar: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isya: prayerTimes.isha,
      middleOfTheNight: sunnahTimes.middleOfTheNight,
      lastThirdOfTheNight: sunnahTimes.lastThirdOfTheNight,
    );

    var resultNextDay = PrayerTime(
      shubuh: prayerTimesNext.fajr,
      sunrise: prayerTimesNext.sunrise,
      dhuhur: prayerTimesNext.dhuhr,
      ashar: prayerTimesNext.asr,
      maghrib: prayerTimesNext.maghrib,
      isya: prayerTimesNext.isha,
      middleOfTheNight: sunnahTimes.middleOfTheNight,
      lastThirdOfTheNight: sunnahTimes.lastThirdOfTheNight,
    );

    currentPrayer(prayerTimes.currentPrayer());
    log("Current prayer: ${prayerTimes.currentPrayer()}");


    nextPrayer(prayerTimes.nextPrayer());
    log("Next prayer: ${prayerTimes.nextPrayer()}");

    prayerTimesToday(result);
    prayerTimesToday.value = result;
    prayerTimesNextDay(resultNextDay);
    prayerTimesNextDay.value = resultNextDay;
  }

  @override
  void getAddressLocationDetail(double latitude, double longitude) async {
    List<Placemark> placeMarks;
    try {
      log("$latitude");
      log("$longitude");
      placeMarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      var address = placeMarks[0];

      log("$address");
      currentAddress(address);
    } on PlatformException catch (e) {
      log(e.toString());
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        placeMarks = await placemarkFromCoordinates(latitude, longitude);
        var address = placeMarks[0];

        log("$address");
        currentAddress(address);
      } catch (e) {
        Get.snackbar(
            "Hay Aksi!", 'Adres alınamadı, lütfen manuel olarak doldurun');
      }
    }
  }

  var isQiblahLoaded = false.obs;

  void getQiblah(double latitude, double longitude) {
    final myCoordinates = Coordinates(latitude, longitude);

    final qiblah = Qibla(myCoordinates);
    log("Qiblah: ${qiblah.direction}");
    qiblahDirection.value = qiblah.direction;
  }

  Future<void> checkDeviceSensorSupport() async {
    FlutterQiblah.androidDeviceSensorSupport().then((value) {
      if (value != null && value) {
        sensorIsSupported.value = value;
        isQiblahLoaded.value = true;
      }
      log("Check $value");
    });
  }

  @override
  void onInit() async {
    super.onInit();
    await getLocation();
    // await Future.delayed(1.seconds);
  }
}
