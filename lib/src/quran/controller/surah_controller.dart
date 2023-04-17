import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/src/quran/model/surah.dart';
import 'package:quran_app/src/quran/model/translations.dart';

import 'package:quran_app/src/quran/model/verse.dart';
import 'package:quran_app/src/quran/model/word.dart';
import 'package:quran_app/src/quran/repository/surah_favorite_repository.dart';

class SurahController extends GetxController {
  final _listOfSurah = <Surah>{}.obs;
  final _listOfAuthors = <Author>{}.obs;
  Set<Surah> get listOfSurah => _listOfSurah();
  Set<Author> get listOfAuthor => _listOfAuthors();

  final _listOfSearchedSurah = <Surah>{}.obs;
  final _listOfSearchedVerse = <Verse>{}.obs;
  Set<Surah> get listOfSearchedSurah => _listOfSearchedSurah().obs;
  Set<Verse> get listOfSearchedVerse => _listOfSearchedVerse().obs;

  void resetListOfSearchedSurah() {
    _listOfSearchedSurah.clear();
    _listOfSearchedVerse.clear();
  }

  searchSurah(String query, String searchType) {
     //_listOfSearchedSurah.clear();

    if (query.isEmpty) {
      _listOfSearchedSurah.clear();
      _listOfSearchedVerse.clear();
    } else {
      if(searchType == "Cüz"){
        var data = query.split(".")[0];
        int juz = int.parse(data);
        for (var item in _versess) {
          if (item.juzNumber == juz) {
            //log(s);
            int index = _versess.toList().indexOf(item);
            _listOfSearchedVerse.add(_versess.toList()[index]);
          }
        }
      }else if(searchType == "Sayfa"){
        var data = query.split(".")[0];
        int page = int.parse(data);
        for (var item in _versess) {
          if (item.page == page) {
            //log(s);
            int index = _versess.toList().indexOf(item);
            _listOfSearchedVerse.add(_versess.toList()[index]);
          }
        }
      }else if(searchType == "Sure"){
        var data = query.split(".")[0];
        int id = int.parse(data);
        for (var item in _versess) {
          if (item.surahId == id) {
            //log(s);
            int index = _versess.toList().indexOf(item);
            _listOfSearchedVerse.add(_versess.toList()[index]);
          }
        }
      }else{
        Future.delayed(Duration(milliseconds: 200),(){
          if(query.length > 2){
            for (var item in _versess) {
              if (item.transcription!.isCaseInsensitiveContainsAny(query)) {
                //_listOfSearchedVerse.clear();
                //log(s);
                int index = _versess.toList().indexOf(item);
                _listOfSearchedVerse.add(_versess.toList()[index]);
              }
            }
          }
        });
      }

    }
  }

  final _verses = <Verse>[].obs;
  final _versess = <Verse>[].obs;
  final _words = <Word>[].obs;
  final _translations = <TranslationsOfVerse>[].obs;
  List<Verse> get verses => _verses();
  List<Verse> get versess => _versess();
  List<Word> get words => _words();
  List<TranslationsOfVerse> get translations => _translations();

  void resetVerses() {
    _verses.clear();
    _audioUrl.clear();
    log("${_verses.length}");
  }

  void resetWords() {
    _words.clear();
  }

  void resetTranslations() {
    _translations.clear();
  }

  final _audioUrl = <String>[].obs;
  List<String> get audioUrl => _audioUrl();

  var isLoading = false.obs;
  var showTafsir = false.obs;
  var isSave = false.obs;

  final _recenly = Surah().obs;
  Surah get recenlySurah => _recenly();

  void setRecenlySurah(Surah value) {
    _recenly.value = value;
  }

  Future fetchListOfSurah() async {
    // clear list of surah
    _listOfSurah.clear();

    try {
      final url = Uri.parse("https://api.acikkuran.com/surahs");
      isLoading.value = true;
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var map = jsonDecode(response.body);
        var data = map['data'];
        for (var json in (data as List)) {
          var surah = Surah.fromJson(json);
          _listOfSurah.add(surah);
          if (_listOfSurah.isNotEmpty) {
            isLoading.value = false;
          }
          if (_listOfSurah.length < 3) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
        fetchAuthors();
        log(_listOfSurah.length.toString());

        for(int i=0; i<114;i++){
          fetchVerseByID(i);
        }

        return true;
      } else {
        log("Opps.. an error occured");
        return false;
      }
    } catch (e) {
      // throw ServerException();
      log("HATA:" +e.toString());
    }
  }

  Future fetchAuthors() async{
    _listOfAuthors.clear();

    try {
      final url = Uri.parse("https://api.acikkuran.com/authors");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var map = jsonDecode(response.body);
        var data = map['data'];
        for (var json in (data as List)) {
          var author = Author.fromJson(json);
          _listOfAuthors.add(author);
        }
        return true;
      } else {
        log("Opps.. an error occured");
        return false;
      }
    } catch (e) {
      // throw ServerException();
      log("HATA:" +e.toString());
    }
  }

  Future<bool> fetchSurahByID(int? id,int? author) async {
    


    final url = Uri.parse("https://api.acikkuran.com/surah/$id?author=$author");
    // isLoading.value = true;
    final response = await http.get(url);

    if (response.statusCode == 200) {
      resetVerses();
      var map = jsonDecode(response.body);
      var data = map["data"];
      var verses = data['verses'];

      for (var json in (verses as List)) {
        var verse = Verse.fromJson(json, data["name"]);
        _verses.add(verse);
        _audioUrl.add(data["audio"]["mp3"]);
      }

      log(_verses.length.toString());
      log("audios = ${_audioUrl.length}");
      return true;
    } else {
      // isLoading.value = false;
      return false;
    }
  }

  Future<bool> fetchVerseByID(int? id) async {
    resetVerses();

    final url = Uri.parse("https://api.acikkuran.com/surah/$id");
    // isLoading.value = true;
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var map = jsonDecode(response.body);
      var data = map["data"];
      var verses = data['verses'];

      for (var json in (verses as List)) {
        var verse = Verse.fromJson(json,data["name"]);
        _versess.add(verse);
      }
      return true;
    } else {
      // isLoading.value = false;
      return false;
    }
  }

  Future fetchWordsOfVerse(int? surahId, int? verseId) async{
    resetWords();
    final url = Uri.parse("https://api.acikkuran.com/surah/$surahId/verse/$verseId/words");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var map = jsonDecode(response.body);
      var data = map["data"];
      for (var json in data) {
        var word = Word.fromJson(json);
        words.add(word);
      }
      return true;
    } else {
      // isLoading.value = false;
      return false;
    }
  }

  Future fetchTranslationsOfVerse(int? surahId, int? verseId) async{
    resetTranslations();
    final url = Uri.parse("https://api.acikkuran.com/surah/$surahId/verse/$verseId/translations");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var map = jsonDecode(response.body);
      var data = map["data"];
      for (var json in data) {
        var tr = TranslationsOfVerse.fromJson(json);
        translations.add(tr);
      }
      return true;
    } else {
      // isLoading.value = false;
      return false;
    }
  }

  // FAVORITE
  final _surahFavorites = <Surah>{}.obs;
  Set<Surah> get surahFavorites => _surahFavorites();

  var isFavoriteLoaded = false.obs;
  var isFavoriteDeleted = false.obs;

  bool isFavorite(Surah surah) {
    return _surahFavorites.contains(surah);
  }

  Future<bool> addToFavorite(int userID, Surah surah) async {
    final surahRepo = SurahFavoriteRepositoryImpl();

    final value = await surahRepo.addSurahFavorite(userID, surah.number!);
    if (value.error != null) {
      Get.snackbar("Hay Aksi", value.error.toString());
      return false;
    } else {
      if (value.surahFavorites!.isNotEmpty) {
        _surahFavorites.add(surah);
        printInfo(info: "add to favorite");
      }
      return true;
    }
  }

  Future<bool> removeFromFavorite(int userID, Surah surah) async {
    final surahRepo = SurahFavoriteRepositoryImpl();

    isFavoriteDeleted.value = true;

    final value = await surahRepo.removeSurahFavorite(userID, surah.number!);
    if (value.error != null) {
      Get.snackbar("Opps", value.error.toString());
      isFavoriteDeleted.value = false;
      return false;
    } else {
      if (value.surahFavorites!.isNotEmpty) {
        _surahFavorites.remove(surah);
        printInfo(info: "remove from favorite");
      }
      isFavoriteDeleted.value = false;
      return true;
    }
  }

  void removeAllFromFavorite(int userID) async {
    final surahRepo = SurahFavoriteRepositoryImpl();

    isFavoriteDeleted.value = true;

    final value = await surahRepo.removeAllSurahFavorite(userID);
    if (value.error != null) {
      Get.snackbar("Opps", value.error.toString());
    } else {
      if (value.surahFavorites!.isNotEmpty) {
        _surahFavorites.clear();
        printInfo(info: "remove all from favorite");
      }
      Get.back();
    }

    isFavoriteDeleted.value = false;
  }

  Future<void> fetchSurahFavorites(int userID) async {
    _surahFavorites.clear();

    final surahFavoriteRepo = SurahFavoriteRepositoryImpl();

    log(surahFavorites.length.toString());
    isFavoriteLoaded.value = true;

    final result = await surahFavoriteRepo.getListOfFavoriteSurah(userID);
    if (result.error != null) {
      Get.snackbar("Hay Aksi...", result.error.toString());
    } else {
      if (result.surahFavorites!.isNotEmpty) {
        var i = 0;
        do {
          for (var item in _listOfSurah) {
            if (item.number == result.surahFavorites![i].surahId) {
              _surahFavorites.add(item);
            }
          }

          i++;
        } while (i < result.surahFavorites!.length);
      }

      log(surahFavorites.length.toString());
    }

    isFavoriteLoaded.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    fetchListOfSurah();
  }
}
