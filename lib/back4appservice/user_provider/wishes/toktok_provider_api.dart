import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/wishes_model/toktok_model.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class TokTokApi {
  TokTokApi();

  Future<ApiResponse> add(TokTokModel item) async {
    return getApiResponse<TokTokModel>(await item.save());
  }

  Future<ApiResponse> addAll(List<TokTokModel> items) async {
    final List<dynamic> responses = [];

    for (final TokTokModel item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<TokTokModel>(await TokTokModel().getAll());
  }

  Future<ApiResponse?> getUserId(String id) async {
    try {
      final QueryBuilder<TokTokModel> query = QueryBuilder<TokTokModel>(TokTokModel())
        ..whereEqualTo('User_Profile', ProfilePage()..objectId = id)
        ..includeObject(['User_Profile', 'Wish_List', 'User_Login']);
      return getApiResponse<TokTokModel>(await query.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse> getById(String id) async {
    return getApiResponse<TokTokModel>(await TokTokModel().getObject(id));
  }

  Future<ApiResponse> remove(TokTokModel item) async {
    return getApiResponse<TokTokModel>(await item.delete());
  }

  Future<ApiResponse> update(TokTokModel item) async {
    return getApiResponse<TokTokModel>(await item.save());
  }

  Future<ApiResponse> updateAll(List<TokTokModel> items) async {
    final List<dynamic> responses = [];

    for (final TokTokModel item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }
}
