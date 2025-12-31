import 'package:eypop/models/all_notifications/all_notifications.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/tab_model/like_message.dart';
import '../../../models/user_login/user_profile.dart';
import '../../base/api_response.dart';
import '../../repositories_api/tab_api/likemsg_api_plan.dart';

class LikeMsgProviderApi implements LikeMsgProviderContract {
  LikeMsgProviderApi();

  @override
  Future<ApiResponse> add(LikeMessage item) async {
    return getApiResponse<LikeMessage>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<LikeMessage> items) async {
    final List<dynamic> responses = [];

    for (final LikeMessage item in items) {
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
    return getApiResponse<LikeMessage>(await LikeMessage().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<LikeMessage>(await LikeMessage().getObject(id));
  }

  @override
  Future<ApiResponse> getNewerThan() async {
    final QueryBuilder<LikeMessage> query = QueryBuilder<LikeMessage>(LikeMessage())..orderByAscending('createdAt');

    return getApiResponse<LikeMessage>(await query.query());
  }

  @override
  Future<ApiResponse> userProfileQuery(String id) async {
    final QueryBuilder<LikeMessage> query = QueryBuilder<LikeMessage>(LikeMessage())
      ..whereEqualTo('Profile_Id', (ProfilePage()..objectId = id).toPointer());

    return getApiResponse<LikeMessage>(await query.query());
  }

  Future<ApiResponse?> messageCount(String fromProfileId, String toProfileId) async {
    try {
      final QueryBuilder<LikeMessage> query = QueryBuilder<LikeMessage>(LikeMessage())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereArrayContainsAll('Users', [ProfilePage()..objectId = toProfileId, ProfilePage()..objectId = fromProfileId])
        ..whereEqualTo('isRead', false)
        ..orderByAscending('updatedAt');

      return getApiResponse<LikeMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('error in unread message counter $e');
      }
      return null;
    }
  }

  Future<ApiResponse?> messageRead({userId, String? fromUser, required String type}) async {
    try {
      final QueryBuilder<Notifications> query = QueryBuilder<Notifications>(Notifications())
        ..whereEqualTo('ToUser', (UserLogin()..objectId = userId).toPointer())
        ..whereEqualTo('isRead', false)
        ..whereEqualTo('Type', type);
      if (fromUser != null) {
        query.whereEqualTo('FromUser', UserLogin()..objectId = fromUser);
      }

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
      final QueryBuilder<LikeMessage> query = QueryBuilder<LikeMessage>(LikeMessage())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('isPurchased', false);

      return getApiResponse<LikeMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  @override
  Future<ApiResponse> remove(LikeMessage item) async {
    return getApiResponse<LikeMessage>(await item.delete());
  }

  @override
  Future<ApiResponse> update(LikeMessage item) async {
    return getApiResponse<LikeMessage>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<LikeMessage> items) async {
    final List<dynamic> responses = [];

    for (final LikeMessage item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
