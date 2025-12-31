import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/call/calls.dart';
import '../../../models/new_notification/new_notification_pair.dart';
import '../../../models/user_login/user_login.dart';
import '../../base/api_response.dart';
import 'calls_plan.dart';

class UserCallProviderApi implements UserCallProviderContract {
  UserCallProviderApi();

  @override
  Future<ApiResponse> add(CallModel item) async {
    return getApiResponse<CallModel>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<CallModel> items) async {
    final List<dynamic> responses = [];

    for (final CallModel item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }

      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  @override
  Future<ApiResponse> getAll() async {
    return getApiResponse<CallModel>(await CallModel().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<CallModel>(await CallModel().getObject(id));
  }

  Future<ApiResponse?> getCallData(userid) async {
    try {
      QueryBuilder<ParseObject> callFromUser = QueryBuilder<ParseObject>(CallModel())..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> callToUser = QueryBuilder<ParseObject>(CallModel())..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(
        CallModel(),
        [callFromUser, callToUser],
      )
        ..orderByDescending('createdAt')
        ..includeObject(['ToProfile', 'FromProfile', 'ToUser', 'FromUser']);

      var apiResponse = await mainQuery.query();

      return getApiResponse<ParseObject>(apiResponse);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getProfileCall(fromProfileId, toProfileId) async {
    try {
      QueryBuilder<ParseObject> callFromUser = QueryBuilder<ParseObject>(CallModel())
        ..whereEqualTo('FromProfile', (ProfilePage()..objectId = fromProfileId).toPointer())
        ..whereEqualTo('ToProfile', (ProfilePage()..objectId = toProfileId).toPointer())
        ..orderByDescending('createdAt')
        ..includeObject(['ToProfile', 'FromProfile', 'ToUser', 'FromUser']);
      var apiResponse = await callFromUser.query();

      return getApiResponse<ParseObject>(apiResponse);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getCallByPointer(pairNotificationObjectId, bool isVoiceCall) async {
    try {
      final QueryBuilder<ParseObject> callFromUser = QueryBuilder<ParseObject>(CallModel())
        ..whereEqualTo('PairNotification', PairNotifications()..objectId = pairNotificationObjectId)
        ..whereEqualTo('IsVoiceCall', isVoiceCall)
        ..includeObject(['ToProfile', 'FromProfile', 'ToUser', 'FromUser']);
      final apiResponse = await callFromUser.query();
      return getApiResponse<ParseObject>(apiResponse);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getUnReadCallNotification({String? userid}) async {
    try {
      QueryBuilder<CallModel> query = QueryBuilder<CallModel>(CallModel())
        ..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer())
        ..whereEqualTo('isRead', false);
      return getApiResponse<CallModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse> getByIdProfile(ProfilePage id) async {
    final QueryBuilder<CallModel> query1 = QueryBuilder<CallModel>(CallModel())
      ..whereEqualTo('FromProfile', id)
      ..orderByDescending('createdAt');

    final ParseResponse parseResponse = await query1.query();

    return getApiResponse<CallModel>(parseResponse);
  }

  Future<ApiResponse> getCallsFromToUser(String id) async {
    final QueryBuilder<CallModel> query1 = QueryBuilder<CallModel>(CallModel())
      ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
      ..whereEqualTo('FromUser', UserLogin()..objectId = id)
      ..orderByDescending('createdAt')
      ..includeObject(['ToProfile', 'FromProfile', 'ToUser', 'FromUser']);
    return getApiResponse<CallModel>(await query1.query());
  }

  Future<ApiResponse> getCallById(String callId) async {
    final QueryBuilder<ParseObject> query1 = QueryBuilder<ParseObject>(ParseObject('Calls'))..whereEqualTo('objectId', callId);
    query1.includeObject(['ToProfile', 'FromProfile', 'ToUser', 'FromUser']);
    return getApiResponse<ParseObject>(await query1.query());
  }

  @override
  Future<ApiResponse> getNewerThan(DateTime date) async {
    final QueryBuilder<CallModel> query = QueryBuilder<CallModel>(CallModel())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<CallModel>(await query.query());
  }

  @override
  Future<ApiResponse> remove(CallModel item) async {
    return getApiResponse<CallModel>(await item.delete());
  }

  @override
  Future<ApiResponse> update(CallModel item) async {
    return getApiResponse<CallModel>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<CallModel> items) async {
    final List<dynamic> responses = [];

    for (final CallModel item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
