// ignore_for_file: null_check_always_fails

import 'package:eypop/models/purchase_nudeimage_model.dart';
import 'package:eypop/models/user_login/user_post.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'base/api_response.dart';

class PurchaseNudeImageProviderApi {
  PurchaseNudeImageProviderApi();

  Future<ApiResponse> add(PurchaseNudeImage item) async {
    return getApiResponse<PurchaseNudeImage>(await item.save());
  }

  Future<ApiResponse> addAll(List<PurchaseNudeImage> items) async {
    final List<dynamic> responses = [];

    for (final PurchaseNudeImage item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<PurchaseNudeImage>(await PurchaseNudeImage().getAll());
  }

  Future<ApiResponse?> getById(String profileid, String userid) async {
    try {
      final QueryBuilder<PurchaseNudeImage> query = QueryBuilder<PurchaseNudeImage>(PurchaseNudeImage())
        ..whereEqualTo('ToProfile', (ProfilePage()..objectId = profileid).toPointer())
        ..whereEqualTo('FromProfile', (ProfilePage()..objectId = userid).toPointer());

      return getApiResponse<PurchaseNudeImage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  // use in wallScreen get nude image
  Future<ApiResponse?> getByIdNudeImage (List<String> profileid, String userid) async {
    try {
      final QueryBuilder<PurchaseNudeImage> query = QueryBuilder<PurchaseNudeImage>(PurchaseNudeImage())
        ..whereContainedIn(
            'ToProfile',
            profileid.map((id) => (ProfilePage()..objectId = id).toPointer()).toList()
        )
        ..whereEqualTo(
            'FromProfile',
            (ProfilePage()..objectId = userid).toPointer()
        );

      return getApiResponse<PurchaseNudeImage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('Error in getById: $e');
      }
      return null;
    }
  }

  Future<ApiResponse?> getObjectId(String postId, String toProfileId, String fromProfileId) async {
    try {
      final QueryBuilder<PurchaseNudeImage> query = QueryBuilder<PurchaseNudeImage>(PurchaseNudeImage())
        ..whereEqualTo('Post', (UserPost()..objectId = postId).toPointer())
        ..whereEqualTo('ToProfile', (ProfilePage()..objectId = toProfileId).toPointer())
        ..whereEqualTo('FromProfile', (ProfilePage()..objectId = fromProfileId).toPointer());

      return getApiResponse<PurchaseNudeImage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse> remove(PurchaseNudeImage item) async {
    return getApiResponse<PurchaseNudeImage>(await item.delete());
  }

  Future<ApiResponse> update(PurchaseNudeImage item) async {
    return getApiResponse<PurchaseNudeImage>(await item.save());
  }

  Future<ApiResponse> decrement(String id, int amount, String columnName) async {
    var todo = PurchaseNudeImage()
      ..objectId = id
      ..setDecrement(columnName, amount);
    return getApiResponse<PurchaseNudeImage>(await todo.save());
  }

  Future<ApiResponse> increment(String id, int amount, String columnName) async {
    var todo = PurchaseNudeImage()
      ..objectId = id
      ..setIncrement(columnName, amount);
    await todo.save();
    return getApiResponse<PurchaseNudeImage>(await PurchaseNudeImage().getObject(id));
  }

  Future<ApiResponse> updateAll(List<PurchaseNudeImage> items) async {
    final List<dynamic> responses = [];

    for (final PurchaseNudeImage item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null!);
  }
}
