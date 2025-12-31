import '../../../models/verticaltab_model/blockuser.dart';
import '../../base/api_response.dart';

abstract class BlockUSerProviderContract {
  Future<ApiResponse> add(BlockUser item);

  Future<ApiResponse> userProfileQuery(String id);

  Future<ApiResponse> addAll(List<BlockUser> items);

  Future<ApiResponse> update(BlockUser item);

  Future<ApiResponse> updateAll(List<BlockUser> items);

  Future<ApiResponse> remove(BlockUser item);

  Future<ApiResponse> getById(String id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan();
}
