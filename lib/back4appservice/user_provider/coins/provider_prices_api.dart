// ignore_for_file: null_check_always_fails

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/coins/price_model.dart';
import '../../base/api_response.dart';
import '../../repositories_api/coins/prices_api_plan.dart';

class PricesProviderApi implements PricesProviderContract {
  PricesProviderApi();

  @override
  Future<ApiResponse> add(Prices item) async {
    return getApiResponse<Prices>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<Prices> items) async {
    final List<dynamic> responses = [];

    for (final Prices item in items) {
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
    return getApiResponse<Prices>(await Prices().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<Prices>(await Prices().getObject(id));
  }

  @override
  Future<ApiResponse> getNewerThan(DateTime date) async {
    late QueryBuilder<Prices> query = QueryBuilder<Prices>(Prices())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<Prices>(await query.query());
  }

  @override
  Future<ApiResponse> remove(Prices item) async {
    return getApiResponse<Prices>(await item.delete());
  }

  @override
  Future<ApiResponse> update(Prices item) async {
    return getApiResponse<Prices>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<Prices> items) async {
    final List<dynamic> responses = [];

    for (final Prices item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null!);
  }
}
