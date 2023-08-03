import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/services/services/service_base.dart';
import 'package:vocabhub/utils/utility.dart';

class ExploreService extends ServiceBase {
  final _logger = Logger('ExploreService');
  late SharedPreferences _sharedPreferences;
  final kExploreHiddenKey = 'kExploreHiddenKey';
  final kExploreWordsKey = 'kExploreWordsKey';
  final kScrollMessageShownDateKey = 'kScrollMessageShownDateKey';
  final kIsScrollMessageShownKey = 'kIsScrollMessageShownKey';
  late String _kCollectionKey;
  @override
  Future<void> initService() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _kCollectionKey = 'kCollectionKey';
  }

  set collectionKey(String value) {
    _kCollectionKey = value;
  }

  /// This method is used to fetch explore words from the database.
  Future<List<Word>> getExploreWords(String email, {int page = 0}) async {
    try {
      // get All words
      final response = await DatabaseService.findLimitedWords(sort: false);
      final masteredWords = await VocabStoreService.getBookmarks(email, isBookmark: false);
      List<Word> words = [];
      final List<Word> _exploreWords = [];
      if (response.status == 200) {
        words = (response.data as List).map((e) => Word.fromJson(e)).toList();
        words.shuffle();

        /// exclude words that are already bookmarked.
        words.forEach((element) {
          if (!masteredWords.contains(element)) {
            _exploreWords.add(element);
          }
        });
        setExploreWords(_exploreWords);
        return _exploreWords;
      }
      if (response.status == 500) {
        _logger.e("Device is offline");
        return dashboardController.words;
      }
      throw "Something went wrong";
    } catch (_) {
      _logger.e(_.toString());
      return dashboardController.words;
    }
  }

  Future<void> setExploreWords(List<Word> words) async {
    final List<String> wordsString = words.map((e) => jsonEncode(e.toJson())).toList();
    await _sharedPreferences.setStringList(kExploreWordsKey, wordsString);
  }

  Future<List<Word>> exploreLocalWords() async {
    final List<String>? wordsString = _sharedPreferences.getStringList(kExploreWordsKey);
    if (wordsString != null && wordsString.isNotEmpty) {
      final List<Word> words = wordsString.map((e) => Word.fromJson(jsonDecode(e))).toList();
      return words;
    } else {
      return await VocabStoreService.getAllWords();
    }
  }

  Future<void> setScrollMessageShownDate(DateTime date) {
    return _sharedPreferences.setString(kScrollMessageShownDateKey, date.toString());
  }

  Future<DateTime> getScrollMessageShownDate() async {
    final String? date = _sharedPreferences.getString(kScrollMessageShownDateKey);
    if (date != null) {
      return DateTime.parse(date);
    }
    return DateTime.now().subtract(Duration(days: Constants.scrollMessageShownInterval + 1));
  }

  Future<void> setIsScrollMessageShown(bool value) async {
    await setScrollMessageShownDate(DateTime.now());
    await _sharedPreferences.setBool(kIsScrollMessageShownKey, value);
  }

  Future<bool> getIsScrollMessageShown() async {
    return _sharedPreferences.getBool(kIsScrollMessageShownKey) ?? false;
  }

  Future<bool> getExploreHidden() async {
    return _sharedPreferences.getBool(kExploreHiddenKey) ?? false;
  }

  Future<Map<String, List<Word>>> getCollections() async {
    _kCollectionKey = '${authController.user.username}_collection';
    final String? collectionString = _sharedPreferences.getString(_kCollectionKey) ?? '{}';
    if (collectionString != null && collectionString.isNotEmpty) {
      final Map<String, dynamic> collection = jsonDecode(collectionString);
      final Map<String, List<Word>> _collections = {};
      collection.forEach((key, value) {
        _collections[key] = (value as List).map((e) => Word.fromJson(e)).toList();
      });
      return _collections;
    }
    return {};
  }

  Future<void> setCollections(Map<String, List<Word>> collections) async {
    _kCollectionKey = '${authController.user.username}_collection';
    final Map<String, dynamic> collection = {};
    collections.forEach((key, value) {
      collection[key] = value.map((e) => e.toJson()).toList();
    });
    await _sharedPreferences.setString(_kCollectionKey, jsonEncode(collection));
  }

  Future<void> addCollection(String collectionName) async {
    final Map<String, List<Word>> collections = await getCollections();
    if (collections.containsKey(collectionName)) {
      showToast('Collection already exists');
    } else {
      collections[collectionName] = [];
      showToast('Collection added');
    }
    await setCollections(collections);
  }

  Future<void> addToCollection(String collectionName, Word word) async {
    final Map<String, List<Word>> collections = await getCollections();
    if (collections.containsKey(collectionName)) {
      final List<Word> words = collections[collectionName]!;
      if (!words.containsWord(word)) {
        words.add(word);
        showToast('Word added to $collectionName');
      } else {
        showToast('Word already exists in the collection');
      }
    } else {
      collections[collectionName] = [word];
      showToast('Word added to $collectionName');
    }
    await setCollections(collections);
  }

  Future<void> removeFromCollection(String collectionName, Word word) async {
    final Map<String, List<Word>> collections = await getCollections();
    if (collections.containsKey(collectionName)) {
      final List<Word> words = collections[collectionName]!;
      if (words.containsWord(word)) {
        words.remove(word);
        showToast('Word removed from $collectionName');
      } else {
        showToast('Word does not exist in the collection');
      }
    } else {
      showToast('Word does not exist in the collection');
    }
    await setCollections(collections);
  }

  Future<void> setExploreHidden(bool value) async {
    await _sharedPreferences.setBool(kExploreHiddenKey, value);
  }

  @override
  Future<void> disposeService() async {}
}
