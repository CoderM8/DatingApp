// ignore_for_file: null_check_always_fails

import 'package:eypop/models/coins/purchase_model.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../base/api_response.dart';

class PurchaseProviderApi  {
  PurchaseProviderApi();

  Future<ApiResponse> add(PurchaseHistoryModel item) async {
    return getApiResponse<PurchaseHistoryModel>(await item.save());
  }

  Future<ApiResponse> addAll(List<PurchaseHistoryModel> items) async {
    final List<dynamic> responses = [];

    for (final PurchaseHistoryModel item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<PurchaseHistoryModel>(await PurchaseHistoryModel().getAll());
  }

  Future<ApiResponse> getOffer() async {
    QueryBuilder<PurchaseHistoryModel> coinOffer = QueryBuilder<PurchaseHistoryModel>(PurchaseHistoryModel())
      ..orderByAscending('Coins')
      ..whereNotEqualTo('Status', false);

    var apiResponse = await coinOffer.query();
    return getApiResponse<PurchaseHistoryModel>(apiResponse);
  }

  Future<ApiResponse> getById(String id) async {
    return getApiResponse<PurchaseHistoryModel>(await PurchaseHistoryModel().getObject(id));
  }

  Future<ApiResponse> getNewerThan(DateTime date) async {
    late QueryBuilder<PurchaseHistoryModel> query = QueryBuilder<PurchaseHistoryModel>(PurchaseHistoryModel())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<PurchaseHistoryModel>(await query.query());
  }

  Future<ApiResponse> remove(PurchaseHistoryModel item) async {
    return getApiResponse<PurchaseHistoryModel>(await item.delete());
  }

  Future<ApiResponse> update(PurchaseHistoryModel item) async {
    return getApiResponse<PurchaseHistoryModel>(await item.save());
  }

  Future<ApiResponse> updateAll(List<PurchaseHistoryModel> items) async {
    final List<dynamic> responses = [];

    for (final PurchaseHistoryModel item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null!);
  }
}
