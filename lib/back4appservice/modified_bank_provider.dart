// ignore_for_file: null_check_always_fails, file_names

import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/modification_bankdetails.dart';
import '../models/user_login/user_login.dart';
import '../service/local_storage.dart';
import 'base/api_response.dart';

class ModificationBankDetailsProviderApi {
  ModificationBankDetailsProviderApi();

  Future<ApiResponse> add(ModificationBankDetailsModel item) async {
    return getApiResponse<ModificationBankDetailsModel>(await item.save());
  }

  Future<ApiResponse> addAll(List<ModificationBankDetailsModel> items) async {
    final List<dynamic> responses = [];

    for (final ModificationBankDetailsModel item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<ModificationBankDetailsModel>(await ModificationBankDetailsModel().getAll());
  }

  Future<ApiResponse?> getById() async {
    try {
      final QueryBuilder<ModificationBankDetailsModel> query = QueryBuilder<ModificationBankDetailsModel>(ModificationBankDetailsModel())
        ..orderByDescending("updatedAt")
        ..whereEqualTo('UserId', UserLogin()..objectId = StorageService.getBox.read("ObjectId"));

      return getApiResponse<ModificationBankDetailsModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse> remove(ModificationBankDetailsModel item) async {
    return getApiResponse<ModificationBankDetailsModel>(await item.delete());
  }

  Future<ApiResponse> update(ModificationBankDetailsModel item) async {
    return getApiResponse<ModificationBankDetailsModel>(await item.save());
  }

  Future<ApiResponse> updateAll(List<ModificationBankDetailsModel> items) async {
    final List<dynamic> responses = [];

    for (final ModificationBankDetailsModel item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null!);
  }
}
