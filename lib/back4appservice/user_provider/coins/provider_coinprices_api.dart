// ignore_for_file: null_check_always_fails

import 'package:eypop/back4appservice/repositories_api/coins/coinprice_api_plan.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/coins/coinprice_model.dart';
import '../../base/api_response.dart';

class CoinPricesProviderApi implements CoinPricesProviderContract {
  CoinPricesProviderApi();

  @override
  Future<ApiResponse> add(CoinPrices item) async {
    return getApiResponse<CoinPrices>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<CoinPrices> items) async {
    final List<dynamic> responses = [];

    for (final CoinPrices item in items) {
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
    return getApiResponse<CoinPrices>(await CoinPrices().getAll());
  }

  Future<ApiResponse> getOffer() async {
    QueryBuilder<CoinPrices> coinOffer = QueryBuilder<CoinPrices>(CoinPrices())
      ..orderByAscending('Coins')
      ..whereEqualTo('Status', false)
      ..whereEqualTo('FlashSale', false);

    var apiResponse = await coinOffer.query();
    return getApiResponse<CoinPrices>(apiResponse);
  }

  Future<ApiResponse?> getFlashSale() async {
    try {
      QueryBuilder<CoinPrices> coinOffer = QueryBuilder<CoinPrices>(CoinPrices())
        ..orderByAscending('Coins')
        ..whereEqualTo('Status', false)
        ..whereEqualTo('FlashSale', true);

      var apiResponse = await coinOffer.query();
      return getApiResponse<CoinPrices>(apiResponse);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<CoinPrices>(await CoinPrices().getObject(id));
  }

  @override
  Future<ApiResponse> getNewerThan(DateTime date) async {
    late QueryBuilder<CoinPrices> query = QueryBuilder<CoinPrices>(CoinPrices())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<CoinPrices>(await query.query());
  }

  @override
  Future<ApiResponse> remove(CoinPrices item) async {
    return getApiResponse<CoinPrices>(await item.delete());
  }

  @override
  Future<ApiResponse> update(CoinPrices item) async {
    return getApiResponse<CoinPrices>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<CoinPrices> items) async {
    final List<dynamic> responses = [];

    for (final CoinPrices item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null!);
  }
}
