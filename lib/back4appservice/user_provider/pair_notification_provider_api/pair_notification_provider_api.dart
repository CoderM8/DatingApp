import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/models/new_notification/new_notification_pair.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/user_login/user_profile.dart';
import '../../base/api_response.dart';

class PairNotificationProviderApi {
  Future<ApiResponse> add(PairNotifications item) async {
    return getApiResponse<PairNotifications>(await item.save());
  }

  Future<ApiResponse> addAll(List<PairNotifications> items) async {
    final List<dynamic> responses = [];

    for (final PairNotifications item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }

      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<PairNotifications>(await PairNotifications().getAll());
  }

  Future<ApiResponse> userMessage(String toUser, String fromUser) async {
    final QueryBuilder<PairNotifications> query = QueryBuilder<PairNotifications>(PairNotifications())
      ..whereEqualTo('ToProfile', toUser)
      ..whereEqualTo('FromProfile', fromUser);

    final QueryBuilder<PairNotifications> query2 = QueryBuilder<PairNotifications>(PairNotifications())
      ..whereEqualTo('ToProfile', fromUser)
      ..whereEqualTo('FromProfile', toUser);

    PairNotifications playerObject = PairNotifications();

    QueryBuilder<PairNotifications> mainQuery = QueryBuilder.or(
      playerObject,
      [query, query2],
    );

    return getApiResponse<PairNotifications>(await mainQuery.query());
  }

  Future<ApiResponse> getById(String id) async {
    return getApiResponse<PairNotifications>(await PairNotifications().getObject(id));
  }

  Future<ApiResponse?> getByProfile(fromProfileId, toProfileId, type) async {
    try {
      final QueryBuilder<PairNotifications> query = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('Type', type)
        ..whereArrayContainsAll('Users', [ProfilePage()..objectId = toProfileId, ProfilePage()..objectId = fromProfileId]);
      return getApiResponse<PairNotifications>(await query.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse?> getUserWish({fromProfileId, toProfileId}) async {
    try {
      final QueryBuilder<PairNotifications> query = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('Type', "Wishes")
        ..orderByDescending('createdAt')
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId);
      return getApiResponse<PairNotifications>(await query.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse?> getUsersAllWish() async {
    try {
      final QueryBuilder<PairNotifications> query = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('Type', "Wishes")
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'));
      final count = await query.count();
      query.setLimit(count.count);
      return getApiResponse<PairNotifications>(await query.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse?> getByProfileWish(fromProfileId, toProfileId, type) async {
    try {
      final QueryBuilder<PairNotifications> query = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('Type', type)
        // ..whereEqualTo('FromProfile',)
        // ..whereEqualTo('ToProfile',)
        ..whereArrayContainsAll('Users', [ProfilePage()..objectId = toProfileId, ProfilePage()..objectId = fromProfileId]);

      return getApiResponse<PairNotifications>(await query.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse?> messageCountCheckPair(String toProfileId , String type) async {
    try {
      // /*final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
      //   ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
      //   ..whereEqualTo('Type', type)
      //   ..whereNotContainedIn('DeletedUsers', [
      //     {"__type": "Pointer", "className": "User_login", "objectId": StorageService.getBox.read('ObjectId')}
      //   ]);*/
      //

      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('Type', type) /*..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])*/;

      final QueryBuilder<PairNotifications> queryChatData2 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('Type', type) /*..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])*/;

      final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(PairNotifications(), [queryChatData1, queryChatData2])
        ..whereNotContainedIn('DeletedUsers', [
          {"__type": "Pointer", "className": "User_login", "objectId": StorageService.getBox.read('ObjectId')}
        ])
        ..setLimit(historyLimit)
        ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])
        ..orderByDescending('updatedAt');
      return getApiResponse<PairNotifications>(await mainQuery.query());
    } catch (e) {
      if (kDebugMode) {
        print('error in unread message counter $e');
      }
      return null;
    }
  }

  Future<ApiResponse> getNewerThan(DateTime date) async {
    final QueryBuilder<PairNotifications> query = QueryBuilder<PairNotifications>(PairNotifications())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<PairNotifications>(await query.query());
  }

  Future<ApiResponse?> messageCount(String toProfileId, String fromProfileId) async {
    try {
      final QueryBuilder<PairNotifications> query = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('isRead', false);

      return getApiResponse<PairNotifications>(await query.query());
    } catch (e) {
      return null;
    }
  }

  // Future<ApiResponse?> messageRead({required String userId, required String type}) async {
  //   try {
  //     final QueryBuilder<Notifications> query = QueryBuilder<Notifications>(Notifications())
  //       ..whereEqualTo('ToUser', UserLogin()..objectId = userId)
  //       ..whereEqualTo('isRead', false)
  //       ..whereEqualTo('Type', 'PairNotifications');
  //
  //     return getApiResponse<Notifications>(await query.query());
  //   } catch (e, t) {
  //     if (kDebugMode) {
  //       print(e);
  //       print(t);
  //     }
  //     return null;
  //   }
  // }

  Future<ApiResponse?> messageCountPurchase(String toProfileId, String fromProfileId) async {
    try {
      final QueryBuilder<PairNotifications> query = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('isPurchased', false);

      return getApiResponse<PairNotifications>(await query.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse> remove(PairNotifications item) async {
    return getApiResponse<PairNotifications>(await item.delete());
  }

  Future<ApiResponse> update(PairNotifications item) async {
    return getApiResponse<PairNotifications>(await item.save());
  }

  Future<ApiResponse> updateAll(List<PairNotifications> items) async {
    final List<dynamic> responses = [];

    for (final PairNotifications item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
