// ignore_for_file: null_check_always_fails

import 'package:eypop/models/video_purchase_model.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/user_login/user_login.dart';
import '../models/user_login/user_profile.dart';
import 'base/api_response.dart';

class PurchaseVideoProviderApi {
  PurchaseVideoProviderApi();

  Future<ApiResponse> add(PurchaseVideo item) async {
    return getApiResponse<PurchaseVideo>(await item.save());
  }

  Future<ApiResponse> addAll(List<PurchaseVideo> items) async {
    final List<dynamic> responses = [];

    for (final PurchaseVideo item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<PurchaseVideo>(await PurchaseVideo().getAll());
  }

  int a = 1;
  Future<ApiResponse?> getById(String profileid, String userid) async {
    try {
      final QueryBuilder<PurchaseVideo> query = QueryBuilder<PurchaseVideo>(PurchaseVideo())
        ..whereEqualTo('ToProfile', (ProfilePage()..objectId = profileid).toPointer())
        ..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

      return getApiResponse<PurchaseVideo>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse> remove(PurchaseVideo item) async {
    return getApiResponse<PurchaseVideo>(await item.delete());
  }

  Future<ApiResponse> update(PurchaseVideo item) async {
    return getApiResponse<PurchaseVideo>(await item.save());
  }

  Future<ApiResponse> decrement(String id, int amount, String columnName) async {
    var todo = PurchaseVideo()
      ..objectId = id
      ..setDecrement(columnName, amount);
    return getApiResponse<PurchaseVideo>(await todo.save());
  }

  Future<ApiResponse> increment(String id, int amount, String columnName) async {
    var todo = PurchaseVideo()
      ..objectId = id
      ..setIncrement(columnName, amount);
    await todo.save();
    return getApiResponse<PurchaseVideo>(await PurchaseVideo().getObject(id));
  }

  Future<ApiResponse> updateAll(List<PurchaseVideo> items) async {
    final List<dynamic> responses = [];

    for (final PurchaseVideo item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null!);
  }
}
