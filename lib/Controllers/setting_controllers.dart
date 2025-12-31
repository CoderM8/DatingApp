import 'dart:io';

import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../back4appservice/user_provider/users/provider_user_api.dart';
import '../service/local_storage.dart';
import '../ui/splash_screen_first.dart';
import 'Picture_Controller/profile_pic_controller.dart';

final RxBool isBlockLogoutLoading = false.obs;

class SettingController extends GetxController {
  static AppSearchController get _searchController => Get.find<AppSearchController>();

  static PictureController get pictureX => Get.find<PictureController>();

  static PriceController get priceController => Get.find<PriceController>();

  final RxBool callsSwitch = true.obs;
  final RxBool chatSwitch = true.obs;
  final RxBool winkSwitch = true.obs;
  final RxBool heartLikeSwitch = true.obs;
  final RxBool heartMessageSwitch = true.obs;
  final RxBool visitSwitch = true.obs;
  final RxBool lipLike = true.obs;
  final RxBool offerSwitch = true.obs;
  final RxBool wishSwitch = true.obs;
  final RxBool giftSwitch = true.obs;
  final RxList switchValues = [].obs;
  final RxBool isLogout = false.obs;

  List<Map<String, dynamic>> switchTitle = [
    {'svg': 'assets/Icons/wink_outline.svg'.tr, 'title': 'winks'.tr},
    {'svg': 'assets/Icons/kiss_outline.svg'.tr, 'title': 'kisses'.tr},
    {'svg': 'assets/Icons/heart_outline.svg'.tr, 'title': 'i_like_you'.tr},
    {'svg': 'assets/Icons/message_outline.svg'.tr, 'title': 'messages'.tr},
    {'svg': 'assets/Icons/eye_outline.svg'.tr, 'title': 'visits'.tr},
    {'svg': 'assets/Icons/bullseye_outline.svg'.tr, 'title': 'TokTok'},
    {'svg': 'assets/Icons/gift_outline.svg'.tr, 'title': 'gifts'.tr},
    {'svg': 'assets/Icons/offer_outline.svg'.tr, 'title': 'offers'.tr},
  ];

  final RxMap<String, dynamic> downloadTile = <String, dynamic>{
    'Call': null,
    'VideoCall': null,
    'ChatMessage': null,
    'WinkMessage': null,
    'LipLike': null,
    'HeartLike': null,
    'HeartMessage': null,
    'Visit': null,
    'Wishes': null,
    'ChatGift': null
  }.obs;

  Map getTypes(String type) {
    switch (type) {
      case 'Call':
        {
          return {'svg': 'assets/Icons/call_outline.svg'.tr, 'title': 'calls'.tr};
        }
      case "VideoCall":
        {
          return {'svg': 'assets/Icons/video_outline.svg'.tr, 'title': 'videocalls'.tr};
        }
      case "ChatMessage":
        {
          return {'svg': 'assets/Icons/chat_outline.svg'.tr, 'title': 'chats'.tr};
        }
      case "WinkMessage":
        {
          return {'svg': 'assets/Icons/wink_outline.svg'.tr, 'title': 'winks'.tr};
        }
      case "LipLike":
        {
          return {'svg': 'assets/Icons/kiss_outline.svg'.tr, 'title': 'kisses'.tr};
        }
      case "HeartLike":
        {
          return {'svg': 'assets/Icons/heart_outline.svg'.tr, 'title': 'i_like_you'.tr};
        }
      case "HeartMessage":
        {
          return {'svg': 'assets/Icons/message_outline.svg'.tr, 'title': 'messages'.tr};
        }
      case "Visit":
        {
          return {'svg': 'assets/Icons/eye_outline.svg'.tr, 'title': 'visits'.tr};
        }
      case "Wishes":
        {
          return {'svg': 'assets/Icons/bullseye_outline.svg'.tr, 'title': 'TokTok'};
        }
      case "ChatGift":
        {
          return {'svg': 'assets/Icons/gift_outline.svg'.tr, 'title': 'gifts'.tr};
        }
    }
    return {'svg': 'assets/Icons/call_outline.svg'.tr, 'title': 'calls'.tr};
  }

  final RxString birthDate = ''.obs;
  final RxString appVersion = ''.obs;

  Future<void> getUserdata() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      localVersion = int.parse(packageInfo.buildNumber);
      appVersion.value = packageInfo.version;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('HELLO INFO APP DATA ERROR $e');
      }
    }
  }

  UserLogin userLogin = UserLogin();

  @override
  void onInit() {
    userdata();
    getDefaultProfile();
    getUserdata();
    super.onInit();
  }

  Future<void> userdata() async {
    if (StorageService.getBox.read('ObjectId') != null) {
      await UserLoginProviderApi().getById(StorageService.getBox.read('ObjectId')).then((userdata) {
        if (userdata.result != null) {
          userEmail.value = userdata.result['Email'];
          userLoginType.value = userdata.result['Type'];
          if (userEmail.value.isEmpty || userEmail.value == 'null') {
            userEmail.value = (userdata.result['Type'] ?? 'Eypop');
          }
          birthDate.value = DateFormat('dd/MM/yyyy').format(userdata.result['BirthDate']);
          noCalls.value = (userdata.result['NoCalls'] ?? false);
          noVideocalls.value = (userdata.result['NoVideocalls'] ?? false);
          noChats.value = (userdata.result['NoChats'] ?? false);
          nonVisibleInteractionsOptions.value = (userdata.result['NonVisibleInteractionOptions'] ?? false);
          influencerCall.value = (userdata.result['InfluencerCall'] ?? false);
          influencerVideocall.value = (userdata.result['InfluencerVideocall'] ?? false);
          hasLoggedIn.value = (userdata.result['HasLoggedIn'] ?? true);
          accountType.value = (userdata.result['AccountType']);
          callsSwitch.value = (userdata.result['CallNotification'] ?? true);
          chatSwitch.value = (userdata.result['ChatNotification'] ?? true);
          winkSwitch.value = (userdata.result['WinkMessageNotification'] ?? true);
          lipLike.value = (userdata.result['LipLikeNotification'] ?? true);
          heartLikeSwitch.value = (userdata.result['HeartLikeNotification'] ?? true);
          heartMessageSwitch.value = (userdata.result['HeartMessageNotification'] ?? true);
          visitSwitch.value = (userdata.result['VisitNotification'] ?? true);
          wishSwitch.value = (userdata.result['wishNotification'] ?? true);
          giftSwitch.value = (userdata.result['GiftNotification'] ?? true);
          offerSwitch.value = (userdata.result['OfferNotification'] ?? true);

          switchValues.value = [
            winkSwitch.value,
            lipLike.value,
            heartLikeSwitch.value,
            heartMessageSwitch.value,
            visitSwitch.value,
            wishSwitch.value,
            giftSwitch.value,
            offerSwitch.value
          ];
        } else {
          switchValues.value = [
            winkSwitch.value,
            lipLike.value,
            heartLikeSwitch.value,
            heartMessageSwitch.value,
            visitSwitch.value,
            wishSwitch.value,
            giftSwitch.value,
            offerSwitch.value
          ];
        }
      });
    }
  }

  Future<void> logout() async {
    Get.put(PictureController());
    Get.put(PriceController());
    print('isBlockLogoutLoading.value 00 :: ${isBlockLogoutLoading.value}');
    isBlockLogoutLoading.value = true;
    print('isBlockLogoutLoading.value 11 :: ${isBlockLogoutLoading.value}');
    _searchController.isPixLoad.value = false;
    _searchController.likeList.clear();
    _searchController.imagePostCount.clear();
    _searchController.wallPostCount.clear();
    _searchController.wallVideoPostCount.clear();
    _searchController.videoPostCount.clear();
    _searchController.finalPost.clear();
    _searchController.tempGetWallProfileId.clear();
    _searchController.parseObjectList.clear();
    _searchController.showNudeImage.clear();
    indexMuroList.clear();
    indexTokTokList.clear();
    _searchController.seenKeys.clear();
    pictureX.swiperIndex.value = 0;
    _searchController.page.value = 0;
    _searchController.load.value = false;
    priceController.userTotalCoin.value = 0;
    final ApiResponse apiResponse = await UserLoginProviderApi().getById(StorageService.getBox.read('ObjectId'));
    final String? token = Platform.isAndroid
        ? await FirebaseMessaging.instance.getToken()
        : (await FlutterCallkitIncoming.getDevicePushTokenVoIP()).toString().toUpperCase();

    final DateTime dateTime = await currentTime();
    final List tokenList = (apiResponse.result['deviceTokenCall'] ?? []);
    tokenList.removeWhere((element) => element.contains(token!));

    /// when offline user_login all this changes
    final UserLogin userLogin = UserLogin();
    userLogin.objectId = StorageService.getBox.read('ObjectId');
    userLogin.lastOnline = dateTime;
    userLogin.showOnline = false;
    userLogin.hasLoggedIn = false;
    // userLogin.noCalls = true;
    // userLogin.noChats = true;
    // userLogin.noVideocalls = true;
    if (tokenList.isNotEmpty) {
      userLogin['deviceTokenCall'] = tokenList;
    }
    await UserLoginProviderApi().update(userLogin);

    /// when offline user_profile default profile all this changes
    await updateLastOnlineProfile();

    // /// when user logout all profile status Deactive
    // for (var e in _searchController.profileData) {
    //   final ProfilePage profile = ProfilePage();
    //   profile.objectId = e['objectId'];
    //   profile.noCalls = true;
    //   profile.noChats = true;
    //   profile.noVideocalls = true;
    //   UserProfileProviderApi().update(profile);
    // }

    removeInstallation();
    try {
      final ParseUser currentUser = await ParseUser.currentUser();
      final response = await currentUser.logout();
      if (kDebugMode) {
        print('PARSE USER LOGOUT ${response.success}');
      }
      try {
        await FacebookAuth.instance.logOut();
        GoogleSignIn googleSignIn = GoogleSignIn(scopes: ["EMAIL"]);
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('USER LOGOUT ERROR $e');
      }
    }
    StorageService.getBox.erase();
    StorageService.wishBox.clear();
    StorageService.photosBox.clear();
    StorageService.profileBox.clear();
    Get.deleteAll();
    con.value = {}.obs;
    con.clear();
    isBlockLogoutLoading.value = false;
    Get.offAll(() => SplashScreenFirst());
  }

  void removeInstallation() async {
    if (Platform.isAndroid) {
      final ParseInstallation currentInstallation = await ParseInstallation.currentInstallation();
      currentInstallation.set('UserId', 'noUserLogout');
      final ParseResponse pr = await currentInstallation.save();
      if (kDebugMode) {
        print("Installation Entry remove Android: ${pr.result} error: ${pr.error}");
      }
    } else if (Platform.isIOS) {
      final value = await getIOSInstallation();
      final ParseObject installation = ParseObject('_Installation');
      installation.objectId = value["objectId"];
      installation.set('UserId', 'noUserLogout');
      final ParseResponse pr = await installation.save();
      if (kDebugMode) {
        print("Installation Entry remove IOS: ${pr.result} error: ${pr.error}");
      }
    }
  }

  button(ind) async {
    for (int i = 0; i < switchValues.length; i++) {
      if (i == ind) {
        switchValues[i] = !switchValues[i];
        if (i == 0) {
          userLogin.winkMessage = switchValues[i];
        }
        if (i == 1) {
          userLogin.lipLike = switchValues[i];
        }
        if (i == 2) {
          userLogin.heartLike = switchValues[i];
        }
        if (i == 3) {
          userLogin.heartMessage = switchValues[i];
        }
        if (i == 4) {
          userLogin.visit = switchValues[i];
        }
        if (i == 5) {
          userLogin.wish = switchValues[i];
        }
        if (i == 6) {
          userLogin.gift = switchValues[i];
        }
        if (i == 7) {
          userLogin.offer = switchValues[i];
        }
      }
      userLogin.objectId = StorageService.getBox.read('ObjectId');
      UserLoginProviderApi().update(userLogin).whenComplete(() {
        userdata();
      });
    }
  }

  RxList<ProfilePage> profileData = <ProfilePage>[].obs;

  /// for Real User (All Profile)
  statusChange(ind) async {
    if (ind == 0) {
      // AUDIO CALL
      noCalls.value = !noCalls.value;
      final UserLogin current = UserLogin();
      current.objectId = StorageService.getBox.read('ObjectId');
      current.noCalls = noCalls.value;
      UserLoginProviderApi().update(current); // user_login update

      for (var e in _searchController.profileData) {
        final ProfilePage profile = ProfilePage();
        profile.objectId = e['objectId'];
        profile.noCalls = noCalls.value;
        UserProfileProviderApi().update(profile);
      } // user_profile update
    }
    if (ind == 1) {
      // VIDEO CALL
      noVideocalls.value = !noVideocalls.value;
      final UserLogin current = UserLogin();
      current.objectId = StorageService.getBox.read('ObjectId');
      current.noVideocalls = noVideocalls.value;
      UserLoginProviderApi().update(current); // user_login update

      for (var e in _searchController.profileData) {
        final ProfilePage profile = ProfilePage();
        profile.objectId = e['objectId'];
        profile.noVideocalls = noVideocalls.value;
        UserProfileProviderApi().update(profile);
      } // user_profile update
    }
    if (ind == 2) {
      // CHAT
      noChats.value = !noChats.value;
      final UserLogin current = UserLogin();
      current.objectId = StorageService.getBox.read('ObjectId');
      current.noChats = noChats.value;
      UserLoginProviderApi().update(current); // user_login update

      for (var e in _searchController.profileData) {
        final ProfilePage profile = ProfilePage();
        profile.objectId = e['objectId'];
        profile.noChats = noChats.value;
        UserProfileProviderApi().update(profile);
      } // user_profile update
    }
  }

  /// for Fake User (Influencer) and ProfileWise (this change only for noCalls and noVideocalls)
  statusChangeInfluencer(ind) async {
    if (ind == 0) {
      // AUDIO CALL
      noCallsProfile.value = !noCallsProfile.value;
      final ProfilePage profile = ProfilePage();
      profile.objectId = StorageService.getBox.read('DefaultProfile');
      profile.noCalls = noCallsProfile.value;
      UserProfileProviderApi().update(profile); // user_profile update
    }

    if (ind == 1) {
      // VIDEO CALL
      noVideocallsProfile.value = !noVideocallsProfile.value;
      final ProfilePage profile = ProfilePage();
      profile.objectId = StorageService.getBox.read('DefaultProfile');
      profile.noVideocalls = noVideocallsProfile.value;
      UserProfileProviderApi().update(profile); // user_profile update
    }

    if (ind == 2) {
      // CHAT
      noChatsProfile.value = !noChatsProfile.value;
      final ProfilePage profile = ProfilePage();
      profile.objectId = StorageService.getBox.read('DefaultProfile');
      profile.noChats = noChatsProfile.value;
      UserProfileProviderApi().update(profile); // user_profile update
    }
  }
}
