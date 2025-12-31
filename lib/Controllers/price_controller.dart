import 'dart:async';

import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/Picture_Controller/profile_pic_controller.dart';
import 'package:eypop/Controllers/all_notification_controller/all_notification_controller.dart';
import 'package:eypop/Controllers/tab_Controller/conversation_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/user_provider/coins/provider_prices_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/models/all_notifications/all_notifications.dart';
import 'package:eypop/models/new_notification/new_notification_pair.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../back4appservice/repositories/Calls/call_provider_api.dart';
import '../back4appservice/user_provider/all_notifications/all_notifications.dart';
import '../back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import '../back4appservice/user_provider/tab_provider/visits.dart';
import '../back4appservice/user_provider/users/provider_profileuser_api.dart';
import '../models/user_login/user_login.dart';
import '../models/user_login/user_post.dart';
import '../models/user_login/user_postvideo.dart';
import '../models/user_login/user_profile.dart';
import '../ui/User_profile/user_fullprofile_screen.dart';
import '../ui/store_screen.dart';
import 'PairNotificationController/pair_notification_controller.dart';
import 'notification_controller.dart';

class PriceController extends GetxController {
  final PictureController pictureX = Get.put(PictureController());
  final NotificationController _notificationController = Get.put(NotificationController());

  @override
  Future<void> onInit() async {
    getAllPrices();
    super.onInit();
  }

  String getFormattedTime(Duration totalSeconds) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final days = totalSeconds.inDays;
    final hours = twoDigits(totalSeconds.inHours.remainder(24));
    final minutes = twoDigits(totalSeconds.inMinutes.remainder(60));
    final seconds = twoDigits(totalSeconds.inSeconds.remainder(60));

    if (days == 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${days.toString().padLeft(2, '0')}:'
          '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  final TextEditingController chat = TextEditingController();
  final RxInt heartLikePrice = 0.obs;
  final RxInt lipLikePrice = 0.obs;
  final RxInt heartMessagePrice = 0.obs;
  final RxInt callPrice = 0.obs;
  final RxInt videoCallPrice = 0.obs;
  final RxInt chatMessagePrice = 0.obs;
  final RxInt winkMessagePrice = 0.obs;
  final RxInt userTotalCoin = 0.obs;

  // final RxInt videoPrice = 0.obs;
  // final RxInt imagePrice = 0.obs;
  final RxInt createProfile = 0.obs;
  final RxInt createGirlProfile = 0.obs;
  final RxBool isPurchase = false.obs;
  final RxBool isShowConnectCallButton = false.obs;
  final RxBool isGiftSending = false.obs;

  /// GIRLS TOKENS
  final RxInt chatGirlMessageToken = 0.obs;
  final RxInt heartGirlMessageToken = 0.obs;
  final RxInt callGirlToken = 0.obs;
  final RxInt videoCalGirlToken = 0.obs;
  final RxInt winkGirlToken = 0.obs;
  final RxInt lipLikeGirlToken = 0.obs;
  final RxInt giftGirlToken = 0.obs;

  /// PAYMENT
  final RxBool payPalEnable = false.obs;
  final RxString payPalUrl = "".obs;
  final RxString cardUrl = "".obs;
  final RxBool cardEnable = false.obs;

  Future<void> getAllPrices({ApiResponse? login}) async {
    ApiResponse? loginResponse = login;
    if (login == null) {
      if (StorageService.getBox.read('ObjectId') != null) {
        loginResponse = await UserLoginProviderApi().getById(StorageService.getBox.read('ObjectId'));
      }
    }
    if (loginResponse != null && loginResponse.success) {
      if (StorageService.getBox.read('Gender') == 'male') {
        userTotalCoin.value = (loginResponse.result['TotalCoin'] ?? 0);
      } else {
        userTotalCoin.value = (loginResponse.result['TotalToken'] ?? 0);
        chatGirlMessageToken.value = (loginResponse.result['ChatMessageToken'] ?? 0);
        heartGirlMessageToken.value = (loginResponse.result['HeartMessageToken'] ?? 0);
        callGirlToken.value = (loginResponse.result['CallToken'] ?? 0);
        videoCalGirlToken.value = (loginResponse.result['VideoCallToken'] ?? 0);
        winkGirlToken.value = (loginResponse.result['WinkMessageToken'] ?? 0);
        lipLikeGirlToken.value = (loginResponse.result['LipLikeToken'] ?? 0);
        giftGirlToken.value = (loginResponse.result['GiftToken'] ?? 0);
      }
    }
    final ApiResponse prices = await PricesProviderApi().getAll();
    chatMessagePrice.value = prices.result['ChatMessage'];
    heartMessagePrice.value = prices.result['HeartMessage'];
    callPrice.value = prices.result['Call'];
    videoCallPrice.value = prices.result['VideoCall'];
    winkMessagePrice.value = prices.result['WinkMessage'];
    heartLikePrice.value = prices.result['HeartLike'];
    lipLikePrice.value = prices.result['LipLike'];
    // imagePrice.value = prices.result['ImagePrice'];
    // videoPrice.value = prices.result['VideoPrice'];
    createProfile.value = prices.result['CreateProfile'];
    createGirlProfile.value = prices.result['CreateGirlProfile'];
    getPaymentData();
  }

  /// PAYMENT METHOD
  Future<void> getPaymentData() async {
    String? country = Get.deviceLocale!.countryCode;
    if (country == "GB") {
      country = 'ES';
    }
    final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Country'))..whereEqualTo('CountryCode', country);
    final apiResponse = await query.query();
    if (apiResponse.results != null) {
      final List methodTypes = (apiResponse.result[0]['Types'] ?? []);
      payPalUrl.value = (apiResponse.result[0]['PayPalUrl'] ?? "");
      cardUrl.value = (apiResponse.result[0]['VisaUrl'] ?? "");
      payPalEnable.value = methodTypes.toString().toLowerCase().contains('paypal');
      cardEnable.value = methodTypes.toString().toLowerCase().contains('card');
    }
  }

  /// ParseObject? giftObject ---> when chat with [Gift] pass this
  /// String? chatType ---> [Gift, Video, Image]
  /// Map<String, dynamic>? postMap
  /// --> chatType = [Video] EX:{'image': base64Encode(List<int> bytes), 'video': base64Encode(base64Encode(List<int> bytes), 'isLandscape': bool}
  /// --> chatType = [Image] EX:{'image': base64Encode(List<int> bytes), 'isLandscape': bool}
  Future<dynamic> coinService(category, toUserGender, toProfile, toUser,
      {String? wishId,
      required int catValue,
      String? tableName,
      String? postId,
      UserPost? imgPost,
      UserPostVideo? videoPost,
      ParseObject? giftObject,
      String? chatType,
      Map<String, dynamic>? postMap,
      String? fromProfile}) async {
    fromProfile ?? StorageService.getBox.read('DefaultProfile');
    if (StorageService.getBox.read('Gender') == 'male') {
      if (kDebugMode) {
        print('we are male');
      }
      if (toUserGender == 'female') {
        if (userTotalCoin.value >= catValue ||
            category == 'HeartMessage' ||
            category == 'WinkMessage' ||
            tableName == 'Like_Message' ||
            category == 'Wishes') {
          if (kDebugMode) {
            print('Coin Greater than price');
          }
          switch (category) {
            case 'LipLike':
              {
                liplike(toUser, toProfile, fromProfile);
              }
              break;

            case 'HeartLike':
              {
                await heartlike(toUser, toProfile, postId: postId);
              }
              break;
            case 'WinkMessage':
              {
                winkMessage(toUser, toProfile, fromProfile);
              }
              break;

            case 'HeartMessage':
              {
                await heartMessage(toUser, toProfile, fromProfile);
              }
              break;

            case 'ChatMessage':
              {
                return await chatMessage(toUser, toProfile, fromProfile,
                    tableName: tableName, giftObject: giftObject, chatType: chatType!, postMap: postMap);
              }
            case 'Call':
              {
                coinCall(toUser, StorageService.getBox.read('ObjectId'), catValue: catValue);
              }
              break;
            // VIDEO CALL
            case 'VideoCall':
              {
                coinVideoCall(toUser, StorageService.getBox.read('ObjectId'), catValue: catValue);
              }
              break;

            case 'ImagePurchase':
              {
                imagePurchase(toUser, toProfile, imgPost);
              }
              break;
            case 'VideoPurchase':
              {
                await videoPurchase(toUser, toProfile, videoPost);
              }
              break;

            case 'Wishes':
              {
                return await wishCreate(toUser, toProfile, wishId);
              }
            default:
              {}
              break;
          }
        } else {
          if (kDebugMode) {
            print('You Need To Add Coin');
          }
          Get.to(() => StoreScreen());
        }
      } else {
        if (kDebugMode) {
          print('same walo male');
        }
        switch (category) {
          case 'LipLike':
            {
              liplike(toUser, toProfile, fromProfile);
            }
            break;

          case 'HeartLike':
            {
              await heartlike(toUser, toProfile, postId: postId);
            }
            break;

          case 'WinkMessage':
            {
              winkMessage(toUser, toProfile, fromProfile);
            }
            break;

          case 'HeartMessage':
            {
              heartMessage(toUser, toProfile, fromProfile);
            }
            break;

          case 'ChatMessage':
            {
              return await chatMessage(toUser, toProfile, fromProfile,
                  tableName: tableName, giftObject: giftObject, chatType: chatType!, postMap: postMap);
            }
          case 'Call':
            {
              coinCall(toUser, StorageService.getBox.read('ObjectId'), catValue: catValue);
            }
            break;
          // VIDEO CALL
          case 'VideoCall':
            {
              coinVideoCall(toUser, StorageService.getBox.read('ObjectId'), catValue: catValue);
            }
            break;
          case 'ImagePurchase':
            {
              imagePurchase(toUser, toProfile, imgPost);
            }
            break;
          case 'VideoPurchase':
            {
              await videoPurchase(toUser, toProfile, videoPost);
            }
            break;
          case 'Wishes':
            {
              return await wishCreate(toUser, toProfile, wishId);
            }
          default:
            {}
            break;
        }
      }
    } else {
      if (kDebugMode) {
        print('we are female');
      }
      switch (category) {
        case 'LipLike':
          {
            liplike(toUser, toProfile, fromProfile);
          }
          break;

        case 'HeartLike':
          {
            await heartlike(toUser, toProfile, postId: postId);
          }
          break;

        case 'WinkMessage':
          {
            winkMessage(toUser, toProfile, fromProfile);
          }
          break;

        case 'HeartMessage':
          {
            heartMessage(toUser, toProfile, fromProfile);
          }
          break;

        case 'ChatMessage':
          {
            return await chatMessage(toUser, toProfile, fromProfile,
                tableName: tableName, giftObject: giftObject, chatType: chatType!, postMap: postMap);
          }
        case 'Call':
          {
            coinCall(toUser, StorageService.getBox.read('ObjectId'), catValue: catValue);
          }
          break;
        // VIDEO CALL
        case 'VideoCall':
          {
            coinVideoCall(toUser, StorageService.getBox.read('ObjectId'), catValue: catValue);
          }
          break;
        case 'ImagePurchase':
          {
            imagePurchase(toUser, toProfile, imgPost);
          }
          break;
        case 'VideoPurchase':
          {
            await videoPurchase(toUser, toProfile, videoPost);
          }
          break;
        case 'Wishes':
          {
            return await wishCreate(toUser, toProfile, wishId);
          }
        default:
          {}
          break;
      }
    }
    return 'Fail';
  }

  Future<void> liplike(toUser, toProfile, String? fromProfileId) async {
    fromProfileId ??= StorageService.getBox.read('DefaultProfile');
    pictureX.visible.value = true;
    final value = await parseCloudInteraction(
      fromUserId: StorageService.getBox.read('ObjectId'),
      toUserId: toUser,
      toProfileId: toProfile,
      type: 'sendLipLike',
      fromProfileId: fromProfileId,
    );

    if (value['success'] == false) {
      if (value['message'] == 'User has no coins') {
        Get.to(() => StoreScreen());
      }
    } else if (value['success'] == true) {
      final ApiResponse toUserAllData = await UserLoginProviderApi().getById(toUser);

      ///Notification
      if (toUserAllData.result['LipLikeNotification']) {
        _notificationController.parseCloudNotification(toUser, 'send you liplike', toProfile, fromProfileId!);
      }
    }
    Future.delayed(const Duration(milliseconds: 2000), () {
      pictureX.visible.value = false;
    });
  }

  Future<ApiResponse> wishCreate(toUser, toProfile, wishId) async {
    final PairNotifications pairNotifications = PairNotifications();
    pairNotifications.toProfile = ProfilePage()..objectId = toProfile;
    pairNotifications.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
    pairNotifications.users = [ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'), ProfilePage()..objectId = toProfile];
    pairNotifications.message = '';
    pairNotifications.notificationType = 'Wishes';
    pairNotifications.isPurchased = true;
    pairNotifications.isRead = true;
    pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
    pairNotifications.toUser = UserLogin()..objectId = toUser;
    pairNotifications['Wishes'] = ParseObject('Wishes_List')..objectId = wishId;

    final ApiResponse response = await PairNotificationProviderApi().add(pairNotifications);
    Notifications notifications = Notifications();
    notifications.toUser = UserLogin()..objectId = toUser;
    notifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
    notifications.toProfile = ProfilePage()..objectId = toProfile;
    notifications.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
    notifications.notificationType = 'Wishes';
    notifications.isRead = false;

    await NotificationsProviderApi().add(notifications);

    final ApiResponse toUserAllData = await UserLoginProviderApi().getById(toUser);

    if (toUserAllData.result['wishNotification'] ?? true) {
      _notificationController.parseCloudNotification(toUser, 'full fill your toktok', toProfile, StorageService.getBox.read('DefaultProfile'));
    }
    return response;
  }

  Future<void> heartlike(toUser, toProfile, {String? postId}) async {
    await Future.delayed(const Duration(milliseconds: 1000), () {});
    final value = await parseCloudInteraction(
      fromUserId: StorageService.getBox.read('ObjectId'),
      fromProfileId: StorageService.getBox.read('DefaultProfile'),
      toUserId: toUser,
      toProfileId: toProfile,
      type: 'sendHeartLike',
      postId: postId,
    );
    if (value['success'] == true) {
      final ApiResponse toUserAllData = await UserLoginProviderApi().getById(toUser);
      if (toUserAllData.result['HeartLikeNotification']) {
        _notificationController.parseCloudNotification(toUser, 'send you heartlike', toProfile, StorageService.getBox.read('DefaultProfile'));
      }
    }
  }

  Future<void> winkMessage(toUser, toProfile, String? fromProfileId) async {
    fromProfileId ??= StorageService.getBox.read('DefaultProfile');
    pictureX.winkvisible.value = true;
    Future.delayed(const Duration(milliseconds: 2000), () {
      pictureX.winkvisible.value = false;
    });
    final value = await parseCloudInteraction(
      fromUserId: StorageService.getBox.read('ObjectId'),
      toUserId: toUser,
      toProfileId: toProfile,
      type: 'sendWinkMessage',
      message: pictureX.winkMsg.text,
      fromProfileId: fromProfileId,
    );
    Get.back();
    pictureX.winkMsg.clear();
    if (value['success'] == true) {
      final ApiResponse toUserAllData = await UserLoginProviderApi().getById(toUser);

      if (toUserAllData.result['WinkMessageNotification']) {
        _notificationController.parseCloudNotification(toUser, 'send you a Wink', toProfile, fromProfileId!);
      }
    }
  }

  Future<void> heartMessage(toUser, toProfile, String? fromProfileId) async {
    fromProfileId ??= StorageService.getBox.read('DefaultProfile');
    pictureX.messagevisible.value = true;
    Get.back();
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat.jm().format(now);
    final outputFormat = DateFormat('MM/dd/yyyy');
    final outputDate = outputFormat.format(now);
    final value = await parseCloudInteraction(
      fromUserId: StorageService.getBox.read('ObjectId'),
      toUserId: toUser,
      toProfileId: toProfile,
      type: 'sendHeartMessage',
      message: pictureX.spam.text,
      time: '$outputDate a las$formattedTime',
      fromProfileId: fromProfileId,
    );
    if (value['success'] == false) {
      if (value['message'] == 'User has no coins') {
        Get.to(() => StoreScreen());
      }
    } else if (value['success'] == true) {
      final ApiResponse toUserAllData = await UserLoginProviderApi().getById(toUser);

      if (toUserAllData.result['HeartMessageNotification']) {
        _notificationController.parseCloudNotification(toUser, 'send you Heart Message', toProfile, fromProfileId!);
      }
    }
    pictureX.spam.clear();
    Future.delayed(const Duration(milliseconds: 2000), () {
      pictureX.messagevisible.value = false;
    });
  }

  ConversationController get _conversationController => Get.find<ConversationController>();

  Future<String?> chatMessage(toUser, toProfile, fromProfile,
      {tableName, ParseObject? giftObject, required String chatType, Map<String, dynamic>? postMap}) async {
    /// 1. Gifts pointer ,Type string [gift] in Chat_Message
    /// 2. Type string [image,video,text], Post, PostThumbnail File in Chat_Message
    /// 3. in PairNotifications [Chat_Message] pointer
    /// 4. in PairNotifications [Like_Message] pointer

    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat.jm().format(now);
    final outputFormat = DateFormat('MM/dd/yyyy');
    final outputDate = outputFormat.format(now);
    final String localChat = chat.text;
    chat.clear();
    if (tableName == 'Chat_Message') {
      String tempUniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      print('localChat :::: $localChat');
      if (localChat.isNotEmpty) {
        _conversationController.tempSendMessage.value
          ..set('objectId', tempUniqueId)
          ..set('createdAt', DateTime.now())
          ..set('isRead', false)
          ..set('Gifts', {})
          ..set('Message', localChat);
        // print('localChat :::: $localChat');
        print('_conversationController.tempSendMessage.value :::: ${_conversationController.tempSendMessage.value}');
        _conversationController.addConversation(parseObject: _conversationController.tempSendMessage.value, fromLive: true);
        _conversationController.tempSendMessageTempUniqueId.add(tempUniqueId);
      }

      // print('tempSendMessage ::: ${_conversationController.tempSendMessage.value.toJson()}');
      // print('tempSendMessage isRead ::: ${ _conversationController.tempSendMessageTempUniqueId}');
      // print('hello data ----------- chat message');
      final value = await parseCloudInteraction(
        fromUserId: StorageService.getBox.read('ObjectId'),
        toUserId: toUser,
        toProfileId: toProfile,
        tempUniqueId: tempUniqueId,
        type: 'sendChats',
        chatType: chatType,
        giftObject: giftObject,
        postMap: postMap,
        message: giftObject != null ? giftObject['Image'].url : localChat,
        time: '$outputDate a las$formattedTime',
        fromProfileId: fromProfile,
      );

      if (value['success'] == false) {
        if (value['message'] == 'User has no coins') {
          Get.to(() => StoreScreen());
        }
      } else if (value['success'] == true) {
        if (giftObject != null) {
          isGiftSending.value = true;
        }
        final ApiResponse toUserAllData = await UserLoginProviderApi().getById(toUser);
        final UserLogin userLogin = UserLogin();
        userLogin.objectId = StorageService.getBox.read('ObjectId');
        userLogin['UnanswerChat'] = 0;
        UserLoginProviderApi().update(userLogin);

        // Notification for gift chat
        if ((toUserAllData.result['GiftNotification'] ?? true) && giftObject != null) {
          _notificationController.parseCloudNotification(toUser, 'send you Gift', toProfile, fromProfile);
        } else {
          // Notification for normal chat
          if (toUserAllData.result['ChatNotification']) {
            _notificationController.parseCloudNotification(toUser, 'send you Chat Message', toProfile, fromProfile);
          }
        }

        return 'success';
      }
    } else {
      final value = await parseCloudInteraction(
        fromUserId: StorageService.getBox.read('ObjectId'),
        toUserId: toUser,
        toProfileId: toProfile,
        type: 'sendHeartMessage',
        message: localChat,
        time: '$outputDate a las$formattedTime',
        fromProfileId: fromProfile,
      );
      if (value['success'] == false) {
        if (value['message'] == 'User has no coins') {
          Get.to(() => StoreScreen());
        }
      } else if (value['success'] == true) {
        final ApiResponse toUserAllData = await UserLoginProviderApi().getById(toUser);

        if (toUserAllData.result['HeartMessageNotification']) {
          _notificationController.parseCloudNotification(toUser, 'send you Heart Message', toProfile, fromProfile);
        }
      }
    }
    return 'Fail';
  }

  Future<void> coinCall(toUser, fromUser, {required int catValue}) async {
    await parseCloudInteraction(
        fromUserId: fromUser, toUserId: toUser, toProfileId: '', type: 'CallCoinsExpense', fromProfileId: '', callPrice: catValue);
  }

  Future<void> coinVideoCall(toUser, fromUser, {required int catValue}) async {
    await parseCloudInteraction(
        fromUserId: fromUser, toUserId: toUser, toProfileId: '', type: 'VideoCallCoinsExpense', fromProfileId: '', callPrice: catValue);
  }

  Future<void> imagePurchase(toUser, toProfile, imgPost) async {
    final value = await parseCloudInteraction(
      fromUserId: StorageService.getBox.read('ObjectId'),
      toUserId: toUser,
      toProfileId: toProfile,
      type: 'ImagePurchase',
      fromProfileId: StorageService.getBox.read('DefaultProfile'),
      postId: imgPost.objectId,
    );

    if (value['success'] == false) {
      if (value['message'] == 'User has no coins') {
        Get.to(() => StoreScreen());
      }
    } else if (value['success'] == true) {
      update();
    }
  }

  Future<void> videoPurchase(toUser, toProfile, videoPost) async {
    final value = await parseCloudInteraction(
      fromUserId: StorageService.getBox.read('ObjectId'),
      toUserId: toUser,
      toProfileId: toProfile,
      type: 'VideoPurchase',
      fromProfileId: StorageService.getBox.read('DefaultProfile'),
      postId: videoPost.objectId,
    );

    if (value['success'] == false) {
      if (value['message'] == 'User has no coins') {
        Get.to(() => StoreScreen());
      }
    } else if (value['success'] == true) {
      update();
    }
  }

  RxDouble ten = 10.0.obs;

  Future<bool> winkReceivedPurchase(items, {required PairNotificationController pair, required AllNotificationController notification}) async {
    if (StorageService.getBox.read('Gender') == 'male' && !items['IsPurchased']) {
      if (userTotalCoin.value >= winkMessagePrice.value) {
        final value = await parseCloudInteraction(
          fromUserId: items['FromUser']['objectId'],
          toUserId: StorageService.getBox.read('ObjectId'),
          toProfileId: StorageService.getBox.read('DefaultProfile'),
          type: 'WinkMessagePurchase',
          objectId: items['objectId'],
          fromProfileId: items['FromProfile']['objectId'],
        );
        if (value['success'] == false) {
          if (value['message'] == 'User has no coins') {
            Get.to(() => StoreScreen());
          }
        } else if (value['success'] == true) {
          update();
          return true;
        }
      } else {
        Get.to(() => StoreScreen());
      }
    } else {
      Get.to(() => UserFullProfileScreen(
            isDindon: true,
            toUserId: items['ToUser']['objectId'] == StorageService.getBox.read('ObjectId') ? items['FromUser'] : items['ToUser'],
            toProfileId: items['ToUser']['objectId'] == StorageService.getBox.read('ObjectId')
                ? items['FromProfile']['objectId']
                : items['ToProfile']['objectId'],
            fromProfileId: items['FromUser']['objectId'] == StorageService.getBox.read('ObjectId')
                ? items['FromProfile']['objectId']
                : items['ToProfile']['objectId'],
          ));
      if (pair.winkList.length < 5 && (items['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'))) {
        notification.redFunc(category: 'Guiños', fromUser: items['FromUser']['objectId']);
      }
      update();
    }
    return false;
  }

  Future<ApiResponse?> switchFuture({required String type}) async {
    switch (type) {
      case "Llamadas":
        return UserCallProviderApi().getCallData(StorageService.getBox.read('ObjectId'));

      case "Visitas":
        return VisitsProviderApi().getVisitsNotification(userid: StorageService.getBox.read('ObjectId'));

      case "Me gustas":
        return UserProfileProviderApi().getlikeNotification(userid: StorageService.getBox.read('ObjectId'));

      case "Guiños":
        return UserProfileProviderApi().getwinksMessagesNotification(userid: StorageService.getBox.read('ObjectId'));

      case "Besos":
        return UserProfileProviderApi().getLipLikeNotification2(userid: StorageService.getBox.read('ObjectId'));

      case "Bloqueados":
        return UserProfileProviderApi().getblockUserNotification(userid: StorageService.getBox.read('ObjectId'));

      default:
        return null;
    }
  }
}
