// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/call_controller/agora_call_controller.dart';
import 'package:eypop/Controllers/call_controller/call_controller.dart';
import 'package:eypop/Controllers/call_controller/single_call_page_controller.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/repositories/Calls/call_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/firebase_options.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/service/local_notification_services.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/User_profile/user_fullprofile_screen.dart';
import 'package:eypop/ui/call/incoming_call.dart';
import 'package:eypop/ui/video_call/incoming_video_call.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../models/call/calls.dart';

List<String> uuidList = [];
RtcEngine? bgAgoraEngine;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a message data background: ${message.data}");
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final Map<String, dynamic> map = message.data;
  backgroundListener();
  if (map['type'] == 'Calling you') {
    await CallService.showCallkitIncoming(map['id'], map);
  } else if (map['type'] == 'Cut') {
    await FlutterCallkitIncoming.endCall(map['id']);
  } else if (map['data'] != null) {
    final Map<String, dynamic> local = jsonDecode(map['data']);
    if (local['translatedAlert'] == 'Send Notification') {
      LocalNotificationService().showNotifications(
          title: local['senderName'], body: local['alert'], payload: map['data'], msgId: message.messageId, image:Platform.isIOS?local['attachment']['url']??'' :local['image'] ?? '');
    } else {
      LocalNotificationService().showNotifications(
          title: local['senderName'], body: local['alert'], payload: map['data'], msgId: message.messageId, image:Platform.isIOS?local['attachment']['url']??'' :local['image'] ?? '');
    }
  }
}

class CallService {
  /// GET ACTIVE CALL FROM INCOMING CALL KIT
  static Future<dynamic> getCurrentCall(String path) async {
    //check current call from pushkit if possible
    final calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        print('Hello getCurrentCall *** $path *** [${calls.length}] : ${calls[0]}');
        return calls[0];
      } else {
        return null;
      }
    }
  }

  /// CHECK CALL IS ACCEPTED AND REDIRECT USER TO CALL SCREEN
  static Future<void> checkAndNavigationCallingPage(bool visitType, String path) async {
    final currentCall = await getCurrentCall('Calling/$path/85');

    // TODO: ONLY WORK FOR ANDROID --> [currentCall['accepted']]
    final bool accepted = (currentCall != null && (Platform.isAndroid ? currentCall['accepted'] == true : true));
    print('Hello check navigation call Location *** $path *** currentCall["accepted"] $accepted');
    if (accepted) {
      final CallController callController = Get.put(CallController());
      final ApiResponse apiResponse = await UserCallProviderApi().getCallById(currentCall['extra']['callId']);
      parseCall.value = apiResponse.result;
      print(
          'Hello check navigation call by id objectId ${apiResponse.result['objectId']} IsCallEnd ${apiResponse.result['IsCallEnd']} --- Accepted ${apiResponse.result['Accepted']}');
      if (apiResponse.result['IsCallEnd'] == false) {
        await callController.permissionMic();
        if (apiResponse.result['Accepted'] == false && apiResponse.result['objectId'] == currentCall['extra']['callId']) {
          final DateTime dateTime = await currentTime();
          final callModel = CallModel()
            ..objectId = currentCall['extra']['callId']
            ..set('startTime', dateTime)
            ..set('Accepted', true);
          await callModel.save();
        }
        if (apiResponse.result['IsVoiceCall'] == true) {
          Get.to(() => Incoming(
                visitType: visitType,
                callInfo: apiResponse.result,
                callId: apiResponse.result["objectId"],
                name: apiResponse.result['FromProfile']['Name'],
                name2: apiResponse.result['ToProfile']['Name'],
                location: apiResponse.result['FromProfile']["Location"],
                location2: apiResponse.result['ToProfile']["Location"],
                fromImg: apiResponse.result['FromProfile']['Imgprofile'].url,
                toImg: apiResponse.result['ToProfile']['Imgprofile'].url,
                toGender: apiResponse.result['ToUser']['Gender'],
              ));
        } else {
          // VIDEO CALL
          await callController.permissionCamera();
          Get.to(() => IncomingVideoCall(
                visitType: visitType,
                callInfo: apiResponse.result,
                callId: apiResponse.result["objectId"],
                name: apiResponse.result['ToProfile']['Name'],
                // name2: apiResponse.result['ToProfile']['Name'],
                // location: apiResponse.result['FromProfile']["Location"],
                // location2: apiResponse.result['ToProfile']["Location"],
                fromImg: apiResponse.result['FromProfile']['Imgprofile'].url,
                toImg: apiResponse.result['ToProfile']['Imgprofile'].url,
                toGender: apiResponse.result['ToUser']['Gender'],
              ));
        }
      } else {
        if (currentCall != null) {
          await FlutterCallkitIncoming.endCall(currentCall['id']);
        }
      }
    }
    /// TODO : android & ios working fine when app resumed on Dial Page (do not uncomment code)
    // else {
    //    parseCall.value = CallModel();
    // }
  }

  /// FIREBASE NOTIFICATION AND LOCAL NOTIFICATION INITIALIZE
  static void initialNotification() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('User authorizationStatus permission ${settings.authorizationStatus}');
    }
    // Required to display a heads up notification
    await messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Handling a message data foreground: ${message.data}');
      if (message.data.isNotEmpty) {
        final Map<String, dynamic> map = message.data;
        // Calling you
        if (map['type'] == 'Calling you') {
          await showCallkitIncoming(map['id'], map);
        } else if (map['type'] == 'Cut') {
          await FlutterCallkitIncoming.endCall(map['id']);
        } else if (map['data'] != null) {
          final Map<String, dynamic> local = jsonDecode(map['data']);
          if (local['translatedAlert'] == 'Send Notification' || local['translatedAlert'] == 'go_internal_link' || local['translatedAlert'] == 'go_advertisement') {
            LocalNotificationService().showNotifications(
                title: local['senderName'], body: local['alert'], payload: map['data'], msgId: message.messageId, image: Platform.isIOS?local['attachment']['url']??'' :local['image'] ?? '');
          }
        }
      }
    });
  }

  /// CALL NOTIFICATION FOR ANDROID DEVICE
  static Future<void> sendAndroidCallNotification(
      {required String deviceToken,
      required String senderName,
      required String avatar,
      required String userId,
      required String senderId,
      required String type,
      required String uuid,
      required String callId,
      required bool isVoiceCall}) async {
    // Map data = {
    //   "data": {
    //     "senderName": senderName,
    //     "avatar": avatar,
    //     "UserId": userId,
    //     "senderId": senderId,
    //     "type": type,
    //     "id": uuid,
    //     "callId": callId,
    //     "isVoiceCall": isVoiceCall ? 0 : 1, // VIDEO [1] AUDIO [0] CALLS
    //     "sound": "default",
    //     "alert": "",
    //     "title": "",
    //     "click_action": "FLUTTER_NOTIFICATION_CLICK",
    //     "status": "done"
    //   },
    //   "priority": "high",
    //   // "notification": {"title": "Eypop", "body": "Incoming Call"},
    //   "ios_voip": 1,
    //   "apple": {"subtitle": "subtitle"},
    //   "to": deviceToken, //this is fcm token to send notification
    //   "content_available": true,
    //   // "apns-priority": 5
    // };
    //
    // final body = json.encode(data);
    // Map<String, String> header = {
    //   "Content-Type": "application/json; charset=UTF-8",
    //   "Authorization":
    //       "key = AAAA5X8RLOc:APA91bFZLfC0oWCGzcJimzBai1sBEVPoWcaZGx5XvPt5fI_h_fJfysi9MdOCvd8yBYgeSgLcgTYnWrGYOS-5PKCPeDP32TuIydQv0YCgacZcWJV9Wmo55-nG8BcYgT3I2lxqbNMaCO5x",
    // };
    // http.Response res = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'), headers: header, body: body);
    // if (kDebugMode) {
    //   print('Hello sendCallNotification com Android : ${res.body}');
    // }

    final String serverKey = await getAccessToken();
    const String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/eypop-c3e1d/messages:send';
    final Map<String, dynamic> body = {
      'message': {
        'token': deviceToken,
        'data': {
          "senderName": senderName,
          "avatar": avatar,
          "UserId": userId,
          "senderId": senderId,
          "type": type,
          "id": uuid,
          "callId": callId,
          "isVoiceCall": isVoiceCall ? '0' : '1', // VIDEO [1] AUDIO [0] CALLS
          "sound": "default",
          "alert": "",
          "title": "",
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "status": "done"
        },
        // when mobile lock and call arrived [ttl] wake up screen
        "android": {"priority": "high", "ttl": "1s"},
        "apns": {
          "payload": {
            "aps": {"content-available": 1},
            "ios_voip": 1
          }
        },
      }
    };

    final http.Response response = await http.post(Uri.parse(fcmEndpoint),
        headers: <String, String>{'Content-Type': 'application/json', 'Authorization': 'Bearer $serverKey'}, body: jsonEncode(body));
    print(
        'Hello sendCallNotification Send Android \n=============== \nType: $type \nCallId: $callId \nVoiceCall: $isVoiceCall \nSuccess: ${response.statusCode == 200} \nUrl: $fcmEndpoint \n===============');

    /// Success Code: 200 Body:- { "name": "projects/eypop-c3e1d/messages/0:1725961392153007%85111136f9fd7ecd" }
  }

  /// CALL NOTIFICATION FOR IOS DEVICE
  static Future<void> sendIosCallNotification(
      {required String deviceToken,
      required String senderName,
      required String avatar,
      required String userId,
      required String senderId,
      required String type,
      required String uuid,
      required String callId,
      required bool isVoiceCall}) async {
    final Map body = {
      "device_token": deviceToken,
      "alert": senderName,
      "nameCaller": senderName,
      "senderName": senderName,
      "avatar": avatar,
      "UserId": userId,
      "senderId": senderId,
      "type": type,
      "isVoiceCall": isVoiceCall ? "false" : "true", // VIDEO [true] AUDIO [false] CALLS
      "id": uuid,
      "callId": callId,
      "handle": "0123456789"
    };

    const Map<String, String> headers = {"Content-Type": "application/x-www-form-urlencoded"};
    final String url = kDebugMode ? 'https://vocsyapp.com/eypoptest/sendbox.php' : iosCallApiLink.value;
    final http.Response res = await http.post(Uri.parse(url), headers: headers, body: body, encoding: Encoding.getByName('utf-8'));
    print(
        'Hello sendCallNotification Send IOS \n*************** \nType: $type \nCallId: $callId \nDeviceToken: $deviceToken \nVoiceCall: $isVoiceCall \nSuccess: ${res.statusCode == 200} \nBody: ${res.body} \nUrl: $url \n***************');

    /// Success Code: 200 Body:- Curl New success:
  }

  /// GET USER DEVICE TOKEN AND SEND NOTIFICATION
  static Future<void> callRequests(
      {required String userId, required String type, required String fromProfileId, required String callId, required bool isVoiceCall}) async {
    final ApiResponse apiResponse = await UserLoginProviderApi().getById(userId);
    final ProfilePage userProfile = await UserProfileProviderApi().getByIdNotification(fromProfileId);

    if (type != 'Cut') {
      uuidList.clear();
    }

    for (int i = 0; i < (apiResponse.result['deviceTokenCall'] ?? []).take(10).length; i++) {
      if (type != 'Cut') {
        uuidList.add(const Uuid().v4());
      }
      final element = apiResponse.result['deviceTokenCall'][i];
      if (!element.toString().containsLowercase) {
        await sendIosCallNotification(
          deviceToken: element,
          senderName: userProfile.name,
          avatar: userProfile.imgProfile.url!,
          userId: userId,
          senderId: userProfile.userId.objectId!,
          type: type,
          uuid: uuidList[i],
          callId: callId,
          isVoiceCall: isVoiceCall,
        );
      } else {
        await sendAndroidCallNotification(
          deviceToken: element,
          senderName: userProfile.name,
          avatar: userProfile.imgProfile.url!,
          userId: userId,
          senderId: userProfile.userId.objectId!,
          type: type,
          uuid: uuidList[i],
          callId: callId,
          isVoiceCall: isVoiceCall,
        );
      }
    }
  }

  static Future<String> getAccessToken() async {
    // Your client ID and client secret obtained from Google Cloud Console
    const List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    final http.Client client = await auth.clientViaServiceAccount(auth.ServiceAccountCredentials.fromJson(accountJson), scopes);
    // Obtain the access token
    final auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(auth.ServiceAccountCredentials.fromJson(accountJson), scopes, client);
    // Close the HTTP client
    client.close();
    // Return the access token
    return credentials.accessToken.data;
  }

  /// SEND REQUEST TO USER FOR AUDIO CALL
  static Future<void> makeCall(
      {required String userId, required String type, String? fromProfileId, required String callId, required bool isVoiceCall}) async {
    print('Hello makeCall data before ids: ${uuidList.length}');
    await callRequests(
        userId: userId,
        type: type,
        fromProfileId: fromProfileId ?? StorageService.getBox.read('DefaultProfile'),
        callId: callId,
        isVoiceCall: isVoiceCall);
    if (type == 'Cut') {
      uuidList.clear();
    }
    print('Hello makeCall data after ids: ${uuidList.length}');
  }

  /// IN-COMING CALL KIT EVENT
  static Future<void> listenerEvent() async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        final CallController callController = Get.put(CallController());
        if (kDebugMode) {
          print('FlutterCallkitIncoming listenerEvent onEvent : $event');
        }
        switch (event!.event) {
          case Event.actionCallIncoming:
            //  received an incoming call
            print('Hello call listen actionCallIncoming ');
            callController.selfCut.value = false;
            break;
          case Event.actionCallStart:
            //  started an outgoing call
            //  show screen calling in Flutter
            if (kDebugMode) {
              print('Hello call listen actionCallStart ');
            }
            break;
          case Event.actionCallAccept:
            await callController.permissionMic();
            //  accepted an incoming call
            //  show screen calling in Flutter
            print('Hello call listen actionCallAccept ${event.body['extra']['senderId']} callId ${event.body['extra']['callId']}');
            final DateTime dateTime = await currentTime();
            final callModel = CallModel()
              ..objectId = event.body['extra']['callId']
              ..set('startTime', dateTime)
              ..set('Accepted', true);
            await callModel.save();
            Get.put(PriceController());
            final apiResponse = await UserCallProviderApi().getCallById(event.body['extra']['callId']);
            parseCall.value = apiResponse.result;
            if (apiResponse.result['IsCallEnd'] == false) {
              if (apiResponse.result['IsVoiceCall'] == true) {
                Get.to(() => Incoming(
                      visitType: false,
                      callInfo: apiResponse.result,
                      callId: apiResponse.result["objectId"],
                      name: apiResponse.result['FromProfile']['Name'],
                      name2: apiResponse.result['ToProfile']['Name'],
                      location: apiResponse.result['FromProfile']["Location"],
                      location2: apiResponse.result['ToProfile']["Location"],
                      fromImg: apiResponse.result['FromProfile']['Imgprofile'].url,
                      toImg: apiResponse.result['ToProfile']['Imgprofile'].url,
                      toGender: apiResponse.result['ToUser']['Gender'],
                    ));

                final UserLogin userLogin2 = UserLogin();
                userLogin2.objectId = StorageService.getBox.read('ObjectId');
                userLogin2['UnanswerCall'] = 0;
                UserLoginProviderApi().update(userLogin2);
              } else {
                // VIDEO CALL
                await callController.permissionCamera();
                Get.to(() => IncomingVideoCall(
                      visitType: false,
                      callInfo: apiResponse.result,
                      callId: apiResponse.result["objectId"],
                      name: apiResponse.result['ToProfile']['Name'],
                      // name2: apiResponse.result['ToProfile']['Name'],
                      // location: apiResponse.result['FromProfile']["Location"],
                      // location2: apiResponse.result['ToProfile']["Location"],
                      fromImg: apiResponse.result['FromProfile']['Imgprofile'].url,
                      toImg: apiResponse.result['ToProfile']['Imgprofile'].url,
                      toGender: apiResponse.result['ToUser']['Gender'],
                    ));
                final UserLogin userLogin2 = UserLogin();
                userLogin2.objectId = StorageService.getBox.read('ObjectId');
                userLogin2['UnanswerVideoCall'] = 0;
                UserLoginProviderApi().update(userLogin2);
              }

              bgAgoraEngine = await initAgoraBackground(apiResponse.result["objectId"], event.body['id'], apiResponse.result['IsVoiceCall']);
            } else {
              await FlutterCallkitIncoming.endCall(event.body['id']);
            }
            break;
          case Event.actionCallDecline:
            //  declined an incoming call
            print('Hello call listen actionCallDecline ');
            final DateTime dateTime = await currentTime();
            final ParseObject callObject = ParseObject('Calls')
              ..objectId = event.body['extra']['callId']
              ..set('endTime', dateTime)
              ..set('startTime', dateTime)
              ..set('IsCallEnd', true)
              ..set('Log', {
                "CallId": event.body['extra']['callId'],
                "Event": 'EndCall',
                "Type": event.body['extra']['isVoiceCall'],
                "Users": "senderId: ${event.body['extra']['senderId']} UserId: ${event.body['extra']['UserId']}",
                "State": "Calling/listenerEvent/actionCallDecline/343",
              });
            await callObject.save();
            await FlutterCallkitIncoming.endCall(event.body['id']);
            break;
          case Event.actionCallEnded:
            //  ended an incoming/outgoing call
            if (kDebugMode) {
              print('Hello call listen actionCallEnded ${event.body}');
            }

            final SingleCallPageController singleCallPageController = Get.put(SingleCallPageController());
            if (callController.selfCut.value == false) {
              singleCallPageController.cutCall();
            }
            if (bgAgoraEngine != null) {
              await bgAgoraEngine!.leaveChannel();
              await bgAgoraEngine!.release();
              bgAgoraEngine = null;
            }
            break;
          case Event.actionCallTimeout:
            //  missed an incoming call
            if (kDebugMode) {
              print('Hello call listen actionCallTimeout ');
            }
            break;
          case Event.actionCallCallback:
            //  only Android - click action `Call back` from missed call notification
            await LocalNotificationService().cancelAllNotifications();
            print('Hello call listen actionCallCallback ${event.body}');

            ApiResponse apiResponse = await UserCallProviderApi().getCallsFromToUser(event.body['extra']['senderId']);
            Get.to(() => UserFullProfileScreen(
                isNotification: true,
                fromProfileId: apiResponse.result['ToProfile']['objectId'],
                toProfileId: apiResponse.result['FromProfile']['objectId'],
                toUserId: apiResponse.result['FromUser']));
            break;
          case Event.actionCallToggleHold:
            //  only iOS
            if (kDebugMode) {
              print('Hello call listen actionCallToggleHold ');
            }
            break;
          case Event.actionCallToggleMute:
            //  only iOS
            if (kDebugMode) {
              print('Hello call listen actionCallToggleMute ');
            }
            break;
          case Event.actionCallToggleDmtf:
            //  only iOS
            if (kDebugMode) {
              print('Hello call listen actionCallToggleDmtf ');
            }
            break;
          case Event.actionCallToggleGroup:
            //  only iOS
            if (kDebugMode) {
              print('Hello call listen actionCallToggleGroup ');
            }
            break;
          case Event.actionCallToggleAudioSession:
            //  only iOS
            if (kDebugMode) {
              print('Hello call listen actionCallToggleAudioSession ');
            }
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            //  only iOS
            if (kDebugMode) {
              print('Hello call listen actionDidUpdateDevicePushTokenVoip ');
            }
            break;
          case Event.actionCallCustom:
            if (kDebugMode) {
              print('Hello call listen actionCallCustom ');
            }
            break;
        }
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        print('listenerEvent Error $e');
      }
    }
  }

  /// SHOW CALL NOTIFICATION
  static Future<void> showCallkitIncoming(String uuid, map) async {
    print('Hello showCallkitIncoming id: $uuid');
    final CallKitParams params = CallKitParams(
      id: uuid,
      nameCaller: map['senderName'],
      appName: 'Eypop',
      avatar: map['avatar'],
      handle: 'Calling',
      type: int.parse(map['isVoiceCall'].toString()),
      // VIDEO [1] AUDIO [0] CALLS
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{'UserId': map['UserId'], "senderId": map['senderId'], "callId": map['callId'], "isVoiceCall": map['isVoiceCall']},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0076C1',
        //backgroundUrl: 'assets/callingbackgroundimage.png',
        actionColor: '#4CAF50',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }
}

/// WHEN APP IN BACKGROUND IN-COMING EVENT FOR [ANDROID]
void backgroundListener() async {
  await Parse().initialize(
    keyParseApplicationId,
    keyParseServerUrl,
    clientKey: keyParseClientKey,
    liveQueryUrl: 'https://eypopv13.b4a.io/',
    autoSendSessionId: true,
    masterKey: keyParseMasterKey,
    debug: keyDebug,
  );
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    if (kDebugMode) {
      print('FlutterCallkitIncoming backgroundListener onEvent : $event');
    }
    switch (event!.event) {
      case Event.actionCallIncoming:
        await startLiveQueryBackground(event.body['extra']['callId']);
        break;
      case Event.actionCallStart:
        break;
      case Event.actionCallAccept:
        print('Hello call listen actionCallAccept backgroundListener callId ${event.body['extra']['callId']} body ${event.body}');
        if (Platform.isIOS) {
          final DateTime dateTime = await currentTime();
          final callModel = CallModel()
            ..objectId = event.body['extra']['callId']
            ..set('startTime', dateTime)
            ..set('Accepted', true);
          await callModel.save();
        }
        break;
      case Event.actionCallDecline:
        {
          print('Hello call listen actionCallDecline backgroundListener ${event.body['extra']['callId']}');
          final DateTime dateTime = await currentTime();
          final ParseObject callObject = ParseObject('Calls')
            ..objectId = event.body['extra']['callId']
            ..set('endTime', dateTime)
            ..set('startTime', dateTime)
            ..set('IsCallEnd', true)
            ..set('Log', {
              "CallId": event.body['extra']['callId'],
              "Event": 'EndCall',
              "Users": "senderId: ${event.body['extra']['senderId']} UserId: ${event.body['extra']['UserId']}",
              "State": "Calling/backgroundListener/actionCallDecline/647",
            });
          await callObject.save();
          await FlutterCallkitIncoming.endCall(event.body['id']);
        }
        break;
      case Event.actionCallEnded:
        break;
      case Event.actionCallTimeout:
        break;
      case Event.actionCallCallback:
        break;
      case Event.actionCallToggleHold:
        break;
      case Event.actionCallToggleMute:
        break;
      case Event.actionCallToggleDmtf:
        break;
      case Event.actionCallToggleGroup:
        break;
      case Event.actionCallToggleAudioSession:
        break;
      case Event.actionDidUpdateDevicePushTokenVoip:
        break;
      case Event.actionCallCustom:
        break;
    }
  });
}

/// WHEN APP IN BACKGROUND START CALL LIVE QUERY
@pragma('vm:entry-point')
Future<void> startLiveQueryBackground(String callId) async {
  final QueryBuilder<ParseObject> query = QueryBuilder(ParseObject('Calls'))..whereEqualTo('objectId', callId);
  final LiveQuery liveQuery = LiveQuery(autoSendSessionId: true, debug: false);
  final Subscription<ParseObject> subscription = await liveQuery.client.subscribe(query);
  subscription.on(LiveQueryEvent.update, (value) {
    print('HELLO AGORA CALL LIVEQUERY BACKGROUND ****** UPDATE ***** $value');
    parseCall.value = value;
  });
}

@pragma('vm:entry-point')
Future<RtcEngine?> initAgoraBackground(callId, String id, bool isVoiceCall) async {
  print('HELLO AGORA CALL BACKGROUND $callId isVoiceCall $isVoiceCall');
  if (agoraAppId.isEmpty) {
    return null;
  }
  await Permission.microphone.request();
  if (!isVoiceCall) {
    await Permission.camera.request();
  }
  final RtcEngine engine = await createAgoraBackground();
  agoraEventHandlerBackground(engine, id, isVoiceCall);
  await engine.joinChannel(
      token: agoraAppId, channelId: callId, uid: 2, options: const ChannelMediaOptions(clientRoleType: ClientRoleType.clientRoleBroadcaster));
  if (!isVoiceCall) {
    await engine.enableVideo();
    await engine.startPreview();
  }
  return engine;
}

Future<RtcEngine> createAgoraBackground() async {
  final RtcEngine engine = createAgoraRtcEngine();
  await engine.initialize(const RtcEngineContext(appId: agoraAppId, channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
  return engine;
}

void agoraEventHandlerBackground(RtcEngine engine, id, bool isVoiceCall) {
  engine.registerEventHandler(RtcEngineEventHandler(onError: (ErrorCodeType errorCodeType, String message) {
    print('HELLO AGORA CALL BACKGROUND CON-ERROR $message');
  }, onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
    print('HELLO AGORA CALL BACKGROUND ON-JOIN-SUCCESS');
    onUserJoin.value = true;
  }, onLeaveChannel: (RtcConnection connection, RtcStats stats) async {
    print('HELLO AGORA CALL BACKGROUND ON-LEAVE-CHANNEL');
    await FlutterCallkitIncoming.endCall(id);
    onUserJoin.value = false;
    remoteUidVideo.value = 0;
  }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) async {
    print('HELLO AGORA CALL BACKGROUND ON-USER-JOIN $remoteUid');
    remoteUidVideo.value = remoteUid;
    if (!isVoiceCall) {
      await engine.setEnableSpeakerphone(true);
    } else {
      engine.setEnableSpeakerphone(false);
    }
  }, onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
    engine.leaveChannel();
    engine.release();
    print('HELLO AGORA CALL BACKGROUND ON-USER-OFFLINE $remoteUid');
  }, onFirstRemoteVideoFrame: (RtcConnection connection, int remoteUid, int width, int height, int elapsed) {
    print('HELLO AGORA CALL BACKGROUND ON-FIRST-REMOTE-VIDEO-FRAME $remoteUid');
  }));
}
