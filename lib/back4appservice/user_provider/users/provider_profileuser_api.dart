// ignore_for_file: non_constant_identifier_names

import 'package:eypop/back4appservice/repositories_api/login_user/profile_api_plan.dart';
import 'package:eypop/models/tab_model/chat_message.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/tab_model/heart_like.dart';
import '../../../models/tab_model/like_message.dart';
import '../../../models/tab_model/lip_like.dart';
import '../../../models/tab_model/wink_message.dart';
import '../../../models/verticaltab_model/blockuser.dart';
import '../../base/api_response.dart';

class UserProfileProviderApi implements UserProfileProviderContract {
  UserProfileProviderApi();

  @override
  Future<ApiResponse> add(ProfilePage item) async {
    return getApiResponse<ProfilePage>(await item.save());
  }

  @override
  Future<ApiResponse> getLipLikeNotification({String? userid}) async {
    QueryBuilder<ParseObject> liplikequery = QueryBuilder<ParseObject>(LipLike())
      ..includeObject(['ToProfile', 'FromProfile'])
      ..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

    var apiResponse = await liplikequery.query();

    return getApiResponse<ParseObject>(apiResponse);
  }

  @override
  Future<ApiResponse?> getLipLikeNotification2({String? userid}) async {
    try {
      QueryBuilder<ParseObject> liplikequeryFromUser = QueryBuilder<ParseObject>(LipLike())..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> liplikequeryToUser = QueryBuilder<ParseObject>(LipLike())..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(
        LipLike(),
        [liplikequeryFromUser, liplikequeryToUser],
      )
        ..orderByDescending('createdAt')
        ..includeObject(['ToProfile', 'FromProfile']);

      var apiResponse = await mainQuery.query();
      return getApiResponse<ParseObject>(apiResponse);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getCheckData() async {
    try {
      QueryBuilder<ProfilePage> query = QueryBuilder<ProfilePage>(ProfilePage())
        ..whereEqualTo('User', (UserLogin()..objectId = StorageService.getBox.read('ObjectId')).toPointer());
      return getApiResponse<ProfilePage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getUnReadLipLikeNotification({String? userid}) async {
    try {
      QueryBuilder<LipLike> query = QueryBuilder<LipLike>(LipLike())
        ..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer())
        ..whereEqualTo('isRead', false);
      return getApiResponse<LipLike>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getChatNotification({String? userid}) async {
    try {
      QueryBuilder<ChatMessage> heartMessagequeryFromUser = QueryBuilder<ChatMessage>(ChatMessage())..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ChatMessage> heartMessagequeryToUser = QueryBuilder<ChatMessage>(ChatMessage())..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ChatMessage> mainQuery = QueryBuilder.or(
        ChatMessage(),
        [heartMessagequeryFromUser, heartMessagequeryToUser],
      )
        ..includeObject(['ToProfile', 'FromProfile', 'ToUser', 'FromUser'])
        ..orderByDescending("createdAt");

      ParseResponse apiResponse = await mainQuery.query();

      return getApiResponse<ChatMessage>(apiResponse);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getUnReadChatNotification({String? userid}) async {
    try {
      QueryBuilder<ChatMessage> query = QueryBuilder<ChatMessage>(ChatMessage())
        ..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer())
        ..whereEqualTo('isRead', false);
      return getApiResponse<ChatMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getheartMessagesNotification({String? userid, time}) async {
    try {
      QueryBuilder<ParseObject> heartMessagequeryFromUser = QueryBuilder<ParseObject>(LikeMessage())..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> heartMessagequeryToUser = QueryBuilder<ParseObject>(LikeMessage())..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(
        LikeMessage(),
        [heartMessagequeryFromUser, heartMessagequeryToUser],
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

  Future<ApiResponse?> getUnReadheartMessagesNotification({String? userid}) async {
    try {
      QueryBuilder<LikeMessage> query = QueryBuilder<LikeMessage>(LikeMessage())
        ..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer())
        ..whereEqualTo('isRead', false);
      return getApiResponse<LikeMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getwinksMessagesNotification({String? userid, bool noti = false}) async {
    try {
      QueryBuilder<WinkMessage> winkMessagequeryFromUser = QueryBuilder<WinkMessage>(WinkMessage())..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<WinkMessage> winkMessagequeryToUser = QueryBuilder<WinkMessage>(WinkMessage())..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer());
      QueryBuilder<WinkMessage> mainQuery = QueryBuilder.or(
        WinkMessage(),
        [winkMessagequeryFromUser, winkMessagequeryToUser],
      )
        ..orderByDescending('createdAt')
        ..includeObject(['ToProfile', 'FromProfile', 'FromUser', 'ToUser']);

      var apiResponse = await mainQuery.query();

      return getApiResponse<WinkMessage>(apiResponse);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getUnReadWinkNotification({String? userid}) async {
    try {
      QueryBuilder<WinkMessage> query = QueryBuilder<WinkMessage>(WinkMessage())
        ..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer())
        ..whereEqualTo('isRead', false);
      return getApiResponse<WinkMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse> getchatNotification({String? userid}) async {
    QueryBuilder<ParseObject> heartMessagequeryFromUser = QueryBuilder<ParseObject>(WinkMessage())..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

    QueryBuilder<ParseObject> heartMessagequeryToUser = QueryBuilder<ParseObject>(WinkMessage())..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer());

    QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(
      WinkMessage(),
      [heartMessagequeryFromUser, heartMessagequeryToUser],
    )..includeObject(['ToProfile', 'FromProfile']);

    var apiResponse = await mainQuery.query();
    return getApiResponse<ParseObject>(apiResponse);
  }

  Future<ApiResponse?> getblockUserNotification({String? userid}) async {
    try {
      QueryBuilder<ParseObject> heartMessagequeryFromUser = QueryBuilder<ParseObject>(BlockUser())
        ..whereEqualTo('Type', 'BLOCK')
        ..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> heartMessagequeryToUser = QueryBuilder<ParseObject>(BlockUser())..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(
        BlockUser(),
        [heartMessagequeryFromUser, heartMessagequeryToUser],
      )
        ..orderByDescending('createdAt')
        ..includeObject(['ToProfile', 'FromProfile']);

      var apiResponse = await mainQuery.query();
      return getApiResponse<ParseObject>(apiResponse);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getlikeNotification({String? userid}) async {
    try {
      QueryBuilder<ParseObject> heartMessagequeryFromUser = QueryBuilder<ParseObject>(HeartLike())..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> heartMessagequeryToUser = QueryBuilder<ParseObject>(HeartLike())..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(
        HeartLike(),
        [heartMessagequeryFromUser, heartMessagequeryToUser],
      )
        ..orderByDescending('createdAt')
        ..includeObject(['ToProfile', 'FromProfile']);

      var apiResponse = await mainQuery.query();
      return getApiResponse<ParseObject>(apiResponse);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getUnReadLikeNotification({String? userid}) async {
    try {
      QueryBuilder<HeartLike> query = QueryBuilder<HeartLike>(HeartLike())
        ..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer())
        ..whereEqualTo('isRead', false);
      return getApiResponse<HeartLike>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  @override
  Future<ApiResponse> addAll(List<ProfilePage> items) async {
    final List<dynamic> responses = [];

    for (final ProfilePage item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }

      response.results?.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  @override
  Future<ApiResponse> getAll() async {
    return getApiResponse<ProfilePage>(await ProfilePage().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    final QueryBuilder<ProfilePage> query = QueryBuilder<ProfilePage>(ProfilePage())
      ..whereEqualTo('objectId', id)
      ..includeObject(['User', 'Language', 'DefaultImg']);
    return getApiResponse<ProfilePage>(await query.query());
  }

  Future<ApiResponse> getByObjectId(String id) async {
    final QueryBuilder<ProfilePage> query = QueryBuilder<ProfilePage>(ProfilePage())
      ..whereEqualTo('objectId', id);
    return getApiResponse<ProfilePage>(await query.query());
  }

  Future<ApiResponse> getByUserId(String id) async {
    final QueryBuilder<ProfilePage> query = QueryBuilder<ProfilePage>(ProfilePage())
      ..whereEqualTo('User', UserLogin()..objectId = id);
    return getApiResponse<ProfilePage>(await query.query());
  }

  Future<ProfilePage> getByIdNotification(String id) async {
    final QueryBuilder<ProfilePage> query = QueryBuilder<ProfilePage>(ProfilePage())
      ..includeObject(['User', 'Language'])
      ..whereEqualTo('objectId', id);
    ProfilePage profilePage = await getApiResponse<ProfilePage>(await query.query()).result;

    return profilePage;
  }

  @override
  Future<ApiResponse> getNewerThan() async {
    final QueryBuilder<ProfilePage> query = QueryBuilder<ProfilePage>(ProfilePage())..orderByDescending('createdAt');

    return getApiResponse<ProfilePage>(await query.query());
  }

  @override
  Future<ApiResponse?> userProfileQuery(String id) async {
    try {
      final QueryBuilder<ProfilePage> query = QueryBuilder<ProfilePage>(ProfilePage())
        ..includeObject(['User', 'Language'])
        ..whereEqualTo('User', UserLogin()..objectId = id);
      final tt = await query.count();
      query.setLimit(tt.count);
      return getApiResponse<ProfilePage>(await query.query());
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ApiResponse> remove(ProfilePage item) async {
    return getApiResponse<ProfilePage>(await item.delete());
  }

  Future<void> updateTodo(String id, bool done) async {}

  @override
  Future<ApiResponse> update(ProfilePage item) async {
    return getApiResponse<ProfilePage>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<ProfilePage> items) async {
    final List<dynamic> responses = [];

    for (final ProfilePage item in items) {
      try {
        final ApiResponse response = await update(item);
        print('hello status ---- ${response.success}');
        print('hello result ---- ${response.result}');

        if (!response.success) {
                return response;
              }
        response.results!.forEach(responses.add);
      } catch (e,t) {
        print('hello Error status ---- ${e}');
        print('hello Trace status ---- ${t}');

      }
    }

    return ApiResponse(true, 200, responses, null);
  }
}
