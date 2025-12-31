import 'package:eypop/Controllers/setting_controllers.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/ui/block_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../Constant/constant.dart';
import '../../back4appservice/base/api_response.dart';
import '../../back4appservice/user_provider/all_notifications/all_notifications.dart';
import '../../back4appservice/user_provider/tab_provider/provider_chatmsg.dart';
import '../../back4appservice/user_provider/tab_provider/provider_likemsg.dart';
import '../../back4appservice/user_provider/users/provider_profileuser_api.dart';
import '../../models/all_notifications/all_notifications.dart';
import '../../service/local_storage.dart';
import '../PairNotificationController/pair_notification_controller.dart';
import '../price_controller.dart';

class AllNotificationController extends GetxController {
  final RxInt userTotalNotification = 0.obs;
  final RxList chatNotificationCount = [].obs;
  final RxList messageNotificationCount = [].obs;
  final RxList callNotificationCount = [].obs;
  final RxList videoCallNotificationCount = [].obs;
  final RxList visitNotificationCount = [].obs;
  final RxList heartLikeNotificationCount = [].obs;
  final RxList winkMessageNotificationCount = [].obs;
  final RxList lipLikeNotificationCount = [].obs;
  final RxList blocNotificationCount = [].obs;
  final RxList wishNotificationCount = [].obs;
  final RxList giftNotificationCount = [].obs;

  final PriceController _priceController = Get.put(PriceController());
  final SettingController _settingController = Get.put(SettingController());

  final LiveQuery liveQuery = LiveQuery(debug: false);
  Subscription<ParseObject>? subscription;

  final LiveQuery coinLiveQuery = LiveQuery(debug: false);
  Subscription<ParseObject>? coinSubscription;

  final LiveQuery profileLiveQuery = LiveQuery(debug: false);
  Subscription<ParseObject>? profileSubscription;

  @override
  void onInit() {
    getPostList();
    startLivePostQuery();
    startCoinLiveQuery();
    startDefaultProfileQuery();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    cancelLiveUserQuery();
    cancelCoinLiveUserQuery();
    cancelProfileLiveUserQuery();
  }

  void startDefaultProfileQuery() async {
    try {
      final QueryBuilder<ProfilePage> queryProfileData = QueryBuilder<ProfilePage>(ProfilePage())
        ..whereEqualTo('objectId', StorageService.getBox.read('DefaultProfile'));

      profileSubscription = await profileLiveQuery.client.subscribe(queryProfileData);

      profileSubscription!.on(LiveQueryEvent.create, (value) {
        print('******** CREATE QUERY PROFILE ******** ${value.objectId}');
        noCallsProfile.value = (value['NoCalls'] ?? true);
        noVideocallsProfile.value = (value['NoVideocalls'] ?? true);
        noChatsProfile.value = (value['NoChats'] ?? false);
      });
      profileSubscription!.on(LiveQueryEvent.update, (value) async {
        print('******** UPDATE QUERY PROFILE ******** ${value.objectId}');
        noCallsProfile.value = (value['NoCalls'] ?? true);
        noVideocallsProfile.value = (value['NoVideocalls'] ?? true);
        noChatsProfile.value = (value['NoChats'] ?? false);
      });

      profileSubscription!.on(LiveQueryEvent.delete, (value) {
        print('******** DELETE QUERY PROFILE ********');
      });
    } catch (error, trace) {
      if (kDebugMode) {
        print("startProfileLiveQuery error ::::: $error");
        print("startProfileLiveQuery trace ::::: $trace");
      }
    }
  }

  void startCoinLiveQuery() async {
    try {
      final QueryBuilder<UserLogin> queryCoinData = QueryBuilder<UserLogin>(UserLogin())
        ..whereEqualTo('objectId', StorageService.getBox.read('ObjectId'))
        ..includeObject(['DefaultProfile']);

      coinSubscription = await coinLiveQuery.client.subscribe(queryCoinData);

      coinSubscription!.on(LiveQueryEvent.create, (ParseObject value) {
        if (kDebugMode) {
          print('******** CREATE USER ******** ${value.objectId}');
        }
        if (StorageService.getBox.read('Gender') == 'female') {
          _priceController.userTotalCoin.value = value['TotalToken'] ?? 0;
          _priceController.chatGirlMessageToken.value = value['ChatMessageToken'] ?? 0;
          _priceController.heartGirlMessageToken.value = value['HeartMessageToken'] ?? 0;
          _priceController.callGirlToken.value = value['CallToken'] ?? 0;
          _priceController.videoCalGirlToken.value = value['VideoCallToken'] ?? 0;
          _priceController.winkGirlToken.value = value['WinkMessageToken'] ?? 0;
          _priceController.lipLikeGirlToken.value = value['LipLikeToken'] ?? 0;
          _priceController.giftGirlToken.value = value['GiftToken'] ?? 0;
        } else {
          _priceController.userTotalCoin.value = value['TotalCoin'] ?? 0;
        }

        /// user login call, videocall, chat (on/off)
        noCalls.value = (value['NoCalls'] ?? false);
        noVideocalls.value = (value['NoVideocalls'] ?? false);
        noChats.value = (value['NoChats'] ?? false);
        nonVisibleInteractionsOptions.value = (value['NonVisibleInteractionOptions'] ?? false);
        influencerCall.value = (value['InfluencerCall'] ?? false);
        influencerVideocall.value = (value['InfluencerVideocall'] ?? false);
      });
      coinSubscription!.on(LiveQueryEvent.update, (ParseObject value) async {
        if (kDebugMode) {
          print('******** UPDATE USER ******** ${value.objectId}');
        }
        if (StorageService.getBox.read('Gender') == 'female') {
          _priceController.userTotalCoin.value = value['TotalToken'] ?? 0;
          _priceController.chatGirlMessageToken.value = value['ChatMessageToken'] ?? 0;
          _priceController.heartGirlMessageToken.value = value['HeartMessageToken'] ?? 0;
          _priceController.callGirlToken.value = value['CallToken'] ?? 0;
          _priceController.videoCalGirlToken.value = value['VideoCallToken'] ?? 0;
          _priceController.winkGirlToken.value = value['WinkMessageToken'] ?? 0;
          _priceController.lipLikeGirlToken.value = value['LipLikeToken'] ?? 0;
          _priceController.giftGirlToken.value = value['GiftToken'] ?? 0;
        } else {
          _priceController.userTotalCoin.value = value['TotalCoin'] ?? 0;
        }

        /// user login call, videocall, chat (on/off)
        noCalls.value = (value['NoCalls'] ?? false);
        noVideocalls.value = (value['NoVideocalls'] ?? false);
        noChats.value = (value['NoChats'] ?? false);
        nonVisibleInteractionsOptions.value = (value['NonVisibleInteractionOptions'] ?? false);
        influencerCall.value = (value['InfluencerCall'] ?? false);
        influencerVideocall.value = (value['InfluencerVideocall'] ?? false);
        hasLoggedIn.value = (value['HasLoggedIn'] ?? true);

        if (value['IsBlocked'] == true) {
          if (value['BlockDays'] == 'block_permanent') {
            Get.offAll(() => BlockScreen(
                  text1: 'permanent_block'.tr,
                  text2: 'delete_reason'.tr,
                  reason: value["BlockReason"] ?? 'ok'.tr,
                  onTap: () {
                    _settingController.logout();
                  },
                ));
          } else {
            final DateTime date = value['BlockEndDate'];
            final DateTime currentDate = await currentTime();

            if (currentDate.isBefore(date)) {
              final difference = date.difference(currentDate).inDays;
              Get.offAll(() => BlockScreen(
                    text1: '${'account_blocked'.tr} $difference ${'days'.tr}',
                    text2: 'delete_reason'.tr,
                    reason: value["BlockReason"] ?? 'ok'.tr,
                    onTap: () {
                      _settingController.logout();
                    },
                  ));
            } else {
              UserLogin userLogin = UserLogin();
              userLogin.objectId = value['objectId'];
              userLogin['IsBlocked'] = false;
              userLogin.blockDays = '0';
              userLogin.blockEndDate = value['BlockStartDate'];

              UserLoginProviderApi().update(userLogin);
            }
          }
        }
      });

      coinSubscription!.on(LiveQueryEvent.delete, (ParseObject value) {
        if (kDebugMode) {
          print('******** DELETE USER ******** ${value.objectId}');
        }
        if (StorageService.getBox.read('Gender') == 'female') {
          _priceController.userTotalCoin.value = value['TotalToken'] ?? 0;
          _priceController.chatGirlMessageToken.value = value['ChatMessageToken'] ?? 0;
          _priceController.heartGirlMessageToken.value = value['HeartMessageToken'] ?? 0;
          _priceController.callGirlToken.value = value['CallToken'] ?? 0;
          _priceController.videoCalGirlToken.value = value['VideoCallToken'] ?? 0;
          _priceController.winkGirlToken.value = value['WinkMessageToken'] ?? 0;
          _priceController.lipLikeGirlToken.value = value['LipLikeToken'] ?? 0;
          _priceController.giftGirlToken.value = value['GiftToken'] ?? 0;
        } else {
          _priceController.userTotalCoin.value = value['TotalCoin'] ?? 0;
        }

        /// user login call, videocall, chat (on/off)
        noCalls.value = (value['NoCalls'] ?? false);
        noVideocalls.value = (value['NoVideocalls'] ?? false);
        noChats.value = (value['NoChats'] ?? false);
        nonVisibleInteractionsOptions.value = (value['NonVisibleInteractionOptions'] ?? false);
      });
    } catch (error, trace) {
      if (kDebugMode) {
        print("startCoinLiveQuery error ::::: $error");
        print("startCoinLiveQuery trace ::::: $trace");
      }
    }
  }

  void startLivePostQuery() async {
    final PairNotificationController pairNotificationController = Get.put(PairNotificationController());
    try {
      final QueryBuilder<Notifications> queryPostData = QueryBuilder<Notifications>(Notifications())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereNotEqualTo('Type', 'BlocUser')
        ..includeObject(['ToUser', 'FromUser', 'FromProfile', 'ToProfile']);

      subscription = await liveQuery.client.subscribe(queryPostData);

      subscription!.on(LiveQueryEvent.create, (ParseObject value) {
        UserProfileProviderApi().getById(value['FromProfile']['objectId']).then((value2) {
          if (kDebugMode) {
            print('*** CREATE Notification ***: $value');
          }

          if (!((value2.result['isDeleted'] ?? false) &&
              (value2.result['IsBlocked'] ?? false) &&
              pairNotificationController.meBlocked.toString().contains(value['FromProfile']['objectId']) &&
              pairNotificationController.meBlocked.toString().contains(value['ToProfile']['objectId']))) {
            notiSwitch(type: value['Type'], value: value2.result, toProfileId: value['ToProfile']['objectId']);
          }
        });

        notificationSingleAdd(value);

        userTotalNotification.value++;
      });
      subscription!.on(LiveQueryEvent.update, (value) {
        if (kDebugMode) {
          print('*** UPDATE Notification ***: $value ');
        }
      });
      subscription!.on(LiveQueryEvent.delete, (value) {
        if (kDebugMode) {
          print('*** DELETE Notification ***: $value ');
        }
      });
    } catch (error, trace) {
      if (kDebugMode) {
        print("startLivePostQuery error ::::: $error");
        print("startLivePostQuery trace ::::: $trace");
      }
    }
  }

  notiSwitch({required String type, required value, required String toProfileId}) async {
    switch (type) {
      case 'LipLike':
        {
          if (_settingController.lipLike.value) {
            con.value = {
              "FromProfileId": value['objectId'],
              "ToProfileId": toProfileId,
              "senderId": value['User']['objectId'],
              "senderName": value['Name'],
              "alert": "send you liplike",
              "UserId": StorageService.getBox.read('ObjectId'),
              "avatar": value['Imgprofile'].url,
              "title": value['Name']
            };
          }
        }
        break;
      case 'HeartLike':
        {
          if (_settingController.heartLikeSwitch.value) {
            con.value = {
              "FromProfileId": value['objectId'],
              "ToProfileId": toProfileId,
              "senderId": value['User']['objectId'],
              "senderName": value['Name'],
              "alert": 'send you heartlike',
              "UserId": StorageService.getBox.read('ObjectId'),
              "avatar": value['Imgprofile'].url,
              "title": value['Name']
            };
          }
        }
        break;
      case 'WinkMessage':
        {
          if (_settingController.winkSwitch.value) {
            con.value = {
              "FromProfileId": value['objectId'],
              "ToProfileId": toProfileId,
              "senderId": value['User']['objectId'],
              "senderName": value['Name'],
              "alert": 'send you a Wink',
              "UserId": StorageService.getBox.read('ObjectId'),
              "avatar": value['Imgprofile'].url,
              "title": value['Name']
            };
          }
        }
        break;
      case 'Visit':
        {
          if (_settingController.visitSwitch.value) {
            con.value = {
              "FromProfileId": value['objectId'],
              "ToProfileId": toProfileId,
              "senderId": value['User']['objectId'],
              "senderName": value['Name'],
              "alert": "Visit Your profile",
              "UserId": StorageService.getBox.read('ObjectId'),
              "avatar": value['Imgprofile'].url,
              "title": value['Name']
            };
          }
        }
        break;
      case 'HeartMessage':
        {
          if (_settingController.heartMessageSwitch.value) {
            con.value = {
              "FromProfileId": value['objectId'],
              "ToProfileId": toProfileId,
              "senderId": value['User']['objectId'],
              "senderName": value['Name'],
              "alert": "send you Heart Message",
              "UserId": StorageService.getBox.read('ObjectId'),
              "avatar": value['Imgprofile'].url,
              "title": value['Name']
            };
          }
        }
        break;
      case 'ChatMessage':
        {
          if (_settingController.chatSwitch.value) {
            con.value = {
              "FromProfileId": value['objectId'],
              "ToProfileId": toProfileId,
              "senderId": value['User']['objectId'],
              "senderName": value['Name'],
              "alert": "send you Chat Message",
              "UserId": StorageService.getBox.read('ObjectId'),
              "avatar": value['Imgprofile'].url,
              "title": value['Name']
            };
          }
        }
        break;
      case 'Wishes':
        {
          if (_settingController.wishSwitch.value) {
            con.value = {
              "FromProfileId": value['objectId'],
              "ToProfileId": toProfileId,
              "senderId": value['User']['objectId'],
              "senderName": value['Name'],
              "alert": "full fill your toktok",
              "UserId": StorageService.getBox.read('ObjectId'),
              "avatar": value['Imgprofile'].url,
              "title": value['Name']
            };
          }
        }
        break;
      case 'ChatGift':
        {
          if (_settingController.giftSwitch.value) {
            con.value = {
              "FromProfileId": value['objectId'],
              "ToProfileId": toProfileId,
              "senderId": value['User']['objectId'],
              "senderName": value['Name'],
              "alert": "send you Gift",
              "UserId": StorageService.getBox.read('ObjectId'),
              "avatar": value['Imgprofile'].url,
              "title": value['Name']
            };
          }
        }
        break;
      case 'Call':
        {}
        break;
      case 'VideoCall':
        {}
        break;
      default:
        {}
        break;
    }
  }

  void cancelLiveUserQuery() async {
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }
  }

  void cancelCoinLiveUserQuery() async {
    if (coinSubscription != null) {
      coinLiveQuery.client.unSubscribe(coinSubscription!);
    }
  }

  void cancelProfileLiveUserQuery() async {
    if (profileSubscription != null) {
      profileLiveQuery.client.unSubscribe(profileSubscription!);
    }
  }

  void getPostList() async {
    final QueryBuilder<Notifications> query = QueryBuilder<Notifications>(Notifications())
      ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
      ..whereEqualTo('isRead', false)
      ..count();
    final rr = await query.count();
    query.setLimit(rr.count);
    final apiResponse = await query.query();

    if (apiResponse.results != null) {
      userTotalNotification.value = apiResponse.results!.length;
      notificationType(apiResponse.results as List<ParseObject>);
    }
  }

  notificationSingleAdd(value) {
    switch (value['Type']) {
      case 'WinkMessage':
        {
          winkMessageNotificationCount.add(value);
        }
        break;
      case 'ChatMessage':
        {
          chatNotificationCount.add(value);
        }
        break;
      case 'HeartMessage':
        {
          messageNotificationCount.add(value);
        }
        break;
      case 'Call':
        {
          callNotificationCount.add(value);
        }
        break;
      case 'VideoCall':
        {
          videoCallNotificationCount.add(value);
        }
        break;
      case 'LipLike':
        {
          lipLikeNotificationCount.add(value);
        }
        break;
      case 'HeartLike':
        {
          heartLikeNotificationCount.add(value);
        }
        break;
      case 'BlocUser':
        {
          blocNotificationCount.add(value);
        }
        break;
      case 'Visit':
        {
          visitNotificationCount.add(value);
        }
        break;
      case 'Wishes':
        {
          wishNotificationCount.add(value);
          print('wish --- ${wishNotificationCount.length}');
        }
        break;
      default:
        {}
        break;
    }
  }

  notificationSingleUpdate(value) {
    switch (value['Type']) {
      case 'WinkMessage':
        {
          winkMessageNotificationCount.removeWhere((element) => element.objectId == value.objectId);
        }
        break;
      case 'ChatMessage':
        {
          chatNotificationCount.removeWhere((element) => element.objectId == value.objectId);
        }
        break;
      case 'HeartMessage':
        {
          messageNotificationCount.removeWhere((element) => element.objectId == value.objectId);
        }
        break;
      case 'Call':
        {
          callNotificationCount.removeWhere((element) => element.objectId == value.objectId);
        }
        break;
      case 'VideoCall':
        {
          videoCallNotificationCount.removeWhere((element) => element.objectId == value.objectId);
        }
        break;
      case 'LipLike':
        {
          lipLikeNotificationCount.removeWhere((element) => element.objectId == value.objectId);
        }
        break;
      case 'HeartLike':
        {
          heartLikeNotificationCount.removeWhere((element) => element.objectId == value.objectId);
        }
        break;
      case 'BlocUser':
        {
          blocNotificationCount.removeWhere((element) => element.objectId == value.objectId);
        }
        break;
      case 'Visit':
        {
          visitNotificationCount.removeWhere((element) => element.objectId == value.objectId);
        }
        break;
      case 'Wishes':
        {
          wishNotificationCount.removeWhere((element) => element.objectId == value.objectId);
        }
        break;
      default:
        {}
        break;
    }
  }

  notificationType(apiResponse) {
    chatNotificationCount.addAll(apiResponse);
    messageNotificationCount.addAll(apiResponse);
    callNotificationCount.addAll(apiResponse);
    videoCallNotificationCount.addAll(apiResponse);
    visitNotificationCount.addAll(apiResponse);
    heartLikeNotificationCount.addAll(apiResponse);
    winkMessageNotificationCount.addAll(apiResponse);
    lipLikeNotificationCount.addAll(apiResponse);
    blocNotificationCount.addAll(apiResponse);
    wishNotificationCount.addAll(apiResponse);
    giftNotificationCount.addAll(apiResponse);

    chatNotificationCount.removeWhere((element) => element['Type'] != 'ChatMessage');
    messageNotificationCount.removeWhere((element) => element['Type'] != 'HeartMessage');
    callNotificationCount.removeWhere((element) => element['Type'] != 'Call');
    videoCallNotificationCount.removeWhere((element) => element['Type'] != 'VideoCall');
    lipLikeNotificationCount.removeWhere((element) => element['Type'] != 'LipLike');
    winkMessageNotificationCount.removeWhere((element) => element['Type'] != 'WinkMessage');
    heartLikeNotificationCount.removeWhere((element) => element['Type'] != 'HeartLike');
    blocNotificationCount
        .removeWhere((element) => element['Type'] != 'BlocUser' || element['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));
    visitNotificationCount.removeWhere((element) => (element['Type'] != 'Visit'));
    wishNotificationCount.removeWhere((element) => (element['Type'] != 'Wishes'));
    giftNotificationCount.removeWhere((element) => (element['Type'] != 'ChatGift'));
  }

  RxBool notificationSwitch(val) {
    switch (val) {
      case 'Chats':
        {
          return chatNotificationCount.isNotEmpty.obs;
        }
      case 'Mensajes':
        {
          return messageNotificationCount.isNotEmpty.obs;
        }
      case 'Llamadas':
        {
          return callNotificationCount.isNotEmpty.obs;
        }
      case 'Videollamada':
        {
          return videoCallNotificationCount.isNotEmpty.obs;
        }
      case 'Visitas':
        {
          return visitNotificationCount.isNotEmpty.obs;
        }
      case 'Me gustas':
        {
          return heartLikeNotificationCount.isNotEmpty.obs;
        }
      case 'Guiños':
        {
          return winkMessageNotificationCount.isNotEmpty.obs;
        }
      case 'Besos':
        {
          return lipLikeNotificationCount.isNotEmpty.obs;
        }
      case 'Bloqueados':
        {
          return blocNotificationCount.isNotEmpty.obs;
        }
      case 'wishes':
        {
          return wishNotificationCount.isNotEmpty.obs;
        }
      case 'Regalos':
        {
          return giftNotificationCount.isNotEmpty.obs;
        }
      default:
        {
          return false.obs;
        }
    }
  }

  Future<void> redFunc({category, String? fromUser}) async {
    switch (category) {
      case 'Chat':
        {
          final ApiResponse? value =
              await UserChatMessageProviderApi().messageRead(userId: StorageService.getBox.read('ObjectId'), fromUser: fromUser, type: 'ChatMessage');
          if (fromUser == null) {
            userTotalNotification.value -= chatNotificationCount.length;
            chatNotificationCount.clear();
          } else {
            userTotalNotification.value -= chatNotificationCount.isNotEmpty ? 1 : 0;
          }
          List<Notifications> chatData = [];
          if (value != null && value.results != null) {
            for (final ele in value.results ?? []) {
              final Notifications chatMessage = Notifications();
              chatMessage.objectId = ele['objectId'];
              chatMessage.isRead = true;
              chatData.add(chatMessage);
            }
            NotificationsProviderApi().updateAll(chatData);
          }
        }
        break;
      case 'Regalos':
        {
          final ApiResponse? value =
              await UserChatMessageProviderApi().messageRead(userId: StorageService.getBox.read('ObjectId'), fromUser: fromUser, type: 'ChatGift');
          if (fromUser == null) {
            userTotalNotification.value -= giftNotificationCount.length;
            giftNotificationCount.clear();
          } else {
            userTotalNotification.value -= giftNotificationCount.isNotEmpty ? 1 : 0;
          }
          List<Notifications> chatData = [];
          if (value != null && value.results != null) {
            for (final ele in value.results ?? []) {
              final Notifications chatMessage = Notifications();
              chatMessage.objectId = ele['objectId'];
              chatMessage.isRead = true;
              chatData.add(chatMessage);
            }
            NotificationsProviderApi().updateAll(chatData);
          }
        }
        break;
      case 'Mensajes':
        {
          final ApiResponse? data =
              await LikeMsgProviderApi().messageRead(userId: StorageService.getBox.read('ObjectId'), fromUser: fromUser, type: 'HeartMessage');
          if (fromUser == null) {
            userTotalNotification.value -= messageNotificationCount.length;
            messageNotificationCount.clear();
          } else {
            userTotalNotification.value -= messageNotificationCount.isNotEmpty ? 1 : 0;
          }
          List<Notifications> messageData = [];
          if (data != null && data.results != null) {
            for (final ele in data.results ?? []) {
              final Notifications likeMessage = Notifications();
              likeMessage.objectId = ele['objectId'];
              likeMessage.isRead = true;
              messageData.add(likeMessage);
            }
            NotificationsProviderApi().updateAll(messageData);
          }
        }
        break;
      case 'Llamadas':
        {
          final ApiResponse? data = await NotificationsProviderApi()
              .notificationCountUnRead(userId: StorageService.getBox.read('ObjectId'), fromUser: fromUser, type: 'Call');
          if (fromUser == null) {
            userTotalNotification.value -= callNotificationCount.length;
            callNotificationCount.clear();
          } else {
            userTotalNotification.value -= callNotificationCount.isNotEmpty ? 1 : 0;
          }
          List<Notifications> chatData = [];
          if (data != null && data.results != null) {
            for (final ele in data.results ?? []) {
              final Notifications chatMessage = Notifications();
              chatMessage.objectId = ele['objectId'];
              chatMessage.isRead = true;
              chatData.add(chatMessage);
            }
            NotificationsProviderApi().updateAll(chatData);
          }
        }
        break;
      case 'Videollamada':
        {
          final ApiResponse? data = await NotificationsProviderApi()
              .notificationCountUnRead(userId: StorageService.getBox.read('ObjectId'), fromUser: fromUser, type: 'VideoCall');
          if (fromUser == null) {
            userTotalNotification.value -= videoCallNotificationCount.length;
            videoCallNotificationCount.clear();
          } else {
            userTotalNotification.value -= videoCallNotificationCount.isNotEmpty ? 1 : 0;
          }
          List<Notifications> chatData = [];
          if (data != null && data.results != null) {
            for (final ele in data.results ?? []) {
              final Notifications chatMessage = Notifications();
              chatMessage.objectId = ele['objectId'];
              chatMessage.isRead = true;
              chatData.add(chatMessage);
            }
            NotificationsProviderApi().updateAll(chatData);
          }
        }
        break;
      case 'Visitas':
        {
          final ApiResponse? data = await NotificationsProviderApi()
              .notificationCountUnRead(userId: StorageService.getBox.read('ObjectId'), fromUser: fromUser, type: 'Visit');
          if (fromUser == null) {
            userTotalNotification.value -= visitNotificationCount.length;
            visitNotificationCount.clear();
          } else {
            userTotalNotification.value -= visitNotificationCount.isNotEmpty ? 1 : 0;
          }
          List<Notifications> notificationData = [];
          if (data != null && data.results != null) {
            for (final ele in data.results ?? []) {
              final Notifications notifications = Notifications();
              notifications.objectId = ele['objectId'];
              notifications.isRead = true;
              notificationData.add(notifications);
            }
            NotificationsProviderApi().updateAll(notificationData);
          }
        }
        break;
      case 'Me gustas':
        {
          final ApiResponse? data = await NotificationsProviderApi()
              .notificationCountUnRead(userId: StorageService.getBox.read('ObjectId'), fromUser: fromUser, type: 'HeartLike');
          if (fromUser == null) {
            userTotalNotification.value -= heartLikeNotificationCount.length;
            heartLikeNotificationCount.clear();
          } else {
            userTotalNotification.value -= heartLikeNotificationCount.isNotEmpty ? 1 : 0;
          }
          List<Notifications> chatData = [];
          if (data != null && data.results != null) {
            for (final ele in data.results ?? []) {
              final Notifications chatMessage = Notifications();
              chatMessage.objectId = ele['objectId'];
              chatMessage.isRead = true;
              chatData.add(chatMessage);
            }
            NotificationsProviderApi().updateAll(chatData);
          }
        }
        break;
      case 'Guiños':
        {
          final ApiResponse? data = await NotificationsProviderApi()
              .notificationCountUnRead(userId: StorageService.getBox.read('ObjectId'), fromUser: fromUser, type: 'WinkMessage');
          if (fromUser == null) {
            userTotalNotification.value -= winkMessageNotificationCount.length;
            winkMessageNotificationCount.clear();
          } else {
            userTotalNotification.value -= winkMessageNotificationCount.isNotEmpty ? 1 : 0;
          }
          List<Notifications> chatData = [];
          if (data != null && data.results != null) {
            for (final ele in data.results ?? []) {
              final Notifications chatMessage = Notifications();
              chatMessage.objectId = ele['objectId'];
              chatMessage.isRead = true;
              chatData.add(chatMessage);
            }
            NotificationsProviderApi().updateAll(chatData);
          }
        }
        break;
      case 'Besos':
        {
          final ApiResponse? data = await NotificationsProviderApi()
              .notificationCountUnRead(userId: StorageService.getBox.read('ObjectId'), fromUser: fromUser, type: 'LipLike');
          if (fromUser == null) {
            userTotalNotification.value -= lipLikeNotificationCount.length;
            lipLikeNotificationCount.clear();
          } else {
            userTotalNotification.value -= lipLikeNotificationCount.isNotEmpty ? 1 : 0;
          }
          List<Notifications> chatData = [];
          if (data != null && data.results != null) {
            for (final ele in data.results ?? []) {
              final Notifications chatMessage = Notifications();
              chatMessage.objectId = ele['objectId'];
              chatMessage.isRead = true;
              chatData.add(chatMessage);
            }
            NotificationsProviderApi().updateAll(chatData);
          }
        }
        break;

      case 'Bloqueados':
        {
          final ApiResponse? data = await NotificationsProviderApi()
              .notificationCountUnRead(userId: StorageService.getBox.read('ObjectId'), fromUser: fromUser, type: 'BlocUser');
          if (fromUser == null) {
            userTotalNotification.value -= blocNotificationCount.length;
            blocNotificationCount.clear();
          } else {
            userTotalNotification.value -= blocNotificationCount.isNotEmpty ? 1 : 0;
          }
          List<Notifications> chatData = [];
          if (data != null && data.results != null) {
            for (final ele in data.results ?? []) {
              final Notifications chatMessage = Notifications();
              chatMessage.objectId = ele['objectId'];
              chatMessage.isRead = true;
              chatData.add(chatMessage);
            }
            NotificationsProviderApi().updateAll(chatData);
          }
        }
        break;

      case 'wishes':
        {
          final ApiResponse? data = await NotificationsProviderApi()
              .notificationCountUnRead(userId: StorageService.getBox.read('ObjectId'), fromUser: fromUser, type: 'Wishes');
          if (fromUser == null) {
            userTotalNotification.value -= wishNotificationCount.length;
            wishNotificationCount.clear();
          } else {
            userTotalNotification.value -= wishNotificationCount.isNotEmpty ? 1 : 0;
          }
          List<Notifications> notificationsData = [];
          if (data != null && data.results != null) {
            for (final ele in data.results ?? []) {
              final Notifications notifications = Notifications();
              notifications.objectId = ele['objectId'];
              notifications.isRead = true;
              notificationsData.add(notifications);
            }
            NotificationsProviderApi().updateAll(notificationsData);
          }
        }
        break;
      default:
        {}
        break;
    }
  }
}
