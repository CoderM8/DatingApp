// ignore_for_file: null_check_always_fails

import 'package:eypop/models/user_login/languages_model.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../base/api_response.dart';
import '../repositories_api/language_plan_contract.dart';

class LanguageProviderApi implements LanguageProviderContract {
  LanguageProviderApi();

  @override
  Future<ApiResponse> add(Languages item) async {
    return getApiResponse<Languages>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<Languages> items) async {
    final List<dynamic> responses = [];

    for (final Languages item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<Languages>(await Languages().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<Languages>(await Languages().getObject(id));
  }

  Future<ApiResponse> getByLanguageName(String title) async {
    final QueryBuilder<Languages> query = QueryBuilder<Languages>(Languages())..whereContains('title', title);

    return getApiResponse<Languages>(await query.query());
  }

  // @override
  // Future<ApiResponse?> getByIdPointer(String id) async {
  //   try {
  //     final QueryBuilder<Languages> query = QueryBuilder<Languages>(Languages())
  //       ..whereEqualTo('objectId', (ProfilePage()..objectId = id).toPointer());
  //
  //     return getApiResponse<Languages>(await query.query());
  //   } catch (trace, error) {
  //     print('trace:: $trace');
  //     print('error:: $error');
  //     return null;
  //   }
  // }

  @override
  Future<ApiResponse> getNewerThan(DateTime date) async {
    late QueryBuilder<Languages> query = QueryBuilder<Languages>(Languages())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<Languages>(await query.query());
  }

  @override
  Future<ApiResponse> remove(Languages item) async {
    return getApiResponse<Languages>(await item.delete());
  }

  @override
  Future<ApiResponse> update(Languages item) async {
    return getApiResponse<Languages>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<Languages> items) async {
    final List<dynamic> responses = [];

    for (final Languages item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null!);
  }
}
