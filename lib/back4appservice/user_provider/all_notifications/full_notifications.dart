import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/all_notifications/full_notification.dart';

class NotificationsProviderApi {
  NotificationsProviderApi();

  Future<ApiResponse> add(FullNotifications item) async {
    return getApiResponse<FullNotifications>(await item.save());
  }

  Future<ApiResponse> addAll(List<FullNotifications> items) async {
    final List<dynamic> responses = [];

    for (final FullNotifications item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }

      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<FullNotifications>(await FullNotifications().getAll());
  }

  Future<ApiResponse> userMessage(String toUser, String fromUser) async {
    final QueryBuilder<FullNotifications> query = QueryBuilder<FullNotifications>(FullNotifications())
      ..whereEqualTo('ToProfile', toUser)
      ..whereEqualTo('FromProfile', fromUser);

    final QueryBuilder<FullNotifications> query2 = QueryBuilder<FullNotifications>(FullNotifications())
      ..whereEqualTo('ToProfile', fromUser)
      ..whereEqualTo('FromProfile', toUser);

    FullNotifications playerObject = FullNotifications();

    QueryBuilder<FullNotifications> mainQuery = QueryBuilder.or(
      playerObject,
      [query, query2],
    );

    return getApiResponse<FullNotifications>(await mainQuery.query());
  }

  Future<ApiResponse> getById(String id) async {
    return getApiResponse<FullNotifications>(await FullNotifications().getObject(id));
  }

  Future<ApiResponse> getNewerThan(DateTime date) async {
    final QueryBuilder<FullNotifications> query = QueryBuilder<FullNotifications>(FullNotifications())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<FullNotifications>(await query.query());
  }

  Future<ApiResponse?> messageCount(String toProfileId, String fromProfileId) async {
    try {
      final QueryBuilder<FullNotifications> query = QueryBuilder<FullNotifications>(FullNotifications())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('isRead', false);

      return getApiResponse<FullNotifications>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> messageCountPurchase(String toProfileId, String fromProfileId) async {
    try {
      final QueryBuilder<FullNotifications> query = QueryBuilder<FullNotifications>(FullNotifications())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('isPurchased', false);

      return getApiResponse<FullNotifications>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> messageCountUnRead(String toProfileId, String fromProfileId, String type) async {
    try {
      final QueryBuilder<FullNotifications> query = QueryBuilder<FullNotifications>(FullNotifications())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('Type', type)
        ..whereEqualTo('isRead', false);

      return getApiResponse<FullNotifications>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> notificationCountUnRead({userId, required String type}) async {
    try {
      final QueryBuilder<FullNotifications> query = QueryBuilder<FullNotifications>(FullNotifications())
        ..whereEqualTo('ToUser', (UserLogin()..objectId = userId).toPointer())
        ..whereEqualTo('isRead', false)
        ..whereEqualTo('Type', type);

      return getApiResponse<FullNotifications>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse> remove(FullNotifications item) async {
    return getApiResponse<FullNotifications>(await item.delete());
  }

  Future<ApiResponse> update(FullNotifications item) async {
    return getApiResponse<FullNotifications>(await item.save());
  }

  Future<ApiResponse> updateAll(List<FullNotifications> items) async {
    final List<dynamic> responses = [];

    for (final FullNotifications item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
