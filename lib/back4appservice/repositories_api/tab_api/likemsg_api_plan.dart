import '../../../models/tab_model/like_message.dart';
import '../../base/api_response.dart';

abstract class LikeMsgProviderContract {
  Future<ApiResponse> add(LikeMessage item);

  Future<ApiResponse> userProfileQuery(String id);

  Future<ApiResponse> addAll(List<LikeMessage> items);

  Future<ApiResponse> update(LikeMessage item);

  Future<ApiResponse> updateAll(List<LikeMessage> items);

  Future<ApiResponse> remove(LikeMessage item);

  Future<ApiResponse> getById(String id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan();
}
