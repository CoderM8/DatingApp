import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_post.dart';
import 'package:eypop/models/user_login/user_postvideo.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/wishes_model/wish_model.dart';
import '../../../service/local_storage.dart';
import '../../base/api_response.dart';
import '../users/provider_profileuser_api.dart';

RxList seenWishIds = [].obs;
RxInt searchRadiusKm = 10.obs; // Starting radius in kilometers

class WishesApi {
  WishesApi();

  Future<ApiResponse> add(WishModel item) async {
    return getApiResponse<WishModel>(await item.save());
  }

  Future<ApiResponse> addAll(List<WishModel> items) async {
    final List<dynamic> responses = [];

    for (final WishModel item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<WishModel>(await WishModel().getAll());
  }

  Future<ApiResponse> getById(String id) async {
    return getApiResponse<WishModel>(await WishModel().getObject(id));
  }

  Future<ApiResponse?> postCount(String id) async {
    try {
      final QueryBuilder<WishModel> query = QueryBuilder<WishModel>(WishModel())..whereEqualTo('Profile', (ProfilePage()..objectId = id).toPointer());
      final ApiResponse data = getApiResponse<WishModel>(await query.query());
      return data;
    } catch (e) {
      return null;
    }
  }

  // Future<ApiResponse?> getWishesForSwiper(int page, List ids, bool isFromKm) async {
  //   try {
  //     final QueryBuilder<WishModel> query = QueryBuilder<WishModel>(WishModel());
  //     if (isFromKm) {
  //       // when click on global search button
  //       final ApiResponse apiResponse = await UserProfileProviderApi().getById(StorageService.getBox.read('DefaultProfile'));
  //       List proIds = [];
  //       try {
  //         final QueryBuilder<ProfilePage> queryProfile = QueryBuilder<ProfilePage>(ProfilePage())
  //           ..whereNotEqualTo('Gender', StorageService.getBox.read('Gender'))
  //           ..whereNotContainedIn('objectId', ids)
  //           ..whereNotEqualTo('StatusActive_P', 0)
  //           ..whereNotEqualTo('isDeleted', true)
  //           ..whereNotEqualTo('IsBlocked', true)
  //           ..whereNotEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
  //           ..whereWithinKilometers(
  //               'LocationGeoPoint',
  //               ParseGeoPoint(latitude: apiResponse.result['LocationGeoPoint'].latitude, longitude: apiResponse.result['LocationGeoPoint'].longitude),
  //               100.0);
  //
  //         final ApiResponse renderProfile = getApiResponse<ProfilePage>(await queryProfile.query());
  //         for (var element in renderProfile.results ?? []) {
  //           proIds.add(element['objectId']);
  //         }
  //       } catch (e) {
  //         if (kDebugMode) {
  //           print('error in wish get profile $e');
  //         }
  //       }
  //       query
  //         ..whereContainedIn('Profile', proIds)
  //         ..whereEqualTo('IsVisible', true)
  //         ..whereContainedIn('Status', [0, 3]) // status 0 means accept and 3 means Nude
  //         ..setLimit(10)
  //         ..setAmountToSkip(page)
  //         ..orderByDescending('createdAt')
  //         ..includeObject(['Profile', 'Wish_List', 'User', 'TokTok', 'Img_Post', 'Video_Post']);
  //     } else {
  //       // first time call
  //       query
  //         ..whereNotEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
  //         ..whereNotEqualTo('Gender', StorageService.getBox.read('Gender'))
  //         ..whereNotContainedIn('Profile', ids)
  //         ..whereEqualTo('IsVisible', true)
  //         ..whereContainedIn('Status', [0, 3]) // status 0 means accept and 3 means Nude
  //         ..setLimit(10)
  //         ..setAmountToSkip(page)
  //         ..orderByDescending('createdAt')
  //         ..includeObject(['Profile', 'Wish_List', 'User', 'TokTok', 'Img_Post', 'Video_Post']);
  //     }
  //     return getApiResponse<WishModel>(await query.query());
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('error in WishSwiper data $e');
  //     }
  //     return null;
  //   }
  // }

  /// my code
  /*Future<ApiResponse?> getWishesForSwiper(int page, List ids, bool isFromKm) async {
    try {
      final QueryBuilder<WishModel> query = QueryBuilder<WishModel>(WishModel());

      if (isFromKm) {
        // When clicking on the global search button
        final ApiResponse apiResponse = await UserProfileProviderApi().getById(StorageService.getBox.read('DefaultProfile'));

        try {
          final userLocation = apiResponse.result['LocationGeoPoint'];
          if (userLocation == null) {
            throw Exception("User location not available.");
          }
          // Query to get profiles
          final QueryBuilder<ProfilePage> queryProfile = QueryBuilder<ProfilePage>(ProfilePage())
            ..whereNotEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
            ..whereWithinKilometers(
                'LocationGeoPoint',
                ParseGeoPoint(latitude: apiResponse.result['LocationGeoPoint'].latitude, longitude: apiResponse.result['LocationGeoPoint'].longitude),
            200);
          query
            ..whereNotEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
            ..whereNotEqualTo('Gender', StorageService.getBox.read('Gender'))
            ..whereNotContainedIn('Profile', ids)
            ..whereNotContainedIn('objectId', seenWishIds)
            ..whereEqualTo('IsVisible', true)
            ..orderByAscending('LocationGeoPoint') // Order wishes by distance
            ..whereContainedIn('Status', [0, 3]) // Status 0 means accept, 3 means nude
            ..setLimit(10)
            ..setAmountToSkip(page)
            ..orderByDescending('createdAt')
            ..includeObject(['Profile', 'Wish_List', 'User', 'TokTok', 'Img_Post', 'Video_Post'])
            ..whereMatchesQuery('Profile', queryProfile);
        } catch (e) {
          if (kDebugMode) {
            print('Error in fetching profile or calculating distance: $e');
          }
        }
      } else {
        // First-time call, no radius filtering
        query
          ..whereNotEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
          ..whereNotEqualTo('Gender', StorageService.getBox.read('Gender'))
          ..whereNotContainedIn('Profile', ids)
          ..whereEqualTo('IsVisible', true)
          ..whereContainedIn('Status', [0, 3]) // Status 0 means accept, 3 means nude
          ..setLimit(10)
          ..setAmountToSkip(page)
          ..orderByDescending('createdAt')
          ..includeObject(['Profile', 'Wish_List', 'User', 'TokTok', 'Img_Post', 'Video_Post']);
      }

      // Execute the query and return the result
      return getApiResponse<WishModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('Error in WishSwiper data: $e');
      }
      return null;
    }

  }*/

  /// new code
  Future<ApiResponse?> getWishesForSwiper(int page, List ids, bool isFromKm) async {
    try {
      final QueryBuilder<WishModel> query = QueryBuilder<WishModel>(WishModel());

      if (isFromKm) {

        // Nearby Location Data (Nearby Location)
        final ApiResponse apiResponse = await UserProfileProviderApi().getById(StorageService.getBox.read('DefaultProfile'));
        final userLocation = apiResponse.result['LocationGeoPoint'];

        // Create GeoPoint from user location
        if (userLocation == null) {
          throw Exception("User location not available. ");
        }

        final double latitude = userLocation.latitude;
        final double longitude = userLocation.longitude;
        final ParseGeoPoint userGeoPoint = ParseGeoPoint(latitude: latitude, longitude: longitude);
        try {
          final userLocation = apiResponse.result['LocationGeoPoint'];
          if (userLocation == null) {
            throw Exception("User location not available.");
          }
          print('searchRadiusKm.value ::: ${searchRadiusKm.value}');

          // Query to get profiles
          final QueryBuilder<ProfilePage> queryProfile = QueryBuilder<ProfilePage>(ProfilePage())
            ..whereNotEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
            ..whereGreaterThan('lastOnline', DateTime.now().subtract(Duration(days: tokTokDeactiveDays)).toLocal())
            ..whereWithinKilometers('LocationGeoPoint', userGeoPoint, searchRadiusKm.value.clamp(0, 500).toDouble());
          query
            ..whereNotEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
            ..whereNotEqualTo('Gender', StorageService.getBox.read('Gender'))
            ..whereNotContainedIn('Profile', ids)
            ..whereNotContainedIn('objectId', seenWishIds)
            ..whereEqualTo('IsVisible', true)
            ..whereNotContainedIn('Profile', ids)
            ..whereContainedIn('Status', [0, 3]) // Status 0 means accept, 3 means nude
            ..setLimit(10)
            ..setAmountToSkip(0)
            ..orderByDescending('createdAt')
            ..includeObject(['Profile', 'Wish_List', 'User', 'TokTok', 'Img_Post', 'Video_Post'])
            ..whereMatchesQuery('Profile', queryProfile);

          searchRadiusKm.value = searchRadiusKm.value += 10;
        } catch (e) {
          if (kDebugMode) {
            print('Error in fetching profile or calculating distance: $e');
          }
        }
      } else {
        // First-time call, no radius filtering (World)

        final QueryBuilder<ProfilePage> queryProfile = QueryBuilder<ProfilePage>(ProfilePage())
          ..whereGreaterThan('lastOnline', DateTime.now().subtract(Duration(days: tokTokDeactiveDays)).toLocal());
        query
          ..whereNotEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
          ..whereNotEqualTo('Gender', StorageService.getBox.read('Gender'))
          ..whereNotContainedIn('Profile', ids)
          ..whereEqualTo('IsVisible', true)
          ..whereContainedIn('Status', [0, 3]) // Status 0 means accept, 3 means nude
          ..setLimit(10)
          ..setAmountToSkip(page)
          ..orderByDescending('createdAt')
          ..includeObject(['Profile', 'Wish_List', 'User', 'TokTok', 'Img_Post', 'Video_Post'])
          ..whereMatchesQuery('Profile', queryProfile);
      }
      return getApiResponse<WishModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('Error in WishSwiper data: $e');
      }
      return null;
    }
  }

  Future<ApiResponse?> getByProfileId(String id) async {
    try {
      final QueryBuilder<WishModel> query = QueryBuilder<WishModel>(WishModel())
        ..whereEqualTo('Profile', ProfilePage()..objectId = id)
        ..includeObject(['Profile', 'Wish_List', 'User', 'TokTok', 'Img_Post', 'Video_Post']);
      return getApiResponse<WishModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('error in WishModel data $e');
      }
      return null;
    }
  }

  Future<ApiResponse?> getByToktokImage(String id) async {
    try {
      final QueryBuilder<WishModel> query = QueryBuilder<WishModel>(WishModel())
        ..whereEqualTo('Img_Post', UserPost()..objectId = id)
        ..includeObject(['Profile', 'Wish_List', 'User', 'TokTok', 'Img_Post', 'Video_Post']);
      return getApiResponse<WishModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('error in WishModel data $e');
      }
      return null;
    }
  }

  Future<ApiResponse?> getByToktokVideo(String id) async {
    try {
      final QueryBuilder<WishModel> query = QueryBuilder<WishModel>(WishModel())
        ..whereEqualTo('Video_Post', UserPostVideo()..objectId = id)
        ..includeObject(['Profile', 'Wish_List', 'User', 'TokTok', 'Img_Post', 'Video_Post']);
      return getApiResponse<WishModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('error in WishModel data $e');
      }
      return null;
    }
  }

  Future<ApiResponse?> getProfileWishByIdType({required String profileId}) async {
    try {
      final QueryBuilder<WishModel> query = QueryBuilder<WishModel>(WishModel())
        ..whereEqualTo('Profile', ProfilePage()..objectId = profileId)
        ..whereContainedIn('Status', [0, 1, 3])
        // ..whereValueExists('TokTok', true)
        ..includeObject(['Profile', 'Wish_List', 'User', 'TokTok', 'Img_Post', 'Video_Post']);
      final total = await query.count();
      query.setLimit(total.count);
      return getApiResponse<WishModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print('getProfileImageWish error $e');
      }
      return null;
    }
  }

  Future<ApiResponse?> deleted({required String fromId, required String toId, type}) async {
    try {
      final QueryBuilder<WishModel> query = QueryBuilder<WishModel>(WishModel())
        ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toId)
        ..whereEqualTo('Type', type);
      return getApiResponse<WishModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> getSpeceficId({required String fromId, required String toId, type}) async {
    try {
      final QueryBuilder<WishModel> query = QueryBuilder<WishModel>(WishModel())
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromId)
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toId)
        ..whereEqualTo('Type', type);
      return getApiResponse<WishModel>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  // Future<ApiResponse?> getByIdPointer(String id) async {
  //   try {
  //     final QueryBuilder<DeleteConnection> query = QueryBuilder<DeleteConnection>(DeleteConnection())
  //       ..whereEqualTo('objectId', (ProfilePage()..objectId = id).toPointer());
  //
  //     return getApiResponse<DeleteConnection>(await query.query());
  //   } catch (trace, error) {
  //     print('trace:: $trace');
  //     print('error:: $error');
  //     return null;
  //   }
  // }

  Future<ApiResponse> getNewerThan(DateTime date) async {
    final QueryBuilder<WishModel> query = QueryBuilder<WishModel>(WishModel())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<WishModel>(await query.query());
  }

  Future<ApiResponse> remove(WishModel item) async {
    return getApiResponse<WishModel>(await item.delete());
  }

  Future<ApiResponse> update(WishModel item) async {
    return getApiResponse<WishModel>(await item.save());
  }

  Future<ApiResponse> updateAll(List<WishModel> items) async {
    final List<dynamic> responses = [];

    for (final WishModel item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }
}
