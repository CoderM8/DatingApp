import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/tab_model/lip_like.dart';
import '../../../models/user_login/user_login.dart';
import '../../../models/user_login/user_profile.dart';
import '../../base/api_response.dart';
import '../../repositories_api/tab_api/liplike_api_plan.dart';

class LipLikeProviderApi implements LipLikeProviderContract {
  LipLikeProviderApi();

  @override
  Future<ApiResponse> add(LipLike item) async {
    return getApiResponse<LipLike>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<LipLike> items) async {
    final List<dynamic> responses = [];

    for (final LipLike item in items) {
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
    return getApiResponse<LipLike>(await LipLike().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<LipLike>(await LipLike().getObject(id));
  }

  @override
  Future<ApiResponse> getNewerThan() async {
    final QueryBuilder<LipLike> query = QueryBuilder<LipLike>(LipLike())..orderByAscending('createdAt');

    return getApiResponse<LipLike>(await query.query());
  }

  @override
  Future<ApiResponse> userProfileQuery(String id) async {
    final QueryBuilder<LipLike> query = QueryBuilder<LipLike>(LipLike())..whereEqualTo('Profile_Id', (ProfilePage()..objectId = id).toPointer());

    return getApiResponse<LipLike>(await query.query());
  }

  Future<ApiResponse?> getUnReadLiplikeNotification({String? userid}) async {
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

  @override
  Future<ApiResponse> remove(LipLike item) async {
    return getApiResponse<LipLike>(await item.delete());
  }

  @override
  Future<ApiResponse> update(LipLike item) async {
    return getApiResponse<LipLike>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<LipLike> items) async {
    final List<dynamic> responses = [];

    for (final LipLike item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
