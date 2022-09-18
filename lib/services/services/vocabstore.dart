import 'dart:convert';

import 'package:supabase/supabase.dart';
import 'package:logger/logger.dart' as log;
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/utils/secrets.dart';
import 'package:vocabhub/platform/mobile.dart'
    if (dart.library.html) 'package:vocabhub/platform/web.dart' as platformOnly;

/// Global Vocabulary table's api.
class VocabStoreService {
  static String tableName = '$VOCAB_TABLE_NAME';
  static final _logger = log.Logger();
  final SupabaseClient _supabase = SupabaseClient("$CONFIG_URL", "$APIkey");

  Future<PostgrestResponse> findById(String id) async {
    final response = await DatabaseService.findSingleRowByColumnValue(id,
        columnName: ID_COLUMN, tableName: tableName);
    return response;
  }

  /// TODO: Can be used to implement server side search.

  // Future<List<Word>> findByWord(String word) async {
  //   if (word.isEmpty) {
  //     return await getAllWords();
  //   }
  //   final response = await _supabase
  //       .from(tableName)
  //       .select("*")
  //       .contains('$WORD_COLUMN', word)
  //       .execute();
  //   List<Word> words = [];
  //   if (response.status == 200) {
  //     words = (response.data as List).map((e) => Word.fromJson(e)).toList();
  //   }
  //   return words;
  // }

  static Future<Response> addWord(Word word) async {
    final json = word.toJson();
    final vocabresponse = Response(didSucced: false, message: "Failed");
    try {
      final response =
          await DatabaseService.insertIntoTable(json, table: tableName);
      if (response.status == 201) {
        vocabresponse.didSucced = true;
        vocabresponse.message = 'Success';
        final word = Word.fromJson(response.data[0]);
        vocabresponse.data = word;
      }
      vocabresponse.status = response.status;
      vocabresponse.message = response.error!.message;
    } catch (_) {
      throw "Failed to add word,error:$_";
    }
    return vocabresponse;
  }

  /// ```Select * from words Where state = 'approved';```
  ///
  // Future<List<Word>> getAllApprovedWords({bool sort = true}) async {
  //   final response = await _supabase
  //       .from(tableName)
  //       .select("*")
  //       .eq('state', 'approved')
  //       .execute();
  //   List<Word> words = [];
  //   if (response.status == 200) {
  //     words = (response.data as List).map((e) => Word.fromJson(e)).toList();
  //     if (sort) {
  //       words.sort((a, b) => a.word.compareTo(b.word));
  //     }
  //   }
  //   return words;
  // }

  /// ```Select * from words```

  static Future<List<Word>> getAllWords({bool sort = false}) async {
    final response = await DatabaseService.findAll(tableName: tableName);
    List<Word> words = [];
    if (response.status == 200) {
      words = (response.data as List).map((e) => Word.fromJson(e)).toList();
      if (sort) {
        words.sort((a, b) => a.word.compareTo(b.word));
      }
    }
    return words;
  }

  static Future<Word> getLastUpdatedRecord() async {
    final response = await DatabaseService.findRecentlyUpdatedRow(
        'created_at', '',
        table1: WORD_OF_THE_DAY_TABLE_NAME,
        table2: VOCAB_TABLE_NAME,
        ascending: false);
    if (response.status == 200) {
      Word lastWordOfTheDay =
          Word.fromJson(response.data[0]['vocabsheet_copy']);
      lastWordOfTheDay.created_at =
          DateTime.parse(response.data[0]['created_at']);
      return lastWordOfTheDay;
    } else {
      throw "Failed to get last updated record";
    }
  }

  static Future<List<Word>> searchWord(String query,
      {bool sort = false}) async {
    final response = await DatabaseService.findRowsContaining(query,
        columnName: WORD_COLUMN, tableName: tableName);
    List<Word> words = [];
    if (response.status == 200) {
      words = (response.data as List).map((e) => Word.fromJson(e)).toList();
      if (sort) {
        words.sort((a, b) => a.word.compareTo(b.word));
      }
    }
    return words;
  }

  Future<bool> downloadFile() async {
    try {
      final response = await _supabase.from(tableName).select("*").execute();
      if (response.status == 200) {
        platformOnly.fileSaver(json.encode(response.data), 'file.json');
        return true;
      }
      return false;
    } catch (x) {
      logger.d(x);
      throw 'x';
    }
  }

  static Future<PostgrestResponse> updateWord({
    required String id,
    required Word word,
  }) async {
    final Map<String, dynamic> json = word.toJson();
    final response = await DatabaseService.updateRow(
        rowValue: id, data: json, columnName: ID_COLUMN, tableName: tableName);
    return response;
  }

  Future<PostgrestResponse> updateMeaning({
    required String id,
    required Word word,
  }) async {
    final response = await DatabaseService.updateColumn(
        searchColumn: ID_COLUMN,
        searchValue: id,
        columnValue: word.meaning,
        columnName: MEANING_COLUMN,
        tableName: tableName);
    return response;
  }

  static Future<PostgrestResponse> deleteById(String id) async {
    _logger.i(tableName);
    final response = await DatabaseService.deleteRow(id,
        tableName: tableName, columnName: ID_COLUMN);
    return response;
  }
}
