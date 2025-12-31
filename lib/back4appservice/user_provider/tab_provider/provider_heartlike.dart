import 'package:eypop/models/user_login/user_post.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/tab_model/heart_like.dart';
import '../../../models/user_login/user_login.dart';
import '../../../models/user_login/user_profile.dart';
import '../../base/api_response.dart';
import '../../repositories_api/tab_api/heartlike_api_plan.dart';

class HeartLikeProviderApi implements HeartLikeProviderContract {
  HeartLikeProviderApi();

  @override
  Future<ApiResponse> add(HeartLike item) async {
    return getApiResponse<HeartLike>(await item.save());
  }

  Future<ParseResponse> likeGetData(String id) async {
    final QueryBuilder<HeartLike> query = QueryBuilder<HeartLike>(HeartLike())
      ..whereEqualTo('FromProfile', (ProfilePage()..objectId = id).toPointer());
    var tt = await query.query();
    if (tt.count == 0) {
      tt.results = [];
    }

    return tt;
  }

  Future<ApiResponse?> getUnReadheartNotification({String? userid}) async {
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
  Future<ApiResponse> addAll(List<HeartLike> items) async {
    final List<dynamic> responses = [];

    for (final HeartLike item in items) {
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
    return getApiResponse<HeartLike>(await HeartLike().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<HeartLike>(await HeartLike().getObject(id));
  }

  Future<ApiResponse?> getByFromProfileId(String id, String postId) async {
    try {
      QueryBuilder<HeartLike> mathakut = QueryBuilder<HeartLike>(HeartLike())
        ..whereEqualTo('ToProfile', (ProfilePage()..objectId = id).toPointer())
        ..whereEqualTo('FromProfile', (ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile')).toPointer())
        ..whereEqualTo('PostId', (UserPost()..objectId = postId).toPointer());
      return getApiResponse<HeartLike>(await mathakut.query());
    } catch (e) {
      return null;
    }

    // return getApiResponse<HeartLike>(await HeartLike().getObject(id));
  }

  Future<ApiResponse?> getByToProfileId(String id) async {
    try {
      QueryBuilder<HeartLike> heartLike = QueryBuilder<HeartLike>(HeartLike())
        ..whereEqualTo('FromProfile', (ProfilePage()..objectId = id).toPointer())
        ..includeObject(['PostId']);
      return getApiResponse<HeartLike>(await heartLike.query());
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ApiResponse> getNewerThan() async {
    final QueryBuilder<HeartLike> query = QueryBuilder<HeartLike>(HeartLike())..orderByAscending('createdAt');

    return getApiResponse<HeartLike>(await query.query());
  }

  @override
  Future<ApiResponse> userProfileQuery(String id) async {
    final QueryBuilder<HeartLike> query = QueryBuilder<HeartLike>(HeartLike())
      ..whereEqualTo('Profile_Id', (ProfilePage()..objectId = id).toPointer());

    return getApiResponse<HeartLike>(await query.query());
  }

  @override
  Future<ApiResponse> remove(HeartLike item) async {
    return getApiResponse<HeartLike>(await item.delete());
  }

  @override
  Future<ApiResponse> update(HeartLike item) async {
    return getApiResponse<HeartLike>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<HeartLike> items) async {
    final List<dynamic> responses = [];

    for (final HeartLike item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
