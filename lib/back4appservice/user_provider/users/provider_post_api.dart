import 'package:eypop/back4appservice/repositories_api/login_user/post_api_plan.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/user_login/user_post.dart';
import '../../../models/user_login/user_profile.dart';
import '../../base/api_response.dart';

class PostProviderApi implements PostProviderContract {
  PostProviderApi();

  @override
  Future<ApiResponse> add(UserPost item) async {
    return getApiResponse<UserPost>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<UserPost> items) async {
    final List<dynamic> responses = [];

    for (final UserPost item in items) {
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
    return getApiResponse<UserPost>(await UserPost().getAll());
  }

  Future<ApiResponse?> getById(String id) async {
    try {
      final QueryBuilder<UserPost> query = QueryBuilder<UserPost>(UserPost())..whereEqualTo('objectId', id);
      return getApiResponse<UserPost>(await query.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse> getNullImage() async {
    return getApiResponse<UserPost>(await UserPost().get(''));
  }

  @override
  Future<ApiResponse> getNewerThan() async {
    final QueryBuilder<UserPost> query = QueryBuilder<UserPost>(UserPost())..orderByAscending('createdAt');

    return getApiResponse<UserPost>(await query.query());
  }

  @override
  Future<ApiResponse?> profilePostQuery(String id) async {
    try {
      final QueryBuilder<UserPost> query = QueryBuilder<UserPost>(UserPost())
        ..orderByDescending('createdAt')
        ..includeObject(['Language', 'Profile', 'User'])
        ..whereEqualTo('Profile', (ProfilePage()..objectId = id).toPointer());
      var imageLen = await query.query();

      return getApiResponse<UserPost>(imageLen);
    } catch (e) {
      if (kDebugMode) {
        print('error in image post query $e');
      }
      return null;
    }
  }

  /*Future<ApiResponse?> profilePostQueryFree(String id) async {
    List ids = [];

    for (var element in StorageService.photosBox.values.toList()) {
      if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {
        ids.add(element['id']);
      }
    }
    try {
      final QueryBuilder<UserPost> query = QueryBuilder<UserPost>(UserPost())
        ..orderByDescending('createdAt')
        // ..whereNotEqualTo('Type', 'PAID')
        ..whereEqualTo('Status', true)
        ..whereNotContainedIn('objectId', ids)
        ..whereEqualTo('Profile', ProfilePage()..objectId = id)
        ..includeObject(['Profile', 'User']);
      ParseResponse imageLen = await query.query();
      print('image len ::: ${imageLen.results}');
      return getApiResponse<UserPost>(imageLen);
    } catch (e) {
      if (kDebugMode) {
        print('profilePostQueryFree ERROR $e');
      }
      return null;
    }
  }*/

  /// new code get postbyProfile
  Future<ApiResponse?> profilePostQueryFree(List<String> ids) async {
    List<UserPost> resultPosts = [];

    try {
      // Create ProfilePage objects from the provided IDs
      List<ProfilePage> profilePages = ids.map((id) {
        final profilePage = ProfilePage();
        profilePage.objectId = id;
        return profilePage;
      }).toList();

      // Construct the query
      final QueryBuilder<UserPost> query = QueryBuilder<UserPost>(UserPost())
            ..whereContainedIn('Profile', profilePages) // Filter by Profile
            ..whereEqualTo('Status', true) // Filter by Status = true
            ..whereNotContainedIn('objectId', ids) // Exclude provided IDs
            ..includeObject(['Profile', 'User']) // Include related objects
            ..orderByDescending('createdAt'); // Order by creation date descending
      // Execute the query
      ParseResponse response = await query.query();

      // Check and handle the response
      if (response.success && response.results != null) {
        resultPosts = response.results!.cast<UserPost>();
      }

      return getApiResponse<UserPost>(response);
    } catch (e) {
      if (kDebugMode) {
        print('profilePostQueryFree ERROR $e');
      }
      return null;
    }
  }

/*  Future<ApiResponse?> postCount(String id) async {
    try {
      final QueryBuilder<UserPost> query = QueryBuilder<UserPost>(UserPost())
        ..whereEqualTo('Profile', ProfilePage()..objectId = id)
        ..whereEqualTo('Status', true);
      return getApiResponse<UserPost>(await query.query());
    } catch (e) {
      return null;
    }
  }*/

  /// new code image postCount
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

      // Query for UserPost where Profile is in the list of ProfilePage references
      final QueryBuilder<UserPost> query = QueryBuilder<UserPost>(UserPost())
        ..whereContainedIn('Profile', profilePages) // Use whereContainedIn for multiple IDs
        ..whereEqualTo('Status', true)
        ..setLimit(2000); // Only consider active posts
      return getApiResponse<UserPost>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('postCount ERROR: $e');
      }
      return null;
    }
  }

  @override
  Future<ApiResponse> remove(UserPost item) async {
    return getApiResponse<UserPost>(await item.delete());
  }

  @override
  Future<ApiResponse> update(UserPost item) async {
    return getApiResponse<UserPost>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<UserPost> items) async {
    final List<dynamic> responses = [];

    for (final UserPost item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
