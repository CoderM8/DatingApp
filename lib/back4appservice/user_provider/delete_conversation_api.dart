import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../models/delete_table.dart';
import '../base/api_response.dart';

class DeleteConversationApi {
  DeleteConversationApi();

  Future<ApiResponse> add(DeleteConnection item) async {
    return getApiResponse<DeleteConnection>(await item.save());
  }

  Future<ApiResponse> addAll(List<DeleteConnection> items) async {
    final List<dynamic> responses = [];

    for (final DeleteConnection item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<DeleteConnection>(await DeleteConnection().getAll());
  }

  Future<ApiResponse> getById(String id) async {
    return getApiResponse<DeleteConnection>(await DeleteConnection().getObject(id));
  }

  Future<ApiResponse?> getByUserId(String id, type) async {
    try {
      QueryBuilder<DeleteConnection> query = QueryBuilder<DeleteConnection>(DeleteConnection())
        ..whereEqualTo('FromUser', UserLogin()..objectId = id)
        ..whereEqualTo('Type', type);
      return getApiResponse<DeleteConnection>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('error inn fatch data $e');
      }
      return null;
    }
  }


  Future<ApiResponse?> deleted ({required String fromId, required String toId, type}) async {
    try {
      QueryBuilder<DeleteConnection> query = QueryBuilder<DeleteConnection>(DeleteConnection())
        ..whereEqualTo('FromProfile',  ProfilePage()..objectId = fromId)
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toId)
        ..whereEqualTo('Type', type);
      return getApiResponse<DeleteConnection>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }


  Future<ApiResponse?> getSpeceficId({required String fromId, required String toId, type}) async {
    try {
      QueryBuilder<DeleteConnection> query = QueryBuilder<DeleteConnection>(DeleteConnection())
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromId)
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toId)
        ..whereEqualTo('Type', type);
      return getApiResponse<DeleteConnection>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  // Future<ApiResponse?> getByIdPointer(String id) async {
  //   try {
  //     final QueryBuilder<DeleteConnection> query = QueryBuilder<DeleteConnection>(DeleteConnection())
  //       ..whereEqualTo('objectId', (ProfilePage()..objectId = id).toPointer());
  //
  //     return getApiResponse<DeleteConnection>(await query.query());
  //   } catch (trace, error) {
  //     print('trace:: $trace');
  //     print('error:: $error');
  //     return null;
  //   }
  // }

  Future<ApiResponse> getNewerThan(DateTime date) async {
    late QueryBuilder<DeleteConnection> query = QueryBuilder<DeleteConnection>(DeleteConnection())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<DeleteConnection>(await query.query());
  }

  Future<ApiResponse> remove(DeleteConnection item) async {
    return getApiResponse<DeleteConnection>(await item.delete());
  }

  Future<ApiResponse> update(DeleteConnection item) async {
    return getApiResponse<DeleteConnection>(await item.save());
  }

  Future<ApiResponse> updateAll(List<DeleteConnection> items) async {
    final List<dynamic> responses = [];

    for (final DeleteConnection item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }
}
