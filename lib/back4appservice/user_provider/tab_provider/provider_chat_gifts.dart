import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/repositories_api/tab_api/chat_gifts_api_plan.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UserChatGiftsProviderApi implements UserChatGiftsProviderContract {
  UserChatGiftsProviderApi();

  @override
  Future<ApiResponse> add(ParseObject item) async {
    return getApiResponse<ParseObject>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<ParseObject> items) async {
    final List<dynamic> responses = [];

    for (final ParseObject item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }

      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  @override
  Future<ApiResponse> getAll() async {
    return getApiResponse<ParseObject>(await ParseObject('Gifts').getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<ParseObject>(await ParseObject('Gifts').getObject(id));
  }

  static Future<ApiResponse?> getAllGifts() async {
    try {
      final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Gifts'))
        ..whereEqualTo('Status', true)
        ..orderByAscending('Stars');
      return getApiResponse<ParseObject>(await query.query());
    } catch (e) {
      return null;
    }
  }

  static Future<ApiResponse?> getGiftById(String id) async {
    try {
      final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Gifts'))..whereEqualTo('objectId', id);
      return getApiResponse<ParseObject>(await query.query());
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ApiResponse> remove(ParseObject item) async {
    return getApiResponse<ParseObject>(await item.delete());
  }

  @override
  Future<ApiResponse> update(ParseObject item) async {
    return getApiResponse<ParseObject>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<ParseObject> items) async {
    final List<dynamic> responses = [];

    for (final ParseObject item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
