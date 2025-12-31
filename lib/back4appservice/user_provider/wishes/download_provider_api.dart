import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/wishes_model/download_model.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class DownloadApi {
  DownloadApi();

  static Future<ApiResponse> add(DownloadModel item) async {
    return getApiResponse<DownloadModel>(await item.save());
  }

  static Future<ApiResponse> addAll(List<DownloadModel> items) async {
    final List<dynamic> responses = [];

    for (final DownloadModel item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  static Future<ApiResponse> getAll() async {
    return getApiResponse<DownloadModel>(await DownloadModel().getAll());
  }

  static Future<ApiResponse> getById(String id) async {
    return getApiResponse<DownloadModel>(await DownloadModel().getObject(id));
  }

  static Future<ApiResponse?> getByProfileId() async {
    try {
      final QueryBuilder<DownloadModel> query = QueryBuilder<DownloadModel>(DownloadModel())
        ..whereEqualTo('User_Profile', ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'))
        ..includeObject(['User_Profile', 'User_Login']);
      return getApiResponse<DownloadModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('error in DownloadModel data $e');
      }
      return null;
    }
  }

  static Future<ApiResponse?> getByProfileType(String type) async {
    try {
      final QueryBuilder<DownloadModel> query = QueryBuilder<DownloadModel>(DownloadModel())
        ..whereEqualTo('User_Profile', ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'))
        ..whereEqualTo('Type', type)
        ..includeObject(['User_Profile', 'User_Login']);
      return getApiResponse<DownloadModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('error in DownloadModel data $e');
      }
      return null;
    }
  }

  static Future<ApiResponse> remove(DownloadModel item) async {
    return getApiResponse<DownloadModel>(await item.delete());
  }

  static Future<ApiResponse> update(DownloadModel item) async {
    return getApiResponse<DownloadModel>(await item.save());
  }

  Future<ApiResponse> updateAll(List<DownloadModel> items) async {
    final List<dynamic> responses = [];

    for (final DownloadModel item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }
}
