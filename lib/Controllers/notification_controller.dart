import 'dart:io';

import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/PairNotificationController/pair_notification_controller.dart';
import 'package:eypop/Controllers/bottom_controller.dart';
import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/Controllers/setting_controllers.dart';
import 'package:eypop/Controllers/tab_Controller/conversation_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/repositories/Calls/call_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/ui/User_profile/user_fullprofile_screen.dart';
import 'package:eypop/ui/block_screen.dart';
import 'package:eypop/ui/login_registration_screens/deleted_screen.dart';
import 'package:eypop/ui/splash_screen_first.dart';
import 'package:eypop/ui/store_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constant/translate.dart';
import '../service/local_storage.dart';
import '../ui/bottom_screen.dart';
import '../ui/notification_pages/calles_screen.dart';
import '../ui/tab_pages/conversation_screen.dart';

class NotificationController extends GetxController {
  final AppSearchController _searchController = Get.put(AppSearchController());

  String? notificationLocalText(alert, ApiResponse user) {
    final Languages lan = Languages();
    String local = 'es';

    if (user.result != null) {
      if (kDebugMode) {
        print('Hello opposite language ${user.result['Local']}');
      }
      local = user.result['Local'] ?? 'es';
    }

    switch (alert) {
      case 'send you liplike':
        {
          return lan.keys[local]!['send_you_liplike'];
        }
      case 'send you heartlike':
        {
          return lan.keys[local]!['send_you_heartlike'];
        }
      case 'send you a Wink':
        {
          return lan.keys[local]!['send_you_a_Wink'];
        }
      case 'send you Heart Message':
        {
          return lan.keys[local]!['send_you_Heart_Message'];
        }
      case 'send you Chat Message':
        {
          return lan.keys[local]!['send_you_Chat_Message'];
        }
      case 'Calling you':
        {
          return lan.keys[local]!['calling_you'];
        }
      case 'Visit Your profile':
        {
          return lan.keys[local]!['Visit_Your_profile'];
        }
      case 'full fill your toktok':
        {
          return lan.keys[local]!['full_fill_your_toktok'];
        }
      case 'send you Gift':
        {
          return lan.keys[local]!['Send_You_Gift'];
        }
      default:
        {
          return '';
        }
    }
  }

  void parseCloudNotification(userId, alert, toProfileId, fromProfileId) async {
    final ProfilePage userProfile = await UserProfileProviderApi().getByIdNotification(fromProfileId);
    final ApiResponse user = await UserLoginProviderApi().getById(userId);
    final List<String> ids = [userId];
    final ParseCloudFunction function = ParseCloudFunction('sendPush');
    final Map<String, dynamic> params = <String, dynamic>{
      'alert': notificationLocalText(alert, user),
      'translatedAlert': alert,
      'title': userProfile.name,
      'senderId': userProfile.userId.objectId!,
      'senderName': userProfile.name,
      'avatar': userProfile.imgProfile.url!,
      'UserId': ids,
      'FromProfileId': userProfile.objectId,
      'ToProfileId': toProfileId,
    };
    final ParseResponse parseResponse = await function.execute(parameters: params);
    print("🔔 Hello Notification cloud function: sendPush code:[${parseResponse.statusCode}] result: ${parseResponse.result}");
  }

  ///
  /// This Function navigate you to specific route that gets from the notification
  ///
  ///
  /// Param [type],[senderId],[fromProfileId],[toProfileId],[name],[pic],[context]
  ///
  /// **return** screen that you need to route.
  ///
  void navigationSwitch(String type, senderId, fromProfileId, toProfileId, name, pic, context) async {
    final PairNotificationController pairNotificationController = Get.put(PairNotificationController());

    final ApiResponse jay = await UserLoginProviderApi().getById(senderId);
    switch (type) {
      case 'send you liplike':
        {
          if (kDebugMode) {
            print('Notification type $type');
          }
          Get.to(() => CallScreen(newTitle: 'kisses'.tr, noTitle: 'no_kiss'.tr, type: 'LipLike', title: "Besos", showNumber: false));
        }
        break;
      case 'send you heartlike':
        {
          if (kDebugMode) {
            print('Notification type $type');
          }
          Get.to(() => UserFullProfileScreen(toUserId: jay.result, toProfileId: fromProfileId, fromProfileId: toProfileId));
        }
        break;
      case 'send you a Wink':
        {
          if (kDebugMode) {
            print('Notification type $type');
          }
          Get.to(() => CallScreen(newTitle: 'winks'.tr, noTitle: 'no_wink'.tr, type: 'WinkMessage', title: 'Guiños', showNumber: false));
        }
        break;
      case 'full fill your toktok':
        {
          if (kDebugMode) {
            print('Notification type $type');
          }
          Get.to(() => CallScreen(newTitle: 'TokTok', noTitle: 'no_TokTok'.tr, type: 'Wishes', title: 'wishes', showNumber: false));
        }
        break;
      case 'send you Heart Message':
        {
          if (kDebugMode) {
            print('Notification type $type');
            print('user profile Id $fromProfileId');
          }
          final ApiResponse profile = await UserProfileProviderApi().getById(fromProfileId);
          StorageService.getBox.write('msgToProfileId', fromProfileId);
          StorageService.getBox.write('msgFromProfileId', toProfileId);
          StorageService.getBox.write('chattablename', "Like_Message");
          final ApiResponse apiResponse = await UserProfileProviderApi().getById(toProfileId);

          if (Get.currentRoute == '/ConversationScreen') {
            Get.delete<ConversationController>();
            Get.back();
          }
          Get.to(() => ConversationScreen(
                fromUserDeleted: false,
                toUserDeleted: ((profile.result['isDeleted'] ?? false) ||
                    (profile.result['User']['isDeleted'] ?? false) ||
                    (pairNotificationController.meBlocked.toString().contains(fromProfileId) &&
                        pairNotificationController.meBlocked.toString().contains(toProfileId))),
                // update block
                description: profile.result['Description'],
                toUser: jay.result,
                tableName: 'Like_Message',
                toProfileName: name,
                toProfileImg: pic,
                onlineStatus: true,
                toProfileId: fromProfileId,
                fromProfileId: toProfileId,
                toUserId: senderId,
                toUserGender: jay.result['Gender'],
                fromUserImg: apiResponse.result['Imgprofile'].url,
              ));
        }
        break;
      case 'send you Chat Message':
        {
          if (kDebugMode) {
            print('Notification type $type');
          }
          StorageService.getBox.write('msgToProfileId', fromProfileId);
          StorageService.getBox.write('msgFromProfileId', toProfileId);
          StorageService.getBox.write('chattablename', "Chat_Message");
          final ApiResponse apiResponse = await UserProfileProviderApi().getById(toProfileId);

          if (Get.currentRoute == '/ConversationScreen') {
            Get.delete<ConversationController>();
            Get.back();
          }
          Get.to(() => ConversationScreen(
                fromUserDeleted: false,
                toUserDeleted: ((jay.result['isDeleted'] ?? false) ||
                    (pairNotificationController.meBlocked.toString().contains(fromProfileId) &&
                        pairNotificationController.meBlocked.toString().contains(toProfileId))),
                // update block
                toUser: jay.result,
                toUserGender: jay.result['Gender'],
                tableName: 'Chat_Message',
                toProfileName: name,
                toProfileImg: pic,
                onlineStatus: true,
                toProfileId: fromProfileId,
                fromProfileId: toProfileId,
                toUserId: senderId,
                fromUserImg: apiResponse.result['Imgprofile'].url,
              ));
        }
        break;
      case 'send you Gift':
        {
          if (kDebugMode) {
            print('Notification type $type');
          }
          StorageService.getBox.write('msgToProfileId', fromProfileId);
          StorageService.getBox.write('msgFromProfileId', toProfileId);
          StorageService.getBox.write('chattablename', "Chat_Message");
          final ApiResponse apiResponse = await UserProfileProviderApi().getById(toProfileId);

          if (Get.currentRoute == '/ConversationScreen') {
            Get.delete<ConversationController>();
            Get.back();
          }
          Get.to(() => ConversationScreen(
                fromUserDeleted: false,
                toUserDeleted: ((jay.result['isDeleted'] ?? false) ||
                    (pairNotificationController.meBlocked.toString().contains(fromProfileId) &&
                        pairNotificationController.meBlocked.toString().contains(toProfileId))),
                // update block
                toUser: jay.result,
                toUserGender: jay.result['Gender'],
                tableName: 'Chat_Message',
                toProfileName: name,
                toProfileImg: pic,
                onlineStatus: true,
                toProfileId: fromProfileId,
                fromProfileId: toProfileId,
                toUserId: senderId,
                fromUserImg: apiResponse.result['Imgprofile'].url,
              ));
        }
        break;
      case 'Calling you':
        {
          if (kDebugMode) {
            print('Notification type $type');
          }
          Get.to(() => UserFullProfileScreen(toUserId: jay.result, toProfileId: fromProfileId, fromProfileId: toProfileId));
        }
        break;
      default:
        {
          if (kDebugMode) {
            print('Notification type default');
          }
          if (Get.currentRoute == '/ConversationScreen') {
            Get.to(() => UserFullProfileScreen(toUserId: jay.result, toProfileId: fromProfileId, isNotification: true, fromProfileId: toProfileId));
          } else {
            Get.to(() => UserFullProfileScreen(toUserId: jay.result, toProfileId: fromProfileId, fromProfileId: toProfileId));
          }
        }
        break;
    }
  }

  @override
  Future<void> onInit() async {
    if (StorageService.getBox.read('ObjectId') != null) {
      if (_searchController.profileData.isEmpty) {
        await UserProfileProviderApi().userProfileQuery(StorageService.getBox.read('ObjectId')).then((value) {
          if (value != null && value.results != null) {
            for (final ele in value.results ?? []) {
              if (!_searchController.profileObjectData.toString().contains(ele['objectId'])) {
                _searchController.profileData.add(ele);
                _searchController.profileObjectData.add(ele['objectId']);
              }
            }
          }
        });
      }
      blockCheck();
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (localVersion < newAppVersion) {
        showAlertDialog(
          Get.context,
          title: 'update_from_store'.tr.replaceAll('xxx', Platform.isIOS ? 'AppStore' : 'PlayStore'),
          buttonText: 'update'.tr,
          onTap: () async {
            final appId = Platform.isAndroid ? 'com.actuajeriko.eypop' : '1628570550';
            final url = Uri.parse(
              Platform.isAndroid ? "market://details?id=$appId" : "https://apps.apple.com/app/id$appId",
            );
            await launchUrl(url);
          },
        );
      }
    });
    super.onInit();
  }

  void blockCheck() async {
    final ApiResponse apiResponse = await UserLoginProviderApi().getById(StorageService.getBox.read('ObjectId'));
    if (apiResponse.result != null) {
      StorageService.getBox.write('Gender', apiResponse.result['Gender']);
      StorageService.getBox.write('AccountType', apiResponse.result['AccountType']);
      if (apiResponse.result['isDeleted'] == true) {
        Get.offAll(() => DeletedAccountScreen());
        StorageService.getBox.write('isDeleted', true);
      } else if (apiResponse.result['IsBlocked'] == true) {
        if (apiResponse.result['BlockDays'] == 'block_permanent') {
          Get.offAll(() => BlockScreen(
                text1: 'permanent_block'.tr,
                text2: 'delete_reason'.tr,
                reason: apiResponse.result["BlockReason"] ?? 'ok'.tr,
                onTap: () {
                  SettingController().logout();
                },
              ));
        } else {
          final DateTime date = apiResponse.result['BlockEndDate'];
          final DateTime currentDate = await currentTime();
          final difference = date.difference(currentDate).inDays;
          if (!currentDate.isBefore(date)) {
            final UserLogin userLogin = UserLogin();
            userLogin.objectId = apiResponse.result['objectId'];
            userLogin.isDeleted = false;
            userLogin['BlockEndDate'] = apiResponse.result['BlockStartDate'];
            userLogin['BlockDays'] = '0';
            await UserLoginProviderApi().update(userLogin);
            Get.offAll(() => SplashScreenFirst());
          } else {
            Get.offAll(() => BlockScreen(
                  text1: '${'account_blocked'.tr} $difference ${'days'.tr}',
                  text2: 'delete_reason'.tr,
                  reason: apiResponse.result["BlockReason"] ?? 'ok'.tr,
                  onTap: () {
                    SettingController().logout();
                  },
                ));
          }
        }
      }
    }
  }

  void notificationNavSwitch(oriType, type, senderId, fromProfileId, toProfileId, name, pic, advertisementUrl) async {
    final PairNotificationController pairNotificationController = Get.put(PairNotificationController());
    late ApiResponse fullUser;

    if (senderId != null) {
      fullUser = await UserLoginProviderApi().getById(senderId);
    }
    if (_searchController.profileData.isEmpty) {
      await UserProfileProviderApi().userProfileQuery(StorageService.getBox.read('ObjectId')).then((value) {
        if (value != null && value.results != null) {
          for (final ele in value.results ?? []) {
            if (!_searchController.profileObjectData.toString().contains(ele['objectId'])) {
              _searchController.profileData.add(ele);
              _searchController.profileObjectData.add(ele['objectId']);
            }
          }
        }
      });
    }
    if (fromProfileId != null) {
      if (pairNotificationController.meBlocked.toString().contains(fromProfileId) &&
          pairNotificationController.meBlocked.toString().contains(toProfileId)) {
        oriType = '';
      }
    }
    print('Notification type OriType: $oriType -- Type $type');
    switch (oriType) {
      case 'send you liplike':
        {
          Get.to(() => CallScreen(newTitle: 'kisses'.tr, noTitle: 'no_kiss'.tr, type: 'LipLike', title: "Besos", showNumber: false, visitType: true));
        }
        break;
      case 'full fill your toktok':
        {
          Get.to(() => CallScreen(newTitle: 'TokTok', noTitle: 'no_TokTok'.tr, type: 'Wishes', title: 'wishes', showNumber: false, visitType: true));
        }
        break;
      case 'Visit Your profile':
        {
          Get.offAll(() => UserFullProfileScreen(visitType: true, toUserId: fullUser.result, toProfileId: fromProfileId, fromProfileId: toProfileId));
        }
        break;
      case 'send you heartlike':
        {
          Get.offAll(() => UserFullProfileScreen(visitType: true, toUserId: fullUser.result, toProfileId: fromProfileId, fromProfileId: toProfileId));
        }
        break;
      case 'send you a Wink':
        {
          Get.to(() => CallScreen(
                newTitle: 'winks'.tr,
                noTitle: 'no_wink'.tr,
                visitType: true,
                type: 'WinkMessage',
                title: 'Guiños',
                showNumber: false,
              ));
        }
        break;
      case 'send you Heart Message':
        {
          final ApiResponse fromProfile = await UserProfileProviderApi().getById(fromProfileId);
          StorageService.getBox.write('msgToProfileId', fromProfileId);
          StorageService.getBox.write('msgFromProfileId', toProfileId);
          StorageService.getBox.write('chattablename', "Like_Message");
          final ApiResponse toProfile = await UserProfileProviderApi().getById(toProfileId);
          Get.offAll(() => ConversationScreen(
                fromUserDeleted: false,
                toUserDeleted: ((fromProfile.result['isDeleted'] ?? false) || (fromProfile.result['User']['isDeleted'] ?? false)),
                description: fromProfile.result['Description'],
                visitType: true,
                toUser: fullUser.result,
                tableName: 'Like_Message',
                toProfileName: name,
                toProfileImg: pic,
                onlineStatus: true,
                toProfileId: fromProfileId,
                fromProfileId: toProfileId,
                toUserId: fullUser.result['objectId'],
                toUserGender: fullUser.result['Gender'],
                fromUserImg: toProfile.result['Imgprofile'].url,
              ));
        }
        break;
      case 'send you Chat Message':
        {
          StorageService.getBox.write('msgToProfileId', fromProfileId);
          StorageService.getBox.write('msgFromProfileId', toProfileId);
          StorageService.getBox.write('chattablename', "Chat_Message");
          final ApiResponse toProfile = await UserProfileProviderApi().getById(toProfileId);
          Get.offAll(() => ConversationScreen(
                fromUserDeleted: false,
                toUserDeleted: fullUser.result['isDeleted'] ?? false,
                visitType: true,
                toUserGender: fullUser.result["Gender"],
                toUser: fullUser.result,
                tableName: 'Chat_Message',
                toProfileName: name,
                toProfileImg: pic,
                onlineStatus: true,
                toProfileId: fromProfileId,
                fromProfileId: toProfileId,
                toUserId: fullUser.result['objectId'],
                fromUserImg: toProfile.result['Imgprofile'].url,
              ));
        }
        break;
      case 'send you Gift':
        {
          StorageService.getBox.write('msgToProfileId', fromProfileId);
          StorageService.getBox.write('msgFromProfileId', toProfileId);
          StorageService.getBox.write('chattablename', "Chat_Message");
          final ApiResponse toProfile = await UserProfileProviderApi().getById(toProfileId);
          Get.offAll(() => ConversationScreen(
                fromUserDeleted: false,
                toUserDeleted: fullUser.result['isDeleted'] ?? false,
                visitType: true,
                toUserGender: fullUser.result["Gender"],
                toUser: fullUser.result,
                tableName: 'Chat_Message',
                toProfileName: name,
                toProfileImg: pic,
                onlineStatus: true,
                toProfileId: fromProfileId,
                fromProfileId: toProfileId,
                toUserId: fullUser.result['objectId'],
                fromUserImg: toProfile.result['Imgprofile'].url,
              ));
        }
        break;
      case 'Calling you':
        {
          final apiResponse = await UserCallProviderApi().getCallsFromToUser(senderId);
          if (apiResponse.result['IsCallEnd'] == false) {
          } else {
            Get.offAll(
                () => UserFullProfileScreen(visitType: true, toUserId: fullUser.result, toProfileId: fromProfileId, fromProfileId: toProfileId));
          }
        }
        break;
      case 'go_internal_link':
        {
          if (StorageService.getBox.read('Gender') == 'male') {
            // data load for StoreScreen delay 1 second
            Get.put(BottomControllers());
            Future.delayed(
                const Duration(seconds: 1),
                () => Get.to(() => StoreScreen(
                      isFromNotification: true,
                    )));
          }
        }
        break;
      case 'go_advertisement':
        {
          final Uri uri = Uri.parse(advertisementUrl);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          Get.offAll(() => BottomScreen());
        }
        break;
      default:
        {
          Get.offAll(() => BottomScreen());
        }
    }
  }
}