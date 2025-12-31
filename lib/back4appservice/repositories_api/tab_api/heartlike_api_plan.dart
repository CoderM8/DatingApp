import '../../../models/tab_model/heart_like.dart';
import '../../base/api_response.dart';

abstract class HeartLikeProviderContract {
  Future<ApiResponse> add(HeartLike item);

  Future<ApiResponse> userProfileQuery(String id);

  Future<ApiResponse> addAll(List<HeartLike> items);

  Future<ApiResponse> update(HeartLike item);

  Future<ApiResponse> updateAll(List<HeartLike> items);

  Future<ApiResponse> remove(HeartLike item);

  Future<ApiResponse> getById(String id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan();
}
