import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/all_notifications/all_notifications.dart';
import '../../../models/user_login/user_login.dart';
import '../../../models/user_login/user_profile.dart';
import '../../base/api_response.dart';

class NotificationsProviderApi {
  NotificationsProviderApi();

  Future<ApiResponse> add(Notifications item) async {
    return getApiResponse<Notifications>(await item.save());
  }

  Future<ApiResponse> addAll(List<Notifications> items) async {
    final List<dynamic> responses = [];

    for (final Notifications item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }

      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<Notifications>(await Notifications().getAll());
  }

  Future<ApiResponse> userMessage(String toUser, String fromUser) async {
    final QueryBuilder<Notifications> query = QueryBuilder<Notifications>(Notifications())
      ..whereEqualTo('ToProfile', toUser)
      ..whereEqualTo('FromProfile', fromUser);

    final QueryBuilder<Notifications> query2 = QueryBuilder<Notifications>(Notifications())
      ..whereEqualTo('ToProfile', fromUser)
      ..whereEqualTo('FromProfile', toUser);

    Notifications playerObject = Notifications();

    QueryBuilder<Notifications> mainQuery = QueryBuilder.or(
      playerObject,
      [query, query2],
    );

    return getApiResponse<Notifications>(await mainQuery.query());
  }

  Future<ApiResponse> getById(String id) async {
    return getApiResponse<Notifications>(await Notifications().getObject(id));
  }

  Future<ApiResponse> getNewerThan(DateTime date) async {
    final QueryBuilder<Notifications> query = QueryBuilder<Notifications>(Notifications())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<Notifications>(await query.query());
  }

  Future<ApiResponse?> messageCount(String toProfileId, String fromProfileId) async {
    try {
      final QueryBuilder<Notifications> query = QueryBuilder<Notifications>(Notifications())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('isRead', false);

      return getApiResponse<Notifications>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> messageCountPurchase(String toProfileId, String fromProfileId) async {
    try {
      final QueryBuilder<Notifications> query = QueryBuilder<Notifications>(Notifications())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('isPurchased', false);

      return getApiResponse<Notifications>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> messageCountUnRead(String toProfileId, String fromProfileId, String type) async {
    try {
      final QueryBuilder<Notifications> query = QueryBuilder<Notifications>(Notifications())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('Type', type)
        ..whereEqualTo('isRead', false);

      return getApiResponse<Notifications>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> notificationCountUnRead({userId,String? fromUser, required String type}) async {
    try {
      final QueryBuilder<Notifications> query = QueryBuilder<Notifications>(Notifications())
        ..whereEqualTo('ToUser', (UserLogin()..objectId = userId).toPointer())
        ..whereEqualTo('isRead', false)
        ..whereEqualTo('Type', type)
        ..count();
      if (fromUser != null) {
        query.whereEqualTo('FromUser', UserLogin()..objectId = fromUser);
      }
      var rr = await query.count();
      query.setLimit(rr.count);
      return getApiResponse<Notifications>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse> remove(Notifications item) async {
    return getApiResponse<Notifications>(await item.delete());
  }

  Future<ApiResponse> update(Notifications item) async {
    return getApiResponse<Notifications>(await item.save());
  }

  Future<ApiResponse> updateAll(List<Notifications> items) async {
    final List<dynamic> responses = [];

    for (final Notifications item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
