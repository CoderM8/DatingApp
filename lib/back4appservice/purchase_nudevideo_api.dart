// ignore_for_file: null_check_always_fails

import 'package:eypop/models/user_login/user_postvideo.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/wishes_model/purchase_nudevideo_model.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'base/api_response.dart';

class PurchaseNudeVideoProviderApi {
  PurchaseNudeVideoProviderApi();

  Future<ApiResponse> add(PurchaseNudeVideo item) async {
    return getApiResponse<PurchaseNudeVideo>(await item.save());
  }

  Future<ApiResponse> addAll(List<PurchaseNudeVideo> items) async {
    final List<dynamic> responses = [];

    for (final PurchaseNudeVideo item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<PurchaseNudeVideo>(await PurchaseNudeVideo().getAll());
  }

  Future<ApiResponse?> getById(String profileid, String userid) async {
    try {
      final QueryBuilder<PurchaseNudeVideo> query = QueryBuilder<PurchaseNudeVideo>(PurchaseNudeVideo())
        ..whereEqualTo('ToProfile', (ProfilePage()..objectId = profileid).toPointer())
        ..whereEqualTo('FromProfile', (ProfilePage()..objectId = userid).toPointer());

      return getApiResponse<PurchaseNudeVideo>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getObjectId(String postId,String toProfileId, String fromProfileId) async {
    try {
      final QueryBuilder<PurchaseNudeVideo> query = QueryBuilder<PurchaseNudeVideo>(PurchaseNudeVideo())
        ..whereEqualTo('Post', (UserPostVideo()..objectId = postId).toPointer())
        ..whereEqualTo('ToProfile', (ProfilePage()..objectId = toProfileId).toPointer())
        ..whereEqualTo('FromProfile', (ProfilePage()..objectId = fromProfileId).toPointer());

      return getApiResponse<PurchaseNudeVideo>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse> remove(PurchaseNudeVideo item) async {
    return getApiResponse<PurchaseNudeVideo>(await item.delete());
  }

  Future<ApiResponse> update(PurchaseNudeVideo item) async {
    return getApiResponse<PurchaseNudeVideo>(await item.save());
  }

  Future<ApiResponse> decrement(String id, int amount, String columnName) async {
    var todo = PurchaseNudeVideo()
      ..objectId = id
      ..setDecrement(columnName, amount);
    return getApiResponse<PurchaseNudeVideo>(await todo.save());
  }

  Future<ApiResponse> increment(String id, int amount, String columnName) async {
    var todo = PurchaseNudeVideo()
      ..objectId = id
      ..setIncrement(columnName, amount);
    await todo.save();
    return getApiResponse<PurchaseNudeVideo>(await PurchaseNudeVideo().getObject(id));
  }

  Future<ApiResponse> updateAll(List<PurchaseNudeVideo> items) async {
    final List<dynamic> responses = [];

    for (final PurchaseNudeVideo item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null!);
  }
}
