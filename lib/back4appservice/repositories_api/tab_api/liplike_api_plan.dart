import '../../../models/tab_model/lip_like.dart';
import '../../base/api_response.dart';

abstract class LipLikeProviderContract {
  Future<ApiResponse> add(LipLike item);

  Future<ApiResponse> userProfileQuery(String id);

  Future<ApiResponse> addAll(List<LipLike> items);

  Future<ApiResponse> update(LipLike item);

  Future<ApiResponse> updateAll(List<LipLike> items);

  Future<ApiResponse> remove(LipLike item);

  Future<ApiResponse> getById(String id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan();
}
