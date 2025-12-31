import 'dart:async';
import 'dart:io';

import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/post_view.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/tab_provider/provider_chat_gifts.dart';
import 'package:eypop/back4appservice/user_provider/tab_provider/provider_likemsg.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/gettimeago/get_time_ago.dart';
import 'package:eypop/models/new_notification/new_notification_pair.dart';
import 'package:eypop/models/tab_model/like_message.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/ui/store_screen.dart';
import 'package:eypop/ui/tab_pages/chat_video_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../back4appservice/user_provider/delete_conversation_api.dart';
import '../../back4appservice/user_provider/tab_provider/provider_chatmsg.dart';
import '../../back4appservice/user_provider/users/provider_profileuser_api.dart';
import '../../models/tab_model/chat_message.dart';
import '../../models/user_login/user_profile.dart';
import '../../service/local_storage.dart';
import '../price_controller.dart';
import '../search_controller.dart';
import '../translate_controler.dart';

enum Typing { start, stop }

class ConversationController extends GetxController {
  final PriceController _priceController = Get.put(PriceController());
  String? fromProfileId;
  String? tableName;
  ParseObject? myProfile;
  ParseObject? oppositeProfile;
  String? toProfileId;
  RxBool? isOnline;
  final RxBool onlineStatus = false.obs;
  final RxBool isTyping = false.obs;
  final RxBool isInactive = false.obs;
  final RxBool isNoChat = false.obs;
  final RxBool isNoCall = false.obs;
  final RxBool isCallEnable = false.obs;
  final RxBool isCallBusy = false.obs;
  final RxBool isNoVideocall = false.obs;
  final RxBool isVideocallEnable = false.obs;
  final RxBool isHasLoggedIn = false.obs;
  final RxBool isUpdate = false.obs;
  final RxBool clicked = false.obs;
  final Rx<DateTime> userLastOnline = DateTime.now().obs;
  final RxList<ParseObject> giftsList = <ParseObject>[].obs;
  final ScrollController scrollController = ScrollController();
  final RxInt loadPage = 0.obs;
  final RxBool isUploading = false.obs;
  final RxBool isLimit200 = false.obs;
  final RxBool isLoadMore = false.obs;
  final ImagePicker _imagePicker = ImagePicker();
  final RxMap postPath = {}.obs;
  final RxList<String> tempSendMessageTempUniqueId = <String>[].obs;
  final Rx<ParseObject> tempSendMessage = ParseObject('').obs;
  final RxString tempSendMessageLenght = ''.obs;
  final RxString tempSendMessageTableName = ''.obs;
  final RxMap<DateTime, List<Widget>> messageList =
      <DateTime, List<Widget>>{}.obs; // GET DATE WISE TOTAL CHAT EX: {'Today': [0,1,2,3,4,5],'Yesterday': [0,1,2]}
  final RxList<ParseObject> chatList = <ParseObject>[].obs; // GET TOTAL CHAT

  final RxBool isMyMsgAvail = false.obs;
  final RxInt newChatAdded = 0.obs;

  final RxBool isChatLoading = false.obs;
  final RxBool showRate = false.obs;
  final LiveQuery liveQuery = LiveQuery(debug: false);
  final LiveQuery pairLiveQuery = LiveQuery(debug: false);
  Subscription<ParseObject>? subscription;
  Subscription<PairNotifications>? pairSubscription;

  Timer? timer;
  Timer? _startTypingTimer;
  Timer? _stopTypingTimer;

  Future<File?> uploadPosts({ImageSource source = ImageSource.gallery, bool isVideo = false}) async {
    if (isVideo) {
      final file = await _imagePicker.pickVideo(source: source);
      if (file == null) {
        postPath.clear();
        isUploading.value = false;
        return null;
      }
      return File(file.path);
    } else {
      final file = await _imagePicker.pickImage(source: source);
      if (file == null) {
        postPath.clear();
        isUploading.value = false;
        return null;
      }
      return File(file.path);
    }
  }

  /// Table: [AppInfo] ColumnName: [ChatLimit]
  void _scrollListener() {
    // check when chat max loading limit over or not
    if (loadPage.value < chatLimit) {
      if (isLimit200.value) {
        isLimit200.value = false;
      }
      if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
        isLoadMore.value = true;
        if (tableName == 'Chat_Message') {
          DeleteConversationApi().deleted(fromId: fromProfileId!, toId: toProfileId!, type: 'Chat').then((value) {
            getMessagesList(
                msgFromProfileId: fromProfileId!,
                msgToProfileID: toProfileId!,
                date: value != null ? value.result['updatedAt'] : null,
                page: loadPage.value);
            loadPage.value += 20;
          });
        } else {
          DeleteConversationApi().deleted(fromId: fromProfileId!, toId: toProfileId!, type: 'Mensajes').then((value) {
            getMessagesList(
                msgFromProfileId: fromProfileId!,
                msgToProfileID: toProfileId!,
                date: value != null ? value.result['updatedAt'] : null,
                page: loadPage.value);
            loadPage.value += 20;
          });
        }
        isLoadMore.value = false;
      }
    } else {
      isLimit200.value = true;
    }
  }

  Future<void> save(
      {required String toProfile,
      required String fromProfileId,
      Map<String, dynamic>? postMap,
      String? toUser,
      String? gender,
      ParseObject? giftObject,
      required String tableName,
      required String chatType}) async {
    // if (_priceController.userTotalCoin.value >= _priceController.chatMessagePrice.value) {
    //   instantMessage();
    // }
    await _priceController
        .coinService('ChatMessage', gender, toProfile, toUser,
            tableName: tableName,
            fromProfile: fromProfileId,
            giftObject: giftObject,
            chatType: chatType,
            postMap: postMap,
            catValue: (giftObject != null ? int.parse(giftObject['Stars'].toString()) : _priceController.chatMessagePrice.value))
        .then((value) {
      if (value == 'success') {
        clicked.value = false;
        WidgetsBinding.instance.addPostFrameCallback((cc) async {
          if (chatList.isEmpty) {
          } else if (chatList.length == 1) {
            await UserLoginProviderApi().increment(toUser!, 1, 'UnanswerChat');
            /// cloud function (ChatDeactiveMail)
            final Map<String, dynamic> params = <String, dynamic>{'UserId': toUser};
            final ParseCloudFunction getCurrentTime = ParseCloudFunction('ChatDeactiveMail');
            ParseResponse res = await getCurrentTime.execute(parameters: params);
            print('ChatDeactiveMail status ---- ${res.statusCode}');
          } else if (chatList[chatList.length - 2]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId')) {
            await UserLoginProviderApi().increment(chatList.last['ToUser']['objectId'], 1, 'UnanswerChat');
            /// cloud function (ChatDeactiveMail)
            final Map<String, dynamic> params = <String, dynamic>{'UserId': chatList.last['ToUser']['objectId']};
            final ParseCloudFunction getCurrentTime = ParseCloudFunction('ChatDeactiveMail');
            ParseResponse res = await getCurrentTime.execute(parameters: params);
            print('ChatDeactiveMail status ---- ${res.statusCode}');
          }
        });
        if (_priceController.isGiftSending.value) {
          Future.delayed(const Duration(seconds: 1), () {
            _priceController.isGiftSending.value = false;
          });
        }
      }
    });
  }

  void sendTypingNotification(String text) {
    if (text.trim().isEmpty) return;

    if (_startTypingTimer?.isActive ?? false) return;

    if (_stopTypingTimer?.isActive ?? false) _stopTypingTimer?.cancel();

    dispatchTyping(Typing.start);

    _startTypingTimer = Timer(const Duration(seconds: 3), () {}); //send one event every 3 seconds

    _stopTypingTimer = Timer(const Duration(seconds: 3), () => dispatchTyping(Typing.stop));
  }

  Future<void> dispatchTyping(Typing event) async {
    final ApiResponse? value =
        await PairNotificationProviderApi().getByProfile(fromProfileId, toProfileId, tableName == 'Chat_Message' ? 'ChatMessage' : 'HeartMessage');

    if (value != null) {
      List typingProfiles = [];
      typingProfiles = value.result != null ? value.result['TypingProfiles'] ?? [] : [];

      if (event == Typing.stop) {
        if (typingProfiles.isNotEmpty) {
          typingProfiles.removeWhere((element) => element == fromProfileId);
        }
      } else {
        if (!typingProfiles.toString().contains(fromProfileId!)) {
          typingProfiles.add(fromProfileId!);
        }
      }
      final PairNotifications pairNotifications = PairNotifications();
      pairNotifications.objectId = value.result['objectId'];
      pairNotifications['TypingProfiles'] = typingProfiles;
      await PairNotificationProviderApi().update(pairNotifications);
    }
  }

  void typingStatusLiveQuery() async {
    final QueryBuilder<PairNotifications> query = QueryBuilder<PairNotifications>(PairNotifications())
      ..whereEqualTo('ToProfile', ProfilePage()..objectId = fromProfileId)
      ..whereEqualTo('FromProfile', ProfilePage()..objectId = toProfileId)
      ..whereEqualTo('Type', tableName == 'Chat_Message' ? 'ChatMessage' : 'HeartMessage');
    final QueryBuilder<PairNotifications> query2 = QueryBuilder<PairNotifications>(PairNotifications())
      ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
      ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId)
      ..whereEqualTo('Type', tableName == 'Chat_Message' ? 'ChatMessage' : 'HeartMessage');

    final PairNotifications playerObject = PairNotifications();
    final QueryBuilder<PairNotifications> queryPostData = QueryBuilder.or(playerObject, [query, query2]);
    pairSubscription = await pairLiveQuery.client.subscribe(queryPostData);
    pairSubscription!.on(LiveQueryEvent.create, (value) {
      if (kDebugMode) {
        print('*** CREATE TYPING STATUS ***: $value ');
      }
    });
    pairSubscription!.on(LiveQueryEvent.update, (value) {
      if (kDebugMode) {
        print('*** UPDATE TYPING STATUS ***: $value ');
      }
      if (value['TypingProfiles'] != null) {
        isTyping.value = value['TypingProfiles'].toString().contains(toProfileId!);
      }
    });
    pairSubscription!.on(LiveQueryEvent.delete, (value) {
      if (kDebugMode) {
        print('*** DELETE TYPING STATUS ***: $value ');
      }
    });
  }

  void startLiveMessageQuery() async {
    try {
      final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject(tableName!))
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = toProfileId);

      final QueryBuilder<ParseObject> query2 = QueryBuilder<ParseObject>(ParseObject(tableName!))
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId);

      final ParseObject playerObject = ParseObject(tableName!);
      final QueryBuilder<ParseObject> queryPostData = QueryBuilder.or(playerObject, [query, query2]);

      subscription = await liveQuery.client.subscribe(queryPostData);

      subscription!.on(LiveQueryEvent.create, (ParseObject value) async {
        // Replace temp msg with new content
        for (var element in tempSendMessageTempUniqueId) {
          if (element.contains(value['TempUniqueId'].toString())) {
            removeMessageWithObjectId(
              value['TempUniqueId'].toString(),
            );
            break;
          }
        }
        if (kDebugMode) {
          print('*** CREATE CHAT ***: $value');
        }

        if (value['Gifts'] != null) {
          _priceController.isGiftSending.value = true;
          // Add pointer value when user sends a Gift
          final gift = await UserChatGiftsProviderApi.getGiftById(value['Gifts']['objectId']);
          if (gift != null && gift.result != null) {
            value['Gifts'] = gift.result;
          }
          Future.delayed(const Duration(seconds: 1), () {
            _priceController.isGiftSending.value = false;
          });
        }

        if (value['ChatType'].toString().contains('Video') || value['ChatType'].toString().contains('Image')) {
          isUploading.value = false;
          postPath.clear();
        }

        if (fromProfileId == value["ToProfile"]['objectId'] && tableName == 'Chat_Message' && !value["isRead"] && toChatUser.value.isNotEmpty) {
          value['isRead'] = true;
          final ChatMessage chatMessage = ChatMessage();
          chatMessage.objectId = value.objectId;
          chatMessage.isRead = true;
          await UserChatMessageProviderApi().update(chatMessage);
        }

        // Replace temp msg with new content
        chatList.add(value);
        addConversation(parseObject: value, fromLive: true);
      });

      subscription!.on(LiveQueryEvent.update, (ParseObject value) async {
        if (kDebugMode) {
          print('*** UPDATE CHAT ***: $value');
        }

        if (value['Gifts'] != null) {
          // Add pointer value when user sends a Gift
          final gift = await UserChatGiftsProviderApi.getGiftById(value['Gifts']['objectId']);
          if (gift != null && gift.result != null) {
            value['Gifts'] = gift.result;
          }
        }

        if (value['ChatType'].toString().contains('Video') || value['ChatType'].toString().contains('Image')) {
          isUploading.value = false;
          postPath.clear();
        }

        final int yIndex = chatList.indexWhere((element) => element.objectId == value.objectId);
        if (!yIndex.isNegative) {
          chatList[yIndex] = value;
          chatList.refresh();
        }

        updateConversation(parseObject: value);
      });

      subscription!.on(LiveQueryEvent.delete, (ParseObject value) {
        if (kDebugMode) {
          print('*** DELETE CHAT ***: $value ');
        }
        chatList.removeWhere((element) => element.objectId == value.objectId);
      });
    } catch (error, trace) {
      if (kDebugMode) {
        print("startLiveMessageQuery error ::::: $error");
        print("startLiveMessageQuery trace ::::: $trace");
      }
    }
  }

  /*void startLiveMessageQuery() async {
    try {
      final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject(tableName!))
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = fromProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = toProfileId);
      final QueryBuilder<ParseObject> query2 = QueryBuilder<ParseObject>(ParseObject(tableName!))
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = fromProfileId);

      final ParseObject playerObject = ParseObject(tableName!);
      final QueryBuilder<ParseObject> queryPostData = QueryBuilder.or(playerObject, [query, query2]);
      subscription = await liveQuery.client.subscribe(queryPostData);
      subscription!.on(LiveQueryEvent.create, (ParseObject value) async {

        print('value ::: ${value['TempUniqueId']}');
        // remove temp msg our side
        for (var element in tempSendMessageTempUniqueId) {
          if (element.contains(value['TempUniqueId'])) {
            removeMessageWithObjectId(value['TempUniqueId']);
          }
          break;
        }

        // tempSendMessageTempId2.value++;
        if (kDebugMode) {
          print('*** CREATE CHAT ***: $value');
        }
        // if (messageSections.isNotEmpty && isMyMsgAvail.value && fromProfileId == value["FromProfile"]['objectId']) {
        //   messageSections.removeAt(messageSections.length - 1);
        // }
        if (value['Gifts'] != null) {
          _priceController.isGiftSending.value = true;
          // add pointer value when user send Gift
          final gift = await UserChatGiftsProviderApi.getGiftById(value['Gifts']['objectId']);
          if (gift != null && gift.result != null) {
            value['Gifts'] = gift.result;
          }
          Future.delayed(const Duration(seconds: 1), () {
            _priceController.isGiftSending.value = false;
          });
        }
        // when user send video and image in chat remove this loading
        if (value['ChatType'].toString().contains('Video') || value['ChatType'].toString().contains('Image')) {
          isUploading.value = false;
          postPath.clear();
        }
        if (fromProfileId == value["ToProfile"]['objectId'] && tableName == 'Chat_Message' && !value["isRead"] && toChatUser.value.isNotEmpty) {
          value['isRead'] = true;
          final ChatMessage chatMessage = ChatMessage();
          chatMessage.objectId = value.objectId;
          chatMessage.isRead = true;
          await UserChatMessageProviderApi().update(chatMessage);
        }
        chatList.add(value);
        addConversation(parseObject: value, fromLive: true);
      });
      subscription!.on(LiveQueryEvent.update, (ParseObject value) async {
        if (kDebugMode) {
          print('*** UPDATE CHAT ***: $value');
        }
        if (value['Gifts'] != null) {
          // add pointer value when user send Gift
          final gift = await UserChatGiftsProviderApi.getGiftById(value['Gifts']['objectId']);
          if (gift != null && gift.result != null) {
            value['Gifts'] = gift.result;
          }
        }
        // when user send video and image in chat remove this loading
        if (value['ChatType'].toString().contains('Video') || value['ChatType'].toString().contains('Image')) {
          isUploading.value = false;
          postPath.clear();
        }
        final int yIndex = chatList.indexWhere((element) => element.objectId == value.objectId);
        if (!yIndex.isNegative) {
          chatList[yIndex] = value;
          chatList.refresh();
        }
        updateConversation(parseObject: value);
      });
      subscription!.on(LiveQueryEvent.delete, (ParseObject value) {
        if (kDebugMode) {
          print('*** DELETE CHAT ***: $value ');
        }
        chatList.removeWhere((element) => element.objectId == value.objectId);
      });
    } catch (error, trace) {
      if (kDebugMode) {
        print("startLiveMessageQuery error ::::: $error");
        print("startLiveMessageQuery trace ::::: $trace");
      }
    }
  }*/

  void addConversation({required ParseObject parseObject, bool fromLive = false}) {
    try {
      // this key use to show header EX: 'Today', 'Yesterday'
      final DateTime key = DateTime(parseObject['createdAt'].year, parseObject['createdAt'].month, parseObject['createdAt'].day);
      messageList.putIfAbsent(key, () => []);
      if (fromLive) {
        if (parseObject["ToProfile"] != null && fromProfileId == parseObject["ToProfile"]['objectId']) {
          messageList[key]!.add(oppositeMessage(parseObject: parseObject, length: (messageList[key]!.length + 1).toString(), tableName: tableName!));
        } else {
          messageList[key]!.add(ourMessage(parseObject: parseObject, length: (messageList[key]!.length + 1).toString(), tableName: tableName!));
          if(!parseObject['Message'].toString().contains('http')){
            tempSendMessage.value = parseObject;
            tempSendMessageLenght.value = (messageList[key]!.length).toString();
            tempSendMessageTableName.value = tableName!;
          }

        }
      } else {
        if (parseObject["ToProfile"] != null && fromProfileId == parseObject["ToProfile"]['objectId']) {
          messageList[key] = [
            oppositeMessage(parseObject: parseObject, length: (messageList[key]!.length + 1).toString(), tableName: tableName!),
            ...messageList[key]!
          ];
        } else {
          messageList[key] = [
            ourMessage(parseObject: parseObject, length: (messageList[key]!.length + 1).toString(), tableName: tableName!),
            ...messageList[key]!
          ];

          if(!parseObject['Message'].toString().contains('http')){
            tempSendMessage.value = parseObject;
            tempSendMessageLenght.value = (messageList[key]!.length).toString();
            tempSendMessageTableName.value = tableName!;
          }
        }
        // print('tempSendMessage 😋😋 ${tempSendMessage.value['Message']}');
      }

      messageList.refresh();
    } catch (e, t) {
      if (kDebugMode) {
        print('Hello message addConversation error $e *** $t');
      }
    }
  }

  void removeMessageWithObjectId(String objectId) {
    messageList.forEach((key, value) {
      value.removeWhere((widget) {
        // Check if the widget's key is a ValueKey and matches the objectId
        if (widget.key is ValueKey<String>) {
          return (widget.key as ValueKey<String>).value == objectId;
        }
        return false;
      });
    });
  }

  // void replaceMessageWithObjectId(String objectId, Widget newWidget) {
  //   messageList.forEach((key, value) {
  //     for (int i = 0; i < value.length; i++) {
  //       final widget = value[i];
  //       // Check if the widget's key is a ValueKey and matches the objectId
  //       if (widget.key is ValueKey<String> &&
  //           (widget.key as ValueKey<String>).value == objectId) {
  //         value[i] = newWidget; // Replace the widget with the new widget
  //         break;
  //       }
  //     }
  //   });
  // }

  void updateConversation({required ParseObject parseObject}) {
    // this key use to show header EX: 'Today', 'Yesterday'
    final DateTime key = DateTime(parseObject['createdAt'].year, parseObject['createdAt'].month, parseObject['createdAt'].day);
    messageList.putIfAbsent(key, () => []);
    // Retrieving index using the key this key use to update value when objectId match
    final index = messageList[key]!.indexWhere((element) {
      if (element.key is ValueKey<String>) {
        return (element.key as ValueKey<String>).value == parseObject.objectId;
      }
      return false;
    });
    if (!index.isNegative) {
      messageList[key]!.removeAt(index);
      if (fromProfileId == parseObject["ToProfile"]['objectId']) {
        messageList[key]!
            .insert(index, oppositeMessage(parseObject: parseObject, length: (messageList[key]!.length + 1).toString(), tableName: tableName!));
      } else {
        messageList[key]!
            .insert(index, ourMessage(parseObject: parseObject, length: (messageList[key]!.length + 1).toString(), tableName: tableName!));
      }
      messageList.refresh();
    }
  }

  void cancelMessageQuery() async {
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }
    if (pairSubscription != null) {
      liveQuery.client.unSubscribe(pairSubscription!);
    }
    if (subscriptionUser != null) {
      liveQueryUser.client.unSubscribe(subscriptionUser!);
    }
    if (subscriptionProfile != null) {
      liveQueryProfile.client.unSubscribe(subscriptionProfile!);
    }
  }

  Future<void> getMessagesList({required String msgFromProfileId, required String msgToProfileID, date, required page}) async {
    try {
      final QueryBuilder<ParseObject> query;
      final QueryBuilder<ParseObject> query2;
      if (date != null) {
        query = QueryBuilder<ParseObject>(ParseObject(tableName!))
          ..whereEqualTo('ToProfile', ProfilePage()..objectId = msgFromProfileId)
          ..whereEqualTo('FromProfile', ProfilePage()..objectId = msgToProfileID)
          ..whereGreaterThan('createdAt', date);
        query2 = QueryBuilder<ParseObject>(ParseObject(tableName!))
          ..whereEqualTo('ToProfile', ProfilePage()..objectId = msgToProfileID)
          ..whereEqualTo('FromProfile', ProfilePage()..objectId = msgFromProfileId)
          ..whereGreaterThan('createdAt', date);
      } else {
        query = QueryBuilder<ParseObject>(ParseObject(tableName!))
          ..whereEqualTo('ToProfile', ProfilePage()..objectId = msgFromProfileId)
          ..whereEqualTo('FromProfile', ProfilePage()..objectId = msgToProfileID);
        query2 = QueryBuilder<ParseObject>(ParseObject(tableName!))
          ..whereEqualTo('ToProfile', ProfilePage()..objectId = msgToProfileID)
          ..whereEqualTo('FromProfile', ProfilePage()..objectId = msgFromProfileId);
      }
      final ParseObject playerObject = ParseObject(tableName!);
      final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(playerObject, [query, query2])
        ..orderByDescending('createdAt')
        ..includeObject(['FromUser', 'ToUser', 'Gifts'])
        ..setLimit(20)
        ..setAmountToSkip(page);

      final apiResponse = await mainQuery.query();
      if (apiResponse.success && apiResponse.results != null) {
        if (apiResponse.result[0]['FromUser'] == StorageService.getBox.read('ObjectId')) {
          if (apiResponse.result[0]['ToUser']['StatusActive'] == 0) {
            isInactive.value = true;
          }
        } else {
          if (apiResponse.result[0]['FromUser']['StatusActive'] == 0) {
            isInactive.value = true;
          }
        }
        for (final message in apiResponse.results ?? []) {
          chatList.value = [message, ...chatList];
          addConversation(parseObject: message);
        }
        newChatAdded.value = chatList.length;
      } else {
        chatList.clear();
      }
    } catch (e) {
      if (kDebugMode) {
        print("you don't have any message  $e");
      }
      chatList.clear();
    }
    isChatLoading.value = false;
  }

  @override
  void onInit() async {
    scrollController.addListener(_scrollListener);
    fromProfileId = StorageService.getBox.read('msgFromProfileId');
    toProfileId = StorageService.getBox.read('msgToProfileId');
    tableName = StorageService.getBox.read('chattablename');
    isChatLoading.value = true;
    final List<ApiResponse?> users = await Future.wait([
      UserProfileProviderApi().getById(fromProfileId!),
      UserProfileProviderApi().getById(toProfileId!),
      DeleteConversationApi().deleted(fromId: fromProfileId!, toId: toProfileId!, type: tableName == 'Chat_Message' ? 'Chat' : "Mensajes")
    ]);
    myProfile = users[0]!.result;
    oppositeProfile = users[1]!.result;
    if (tableName == 'Chat_Message') {
      await getMessagesList(
          msgFromProfileId: fromProfileId!,
          msgToProfileID: toProfileId!,
          date: users[2] != null ? users[2]!.result['updatedAt'] : null,
          page: loadPage.value);
      isChatLoading.value = false;
      loadPage.value += 20;
      isNoCall.value = (oppositeProfile!['NoCalls'] ?? false);
      isNoVideocall.value = (oppositeProfile!['NoVideocalls'] ?? false);
      isNoChat.value = (oppositeProfile!['NoChats'] ?? false);
      isHasLoggedIn.value = (oppositeProfile!['User']['HasLoggedIn'] ?? true);
      final bool isOn = (oppositeProfile!['User']['showOnline'] ?? false);
      isOnline = isOn.obs;
      isUpdate.value = !isUpdate.value;
      if (oppositeProfile!['User']['lastOnline'] != null) {
        userLastOnline.value = oppositeProfile!['User']['lastOnline'];
      }
      userLiveQueryStart();
    } else {
      await getMessagesList(
          msgFromProfileId: fromProfileId!,
          msgToProfileID: toProfileId!,
          date: users[2] != null ? users[2]!.result['updatedAt'] : null,
          page: loadPage.value);
      isChatLoading.value = false;
      loadPage.value += 20;
      userLiveQueryStart();
    }

    typingStatusLiveQuery();
    startLiveMessageQuery();
    // if ((await userReview())) {
    //   startTimer();
    // }
    super.onInit();

    if (tableName == 'Chat_Message') {
      final List<ApiResponse?> data = await Future.wait([
        UserChatMessageProviderApi().messageCount(StorageService.getBox.read('msgFromProfileId'), StorageService.getBox.read('msgToProfileId')),
        UserChatGiftsProviderApi.getAllGifts()
      ]);
      // All unread chats
      List<ChatMessage> chatData = [];
      if (data[0] != null && data[0]!.results != null) {
        for (final ele in data[0]!.results ?? []) {
          final ChatMessage chatMessage = ChatMessage();
          chatMessage.objectId = ele['objectId'];
          chatMessage.isRead = true;
          chatData.add(chatMessage);
        }
        UserChatMessageProviderApi().updateAll(chatData);
      }
      // Table [Gifts] get all gifts for chat
      giftsList.clear();
      if (data[1] != null && data[1]!.results != null) {
        for (final element in data[1]!.results ?? []) {
          giftsList.add(element);
        }
      }
    } else {
      final ApiResponse? data =
          await LikeMsgProviderApi().messageCount(StorageService.getBox.read('msgFromProfileId'), StorageService.getBox.read('msgToProfileId'));
      List<LikeMessage> messageData = [];
      if (data != null && data.results != null) {
        for (final ele in data.results ?? []) {
          final LikeMessage likeMessage = LikeMessage();
          likeMessage.objectId = ele['objectId'];
          likeMessage.isRead = true;
          messageData.add(likeMessage);
        }
        LikeMsgProviderApi().updateAll(messageData);
      }
    }
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    toChatUser.value = '';
    toMessageUser.value = '';
    stopTimer();
    cancelMessageQuery();
    isChatLoading.value = false;
  }

  void stopTimer() {
    if (timer != null) {
      timer!.cancel();
    }
    showRate.value = false;
  }

  void startTimer() {
    timer = Timer.periodic(Duration(minutes: reviewTime), (Timer t) {
      if (!Get.currentRoute.contains("/ConversationScreen")) {
        showRate.value = true;
      }
      if (showRate.value == false) {
        showRate.value = true;
        rateAppDialog1(Get.context!, submit: (text) async {
          if (text.isNotEmpty) {
            final ParseObject review = ParseObject('User_Review');
            review['User'] = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
            review['Message'] = text;
            review['status'] = 0;
            await review.save();
            Get.back();
            Get.back();
            timer!.cancel();
            t.cancel();
          }
        }).whenComplete(() {
          showRate.value = false;
          FocusManager.instance.primaryFocus!.unfocus();
        });
      }
    });
  }

  /// LIVE QUERY FOR USER STATUS UPDATE FOR CHAT ONLINE OFFLINE
  final LiveQuery liveQueryUser = LiveQuery(debug: false);

  Subscription<ParseObject>? subscriptionUser;

  final LiveQuery liveQueryProfile = LiveQuery(debug: false);

  Subscription<ParseObject>? subscriptionProfile;

  void userLiveQueryStart() async {
    try {
      final QueryBuilder<UserLogin> queryData = QueryBuilder<UserLogin>(UserLogin())..whereEqualTo('objectId', oppositeProfile!['User']['objectId']);
      final QueryBuilder<ProfilePage> queryProfileData = QueryBuilder<ProfilePage>(ProfilePage())
        ..whereEqualTo('objectId', oppositeProfile!['objectId'])..includeObject(['User']);
      subscriptionUser = await liveQueryUser.client.subscribe(queryData);
      subscriptionProfile = await liveQueryProfile.client.subscribe(queryProfileData);
      subscriptionUser!.on(LiveQueryEvent.update, (ParseObject value) {
        final bool isOn = (value['showOnline'] ?? false);
        isHasLoggedIn.value = (value['HasLoggedIn'] ?? false);
        isOnline = isOn.obs;
        isUpdate.value = !isUpdate.value;
        if (value['lastOnline'] != null) {
          userLastOnline.value = value['lastOnline'];
        }
        isCallBusy.value = (value['IsBusy'] ?? false); // check user is busy another call or not
      });

      subscriptionProfile!.on(LiveQueryEvent.update, (ParseObject value) {
        isNoCall.value = (value['NoCalls'] ?? false); //NoCalls
        isNoVideocall.value = (value['NoVideocalls'] ?? false); //NoVideocalls
        isNoChat.value = (value['NoChats'] ?? false); //NoChats
        isUpdate.value = !isUpdate.value;
      });
    } catch (trace, error) {
      if (kDebugMode) {
        print("userLiveQueryStart trace ::::: $trace");
        print("userLiveQueryStart error ::::: $error");
      }
    }
  }

  Widget userStatus({String? description, required bool onlineStatus, required bool userIsDeleted}) {
    if (!userIsDeleted) {
      // WHEN USER NOT DELETE OR BLOCKED
      if (isInactive.value) {
        return Row(
          key: const ValueKey(0),
          children: [
            CircleAvatar(radius: 6.r, backgroundColor: ConstColors.offlineColor),
            SizedBox(width: 5.w),
            Styles.regular('inactive'.tr, fs: 14.sp),
          ],
        );
      } else {
        if (description != null ) {
          return Styles.regular(description, key: const ValueKey(1), fs: 14.sp, lns: 1, ov: TextOverflow.ellipsis);
        } else {
          if (onlineStatus) {
            if (isOnline == null) {
              return const SizedBox.shrink(key: ValueKey(2));
            } else if (isOnline!.value) {
              return Row(
                key: const ValueKey(3),
                children: [
                  CircleAvatar(radius: 6.r, backgroundColor: ConstColors.lightGreenColor),
                  SizedBox(width: 5.w),
                  Styles.regular('Online'.tr, fs: 14.sp),
                ],
              );
            } else {
              return Row(
                key: const ValueKey(4),
                children: [
                  CircleAvatar(radius: 6.r, backgroundColor: ConstColors.offlineColor),
                  SizedBox(width: 5.w),
                  Styles.regular(
                      GetTimeAgo.getTimeAgo(userLastOnline.value,
                          locale: StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode),
                      fs: 14.sp,
                      c: ConstColors.bottomBorder,
                      lns: 1),
                ],
              );
            }
          } else {
            return Row(
              key: const ValueKey(5),
              children: [
                CircleAvatar(radius: 6.r, backgroundColor: ConstColors.offlineColor),
                SizedBox(width: 5.w),
                Styles.regular(StorageService.getBox.read('Gender') == 'female' ? 'male_Offline'.tr : 'female_Offline'.tr, fs: 14.sp, lns: 1),
              ],
            );
          }
        }
      }
    } else {
      // WHEN USER DELETE OR BLOCKED
      return Row(
        key: const ValueKey(6),
        children: [
          CircleAvatar(radius: 6.r, backgroundColor: ConstColors.redColor),
          SizedBox(width: 5.w),
          Styles.regular(StorageService.getBox.read('Gender') == 'female' ? 'male_Offline'.tr : 'female_Offline'.tr, fs: 16.sp, lns: 1),
        ],
      );
    }
  }

  instantMessage() {
    final String formattedTime = DateFormat.jm().format(DateTime.now());
    final outputFormat = DateFormat('MM/dd/yyyy');
    final outputDate = outputFormat.format(DateTime.now());
    final String time = '$outputDate a las$formattedTime';
    for (var element in chatList) {
      if (element['FromProfile']['objectId'] == myProfile!['objectId']) {
        element["Message"] = _priceController.chat.text;
        element["MessageTime"] = time;
        element["offline"] = true;
        isMyMsgAvail.value = true;
        break;
      }
    }
  }

  Widget ourMessage({required ParseObject parseObject, required String length, required String tableName}) {
    // final Key thisKey = Key(length);
    final bool isRead = (parseObject['isRead'] /*&& chatList.last.objectId == parseObject.objectId*/);
    return Row(
      // key: thisKey,
      // do not remove this objectId if you change this then also change in updateConversation() logic
      key: Key(parseObject.objectId.toString()),
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (tableName == 'Chat_Message') ...[
              if (parseObject["ChatType"].toString().contains('Gift') && parseObject["Message"].toString().contains('http')) ...[
                // when user send gift in chat
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomLeft,
                  children: [
                    Image.network(
                        parseObject['Gifts'] != null
                            ? parseObject['Gifts']['Image'].url
                            : parseObject["Message"],
                        height: 107.w,
                        width: 107.w,
                        fit: BoxFit.cover),
                    if (isRead)
                      Positioned(
                        bottom: -5.h,
                        left: -18.w,
                        child: Container(
                          width: 29.w,
                          height: 29.w,
                          padding: EdgeInsets.all(3.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, border: Border.all(color: ConstColors.white, width: 2.w), color: const Color(0xffEFEFEF)),
                          child: const SvgView('assets/Icons/read.svg', fit: BoxFit.scaleDown),
                        ),
                      ),
                  ],
                ),
              ] else if (parseObject["ChatType"].toString().contains('Image')) ...[
                // when user send Image in chat
                SizedBox(height: 8.h),
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomLeft,
                  children: [
                    ImageView(
                      parseObject["Post"] != null ? parseObject["Post"].url : 'http//',
                      border: Border.all(color: ConstColors.themeColor, width: 2.w),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(3.r)),
                      height: parseObject["IsLandscape"] ? 175.h : 250.w,
                      width: parseObject["IsLandscape"] ? 250.w : 175.w,
                      placeholder: preCachedImage(const ValueKey(0)),
                      onTap: () {
                        Get.to(() => ChatVideoScreen(image: parseObject["Post"].url, isLandscape: parseObject["IsLandscape"]));
                      },
                    ),
                    if (isRead)
                      Positioned(
                        bottom: -5.h,
                        left: -18.w,
                        child: Container(
                          width: 29.w,
                          height: 29.w,
                          padding: EdgeInsets.all(3.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, border: Border.all(color: ConstColors.white, width: 2.w), color: const Color(0xffEFEFEF)),
                          child: const SvgView('assets/Icons/read.svg', fit: BoxFit.scaleDown),
                        ),
                      ),
                  ],
                ),
              ] else if (parseObject["ChatType"].toString().contains('Video')) ...[
                // when user send Video in chat
                SizedBox(height: 8.h),
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomLeft,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(() => ChatVideoScreen(
                            url: parseObject["VideoPost"].url, image: parseObject["Post"].url, isLandscape: parseObject["IsLandscape"]));
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ImageView(
                            parseObject["Post"] != null ? parseObject["Post"].url : 'http//',
                            border: Border.all(color: ConstColors.themeColor, width: 2.w),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.r),
                                topRight: Radius.circular(16.r),
                                bottomLeft: Radius.circular(16.r),
                                bottomRight: Radius.circular(3.r)),
                            height: parseObject["IsLandscape"] ? 175.h : 250.w,
                            width: parseObject["IsLandscape"] ? 250.w : 175.w,
                            placeholder: preCachedImage(const ValueKey(0)),
                          ),
                          SvgView('assets/Icons/video_player.svg', height: 83.w, width: 83.w, fit: BoxFit.scaleDown),
                        ],
                      ),
                    ),
                    if (isRead)
                      Positioned(
                        bottom: -5.h,
                        left: -18.w,
                        child: Container(
                          width: 29.w,
                          height: 29.w,
                          padding: EdgeInsets.all(3.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, border: Border.all(color: ConstColors.white, width: 2.w), color: const Color(0xffEFEFEF)),
                          child: const SvgView('assets/Icons/read.svg', fit: BoxFit.scaleDown),
                        ),
                      ),
                  ],
                )
              ] else ...[
                // when user send Text in chat
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10.h, bottom: 10.h, left: 12.w, right: 10.w),
                      margin: EdgeInsets.only(top: 10.h, bottom: 3.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                            bottomLeft: Radius.circular(16.r),
                            bottomRight: Radius.circular(3.r)),
                        color: ConstColors.themeColor,
                      ),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: MediaQuery.sizeOf(Get.context!).width * 0.65), // Adjust max width as needed for max massage
                        child: Styles.regular(parseObject["Message"], fs: 16.sp, c: Colors.white, al: TextAlign.start),
                      ),
                    ),
                    if (isRead)
                      Positioned(
                        bottom: -5.h,
                        left: -18.w,
                        child: Container(
                          width: 29.w,
                          height: 29.w,
                          padding: EdgeInsets.all(3.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, border: Border.all(color: ConstColors.white, width: 2.w), color: const Color(0xffEFEFEF)),
                          child: const SvgView('assets/Icons/read.svg', fit: BoxFit.scaleDown),
                        ),
                      ),
                  ],
                ),
              ]
            ] else if (tableName == 'Like_Message') ...[
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomLeft,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10.h, bottom: 10.h, left: 12.w, right: 10.w),
                    margin: EdgeInsets.only(top: 10.h, bottom: 3.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(3.r)),
                      color: const Color(0xFF767676),
                    ),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: MediaQuery.sizeOf(Get.context!).width * 0.65), // Adjust max width as needed for max massage
                      child: Styles.regular(parseObject["Message"], fs: 16.sp, c: Colors.white, al: TextAlign.start),
                    ),
                  ),
                  if (parseObject['isPurchased'] ?? true)
                    Positioned(
                      bottom: -5.h,
                      left: -18.w,
                      child: Container(
                        width: 29.w,
                        height: 29.w,
                        padding: EdgeInsets.all(3.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, border: Border.all(color: ConstColors.white, width: 2.w), color: const Color(0xffEFEFEF)),
                        child: const SvgView('assets/Icons/read.svg', fit: BoxFit.scaleDown),
                      ),
                    ),
                ],
              ),
            ],
            Styles.regular(DateFormat('HH:mm').format(parseObject["createdAt"].toLocal()), fs: 12.sp),
          ],
        ),
      ],
    );
  }

  Widget oppositeMessage({required ParseObject parseObject, required String length, required String tableName}) {
    final RxBool isPurchasing = false.obs;
    // final Key thisKey = Key(length);
    final bool delete = ((oppositeProfile!['isDeleted'] ?? false) ||
        (oppositeProfile!['IsBlocked'] ?? false) ||
        (oppositeProfile!['User']['isDeleted'] ?? false) ||
        (oppositeProfile!['User']['IsBlocked'] ?? false));
    return Row(
      // key: thisKey,
      // do not remove this objectId if you change this then also change in updateConversation() logic
      key: Key(parseObject.objectId.toString()),
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ImageView(oppositeProfile!['Imgprofile'].url, height: 50.w, width: 50.w, circle: true),
            // check when opposite user is delete or block
            if (delete)
              Container(
                height: 50.w,
                width: 50.w,
                padding: EdgeInsets.all(16.h),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.6)),
                child: SvgView("assets/Icons/ProfileDelete.svg", height: 30.w, width: 30.w, fit: BoxFit.scaleDown),
              ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.h, bottom: 3.h, left: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // for chat message
              if (tableName == 'Chat_Message') ...[
                if (parseObject["ChatType"].toString().contains('Gift')) ...[
                  // when user send Gift in chat
                  Image.network(parseObject['Gifts'] != null ? parseObject['Gifts']['Image'].url : parseObject["Message"],
                      height: 107.w, width: 107.w, fit: BoxFit.cover),
                ] else if (parseObject["ChatType"].toString().contains('Image')) ...[
                  // when user send Image in chat
                  ImageView(
                    parseObject["Post"] != null ? parseObject["Post"].url : 'http//',
                    border: Border.all(color: const Color(0xffEAEBEF), width: 2.w),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                        bottomLeft: Radius.circular(3.r),
                        bottomRight: Radius.circular(16.r)),
                    height: parseObject["IsLandscape"] ? 175.h : 250.w,
                    width: parseObject["IsLandscape"] ? 250.w : 175.w,
                    placeholder: preCachedImage(const ValueKey(0)),
                    onTap: () {
                      Get.to(() => ChatVideoScreen(image: parseObject["Post"].url, isLandscape: parseObject["IsLandscape"]));
                    },
                  ),
                ] else if (parseObject["ChatType"].toString().contains('Video')) ...[
                  // when user send Video in chat
                  InkWell(
                    onTap: () {
                      Get.to(() => ChatVideoScreen(
                          url: parseObject["VideoPost"].url, image: parseObject["Post"].url, isLandscape: parseObject["IsLandscape"]));
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ImageView(
                          parseObject["Post"] != null ? parseObject["Post"].url : 'http//',
                          border: Border.all(color: const Color(0xffEAEBEF), width: 2.w),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              topRight: Radius.circular(16.r),
                              bottomLeft: Radius.circular(3.r),
                              bottomRight: Radius.circular(16.r)),
                          height: parseObject["IsLandscape"] ? 175.h : 250.w,
                          width: parseObject["IsLandscape"] ? 250.w : 175.w,
                          placeholder: preCachedImage(const ValueKey(0)),
                        ),
                        SvgView('assets/Icons/video_player.svg', height: 83.w, width: 83.w, fit: BoxFit.scaleDown),
                      ],
                    ),
                  )
                ] else ...[
                  // when user send text in chat
                  Container(
                    padding: EdgeInsets.only(top: 10.h, bottom: 10.h, left: 12.w, right: 10.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xffEAEBEF),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r),
                          bottomLeft: Radius.circular(3.r)),
                    ),
                    child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: MediaQuery.sizeOf(Get.context!).width * 0.65), // Adjust max width as needed for max massage
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Styles.regular(parseObject['Message'], fs: 16.sp, c: Colors.black, al: TextAlign.start),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.ease,
                              child: Obx(() {
                                pictureX.chatTranslate.value;
                                return Column(
                                  key: const ValueKey(1),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (pictureX.chatTranslate.value)
                                      FutureBuilder<TranslateLan?>(
                                          future: TranslateController().translateLang(text: parseObject["Message"], targetLanguage: 'es'),
                                          builder: (context, translateSnap) {
                                            if (translateSnap.hasData && translateSnap.connectionState == ConnectionState.done) {
                                              return Styles.regular(translateSnap.data!.data.translations[0].translatedText,
                                                  fs: 16.sp, c: ConstColors.redColor, al: TextAlign.start, key: const ValueKey(2));
                                            } else {
                                              return Shimmer.fromColors(
                                                highlightColor: ConstColors.themeColor,
                                                baseColor: ConstColors.grey,
                                                child: Styles.regular(parseObject['Message'],
                                                    fs: 16.sp, c: ConstColors.black, key: const ValueKey(3), al: TextAlign.start),
                                              );
                                            }
                                          }),
                                  ],
                                );
                              }),
                            ),
                          ],
                        )),
                  ),
                ]
              ] else if (tableName == 'Like_Message') ...[
                // for heart message
                Obx(() {
                  isPurchasing.value;
                  return InkWell(
                    onTap: (parseObject["isPurchased"] || isPurchasing.value)
                        ? null
                        : () async {
                            isPurchasing.value = true;
                            if (_priceController.userTotalCoin.value >= _priceController.heartMessagePrice.value) {
                              // final String ind = thisKey.toString().replaceAll(RegExp(r'[^0-9]'), '');
                              final value = await parseCloudInteraction(
                                toUserId: StorageService.getBox.read('ObjectId'),
                                toProfileId: parseObject['ToProfile']['objectId'],
                                type: 'LikeMessagePurchase',
                                fromProfileId: parseObject['FromProfile']['objectId'],
                                // isPairUpdate: (ind == '1' || int.parse(ind) == conversationList.length), // old logic
                                isPairUpdate: chatList.isNotEmpty && (chatList.last['objectId'] == parseObject['objectId']),
                                objectId: parseObject['objectId'],
                                fromUserId: parseObject["FromUser"]['objectId'],
                              );
                              if (value['success'] == true) {
                                parseObject["isPurchased"] = true;
                              } else if (value['success'] == false) {
                                if (value['message'] == 'User has no coins') {
                                  Get.to(() => StoreScreen());
                                }
                              }
                              pictureX.spam.clear();
                            } else {
                              Get.to(() => StoreScreen());
                            }
                            isPurchasing.value = false;
                          },
                    child: Container(
                      padding: EdgeInsets.only(top: 10.h, bottom: 10.h, left: 12.w, right: 10.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: parseObject["isPurchased"] ? const Color(0xffEAEBEF) : ConstColors.themeColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                            bottomRight: Radius.circular(16.r),
                            bottomLeft: Radius.circular(3.r)),
                      ),
                      child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: MediaQuery.sizeOf(Get.context!).width * 0.65), // Adjust max width as needed for max massage
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.ease,
                            child: isPurchasing.value
                                ? Shimmer.fromColors(
                                    key: const ValueKey(0),
                                    highlightColor: ConstColors.themeColor,
                                    baseColor: ConstColors.grey,
                                    child: Styles.regular('view_message'.tr, fs: 16.sp, c: ConstColors.black, al: TextAlign.start),
                                  )
                                : Column(
                                    key: const ValueKey(1),
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!parseObject["isPurchased"])
                                        Styles.regular('view_message'.tr,
                                            fs: 16.sp, c: ConstColors.white, key: const ValueKey(2), al: TextAlign.start)
                                      else ...[
                                        Styles.regular(parseObject['Message'],
                                            fs: 16.sp, c: Colors.black, al: TextAlign.start, key: const ValueKey(3)),
                                        if (pictureX.chatTranslate.value)
                                          FutureBuilder<TranslateLan?>(
                                              future: TranslateController().translateLang(text: parseObject["Message"], targetLanguage: 'es'),
                                              builder: (context, translateSnap) {
                                                if (translateSnap.hasData && translateSnap.connectionState == ConnectionState.done) {
                                                  return Styles.regular(translateSnap.data!.data.translations[0].translatedText,
                                                      fs: 16.sp, c: ConstColors.redColor, al: TextAlign.start, key: const ValueKey(4));
                                                } else {
                                                  return Shimmer.fromColors(
                                                    highlightColor: ConstColors.themeColor,
                                                    baseColor: ConstColors.grey,
                                                    child: Styles.regular(parseObject['Message'],
                                                        fs: 16.sp, c: ConstColors.black, key: const ValueKey(5), al: TextAlign.start),
                                                  );
                                                }
                                              }),
                                      ],
                                    ],
                                  ),
                          )),
                    ),
                  );
                }),
              ],
              SizedBox(height: 3.h),
              Styles.regular(DateFormat('HH:mm').format(parseObject['createdAt'].toLocal()), fs: 12.sp),
            ],
          ),
        ),
      ],
    );
  }
}

/// DATE TIME
String getWhen({required DateTime date, String? format}) {
  final DateTime now = DateTime.now();
  final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Start of the week (Monday)
  final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6)); // End of the week (Sunday)
  final DateTime startOfMonth = DateTime(now.year, now.month, 1);
  final DateTime endOfMonth = DateTime(now.year, now.month + 1, 0); // Last day of the month

  String when;
  if (date.day == now.day) {
    when = 'Today'.tr;
  } else if (date.day == now.subtract(const Duration(days: 1)).day && date.month == now.month) {
    when = 'yesterday'.tr;
  } else if (date.isAfter(startOfWeek) && date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
    // Day of the current weeks
    when = DateFormat('EEEE', StorageService.getBox.read('languageCode')).format(date);
  } else if (date.isAfter(startOfMonth) && date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
    // Day of the current months
    when =
        GetTimeAgo.parse(date, locale: StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode, pattern: "dd-MMM-yyyy hh:mm aa");
  } else {
    when = DateFormat(format ?? 'dd MMM y', StorageService.getBox.read('languageCode')).format(date);
  }
  return when;
}
