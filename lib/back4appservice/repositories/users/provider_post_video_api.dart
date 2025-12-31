import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/user_login/user_postvideo.dart';
import '../../../models/user_login/user_profile.dart';
import '../../base/api_response.dart';
import '../login_user/postvideo_api_plan.dart';

class PostVideoProviderApi implements PostVideoProviderContract {
  PostVideoProviderApi();

  @override
  Future<ApiResponse> add(UserPostVideo item) async {
    return getApiResponse<UserPostVideo>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<UserPostVideo> items) async {
    final List<dynamic> responses = [];

    for (final UserPostVideo item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }

      response.results?.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  @override
  Future<ApiResponse> getAll() async {
    return getApiResponse<UserPostVideo>(await UserPostVideo().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<UserPostVideo>(await UserPostVideo().getObject(id));
  }

  @override
  Future<ApiResponse> getNewerThan() async {
    final QueryBuilder<UserPostVideo> query = QueryBuilder<UserPostVideo>(UserPostVideo())..orderByAscending('createdAt');

    return getApiResponse<UserPostVideo>(await query.query());
  }

  @override
  Future<ApiResponse?> profileVideoPostQuery(String id) async {
    try {
      final QueryBuilder<UserPostVideo> query = QueryBuilder<UserPostVideo>(UserPostVideo())
        ..orderByDescending('createdAt')
        ..whereEqualTo('Profile', (ProfilePage()..objectId = id).toPointer())
        ..includeObject(['User']);

      ParseResponse jay = await query.query();

      return getApiResponse<UserPostVideo>(jay);
    } catch (e) {
      if (kDebugMode) {
        print('error in video post query $e');
      }
      return null;
    }
  }

/*  Future<ApiResponse?> postCount(String id) async {
    try {
      final QueryBuilder<UserPostVideo> query = QueryBuilder<UserPostVideo>(UserPostVideo())
        ..whereEqualTo('Profile', ProfilePage()..objectId = id)
        ..whereEqualTo('Status', true);
      return getApiResponse<UserPostVideo>(await query.query());
    } catch (e) {
      return null;
    }
  }*/

  /// new code video postCount
  Future<ApiResponse?> postCount(List<String> ids) async {
    try {
      if (ids.isEmpty) {
        if (kDebugMode) {
          print('postCount ERROR: Provided id list is empty');
        }
        return null;
      }

      // Create a list of ProfilePage objects from the provided ids
      final List<ProfilePage> profilePages = ids.map((id) {
        final profilePage = ProfilePage()..objectId = id;
        return profilePage;
      }).toList();

      // Query for UserPostVideo where Profile is in the list of ProfilePage references
      final QueryBuilder<UserPostVideo> query = QueryBuilder<UserPostVideo>(UserPostVideo())
        ..whereContainedIn('Profile', profilePages)  // Use whereContainedIn for multiple IDs
        ..whereEqualTo('Status', true)..setLimit(2000);  // Optional limit to avoid excessive data fetching



      return getApiResponse<UserPostVideo>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('postCount ERROR: $e');
      }
      return null;
    }
  }




  @override
  Future<ApiResponse> remove(UserPostVideo item) async {
    return getApiResponse<UserPostVideo>(await item.delete());
  }

  @override
  Future<ApiResponse> update(UserPostVideo item) async {
    return getApiResponse<UserPostVideo>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<UserPostVideo> items) async {
    final List<dynamic> responses = [];

    for (final UserPostVideo item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
