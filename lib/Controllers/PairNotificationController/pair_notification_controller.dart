import 'dart:async';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/models/new_notification/new_notification_pair.dart';
import 'package:eypop/models/tab_model/chat_message.dart';
import 'package:eypop/models/tab_model/like_message.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../back4appservice/user_provider/tab_provider/provider_chatmsg.dart';
import '../../back4appservice/user_provider/tab_provider/provider_likemsg.dart';
import '../../models/verticaltab_model/blockuser.dart';
import '../../service/local_storage.dart';

class PairNotificationController extends GetxController {
  @override
  void onInit() async {
    getData();
    getMeBlockUserProfile();
    if (StorageService.getBox.read('ObjectId') != null) {
      startPairLiveQuery();
      startBlockLiveQuery();
      await loadAllInteraction();
    }
    super.onInit();
  }

  // All Interaction
  Future<void> loadAllInteraction() async {
    try {
      isLoading.value = true;
      final List<ApiResponse?> allInteraction = await Future.wait([
        //0 ChatMessage // Charlas
        getFutureData(type: 'ChatMessage', page: 0, limit: 5),
        //1 HeartMessage // Mensajes
        getFutureData(type: 'HeartMessage', page: 0, limit: 5),
        //2 Call // Llamadas
        getFutureData(type: 'Call', page: 0, limit: 5),
        //3 VideoCall // Videollamadas
        getFutureData(type: 'VideoCall', page: 0, limit: 5),
        //4 HeartLike // Me gustas
        getFutureData(type: 'HeartLike', page: 0, limit: 5),
        //5 Visit // Visitas
        getFutureData(type: 'Visit', page: 0, limit: 5),
        //6 WinkMessage // Guiños
        getFutureData(type: 'WinkMessage', page: 0, limit: 5),
        //7 LipLike // Besos
        getFutureData(type: 'LipLike', page: 0, limit: 5),
        //8 Wishes // wishes
        getFutureData(type: 'Wishes', page: 0, limit: 5),
        //9 BlocUser // Bloqueados
        getOutGoingData(type: 'BlocUser', page: 0, limit: 5),
        //10 ChatGift // Regalos
        getFutureData(type: 'ChatGift', page: 0, limit: 5),
      ]);

      if (allInteraction[0] != null) {
        //0 ChatMessage // Charlas
        chatMessageList.clear();
        for (final element in allInteraction[0]!.results ?? []) {
          chatMessageList.add(element);
        }
      }
      if (allInteraction[1] != null) {
        //1 HeartMessage // Mensajes
        heartMessageList.clear();
        for (final element in allInteraction[1]!.results ?? []) {
          heartMessageList.add(element);
        }
      }
      if (allInteraction[2] != null) {
        //2 Call // Llamadas
        callList.clear();
        for (final element in allInteraction[2]!.results ?? []) {
          callList.add(element);
        }
      }
      if (allInteraction[3] != null) {
        //3 VideoCall // Videollamada
        videoCallList.clear();
        for (final element in allInteraction[3]!.results ?? []) {
          videoCallList.add(element);
        }
      }
      if (allInteraction[4] != null) {
        //4 HeartLike // Me gustas
        heartLikeList.clear();
        for (final element in allInteraction[4]!.results ?? []) {
          heartLikeList.add(element);
        }
      }
      if (allInteraction[5] != null) {
        //5 Visit // Visitas
        visitList.clear();
        for (final element in allInteraction[5]!.results ?? []) {
          visitList.add(element);
        }
      }
      if (allInteraction[6] != null) {
        //6 WinkMessage // Guiños
        winkList.clear();
        for (final element in allInteraction[6]!.results ?? []) {
          winkList.add(element);
        }
      }
      if (allInteraction[7] != null) {
        //7 LipLike // Besos
        lipLikeList.clear();
        for (final element in allInteraction[7]!.results ?? []) {
          lipLikeList.add(element);
        }
      }
      if (allInteraction[8] != null) {
        //8 Wishes // wishes
        wishList.clear();
        for (final element in allInteraction[8]!.results ?? []) {
          wishList.add(element);
        }
      }
      if (allInteraction[9] != null) {
        //9 BlocUser // Bloqueados
        blockList.clear();
        for (final element in allInteraction[9]!.results ?? []) {
          blockList.add(element);
        }
      }
      if (allInteraction[10] != null) {
        //10 ChatGift // Regalos
        giftList.clear();
        for (final element in allInteraction[10]!.results ?? []) {
          giftList.add(element);
        }
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('Hello all loadAllInteraction ERROR $e');
      }
    }
  }

  final LiveQuery liveQuery = LiveQuery(autoSendSessionId: true, debug: false);
  Subscription<ParseObject>? subscription;

  @override
  void onClose() {
    cancelPairLiveQuery();
    super.onClose();
  }

  RxList meBlocked = [].obs;
  RxList<String> meBlockedUserProfile = <String>[].obs;

  final LiveQuery pairLiveQuery = LiveQuery(autoSendSessionId: true, debug: false);
  Subscription<ParseObject>? pairSubscription;

  setMarkAsRead(type, toProfileId, fromProfileId) async {
    if (type == 'Chat') {
      final ApiResponse? data = await UserChatMessageProviderApi().messageCount(toProfileId, fromProfileId);
      List<ChatMessage> chatData = [];
      if (data != null) {
        for (int index = 0; index < data.results!.length; index++) {
          final ChatMessage chatMessage = ChatMessage();
          chatMessage.objectId = data.results![index]['objectId'];
          chatMessage.isRead = true;
          chatData.add(chatMessage);
        }
        UserChatMessageProviderApi().updateAll(chatData);
      }
    } else {
      final ApiResponse? data = await LikeMsgProviderApi().messageCount(toProfileId, fromProfileId);
      List<LikeMessage> messageData = [];
      if (data != null) {
        for (int index = 0; index < data.results!.length; index++) {
          final LikeMessage likeMessage = LikeMessage();
          likeMessage.objectId = data.results![index]['objectId'];
          likeMessage.isRead = true;
          messageData.add(likeMessage);
        }
        LikeMsgProviderApi().updateAll(messageData);
      }
    }
  }

  startBlockLiveQuery() async {
    try {
      final QueryBuilder<BlockUser> queryChatData1 = QueryBuilder<BlockUser>(BlockUser())
        ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('Type', 'BLOCK');

      final QueryBuilder<BlockUser> queryChatData2 = QueryBuilder<BlockUser>(BlockUser())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('Type', 'BLOCK');

      QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(BlockUser(), [queryChatData1, queryChatData2]);
      subscription = await liveQuery.client.subscribe(mainQuery);

      subscription!.on(LiveQueryEvent.create, (value) {
        if (kDebugMode) {
          print('*** CREATE BLOCK ***: $value');
        }
        meBlocked.add(value);
      });
      subscription!.on(LiveQueryEvent.update, (value) {
        if (kDebugMode) {
          print('*** UPDATE BLOCK ***: $value');
        }
        meBlocked.removeWhere((element) => element.objectId == value.objectId);
      });
      subscription!.on(LiveQueryEvent.delete, (value) {
        if (kDebugMode) {
          print('*** DELETE BLOCK ***: $value');
        }
        meBlocked.removeWhere((element) => element.objectId == value.objectId);
      });
    } catch (e) {
      if (kDebugMode) {
        print("error BLOCK LiveQuery::::: $e");
      }
    }
  }

  startPairLiveQuery() async {
    try {
      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..includeObject([
          /*'Users', */ 'FromUser', /* 'ToUser', 'ToProfile', 'FromProfile'*/
        ]);
      final QueryBuilder<PairNotifications> queryChatData2 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..includeObject([
          /*'Users',*/ 'FromUser', /* 'ToUser', 'ToProfile', 'FromProfile'*/
        ]);

      final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(PairNotifications(), [queryChatData1, queryChatData2]);

      pairSubscription = await pairLiveQuery.client.subscribe(mainQuery);

      pairSubscription!.on(LiveQueryEvent.create, (value) {
        if (kDebugMode) {
          print('*** CREATE PairNotification ***: $value');
        }

        notificationSingleAdd(value);
      });
      pairSubscription!.on(LiveQueryEvent.update, (value) {
        if (kDebugMode) {
          print('*** UPDATE PairNotification ***: $value');
        }
        notificationSingleAdd(value);
      });
      pairSubscription!.on(LiveQueryEvent.delete, (value) {
        if (kDebugMode) {
          print('*** DELETE PairNotification ***: $value');
        }
        notificationSingleAdd(value);
      });
    } catch (trace, error) {
      if (kDebugMode) {
        print("trace ::::: $trace");
        print("error ::::: $error");
      }
    }
  }

  void cancelPairLiveQuery() async {
    if (pairSubscription != null) {
      pairLiveQuery.client.unSubscribe(pairSubscription!);
    }
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }
  }

  Future<ApiResponse?> getFutureData({required String type, required int page, required int limit}) async {
    try {
      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('Type', type);

      final QueryBuilder<PairNotifications> queryChatData2 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('Type', type);

      final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(PairNotifications(), [queryChatData1, queryChatData2])
        ..whereNotContainedIn('DeletedUsers', [
          {"__type": "Pointer", "className": "User_login", "objectId": StorageService.getBox.read('ObjectId')}
        ])
        ..setLimit(limit)
        ..setAmountToSkip(page)
        ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile', 'Wishes', 'Gifts', 'call', 'Like_Message', 'Chat_Message'])
        ..orderByDescending('updatedAt');

      return getApiResponse<PairNotifications>(await mainQuery.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse?> getInteractionData({required String type}) async {
    try {
      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('Type', type);

      final QueryBuilder<PairNotifications> queryChatData2 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('Type', type);

      final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(PairNotifications(), [queryChatData1, queryChatData2])
        ..whereNotContainedIn('DeletedUsers', [
          {"__type": "Pointer", "className": "User_login", "objectId": StorageService.getBox.read('ObjectId')}
        ])
        ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile', 'Wishes', 'Gifts'])
        ..setAmountToSkip(historyLimit)
        ..orderByDescending('updatedAt');
      final count = await mainQuery.count();
      mainQuery.setLimit(count.count);
      return getApiResponse<PairNotifications>(await mainQuery.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse?> getDataFromObjectId(objectId) async {
    final QueryBuilder<PairNotifications> query = QueryBuilder<PairNotifications>(PairNotifications())
      ..whereEqualTo('objectId', objectId)
      ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile', 'Wishes']);

    return getApiResponse<PairNotifications>(await query.query());
  }

  Future getData() async {
    try {
      final QueryBuilder<BlockUser> query = QueryBuilder<BlockUser>(BlockUser())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'));
      final QueryBuilder<BlockUser> query2 = QueryBuilder<BlockUser>(BlockUser())
        ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'));
      final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(BlockUser(), [query, query2])
        ..whereEqualTo('Type', 'BLOCK')
        // ..includeObject(['FromUser', 'ToUser', 'ToProfile', 'FromProfile'])
        ..orderByDescending('updatedAt');
      final rr = await mainQuery.count();
      mainQuery.setLimit(rr.count);
      final ApiResponse apiResponse = getApiResponse<BlockUser>(await mainQuery.query());
      meBlocked.value = apiResponse.results != null ? apiResponse.results! : [];
    } catch (e) {
      if (kDebugMode) {
        print('Hello error in get data $e');
      }
    }
  }

  /// GET USER PROFILE WO BLOCK CURRENT USER
  Future<void> getMeBlockUserProfile() async {
    try {
      final QueryBuilder<BlockUser> queryBlock1 = QueryBuilder<BlockUser>(BlockUser())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'));
      final QueryBuilder<BlockUser> queryBlock2 = QueryBuilder<BlockUser>(BlockUser())
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'));
      final QueryBuilder<ParseObject> mainBlockQuery = QueryBuilder.or(BlockUser(), [queryBlock1, queryBlock2])
        ..whereEqualTo('Type', 'BLOCK')
        ..includeObject(['FromUser', 'ToUser', 'ToProfile', 'FromProfile'])
        ..orderByDescending('updatedAt');
      final limit = await mainBlockQuery.count();
      mainBlockQuery.setLimit(limit.count);
      final ApiResponse response = getApiResponse<BlockUser>(await mainBlockQuery.query());
      for (final ele in response.results!) {
        if (!meBlockedUserProfile.contains(ele['ToProfile']['objectId'])) {
          meBlockedUserProfile.add(ele['ToProfile']['objectId']);
        }
        if (!meBlockedUserProfile.contains(ele['FromProfile']['objectId'])) {
          meBlockedUserProfile.add(ele['FromProfile']['objectId']);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('ERROR getMeBlockUserProfile $e');
      }
    }
  }

  Future<ApiResponse?> getFutureCountData(type) async {
    try {
      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
            ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
            ..whereEqualTo('Type', type) /*
        ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])*/
          ;

      final QueryBuilder<PairNotifications> queryChatData2 = QueryBuilder<PairNotifications>(PairNotifications())
            ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
            ..whereEqualTo('Type', type) /*
        ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])*/
          ;

      final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(PairNotifications(), [queryChatData1, queryChatData2])
            ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])
            ..orderByDescending('updatedAt')
            ..whereNotEqualTo('DeletedUsers', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
          /* ..whereArrayContainsAll('Users',
                [ProfilePage()..objectId = 'YQKnQxCgd8', ProfilePage()..objectId = 'QWwSqSEVpG'])*/
          ;
      final rr = await mainQuery.count();
      mainQuery.setLimit(rr.count);
      return getApiResponse<PairNotifications>(await mainQuery.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse?> getBlocAllData(type) async {
    try {
      final QueryBuilder<PairNotifications> query = QueryBuilder<PairNotifications>(PairNotifications())
            ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
            ..whereEqualTo('Type', type)
            ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])
            ..orderByDescending('updatedAt')

          /* ..whereArrayContainsAll('Users',
                [ProfilePage()..objectId = 'YQKnQxCgd8', ProfilePage()..objectId = 'QWwSqSEVpG'])*/
          ;
      final rr = await query.count();
      query.setLimit(rr.count);
      return getApiResponse<PairNotifications>(await query.query());
    } catch (e) {
      return null;
    }
  }

  //TLn4unk2vA  NfzZKEtgYT

  Future<ApiResponse?> getFilteredData(type, page, profileId) async {
    try {
      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = profileId)
        ..whereEqualTo('Type', type) /*..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])*/;

      final QueryBuilder<PairNotifications> queryChatData2 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = profileId)
        ..whereEqualTo('Type', type) /*..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])*/;

      final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(PairNotifications(), [queryChatData1, queryChatData2])
        ..whereNotContainedIn('DeletedUsers', [
          {"__type": "Pointer", "className": "User_login", "objectId": StorageService.getBox.read('ObjectId')}
        ])
        ..setLimit(10)
        ..setAmountToSkip(page)
        ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])
        ..orderByDescending('updatedAt');
      return getApiResponse<PairNotifications>(await mainQuery.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse?> getCount(type, profileId) async {
    try {
      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('FromProfile', ProfilePage()..objectId = profileId)
        ..whereEqualTo('Type', type);

      final QueryBuilder<PairNotifications> queryChatData2 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = profileId)
        ..whereEqualTo('Type', type);

      final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(PairNotifications(), [queryChatData1, queryChatData2])..count();
      final cnt = await mainQuery.count();
      mainQuery.setLimit(cnt.count);

      return getApiResponse<PairNotifications>(await mainQuery.query());
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse?> chatCount(String toProfileId) async {
    try {
      final QueryBuilder<ChatMessage> query = QueryBuilder<ChatMessage>(ChatMessage())
        // ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        // ..whereEqualTo('isRead', false);
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('isRead', false)
        ..setLimit(2000)
        ..includeObject(['FromProfile','FromUser']);

      return getApiResponse<ChatMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> totalChatCount() async {
    try {
      final QueryBuilder<ChatMessage> query = QueryBuilder<ChatMessage>(ChatMessage())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('isRead', false);

      return getApiResponse<ChatMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  // Future<ApiResponse?> getFilteredcount(type, profileId) async {
  //   try {
  //     final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
  //       ..whereEqualTo('FromProfile', ProfilePage()..objectId = profileId)
  //       ..whereValueExists("Like_Message", true)
  //       ..whereEqualTo('Type', type) /*..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])*/;
  //
  //     final QueryBuilder<PairNotifications> queryChatData2 = QueryBuilder<PairNotifications>(PairNotifications())
  //       ..whereEqualTo('ToProfile', ProfilePage()..objectId = profileId)
  //       ..whereValueExists("Like_Message", true)
  //       ..whereEqualTo('Type', type) /*..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])*/;
  //
  //     final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(PairNotifications(), [queryChatData1, queryChatData2])
  //       ..whereNotContainedIn('DeletedUsers', [
  //         {"__type": "Pointer", "className": "User_login", "objectId": StorageService.getBox.read('ObjectId')}
  //       ])
  //       ..setLimit(20)
  //       ..includeObject(['Like_Message', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile'])
  //       ..orderByDescending('updatedAt');
  //     return getApiResponse<PairNotifications>(await mainQuery.query());
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<ApiResponse?> messageCount(String toProfileId) async {
    try {

      final QueryBuilder<LikeMessage> query = QueryBuilder<LikeMessage>(LikeMessage())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('ToProfile', ProfilePage()..objectId = toProfileId)
        ..whereEqualTo('isRead', false)
        ..includeObject(['FromProfile','FromUser']);



      return getApiResponse<ChatMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<ApiResponse?> totalMessageCount() async {
    try {
      final QueryBuilder<LikeMessage> query = QueryBuilder<LikeMessage>(LikeMessage())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('isRead', false);

      return getApiResponse<ChatMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  /// getOutGoingData Call
  Future<ApiResponse?> getOutGoingData({required String type, required int page, required int limit}) async {
    try {
      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('Type', type)
        ..whereNotContainedIn('DeletedUsers', [
          {"__type": "Pointer", "className": "User_login", "objectId": StorageService.getBox.read('ObjectId')}
        ])
        ..setLimit(limit)
        ..setAmountToSkip(page)
        ..orderByDescending('updatedAt')
        ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile', 'Wishes', 'call', 'Gifts']);
      final ParseResponse returnData = await queryChatData1.query();
      return getApiResponse<PairNotifications>(returnData);
    } catch (e) {
      return null;
    }
  }

  /// getInComingData Call
  Future<ApiResponse?> getInComingData({required String type, required int page}) async {
    try {
      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('Type', type)
        ..setLimit(20)
        ..setAmountToSkip(page)
        ..orderByDescending('updatedAt')
        ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile', 'Wishes', 'call', 'Gifts']);
      final ParseResponse returnData = await queryChatData1.query();

      return getApiResponse<PairNotifications>(returnData);
    } catch (e) {
      return null;
    }
  }

  /// getMissedCallData Call
  Future<ApiResponse?> getMissedCallData({required String type, required int page}) async {
    try {
      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('Type', type)
        //..whereValueExists('call', true)
      ..whereNotContainedIn('call', ['',null])
        ..setLimit(20)
        ..setAmountToSkip(page)
        ..orderByDescending('updatedAt')
        ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile', 'Wishes', 'call']);
      final ParseResponse returnData = await queryChatData1.query();

      return getApiResponse<PairNotifications>(returnData);
    } catch (e) {
      return null;
    }
  }

  /// getBusyCallData Call
  Future<ApiResponse?> getBusyCallData({required String type, required int page}) async {
    //print('fromuser ----- ${StorageService.getBox.read('ObjectId')}');
    try {
      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('busy', true);

      // final QueryBuilder<PairNotifications> queryChatData2 = QueryBuilder<PairNotifications>(PairNotifications())..whereEqualTo('busy', true);
      // final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(PairNotifications(), [queryChatData1, queryChatData2]);

      queryChatData1
        ..whereNotContainedIn('DeletedUsers', [
          {"__type": "Pointer", "className": "User_login", "objectId": StorageService.getBox.read('ObjectId')}
        ])
        ..setLimit(20)
        ..setAmountToSkip(page)
        ..whereEqualTo('Type', type)
        ..orderByDescending('updatedAt')
        ..includeObject(['Users', 'FromUser', 'ToUser', 'ToProfile', 'FromProfile', 'Wishes', 'call', 'Gifts']);
      return getApiResponse<PairNotifications>(await queryChatData1.query());
    } catch (e) {
      return null;
    }
  }

  final RxBool isLoading = false.obs;
  final RxList lipLikeList = [].obs;
  final RxList chatMessageList = [].obs;
  final RxList heartMessageList = [].obs;
  final RxList callList = [].obs;
  final RxList videoCallList = [].obs;
  final RxList visitList = [].obs;
  final RxList heartLikeList = [].obs;
  final RxList winkList = [].obs;
  final RxList wishList = [].obs;
  final RxList giftList = [].obs;
  final RxList blockList = [].obs;

  // WHEN UPDATE DATA IN LIVE QUERY GET LATEST 5 ENTRY BY TYPE limit [5] page [0]
  void notificationSingleAdd(value) async {
    switch (value['Type']) {
      case 'WinkMessage':
        {
          final ApiResponse? apiResponse = await getFutureData(type: 'WinkMessage', page: 0, limit: 5);
          if (apiResponse != null) {
            winkList.clear();
            for (var element in apiResponse.results ?? []) {
              winkList.add(element);
            }
          } else {
            winkList.clear();
          }
        }
        break;
      case 'ChatMessage':
        {
          final ApiResponse? apiResponse = await getFutureData(type: 'ChatMessage', page: 0, limit: 5);
          if (apiResponse != null) {
            chatMessageList.clear();
            for (var element in apiResponse.results ?? []) {
              chatMessageList.add(element);
            }
          } else {
            chatMessageList.clear();
          }
        }
        break;
      case 'HeartMessage':
        {
          final ApiResponse? apiResponse = await getFutureData(type: 'HeartMessage', page: 0, limit: 5);
          if (apiResponse != null) {
            heartMessageList.clear();
            for (var element in apiResponse.results ?? []) {
              heartMessageList.add(element);
            }
          } else {
            heartMessageList.clear();
          }
        }
        break;
      case 'Call':
        {
          final ApiResponse? apiResponse = await getFutureData(type: 'Call', page: 0, limit: 6);
          if (apiResponse != null) {
            callList.clear();
            for (var element in apiResponse.results ?? []) {
              callList.add(element);
            }
          } else {
            callList.clear();
          }
        }
        break;
      case 'VideoCall':
        {
          final ApiResponse? apiResponse = await getFutureData(type: 'VideoCall', page: 0, limit: 5);
          if (apiResponse != null) {
            videoCallList.clear();
            for (var element in apiResponse.results ?? []) {
              videoCallList.add(element);
            }
          } else {
            videoCallList.clear();
          }
        }
        break;
      case 'LipLike':
        {
          final ApiResponse? apiResponse = await getFutureData(type: 'LipLike', page: 0, limit: 5);
          if (apiResponse != null) {
            lipLikeList.clear();
            for (var element in apiResponse.results ?? []) {
              lipLikeList.add(element);
            }
          } else {
            lipLikeList.clear();
          }
        }
        break;
      case 'HeartLike':
        {
          final ApiResponse? apiResponse = await getFutureData(type: 'HeartLike', page: 0, limit: 5);
          if (apiResponse != null) {
            heartLikeList.clear();
            for (var element in apiResponse.results ?? []) {
              heartLikeList.add(element);
            }
          } else {
            heartLikeList.clear();
          }
        }
        break;
      case 'BlocUser':
        {
          final ApiResponse? apiResponse = await getOutGoingData(type: 'BlocUser', page: 0, limit: 5);
          if (apiResponse != null) {
            blockList.clear();
            for (var element in apiResponse.results ?? []) {
              blockList.add(element);
            }
          } else {
            blockList.clear();
          }
        }
        break;
      case 'Visit':
        {
          final ApiResponse? apiResponse = await getFutureData(type: 'Visit', page: 0, limit: 5);
          if (apiResponse != null) {
            visitList.clear();
            for (var element in apiResponse.results ?? []) {
              visitList.add(element);
            }
          } else {
            visitList.clear();
          }
        }
        break;

      case 'Wishes':
        {
          final ApiResponse? apiResponse = await getFutureData(type: 'Wishes', page: 0, limit: 5);
          if (apiResponse != null) {
            wishList.clear();
            for (var element in apiResponse.results ?? []) {
              wishList.add(element);
            }
          } else {
            wishList.clear();
          }
        }
        break;
      case 'ChatGift':
        {
          final ApiResponse? apiResponse = await getFutureData(type: 'ChatGift', page: 0, limit: 5);
          if (apiResponse != null) {
            giftList.clear();
            for (var element in apiResponse.results ?? []) {
              giftList.add(element);
            }
          } else {
            giftList.clear();
          }
        }
        break;
      default:
        {}
        break;
    }
  }
}

FilterModel filterSwitch(val, context) {
  switch (val) {
    case 'Llamadas':
      {
        return FilterModel(
          filter1: 'Outgoing_completed'.tr,
          filter2: 'Incoming_received'.tr,
          filter1svg: SvgView("assets/Icons/call_made2.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor),
          filter2svg: SvgView("assets/Icons/call_made.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor),
        );
      }
    case 'Videollamada':
      {
        return FilterModel(
          filter1: 'Outgoing_completed'.tr,
          filter2: 'Incoming_received'.tr,
          filter1svg: SvgView("assets/Icons/call_made2.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor),
          filter2svg: SvgView("assets/Icons/call_made.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor),
        );
      }
    case 'Visitas':
      {
        return FilterModel(
          filter1: 'I_have_visited'.tr,
          filter2: 'I_have_been_visited'.tr,
          filter1svg: SvgView("assets/Icons/visit.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor),
          filter2svg: SvgView("assets/Icons/visit.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.redColor),
        );
        // return FilterModel(all: 'all_visited'.tr, filter1: 'i_have_been_visited'.tr, filter1svg: '', filter2: 'i_have_visited'.tr, filter2svg: '');
      }
    case 'Me gustas':
      {
        return FilterModel(
          filter1: 'i_like_you'.tr,
          filter2: 'I_like'.tr,
          filter1svg: SvgView("assets/Icons/heart.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.redColor),
          filter2svg: SvgView("assets/Icons/heart.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor),
        );
        // return FilterModel(all: 'all_like'.tr, filter1: 'i_liked'.tr, filter1svg: '', filter2: 'i_have_you'.tr, filter2svg: '');
      }
    case 'Guiños':
      {
        return FilterModel(
          filter1: 'I_have_winked'.tr,
          filter2: 'I_have_been_winked'.tr,
          filter1svg: SvgView("assets/Icons/wink.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor),
          filter2svg: SvgView("assets/Icons/wink.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.redColor),
        );
      }
    case 'Besos':
      {
        return FilterModel(
          filter1: 'I_have_kissed'.tr,
          filter2: 'I_have_been_kissed'.tr,
          filter1svg: SvgView("assets/Icons/lipLike.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor),
          filter2svg: SvgView("assets/Icons/lipLike.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.redColor),
        );
        // return FilterModel(all: 'all_kiss'.tr, filter1: 'i_have_been_kissed'.tr, filter1svg: '', filter2: 'i_kissed'.tr, filter2svg: '');
      }
    case 'wishes':
      {
        return FilterModel(
          filter1: 'Sent'.tr,
          filter2: 'Received'.tr,
          filter1svg: SvgView("assets/Icons/bottomWish.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor),
          filter2svg: SvgView("assets/Icons/bottomWish.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.redColor),
        );
        // return FilterModel(all: 'all_fingers'.tr, filter1: 'grant_my_wishes'.tr, filter1svg: '', filter2: 'I_grant_your_wishes'.tr, filter2svg: '');
      }
    case 'Regalos':
      {
        return FilterModel(
          filter1: 'Sent'.tr,
          filter2: 'Received'.tr,
          filter1svg: SvgView("assets/Icons/sentGift.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor),
          filter2svg: SvgView("assets/Icons/sentGift.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.redColor),
        );
        // return FilterModel(all: 'all_fingers'.tr, filter1: 'grant_my_wishes'.tr, filter1svg: '', filter2: 'I_grant_your_wishes'.tr, filter2svg: '');
      }
    default:
      {
        return FilterModel.fromJson({});
      }
  }
}

class FilterModel {
  final String filter1;
  final String filter2;
  final Widget filter1svg;
  final Widget filter2svg;

  FilterModel({required this.filter1, required this.filter2, required this.filter1svg, required this.filter2svg});

  factory FilterModel.fromJson(Map<String, dynamic> json) =>
      FilterModel(filter1: json["filter1"], filter2: json["filter2"], filter1svg: json["filter1svg"], filter2svg: json["filter2svg"]);

  Map<String, dynamic> toJson() => {"filter1": filter1, "filter2": filter2, "filter1svg": filter1svg, "filter2svg": filter2svg};
}
