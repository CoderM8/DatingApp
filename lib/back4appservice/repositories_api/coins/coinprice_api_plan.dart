import 'package:eypop/back4appservice/base/api_response.dart';
import '../../../models/coins/coinprice_model.dart';

abstract class CoinPricesProviderContract {
  Future<ApiResponse> add(CoinPrices item);

  Future<ApiResponse> addAll(List<CoinPrices> items);

  Future<ApiResponse> update(CoinPrices item);

  Future<ApiResponse> updateAll(List<CoinPrices> items);

  Future<ApiResponse> remove(CoinPrices item);

  Future<ApiResponse> getById(String id);

  // Future<ApiResponse?> getByIdPointer(ParseUser id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan(DateTime date);
}
