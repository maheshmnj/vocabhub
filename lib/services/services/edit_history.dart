import 'dart:async';

import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/history.dart';
import 'package:vocabhub/models/notification.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/utils/logger.dart';
import 'package:vocabhub/utils/utility.dart';

/// Api to access the edit history and also to update the VocabTable
/// These edits are only made when the edits are approved by the admin.
class EditHistoryService {
  static String _tableName = '${Constants.EDIT_HISTORY_TABLE}';
  static final _logger = Logger("EditHistoryService");

  /// id could be userId or wordId
  /// This edits need to be shown under notifications for the user
  /// for admin the notifications will be of state (pending,add,delete)
  /// for user the notifications will be of state (pending)
  static Future<PostgrestResponse> findEditById(String id,
      {String columnName = Constants.ID_COLUMN}) async {
    final response = await DatabaseService.findRowByColumnValue(id,
        columnName: columnName, tableName: _tableName);
    return response;
  }

  /// Fetch all edits of a word
  static Future<PostgrestResponse> findPreviousEditsByWord(String word,
      {bool isNotification = false}) async {
    if (!isNotification) {
      final response = await DatabaseService.findApprovedEdits(word,
          columnName: Constants.WORD_COLUMN,
          table1: _tableName,
          table2: Constants.USER_TABLE_NAME,
          innerJoincolumn: Constants.USER_EMAIL_COLUMN,
          sort: false);
      return response;
    } else {
      final response = await DatabaseService.innerJoinTwoTables(word,
          columnName: Constants.WORD_COLUMN,
          table1: _tableName,
          table2: Constants.USER_TABLE_NAME,
          innerJoincolumn: Constants.USER_EMAIL_COLUMN,
          sort: false);
      return response;
    }
  }

  /// approve/reject an edit by updating the state to [EditState]
  ///
  static Future<PostgrestResponse> updateRowState(String id, EditState state) async {
    final response = await DatabaseService.updateRow(
        colValue: id,
        data: {'state': '${state.name}'},
        columnName: '${Constants.EDIT_ID_COLUMN}',
        tableName: _tableName);
    return response;
  }

  /// Add a history entry for the word
  /// This is called when the user requests a edit to the VocabTable
  /// The edit state is pending (default) on insert
  static Future<Response> insertHistory(EditHistory history) async {
    final vocabresponse = Response(didSucced: false, message: "Failed");
    final data = history.toJson();
    data['edit_id'] = Uuid().v1();
    data['created_at'] = DateTime.now().toIso8601String();
    data.remove(Constants.USER_TABLE_NAME);
    final response = await DatabaseService.insertIntoTable(data, table: _tableName);
    vocabresponse.status = response.status;
    if (response.status == 201) {
      vocabresponse.didSucced = true;
      vocabresponse.message = 'Success';
      vocabresponse.data = history.copyWith(edit_id: response.data[0]['edit_id']);
    } else {
      vocabresponse.status = response.status;
      vocabresponse.message = response.error!.message;
    }
    return vocabresponse;
  }

  /// get edits made by user to show under notifications
  ///
  static Future<Response> getUserEdits(UserModel user) async {
    final resp = Response(didSucced: false, message: "Failed");

    PostgrestResponse response;
    // TODO: Toggle isAdmin
    if (user.isAdmin) {
      response = await DatabaseService.findRowsByInnerJoinOnColumnValue(
          '${Constants.USER_EMAIL_COLUMN}', '${user.email}',
          table1: _tableName, table2: Constants.USER_TABLE_NAME);
      if (response.status == 200) {
        final data = (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
        resp.didSucced = true;
        resp.message = 'Success';
        resp.data = data;
      } else {
        resp.message = response.error!.message;
      }
    } else {
      response = await DatabaseService.findRowByColumnValue(
        user.email,
        columnName: '${Constants.USER_EMAIL_COLUMN}',
        tableName: _tableName,
      );
      if (response.status == 200) {
        final data = (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
        resp.didSucced = true;
        resp.message = 'Success';
        resp.data = data;
      } else {
        resp.message = response.error!.message;
      }
    }
    return resp;
  }

  static Future<Response> getUserContributions(UserModel user) async {
    final resp = Response(didSucced: false, message: "Failed");

    PostgrestResponse response;
    // TODO: Toggle isAdmin
    response = await DatabaseService.findRowByColumnValue(
      '${user.email}',
      // 'approved',
      columnName: '${Constants.USER_EMAIL_COLUMN}',
      // column2Name: '$STATE_COLUMN',
      tableName: _tableName,
    );
    if (response.status == 200) {
      final data = (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
      resp.didSucced = true;
      resp.message = 'Success';
      resp.data = data;
    } else {
      resp.message = response.error!.message;
    }
    return resp;
  }

  /// cancel the request from user

  static Future<Response> updateRequest(String editId,
      {EditState state = EditState.cancelled}) async {
    final resp = Response(didSucced: false, message: "Failed");
    final response = await updateRowState(editId, state);
    resp.status = response.status;
    if (response.status == 200) {
      resp.didSucced = true;
      resp.message = 'Success';
    } else {
      resp.message = response.error!.message;
    }
    return resp;
  }
}
