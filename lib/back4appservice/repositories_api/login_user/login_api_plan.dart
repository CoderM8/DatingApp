import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class UserLoginProviderContract {
  Future<ApiResponse> add(UserLogin item);

  Future<ApiResponse> addAll(List<UserLogin> items);

  Future<ApiResponse> update(UserLogin item);

  Future<ApiResponse> updateAll(List<UserLogin> items);

  Future<ApiResponse> remove(UserLogin item);

  Future<ApiResponse> getById(String id);

  Future<ApiResponse?> getByIdPointer(ParseUser id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan(DateTime date);
}
