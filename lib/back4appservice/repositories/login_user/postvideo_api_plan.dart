import '../../../models/user_login/user_postvideo.dart';
import '../../base/api_response.dart';

abstract class PostVideoProviderContract {
  Future<ApiResponse> add(UserPostVideo item);
  Future<ApiResponse?> profileVideoPostQuery(String id);
  Future<ApiResponse> addAll(List<UserPostVideo> items);

  Future<ApiResponse> update(UserPostVideo item);

  Future<ApiResponse> updateAll(List<UserPostVideo> items);

  Future<ApiResponse> remove(UserPostVideo item);

  Future<ApiResponse> getById(String id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan();
}
