// ignore_for_file: null_check_always_fails, file_names

import 'package:eypop/models/bank_detail_model.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'base/api_response.dart';

class BankDetailsProviderApi {
  BankDetailsProviderApi();

  Future<ApiResponse> add(BankDetailsModel item) async {
    return getApiResponse<BankDetailsModel>(await item.save());
  }

  Future<ApiResponse> addAll(List<BankDetailsModel> items) async {
    final List<dynamic> responses = [];

    for (final BankDetailsModel item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<BankDetailsModel>(await BankDetailsModel().getAll());
  }

  Future<ApiResponse> getByObjId(String id) async {
    return getApiResponse<BankDetailsModel>(await BankDetailsModel().getObject(id));
  }

  Future<ApiResponse?> getById() async {
    try {
      final QueryBuilder<BankDetailsModel> query = QueryBuilder<BankDetailsModel>(BankDetailsModel())
        ..orderByDescending("updatedAt")
        ..whereEqualTo('UserId', UserLogin()..objectId = StorageService.getBox.read("ObjectId"));

      return getApiResponse<BankDetailsModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse> remove(BankDetailsModel item) async {
    return getApiResponse<BankDetailsModel>(await item.delete());
  }

  Future<ApiResponse> update(BankDetailsModel item) async {
    return getApiResponse<BankDetailsModel>(await item.save());
  }

  Future<ApiResponse> updateAll(List<BankDetailsModel> items) async {
    final List<dynamic> responses = [];

    for (final BankDetailsModel item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null!);
  }
}
