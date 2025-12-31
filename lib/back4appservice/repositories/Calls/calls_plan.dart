import '../../../models/call/calls.dart';
import '../../base/api_response.dart';

abstract class UserCallProviderContract {
  Future<ApiResponse> add(CallModel item);

  Future<ApiResponse> addAll(List<CallModel> items);

  Future<ApiResponse> update(CallModel item);

  Future<ApiResponse> updateAll(List<CallModel> items);

  Future<ApiResponse> remove(CallModel item);

  Future<ApiResponse> getById(String id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan(DateTime date);
}