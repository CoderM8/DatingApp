import 'package:eypop/back4appservice/base/api_response.dart';

import '../../../models/coins/price_model.dart';

abstract class PricesProviderContract {
  Future<ApiResponse> add(Prices item);

  Future<ApiResponse> addAll(List<Prices> items);

  Future<ApiResponse> update(Prices item);

  Future<ApiResponse> updateAll(List<Prices> items);

  Future<ApiResponse> remove(Prices item);

  Future<ApiResponse> getById(String id);

  // Future<ApiResponse?> getByIdPointer(ParseUser id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan(DateTime date);
}
