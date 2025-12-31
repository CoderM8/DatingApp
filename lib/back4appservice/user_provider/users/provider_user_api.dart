import 'package:eypop/Controllers/PairNotificationController/pair_notification_controller.dart';
import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/back4appservice/purchase_nudeimage_api.dart';
import 'package:eypop/back4appservice/repositories_api/login_user/login_api_plan.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_post_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_parent.dart';
import 'package:eypop/models/verticaltab_model/blockuser.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/user_login/user_profile.dart';
import '../../../service/local_storage.dart';
import '../../base/api_response.dart';
import '../../repositories/users/provider_post_video_api.dart';
import '../tab_provider/provider_heartlike.dart';

class UserLoginProviderApi implements UserLoginProviderContract {
  UserLoginProviderApi();

  @override
  Future<ApiResponse> add(UserLogin item) async {
    return getApiResponse<UserLogin>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<UserLogin> items) async {
    final List<dynamic> responses = [];

    for (final UserLogin item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  @override
  Future<ApiResponse> getAll() async {
    return getApiResponse<UserLogin>(await UserLogin().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<UserLogin>(await UserLogin().getObject(id));
  }

  /// _User class
  Future<ApiResponse?> checkUserByEmail(String id) async {
    try {
      final QueryBuilder<UserParent> query = QueryBuilder<UserParent>(UserParent())..whereEqualTo('email', id);
      var data = await query.query();
      return getApiResponse<UserParent>(data);
    } catch (error) {
      if (kDebugMode) {
        print('error:: $error');
      }
      return null;
    }
  }

  Future<ApiResponse?> checkUserById(String id) async {
    try {
      final QueryBuilder<UserParent> query = QueryBuilder<UserParent>(UserParent())..whereEqualTo('phone_number', id);
      var data = await query.query();
      return getApiResponse<UserParent>(data);
    } catch (error) {
      if (kDebugMode) {
        print('error:: $error');
      }
      return null;
    }
  }

  /// User_login class
  Future<ApiResponse?> checkUserLoginByEmail({required String id}) async {
    try {
      final QueryBuilder<UserLogin> query = QueryBuilder<UserLogin>(UserLogin())
        ..whereEqualTo('Email', id)
        ..includeObject(['DefaultProfile', 'DefaultUser']);
      var data = await query.query();
      return getApiResponse<UserLogin>(data);
    } catch (error) {
      return null;
    }
  }

  @override
  Future<ApiResponse?> getByIdPointer(ParseUser id) async {
    try {
      final QueryBuilder<UserLogin> query = QueryBuilder<UserLogin>(UserLogin())
        ..includeObject(['DefaultProfile'])
        ..whereEqualTo('DefaultUser', ParseObject('_User')..objectId = id.objectId);

      return getApiResponse<UserLogin>(await query.query());
    } catch (error) {
      if (kDebugMode) {
        print('error:: $error');
      }
      return null;
    }
  }

  @override
  Future<ApiResponse> getNewerThan(DateTime date) async {
    late QueryBuilder<UserLogin> query = QueryBuilder<UserLogin>(UserLogin())..whereGreaterThan(keyVarCreatedAt, date);
    return getApiResponse<UserLogin>(await query.query());
  }

  Future<ApiResponse?> blockId(String defaultProfile) async {
    try {
      final QueryBuilder<BlockUser> queryBlock = QueryBuilder<BlockUser>(BlockUser())
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = defaultProfile)
        ..whereEqualTo('Type', 'BLOCK');
      return getApiResponse<ProfilePage>(await queryBlock.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  /*Future<int> getWallPhotos(String defaultProfile, int addPage) async {
    final AppSearchController searchController = Get.put(AppSearchController());
    final PairNotificationController pairNotificationController = Get.put(PairNotificationController());
    try {
      final List<ApiResponse?> multi = await Future.wait(
          [UserProfileProviderApi().getById(defaultProfile), blockId(defaultProfile), HeartLikeProviderApi().getByToProfileId(StorageService.getBox.read('DefaultProfile'))]);
      List<String> ids = [];

      if (multi[1] != null) {
        for (int i = 0; i < multi[1]!.results!.length; i++) {
          if (!ids.contains(multi[1]!.results![i]['ToProfile']['objectId'])) {
            ids.add(multi[1]!.results![i]['ToProfile']['objectId']);
          }
        }
      }

      for (var element in searchController.profileIds) {
        if (element['selfProfileId'] == defaultProfile) {
          if (!ids.contains(element['id'])) {
            ids.add(element['id']);
          }
        }
      }

      print('ids ==> ${ids.length} :: id = ${ids}');
      final QueryBuilder<ProfilePage> queryProfile = QueryBuilder<ProfilePage>(ProfilePage())
        ..whereNotEqualTo('Gender', StorageService.getBox.read('Gender'))
        ..whereValueExists('DefaultImg', true)
        ..whereNotEqualTo('StatusActive_P', 0)
        ..whereNotContainedIn('objectId', ids)
        ..whereNotEqualTo('isDeleted', true)
        ..whereNotEqualTo('IsBlocked', true)
        ..setLimit(10)
        ..setAmountToSkip(addPage)
        ..whereNotEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereWithinKilometers(
            'LocationGeoPoint',
            ParseGeoPoint(
                latitude: multi[0]!.result['LocationGeoPoint'].latitude,
                longitude: multi[0]!.result['LocationGeoPoint'].longitude),
            double.parse(multi[0]!.result['LocationRadius']));
      final ApiResponse testProfile = getApiResponse<ProfilePage>(await queryProfile.query());

      print(' testProfile data lenght ==> ${testProfile.results!.length}');
      if (testProfile.results != null) {
        testProfile.results!.shuffle();
        for (var element in testProfile.results!) {
          print("element testProfile ==> ${element}");
          final List<ApiResponse?> multiple = await Future.wait([
            PostProviderApi().profilePostQueryFree(element['objectId']),
            PostProviderApi().postCount(element['objectId']),
            PostVideoProviderApi().postCount(element['objectId']),
            PurchaseNudeImageProviderApi().getById(element['objectId'], StorageService.getBox.read('ObjectId')),
          ]);
          if (multiple[0] != null) {
            final ParseObject parseObject = multiple[0]!.result;
            if (!searchController.seenKeys.contains(parseObject['objectId'])) {
              final bool isAdded = (parseObject['User'] != null &&
                  (parseObject['User']['isDeleted'] ?? false) == false &&
                  (parseObject['User']['IsBlocked'] ?? false) == false &&
                  (parseObject['User']['StatusActive'] ?? 1) == 1 &&
                  !pairNotificationController.meBlockedUserProfile.contains(parseObject['Profile']['objectId']));
              if (isAdded) {
                searchController.finalPost.add(parseObject);
                searchController.imagePostCount.add(multiple[1]!.results!.length);

                if (multi[2] != null) {
                  if (multi[2]!.results!.contains(parseObject)) {
                    searchController.likeList.add(true);
                  } else {
                    searchController.likeList.add(false);
                  }
                } else {
                  searchController.likeList.add(false);
                }

                if (multiple[2] != null) {
                  searchController.videoPostCount.add(multiple[2]!.results!.length);
                } else {
                  searchController.videoPostCount.add(0);
                }

                if (multiple[3] != null) {
                  if (multiple[3]!.results!.contains(parseObject.objectId)) {
                    searchController.showNudeImage.add(false);
                  } else {
                    searchController.showNudeImage.add(true);
                  }
                } else {
                  searchController.showNudeImage.add(true);
                }

                searchController.seenKeys.add(parseObject['objectId']);
              }
            }
          }
        }
      }

      if (testProfile.results!.length != searchController.finalPost.length && searchController.finalPost.isEmpty) {
        if (!searchController.isWallPhotosFetched.value) {
          getWallPhotos(defaultProfile, addPage);
          searchController.isWallPhotosFetched.value = true;
        }
        for (var element in StorageService.photosBox.values.toList()) {
          print('StorageService.photosBox ==> $element}');
          if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {
            await StorageService.photosBox.delete(element['id']);
          }
        }
      }
      if (kDebugMode) {
        print('Hello Wall Loading Finish Total finalPost: ${searchController.finalPost.length}');
      }
      return testProfile.results!.length;
    } catch (e, t) {
      if (kDebugMode) {
        print('Hello Wall getWallPhotos ERROR $e , $t');
      }
      return 0;
    }
  }*/

  // Future<int> getWallPhotos(String defaultProfile, int addPage) async {
  //   final AppSearchController searchController = Get.put(AppSearchController());
  //   final PairNotificationController pairNotificationController = Get.put(PairNotificationController());
  //   try {
  //     final List<ApiResponse?> multi = await Future.wait(
  //         [UserProfileProviderApi().getById(defaultProfile), blockId(defaultProfile), HeartLikeProviderApi().getByToProfileId(StorageService.getBox.read('DefaultProfile'))]);
  //     List<String> ids = [];
  //
  //     if (multi[1] != null) {
  //       for (int i = 0; i < multi[1]!.results!.length; i++) {
  //         if (!ids.contains(multi[1]!.results![i]['ToProfile']['objectId'])) {
  //           ids.add(multi[1]!.results![i]['ToProfile']['objectId']);
  //         }
  //       }
  //     }
  //
  //     for (var element in searchController.profileIds) {
  //       if (element['selfProfileId'] == defaultProfile) {
  //         if (!ids.contains(element['id'])) {
  //           ids.add(element['id']);
  //         }
  //       }
  //     }
  //
  //     print('ids ==> ${ids.length} :: id = ${ids}');
  //     final QueryBuilder<ProfilePage> queryProfile = QueryBuilder<ProfilePage>(ProfilePage())
  //       ..whereNotEqualTo('Gender', StorageService.getBox.read('Gender'))
  //       ..whereValueExists('DefaultImg', true)
  //       ..whereNotEqualTo('StatusActive_P', 0)
  //       ..whereNotContainedIn('objectId', ids)
  //       ..whereNotEqualTo('isDeleted', true)
  //       ..whereNotEqualTo('IsBlocked', true)
  //       ..setLimit(10)
  //       ..setAmountToSkip(addPage)
  //       ..whereNotEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
  //       ..whereWithinKilometers(
  //           'LocationGeoPoint',
  //           ParseGeoPoint(
  //               latitude: multi[0]!.result['LocationGeoPoint'].latitude,
  //               longitude: multi[0]!.result['LocationGeoPoint'].longitude),
  //           double.parse(multi[0]!.result['LocationRadius']));
  //     final ApiResponse testProfile = getApiResponse<ProfilePage>(await queryProfile.query());
  //
  //     print(' testProfile data lenght ==> ${testProfile.results!.length}');
  //     if (testProfile.results != null) {
  //       testProfile.results!.shuffle();
  //       for (var element in testProfile.results!) {
  //         print("element testProfile ==> ${element}");
  //         final List<ApiResponse?> multiple = await Future.wait([
  //           PostProviderApi().profilePostQueryFree(element['objectId']),
  //           PostProviderApi().postCount(element['objectId']),
  //           PostVideoProviderApi().postCount(element['objectId']),
  //           PurchaseNudeImageProviderApi().getById(element['objectId'], StorageService.getBox.read('ObjectId')),
  //         ]);
  //         if (multiple[0] != null) {
  //           final ParseObject parseObject = multiple[0]!.result;
  //           if (!searchController.seenKeys.contains(parseObject['objectId'])) {
  //             final bool isAdded = (parseObject['User'] != null &&
  //                 (parseObject['User']['isDeleted'] ?? false) == false &&
  //                 (parseObject['User']['IsBlocked'] ?? false) == false &&
  //                 (parseObject['User']['StatusActive'] ?? 1) == 1 &&
  //                 !pairNotificationController.meBlockedUserProfile.contains(parseObject['Profile']['objectId']));
  //             if (isAdded) {
  //               searchController.finalPost.add(parseObject);
  //               searchController.imagePostCount.add(multiple[1]!.results!.length);
  //
  //               if (multi[2] != null) {
  //                 if (multi[2]!.results!.contains(parseObject)) {
  //                   searchController.likeList.add(true);
  //                 } else {
  //                   searchController.likeList.add(false);
  //                 }
  //               } else {
  //                 searchController.likeList.add(false);
  //               }
  //
  //               if (multiple[2] != null) {
  //                 searchController.videoPostCount.add(multiple[2]!.results!.length);
  //               } else {
  //                 searchController.videoPostCount.add(0);
  //               }
  //
  //               if (multiple[3] != null) {
  //                 if (multiple[3]!.results!.contains(parseObject.objectId)) {
  //                   searchController.showNudeImage.add(false);
  //                 } else {
  //                   searchController.showNudeImage.add(true);
  //                 }
  //               } else {
  //                 searchController.showNudeImage.add(true);
  //               }
  //
  //               searchController.seenKeys.add(parseObject['objectId']);
  //             }
  //           }
  //         }
  //       }
  //     }
  //
  //     if (testProfile.results!.length != searchController.finalPost.length && searchController.finalPost.isEmpty) {
  //       if (!searchController.isWallPhotosFetched.value) {
  //         getWallPhotos(defaultProfile, addPage);
  //         searchController.isWallPhotosFetched.value = true;
  //       }
  //       for (var element in StorageService.photosBox.values.toList()) {
  //         print('StorageService.photosBox ==> $element}');
  //         if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {
  //           await StorageService.photosBox.delete(element['id']);
  //         }
  //       }
  //     }
  //     if (kDebugMode) {
  //       print('Hello Wall Loading Finish Total finalPost: ${searchController.finalPost.length}');
  //     }
  //     return testProfile.results!.length;
  //   } catch (e, t) {
  //     if (kDebugMode) {
  //       print('Hello Wall getWallPhotos ERROR $e , $t');
  //     }
  //     return 0;
  //   }
  // }

  /// new code get wall photo
  Future<int> getWallPhotos(String defaultProfile, int addPage) async {
    final AppSearchController searchController = Get.put(AppSearchController());
    final PairNotificationController pairNotificationController = Get.put(PairNotificationController());

    try {
      // Fetch the required data asynchronously
      final List<ApiResponse?> multi = await Future.wait([
        UserProfileProviderApi().getById(defaultProfile),
        blockId(defaultProfile),
        HeartLikeProviderApi().getByToProfileId(StorageService.getBox.read('DefaultProfile'))
      ]);

      List<String> ids = [];
      List<String> addDataId = [];
      List<ParseObject> tempparseObjectList = [];

      // Add blocked profiles to `ids`
      if (multi[1]?.results != null) {
        for (var result in multi[1]!.results!) {
          if (!ids.contains(result['ToProfile']['objectId'])) {
            ids.add(result['ToProfile']['objectId']);
          }
        }
      }

      // Add other profile IDs to `ids`
      for (var element in searchController.profileIds) {
        if (element['selfProfileId'] == defaultProfile && !ids.contains(element['id'])) {
          ids.add(element['id']);
        }
      }

      // Build the profile query
      final QueryBuilder<ProfilePage> queryProfile = QueryBuilder<ProfilePage>(ProfilePage())
        ..whereNotEqualTo('Gender', StorageService.getBox.read('Gender'))
        // ..whereValueExists('DefaultImg', true)
        ..whereNotContainedIn('DefaultImg', ['', null])
        ..whereNotEqualTo('StatusActive_P', 0)
        ..whereNotContainedIn('objectId', ids)
        ..whereNotContainedIn('objectId', searchController.tempGetWallProfileId)
        ..whereNotEqualTo('isDeleted', true)
        ..whereContainedIn('Medal', searchController.selectMedalList.isNotEmpty ? searchController.selectMedalList : searchController.allMedalList)
        ..whereNotEqualTo('IsBlocked', true)
        ..setLimit(10)
        ..setAmountToSkip(addPage)
        ..whereNotEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereWithinKilometers(
            'LocationGeoPoint',
            ParseGeoPoint(
                latitude: multi[0]?.result['LocationGeoPoint']?.latitude ?? 0, longitude: multi[0]?.result['LocationGeoPoint']?.longitude ?? 0),
            double.parse(multi[0]?.result['LocationRadius'] ?? '0'));

      final ApiResponse testProfile = getApiResponse<ProfilePage>(await queryProfile.query());

      if (testProfile.results != null) {
        // Collect `objectId`s for batch API calls
        List<String> profileIds = testProfile.results!.map((e) => e['objectId'] as String).toList();

        // Fetch multiple API data outside of the loop
        final List<ApiResponse?> multipleResponses = await Future.wait([
          PostProviderApi().profilePostQueryFree(profileIds),
          PostProviderApi().postCount(profileIds),
          PostVideoProviderApi().postCount(profileIds),
          PurchaseNudeImageProviderApi().getByIdNudeImage(profileIds, StorageService.getBox.read('DefaultProfile'))
        ]);

        // Process results and add data to finalPost
        //testProfile.results!.shuffle();

        var postsResponse = multipleResponses[0]; // Post data
        var postCountResponse = multipleResponses[1]; // Post count data
        var videoCountResponse = multipleResponses[2]; // Video post count data
        var nudeImageResponse = multipleResponses[3]; // Nude image access data

        // Add data to Final Post
        // for (int i = 0; i < testProfile.results!.length; i++) {
        // Check if we have a valid post response
        if (postsResponse != null && postsResponse.results != null) {
          searchController.parseObjectList.addAll(postsResponse.results as List<ParseObject>);
          searchController.parseObjectList.shuffle();
          // final List<ParseObject> parseObjectList = postsResponse.results as List<ParseObject>;

          // Filter out posts from the `seenKeys` and add new ones to finalPost and other lists
          for (var element in searchController.parseObjectList) {
            final objectId = element['Profile']['objectId'];
            if (!searchController.seenKeys.contains(element['objectId']) && addDataId.where((id) => id == objectId).isEmpty) {
              tempparseObjectList.add(element);
              searchController.tempGetWallProfileId.add(objectId);
              addDataId.add(objectId);
              //print('add data object Id ::: $objectId');
            }
          }

          // Process each ParseObject (representing a post)
          for (var parseObject in tempparseObjectList) {
            if (!searchController.seenKeys.contains(parseObject['objectId'])) {
              final bool isAdded = (parseObject['User'] != null &&
                  !(parseObject['User']['isDeleted'] ?? true) &&
                  !(parseObject['User']['IsBlocked'] ?? true) &&
                  (parseObject['User']['StatusActive'] ?? 1) == 1 &&
                  !pairNotificationController.meBlockedUserProfile.contains(parseObject['Profile']['objectId']));

              if (isAdded) {
                // Add data to finalPost and other lists
                searchController.finalPost.add(parseObject);

                searchController.likeList.add(multi[2]?.results?.contains(parseObject) ?? false);

                // wallScreen image Post Count
                searchController.imagePostCount.add(postCountResponse?.results?.length ?? 0);

                for (var element1 in profileIds) {
                  // Calculate the count of posts for the current profileId
                  int? count = multipleResponses[1]?.results?.where((element2) => element2["Profile"]['objectId'] == element1).length;

                  // Check if the objectId is already in the list
                  bool isAlreadyAdded = searchController.wallPostCount.any((element) => element["objectId"] == element1);

                  // Add the objectId and count only if it's not already added and count > 0
                  if (!isAlreadyAdded) {
                    searchController.wallPostCount.add({"objectId": element1, "count": count});
                  }
                }

                // wallScreen video Post Count
                searchController.videoPostCount.add(videoCountResponse?.results?.length ?? 0);
                for (var element1 in profileIds) {
                  int? count = videoCountResponse?.results?.where((element2) => element2["Profile"]['objectId'] == element1).length;
                  bool isAlreadyAdded = searchController.wallVideoPostCount.any((element) => element["objectId"] == element1);
                  if (!isAlreadyAdded && (count ?? 0) > 0) {
                    searchController.wallVideoPostCount.add({"objectId": element1, "count": count});
                  }
                }

                // wallScreen check is Nude image
                //searchController.showNudeImage.add((nudeImageResponse?.results?.contains(parseObject['objectId']) ?? true));
                if (nudeImageResponse != null) {
                  if (nudeImageResponse.results!.contains(parseObject.objectId)) {
                    searchController.showNudeImage.add(false);
                  } else {
                    searchController.showNudeImage.add(true);
                  }
                } else {
                  searchController.showNudeImage.add(true);
                }

                // add photo in final post not Repeat this photo
                searchController.seenKeys.add(parseObject['objectId']);
              }
            }
          }
        }
      }
      // }

      // Retry if no posts are found
      if (testProfile.results!.length != searchController.finalPost.length && searchController.finalPost.isEmpty) {
        // no data found! after -> one time api call
        if (!searchController.isWallPhotosFetched.value) {
          getWallPhotos(defaultProfile, addPage);
          searchController.isWallPhotosFetched.value = true;
        }
        // Clear outdated photos in StorageService
        for (var element in StorageService.photosBox.values.toList()) {
          if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {
            await StorageService.photosBox.delete(element['id']);
          }
        }
      }

      print('Hello Wall Loading Finish Total finalPost: ${searchController.finalPost.length}');

      // Clear outdated ids to load more photo to same profile Ids
      if (addDataId.length > 20 && addDataId.isNotEmpty) {
        print('Clearing addDataId after adding 10 data to finalPost...');
        addDataId.clear();
      }

      return testProfile.results?.length ?? 0;
    } catch (e, t) {
      if (kDebugMode) {
        print('Hello Wall getWallPhotos ERROR $e , $t');
      }
      return 0;
    }
  }

  // Future<ApiResponse?> getUserData(String id, String defaultProfile, int addpage) async {
  //   try {
  //     List toblockprofile = [];
  //
  //     final QueryBuilder<BlockUser> query1 = QueryBuilder<BlockUser>(BlockUser())
  //       ..whereEqualTo('FromProfile', (ProfilePage()..objectId = defaultProfile).toPointer());
  //
  //     var blockByMe = await query1.query();
  //
  //     if (blockByMe.results != null) {
  //       for (var i = 0; i < blockByMe.results!.length; i++) {
  //         toblockprofile.add('${blockByMe.results![i]["ToProfile"]["objectId"]}');
  //       }
  //     }
  //
  //     ApiResponse location = await UserLoginProviderApi().getById(StorageService.getBox.read('ObjectId'));
  //
  //     try {
  //       late QueryBuilder<UserLogin> query = QueryBuilder<UserLogin>(UserLogin())
  //         ..whereNotEqualTo('DefaultUser', id)
  //         ..whereNotEqualTo('Gender', StorageService.getBox.read('Gender'))
  //         ..whereNotContainedIn('DefaultProfile', toblockprofile)
  //         ..whereValueExists('DefaultProfile', true)
  //         ..orderByDescending('createdAt')
  //         ..setLimit(10)
  //         ..setAmountToSkip(addpage)
  //         ..whereWithinKilometers(
  //             'LocationGeoPoint',
  //             ParseGeoPoint(latitude: location.result['LocationGeoPoint'].latitude, longitude: location.result['LocationGeoPoint'].longitude),
  //             double.parse(location.result['LocationRadius']))
  //         ..includeObject(['DefaultProfile', 'Language']);
  //       return getApiResponse<UserLogin>(await query.query());
  //     } catch (e, trace) {
  //       if (kDebugMode) {
  //         print('error in user Wall $e');
  //         print('rrr $trace');
  //       }
  //       return null;
  //     }
  //   } catch (e, trace) {
  //     if (kDebugMode) {
  //       print('error  $e');
  //       print('error in wall $trace');
  //     }
  //     return null;
  //   }
  // }

  Future<ApiResponse> getByPointer(String id) async {
    final QueryBuilder<ProfilePage> query = QueryBuilder<ProfilePage>(ProfilePage())
      ..whereEqualTo('DefaultProfile', (ProfilePage()..objectId = id).toPointer());

    return getApiResponse<ProfilePage>(await query.query());
  }

  @override
  Future<ApiResponse> remove(UserLogin item) async {
    return getApiResponse<UserLogin>(await item.delete());
  }

  @override
  Future<ApiResponse> update(UserLogin item) async {
    return getApiResponse<UserLogin>(await item.save());
  }

  Future<ApiResponse> decrement(String id, int amount, String columnName) async {
    var todo = UserLogin()
      ..objectId = id
      ..setDecrement(columnName, amount);
    return getApiResponse<UserLogin>(await todo.save());
  }

  Future<ApiResponse> increment(String id, int amount, String columnName) async {
    var todo = UserLogin()
      ..objectId = id
      ..setIncrement(columnName, amount);
    await todo.save();
    return getApiResponse<UserLogin>(await UserLogin().getObject(id));
  }

  @override
  Future<ApiResponse> updateAll(List<UserLogin> items) async {
    final List<dynamic> responses = [];

    for (final UserLogin item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }
}
