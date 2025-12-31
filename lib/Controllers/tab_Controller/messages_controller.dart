import 'dart:async';

import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/user_provider/tab_provider/provider_likemsg.dart';
import 'package:eypop/models/tab_model/like_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../back4appservice/user_provider/delete_conversation_api.dart';
import '../../back4appservice/user_provider/tab_provider/provider_chatmsg.dart';
import '../../back4appservice/user_provider/users/provider_profileuser_api.dart';
import '../../models/tab_model/chat_message.dart';
import '../../models/user_login/user_profile.dart';
import '../../service/local_storage.dart';
import '../price_controller.dart';

class MessagesController extends GetxController {
  TextEditingController chat = TextEditingController();
  final UserController userController = Get.put(UserController());

  final PriceController priceController = Get.put(PriceController());
  RxList chatMessages = [].obs;
  RxList messages = [].obs;
  List<ChatMessage> randomChatMsg = <ChatMessage>[];
  RxInt length = 0.obs;
  String? meDefultId;
  String? tableName;

  RxInt messagesLength = 0.obs;
  RxList<ChatMessage> messagesList = <ChatMessage>[].obs;
  String? toUserID;

  final ScrollController scrollController = ScrollController();
  final UserChatMessageProviderApi userChatMessageProviderApi = UserChatMessageProviderApi();
  final LikeMsgProviderApi userLikeMessageProviderApi = LikeMsgProviderApi();
  final UserProfileProviderApi userprofileProvider = UserProfileProviderApi();

  Future<void> save({required String toProfile, required String meDefualtId, String? toUser, String? gender, required String tableName}) async {
    await priceController.coinService('ChatMessage', gender, toProfile, toUser, tableName: tableName /*'Chat_Message'*/, fromProfile: meDefualtId, catValue: priceController.chatMessagePrice.value);
  }

  RxList<ParseObject> chatList = <ParseObject>[].obs;
  final LiveQuery liveQuery = LiveQuery(debug: false);
  Subscription<ParseObject>? subscription;

  startLiveMessageQuery() async {
    try {
      final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject(tableName!))
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = meDefultId)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = toUserID);
      final QueryBuilder<ParseObject> query2 = QueryBuilder<ParseObject>(ParseObject(tableName!))
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toUserID)
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = meDefultId);

      ParseObject playerObject = ParseObject(tableName!);
      QueryBuilder<ParseObject> queryPostData = QueryBuilder.or(
        playerObject,
        [query, query2],
      );
      subscription = await liveQuery.client.subscribe(queryPostData);
      subscription!.on(LiveQueryEvent.create, (value) {
        chatList.add(value);
      });
      subscription!.on(LiveQueryEvent.update, (value) {
        if (kDebugMode) {
          print('*** UPDATE ***: $value ');
        }
        try {
          chatList[chatList.indexWhere((element) => element.objectId == value.objectId)] = value;
        } catch (e) {
          if (kDebugMode) {
            print('error in message controller update live query $e');
          }
        }
      });
      subscription!.on(LiveQueryEvent.delete, (value) {
        if (kDebugMode) {
          print('*** DELETE ***: $value ');
        }
        chatList.removeWhere((element) => element.objectId == value.objectId);
      });
    } catch (trace, error) {
      if (kDebugMode) {
        print("trace ::::: $trace");
        print("error ::::: $error");
      }
    }
  }

  void cancelMessageQuery() async {
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }
  }

  void getMessagesList({msgFromProfileId, msgToProfileID, date}) async {
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
    ParseObject playerObject = ParseObject(tableName!);
    QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(
      playerObject,
      [query, query2],
    )..orderByAscending('createdAt');
    final apiResponse = await mainQuery.query();
    if (apiResponse.success && apiResponse.results != null) {
      chatList.addAll(apiResponse.results as List<ParseObject>);

      ///crash
    } else {
      chatList.clear();
    }
    isChatLoading.value = false;
  }

  RxBool isChatLoading = false.obs;

  @override
  void onInit() async {
    meDefultId = StorageService.getBox.read('msgFromProfileId');
    toUserID = StorageService.getBox.read('msgToProfileId');
    tableName = StorageService.getBox.read('chattablename');
    isChatLoading.value = true;
    if (tableName == 'Chat_Message' /*Like_Message*/) {
      DeleteConversationApi().deleted(fromId: meDefultId!, toId: toUserID!, type: 'Chat').then((value) {
        getMessagesList(msgFromProfileId: meDefultId!, msgToProfileID: toUserID!, date: value != null ? value.result['updatedAt'] : null);
      });
    } else {
      DeleteConversationApi().deleted(fromId: meDefultId!, toId: toUserID!, type: 'Mensajes').then((value) {
        getMessagesList(msgFromProfileId: meDefultId!, msgToProfileID: toUserID!, date: value != null ? value.result['updatedAt'] : null);
      });
    }
    super.onInit();
    startLiveMessageQuery();

    if (tableName == 'Chat_Message') {
      ApiResponse? data = await UserChatMessageProviderApi().messageCount(StorageService.getBox.read('msgFromProfileId'), StorageService.getBox.read('msgToProfileId'));
      List<ChatMessage> chatData = [];
      if (data != null) {
        for (int index = 0; index < data.results!.length; index++) {
          ChatMessage chatMessage = ChatMessage();
          chatMessage.objectId = data.results![index]['objectId'];
          chatMessage.isRead = true;
          chatData.add(chatMessage);
        }
        UserChatMessageProviderApi().updateAll(chatData);
      }
    } else {
      ApiResponse? data = await LikeMsgProviderApi().messageCount(StorageService.getBox.read('msgFromProfileId'), StorageService.getBox.read('msgToProfileId'));
      List<LikeMessage> messageData = [];
      if (data != null) {
        for (int index = 0; index < data.results!.length; index++) {
          LikeMessage likeMessage = LikeMessage();
          likeMessage.objectId = data.results![index]['objectId'];
          likeMessage.isRead = true;
          messageData.add(likeMessage);
        }
        LikeMsgProviderApi().updateAll(messageData);
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
    cancelMessageQuery();
  }
}
