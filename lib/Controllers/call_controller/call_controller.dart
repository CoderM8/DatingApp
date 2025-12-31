import 'dart:async';

import 'package:eypop/Controllers/PairNotificationController/pair_notification_controller.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/video_call/video_dial_page.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../back4appservice/user_provider/users/provider_user_api.dart';
import '../../models/user_login/user_login.dart';
import '../../ui/call/dial_page.dart';

/// UnansweredCall for one time entry
List<String> unansweredCallId = [];
final Rx<ParseObject> parseCall = ParseObject('Calls').obs;

class CallController extends GetxController {
  final RxString toGender = ''.obs;
  final RxBool selfCut = false.obs;

  Future<void> permissionMic() async {
    await Permission.microphone.request();
  }

  Future<void> permissionCamera() async {
    await Permission.camera.request();
  }

  @override
  void onInit() {
    if (StorageService.getBox.read('ObjectId') != null) {
      startLiveCallQuery();
    }
    super.onInit();
  }

  final LiveQuery liveQuery = LiveQuery(debug: false);
  Subscription<ParseObject>? subscription;

  void startLiveCallQuery() async {
    if (kDebugMode) {
      print('Hello liveQuery start call ${parseCall.value['objectId']}');
    }
    final PairNotificationController pairNotificationController = Get.put(PairNotificationController());

    ///crash
    final QueryBuilder<ParseObject> queryPostData = QueryBuilder<ParseObject>(ParseObject('Calls'))
      ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'));
    final QueryBuilder<ParseObject> queryPostData2 = QueryBuilder<ParseObject>(ParseObject('Calls'))
      ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'));

    final ParseObject playerObject = ParseObject('Calls');
    final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(playerObject, [queryPostData, queryPostData2]);
    subscription = await liveQuery.client.subscribe(mainQuery);
    subscription!.on(LiveQueryEvent.create, (value) async {
      unansweredCallId.clear();
      if (kDebugMode) {
        print('*** CREATE CALL ***: $value ');
      }
      if (StorageService.getBox.read('ObjectId') == value['ToUser']['objectId']) {
        parseCall.value = value;
        final UserLogin userLogin = UserLogin();
        userLogin.objectId = value['ToUser']['objectId'];
        userLogin.userisbusy = true;
        UserLoginProviderApi().update(userLogin);
      } else if (value['FromUser']['objectId'] == StorageService.getBox.read('ObjectId')) {
        parseCall.value = value;
        final UserLogin userLogin = UserLogin();
        userLogin.objectId = value['FromUser']['objectId'];
        userLogin.userisbusy = true;
        UserLoginProviderApi().update(userLogin);

        final List<ApiResponse> allData =
            await Future.wait([UserProfileProviderApi().getById(value['ToProfile']['objectId']), UserProfileProviderApi().getById(value['FromProfile']['objectId'])]);
        PriceController().isPurchase.value = false;
        PriceController().isShowConnectCallButton.value = false;

        if (!pairNotificationController.meBlocked.toString().contains(value['ToProfile']['objectId'])) {
          if (value['IsVoiceCall'] == true) {
            Get.to(() => DialCall(
                  img: allData[0].result['Imgprofile'].url,
                  name2: allData[1].result['Name'],
                  location: allData[0].result['Location'],
                  location2: allData[1].result['Location'],
                  img2: allData[1].result['Imgprofile'].url,
                  callId: value['objectId'],
                  name: allData[0].result['Name'],
                  toGender: allData[0].result['User']['Gender'],
                ));
          } else {
            // VIDEO CALL
            Get.to(() => VideoDialCall(
                  img: allData[0].result['Imgprofile'].url,
                  name2: allData[1].result['Name'],
                  // location: allData[0].result['Location'],
                  // location2: allData[1].result['Location'],
                  img2: allData[1].result['Imgprofile'].url,
                  callId: value['objectId'],
                  name: allData[0].result['Name'],
                  toGender: allData[0].result['User']['Gender'],
                  // callType: 'Video',
                ));
          }
        }
      }
    });
    subscription!.on(LiveQueryEvent.update, (value) async {
      if (kDebugMode) {
        print('*** UPDATE CALL ***: $value');
      }

      if (value['ChannelName'].contains(StorageService.getBox.read('ObjectId'))) {
        parseCall.value = value;

        if (parseCall.value['IsCallEnd'] == true) {
          final UserLogin userLogin = UserLogin();
          userLogin.objectId = value['ToUser']['objectId'];
          userLogin.userisbusy = false;

          UserLoginProviderApi().update(userLogin);

          final UserLogin userLogin2 = UserLogin();
          userLogin2.objectId = value['FromUser']['objectId'];
          userLogin2.userisbusy = false;
          UserLoginProviderApi().update(userLogin2);
          if (parseCall.value['Accepted'] == false) {
            if (StorageService.getBox.read('ObjectId') == value['FromUser']['objectId']) {
              if (!unansweredCallId.contains(value['objectId'])) {
                unansweredCallId.add(value['objectId']);
                if (value['IsVoiceCall'] == true) {
                 await UserLoginProviderApi().increment(value['ToUser']['objectId'], 1, 'UnanswerCall');
                  /// cloud function (CallDeactiveMail)
                  final Map<String, dynamic> params = <String, dynamic>{'UserId': value['ToUser']['objectId']};
                  final ParseCloudFunction getCurrentTime = ParseCloudFunction('CallDeactiveMail');
                  ParseResponse res = await getCurrentTime.execute(parameters: params);
                  print('CallDeactiveMail status ---- ${res.statusCode}');
                } else {
                  // VIDEO CALL
                 await UserLoginProviderApi().increment(value['ToUser']['objectId'], 1, 'UnanswerVideoCall');
                  /// cloud function (VideoCallDeactiveMail)
                  final Map<String, dynamic> params = <String, dynamic>{'UserId': value['ToUser']['objectId']};
                  final ParseCloudFunction getCurrentTime = ParseCloudFunction('VideoCallDeactiveMail');
                  ParseResponse res = await getCurrentTime.execute(parameters: params);
                  print('VideoCallDeactiveMail status ---- ${res.statusCode}');
                }
              }
            }
          }
        }
        PriceController().isPurchase.value = false;
        PriceController().isShowConnectCallButton.value = false;
      }
    });
    subscription!.on(LiveQueryEvent.delete, (value) {
      if (kDebugMode) {
        print('*** DELETE CALL ***: $value ');
      }
    });
  }

  void cancelLiveCallQuery() async {
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }
  }
}
