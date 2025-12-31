import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/models/user_login/user_profile.dart';

abstract class UserProfileProviderContract {
  Future<ApiResponse> add(ProfilePage item);

  Future<ApiResponse?> userProfileQuery(String id);

  Future<ApiResponse> addAll(List<ProfilePage> items);

  Future<ApiResponse> update(ProfilePage item);

  Future<ApiResponse> updateAll(List<ProfilePage> items);

  Future<ApiResponse> remove(ProfilePage item);

  Future<ApiResponse> getById(String id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getLipLikeNotification();

  Future<ApiResponse?> getLipLikeNotification2();

  Future<ApiResponse> getNewerThan();
}
