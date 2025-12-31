import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class UserChatGiftsProviderContract {
  Future<ApiResponse> add(ParseObject item);
  Future<ApiResponse> addAll(List<ParseObject> items);
  Future<ApiResponse> update(ParseObject item);
  Future<ApiResponse> updateAll(List<ParseObject> items);
  Future<ApiResponse> remove(ParseObject item);
  Future<ApiResponse> getById(String id);
  Future<ApiResponse> getAll();
}
