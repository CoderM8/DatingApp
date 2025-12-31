import '../../../models/user_login/user_post.dart';
import '../../base/api_response.dart';

abstract class PostProviderContract {
  Future<ApiResponse> add(UserPost item);
  Future<ApiResponse?> profilePostQuery(String id);
  Future<ApiResponse> addAll(List<UserPost> items);

  Future<ApiResponse> update(UserPost item);

  Future<ApiResponse> updateAll(List<UserPost> items);

  Future<ApiResponse> remove(UserPost item);


  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan();
}
