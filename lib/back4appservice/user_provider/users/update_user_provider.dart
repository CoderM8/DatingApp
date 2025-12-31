import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/models/user_login/update_user.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UpdateUserProviderApi {
  UpdateUserProviderApi();

  Future<ApiResponse> add(UpdateUser item) async {
    return getApiResponse<UpdateUser>(await item.save());
  }

  Future<ApiResponse> addAll(List<UpdateUser> items) async {
    final List<dynamic> responses = [];

    for (final UpdateUser item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<UpdateUser>(await UpdateUser().getAll());
  }

  Future<ApiResponse> getById(String id) async {
    return getApiResponse<UpdateUser>(await UpdateUser().getObject(id));
  }

  Future<ApiResponse?> checkUserBlock(String id) async {
    try {
      final QueryBuilder<UpdateUser> query = QueryBuilder<UpdateUser>(UpdateUser())..whereEqualTo('Email', id);
      var data = await query.query();
      return getApiResponse<UpdateUser>(data);
    } catch (trace, error) {
      if (kDebugMode) {
        print('trace:: $trace');
        print('error:: $error');
      }
      return null;
    }
  }

  Future<ApiResponse?> getByIdPointer(UserLogin id) async {
    try {
      final QueryBuilder<UpdateUser> query = QueryBuilder<UpdateUser>(UpdateUser())
        ..orderByDescending('createdAt')
        ..whereEqualTo('User', id);

      return getApiResponse<UpdateUser>(await query.query());
    } catch (_) {
      return null;
    }
  }

  Future<ApiResponse> remove(UpdateUser item) async {
    return getApiResponse<UpdateUser>(await item.delete());
  }

  Future<ApiResponse> update(UpdateUser item) async {
    return getApiResponse<UpdateUser>(await item.save());
  }

  Future<ApiResponse> decrement(String id, int amount, String columnName) async {
    var todo = UpdateUser()
      ..objectId = id
      ..setDecrement(columnName, amount);
    return getApiResponse<UpdateUser>(await todo.save());
  }

  Future<ApiResponse> increment(String id, int amount, String columnName) async {
    var todo = UpdateUser()
      ..objectId = id
      ..setIncrement(columnName, amount);
    await todo.save();
    return getApiResponse<UpdateUser>(await UpdateUser().getObject(id));
  }

  Future<ApiResponse> updateAll(List<UpdateUser> items) async {
    final List<dynamic> responses = [];

    for (final UpdateUser item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }
}
