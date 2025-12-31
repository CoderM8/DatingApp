// ignore_for_file: null_check_always_fails

import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/image_puchase_model.dart';
import 'base/api_response.dart';

class PurchaseImgProviderApi {
  PurchaseImgProviderApi();

  Future<ApiResponse> add(PurchaseImage item) async {
    return getApiResponse<PurchaseImage>(await item.save());
  }

  Future<ApiResponse> addAll(List<PurchaseImage> items) async {
    final List<dynamic> responses = [];

    for (final PurchaseImage item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<PurchaseImage>(await PurchaseImage().getAll());
  }

  int a = 1;
  Future<ApiResponse?> getById(String profileid, String userid) async {
    try {
      final QueryBuilder<PurchaseImage> query = QueryBuilder<PurchaseImage>(PurchaseImage())
        ..whereEqualTo('ToProfile', (ProfilePage()..objectId = profileid).toPointer())
        ..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

      return getApiResponse<PurchaseImage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse> remove(PurchaseImage item) async {
    return getApiResponse<PurchaseImage>(await item.delete());
  }

  Future<ApiResponse> update(PurchaseImage item) async {
    return getApiResponse<PurchaseImage>(await item.save());
  }

  Future<ApiResponse> decrement(String id, int amount, String columnName) async {
    var todo = PurchaseImage()
      ..objectId = id
      ..setDecrement(columnName, amount);
    return getApiResponse<PurchaseImage>(await todo.save());
  }

  Future<ApiResponse> increment(String id, int amount, String columnName) async {
    var todo = PurchaseImage()
      ..objectId = id
      ..setIncrement(columnName, amount);
    await todo.save();
    return getApiResponse<PurchaseImage>(await PurchaseImage().getObject(id));
  }

  Future<ApiResponse> updateAll(List<PurchaseImage> items) async {
    final List<dynamic> responses = [];

    for (final PurchaseImage item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null!);
  }
}
