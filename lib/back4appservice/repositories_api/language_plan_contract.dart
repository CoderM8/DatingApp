import 'package:eypop/back4appservice/base/api_response.dart';

import '../../models/user_login/languages_model.dart';

abstract class LanguageProviderContract {
  Future<ApiResponse> add(Languages item);

  Future<ApiResponse> addAll(List<Languages> items);

  Future<ApiResponse> update(Languages item);

  Future<ApiResponse> updateAll(List<Languages> items);

  Future<ApiResponse> remove(Languages item);

  Future<ApiResponse> getById(String id);

  // Future<ApiResponse?> getByIdPointer(ParseUser id);

  Future<ApiResponse> getNewerThan(DateTime date);
}
