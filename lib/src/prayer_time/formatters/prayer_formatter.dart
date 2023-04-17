
class PrayerFormatter{
  static format(String prayer){
    switch(prayer){
      case "Fajr":
        return "Sabah";
      case "Dhuhr":
        return "Öğle";
      case "Asr":
        return "İkindi";
      case  "Maghrib":
        return "Akşam";
      case "Isha":
        return "Yatsı";
      case "Sunrise":
        return "Güneş";
    }
  }
}