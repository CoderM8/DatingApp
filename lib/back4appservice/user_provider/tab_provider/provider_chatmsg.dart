import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/all_notifications/all_notifications.dart';
import '../../../models/tab_model/chat_message.dart';
import '../../../models/user_login/user_login.dart';
import '../../../models/user_login/user_profile.dart';
import '../../base/api_response.dart';
import '../../repositories_api/tab_api/chatmsg_api_plan.dart';

class UserChatMessageProviderApi implements UserChatMessageProviderContract {
  UserChatMessageProviderApi();

  @override
  Future<ApiResponse> add(ChatMessage item) async {
    return getApiResponse<ChatMessage>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<ChatMessage> items) async {
    final List<dynamic> responses = [];

    for (final ChatMessage item in items) {
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
    return getApiResponse<ChatMessage>(await ChatMessage().getAll());
  }

  @override
  Future<ApiResponse> userMessage(String toUser, String fromUser) async {
    final QueryBuilder<ChatMessage> query = QueryBuilder<ChatMessage>(ChatMessage())
      ..whereEqualTo('ToProfile', toUser)
      ..whereEqualTo('FromProfile', fromUser);

    final QueryBuilder<ChatMessage> query2 = QueryBuilder<ChatMessage>(ChatMessage())
      ..whereEqualTo('ToProfile', fromUser)
      ..whereEqualTo('FromProfile', toUser);

    ChatMessage playerObject = ChatMessage();

    QueryBuilder<ChatMessage> mainQuery = QueryBuilder.or(
      playerObject,
      [query, query2],
    );

    return getApiResponse<ChatMessage>(await mainQuery.query());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<ChatMessage>(await ChatMessage().getObject(id));
  }

  @override
  Future<ApiResponse> getNewerThan(DateTime date) async {
    final QueryBuilder<ChatMessage> query = QueryBuilder<ChatMessage>(ChatMessage())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<ChatMessage>(await query.query());
  }

  Future<ApiResponse?> messageCount(String toProfileId, String fromProfileId) async {
    try {
      final QueryBuilder<ChatMessage> query = QueryBuilder<ChatMessage>(ChatMessage())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereArrayContainsAll('Users', [ProfilePage()..objectId = toProfileId, ProfilePage()..objectId = fromProfileId])
        ..whereEqualTo('isRead', false)
        ..orderByAscending('createdAt');

      return getApiResponse<ChatMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('error in unread chat counter $e');
      }
      return null;
    }
  }

  Future<ApiResponse?> messageRead({required String userId, String? fromUser, required String type}) async {
    try {
      final QueryBuilder<Notifications> query = QueryBuilder<Notifications>(Notifications())
        ..whereEqualTo('ToUser', UserLogin()..objectId = userId)
        ..whereEqualTo('isRead', false)
        ..whereEqualTo('Type', type);

      if (fromUser != null) {
        query.whereEqualTo('FromUser', UserLogin()..objectId = fromUser);
      }
      return getApiResponse<Notifications>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print("error in messageRead$e");
      }
      return null;
    }
  }

  Future<ApiResponse?> messageCountPurchase(String toProfileId, String fromProfileId) async {
    try {
      final QueryBuilder<ChatMessage> query = QueryBuilder<ChatMessage>(ChatMessage())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('isPurchased', false);

      return getApiResponse<ChatMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  @override
  Future<ApiResponse> remove(ChatMessage item) async {
    return getApiResponse<ChatMessage>(await item.delete());
  }

  @override
  Future<ApiResponse> update(ChatMessage item) async {
    return getApiResponse<ChatMessage>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<ChatMessage> items) async {
    final List<dynamic> responses = [];

    for (final ChatMessage item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
