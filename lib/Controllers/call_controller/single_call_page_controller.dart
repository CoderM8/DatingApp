import 'dart:async';

import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/call_controller/call_controller.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class SingleCallPageController extends GetxController {
  final PriceController _priceController = Get.put(PriceController());
  final CallController callController = Get.put(CallController());
  late Timer timer;
  final RxString time = '00:00:00'.obs;
  final RxBool show = false.obs;

  final Rx<Duration> duration = const Duration().obs;
  final RxString seconds = '00'.obs;
  final RxString minutes = '00'.obs;
  final RxString hours = '00'.obs;

  Future<void> startTimer({required String type}) async {
    print('Hello startTimer Type $type IsVoiceCall ${parseCall.value['IsVoiceCall']}');
    final int nowB = DateTime.now().millisecondsSinceEpoch;
    final DateTime currentT = await currentTime();
    final int nowA = DateTime.now().millisecondsSinceEpoch;
    final DateTime serverT = parseCall.value['startTime'] ?? currentT;
    final int elapsedTime = nowA - nowB;
    final int serverTime = currentT.millisecondsSinceEpoch - serverT.millisecondsSinceEpoch;
    duration.value = Duration(milliseconds: elapsedTime + serverTime);
    // duration.value =   Duration();
    time.value = '00:00:00';
    final double maxCallDuration =
        (_priceController.userTotalCoin.value * 60) / ((parseCall.value['IsVoiceCall'] ?? true) ? _priceController.callPrice.value : _priceController.videoCallPrice.value);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime(maxCallDuration));
  }

  void addTime(maxCallDuration) {
    const addSeconds = 1;
    final sec = duration.value.inSeconds + addSeconds;
    if (callController.toGender.isNotEmpty && callController.toGender.value == 'female') {
      /// WHEN MALE USER CALL TO FEMALE USER
      if (sec >= maxCallDuration) {
        timer.cancel();
        cutCall();
      } else if (sec < 0) {
        timer.cancel();
      } else {
        duration.value = Duration(seconds: sec);
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        hours.value = twoDigits(duration.value.inHours);
        minutes.value = twoDigits(duration.value.inMinutes.remainder(60));
        seconds.value = twoDigits(duration.value.inSeconds.remainder(60));
        time.value = '${hours.value}:${minutes.value}:${seconds.value}';
      }
    } else {
      /// WHEN FEMALE USER CALL TO MALE USER
      if (sec < 0) {
        timer.cancel();
      } else {
        duration.value = Duration(seconds: sec);
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        hours.value = twoDigits(duration.value.inHours);
        minutes.value = twoDigits(duration.value.inMinutes.remainder(60));
        seconds.value = twoDigits(duration.value.inSeconds.remainder(60));
        time.value = '${hours.value}:${minutes.value}:${seconds.value}';
      }
    }
  }

  void cutCall() async {
    print('Hello cutCall Duration ${time.value}');
    final DateTime dateTime = await currentTime();
    final ParseObject callObject = ParseObject('Calls')
      ..objectId = parseCall.value['objectId']
      ..set('endTime', dateTime)
      ..set('CallDuration', time.value)
      ..set('IsCallEnd', true)
      ..set('Log', {
        "CallId": parseCall.value['objectId'],
        "Event": 'EndCall',
        "EndTime": time.value,
        "Users": "senderId: ${parseCall.value['FromUser']['objectId']} UserId: ${parseCall.value['ToUser']['objectId']}",
        "State": "SingleCallPageController/cutCall/89",
      });
    await callObject.save();
    if ((await userReview()) && (int.parse(minutes.value.toString()) >= reviewTime)) {
      /// RETURN TRUE IF USER NOT GIVE NEGATIVE REVIEW
      if (show.value == false) {
        show.value = true;
        rateAppDialog1(Get.context!, submit: (text) async {
          if (text.isNotEmpty) {
            ParseObject review = ParseObject('User_Review');
            review['User'] = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
            review['Message'] = text;
            review['status'] = 0;
            await review.save();
            Get.back();
            Get.back();
          }
        }).whenComplete(() {
          show.value = false;
          FocusManager.instance.primaryFocus!.unfocus();
        });
      }
    }

    /// If I call someone else and I cut the call, I reset the time to zero There is an issue in the call cut, so there is a delay of 1 second
    Future.delayed(const Duration(seconds: 1),(){
      hours.value = "00";
      minutes.value = "00";
      seconds.value = "00";
      time.value = '00:00:00';
    });

  }

  Future<void> cutUserCallCoin({required String type}) async {
    print('Hello coin cut from $type');
    String toUserId = '';
    if (StorageService.getBox.read('Gender') == 'male') {
      if (StorageService.getBox.read('ObjectId') == parseCall.value['FromUser']['objectId']) {
        toUserId = parseCall.value['ToUser']['objectId'];
      } else {
        return;
      }
    } else {
      return;
    }

    final ApiResponse gender = await UserLoginProviderApi().getById(toUserId);

    if (int.parse(hours.value) != 0) {
      if ((parseCall.value['IsVoiceCall'] ?? true)) {
        _priceController.coinService('Call', gender.result['Gender'], '', toUserId, catValue: ((_priceController.callPrice.value * 60) * double.parse(hours.value)).round());
      } else {
        // VIDEO CALL
        _priceController.coinService('VideoCall', gender.result['Gender'], '', toUserId,
            catValue: ((_priceController.videoCallPrice.value * 60) * double.parse(hours.value)).round());
      }
    }
    if (int.parse(minutes.value) != 0) {
      if ((parseCall.value['IsVoiceCall'] ?? true)) {
        _priceController.coinService('Call', gender.result['Gender'], '', toUserId, catValue: (_priceController.callPrice.value * double.parse(minutes.value)).round());
      } else {
        // VIDEO CALL
        _priceController.coinService('VideoCall', gender.result['Gender'], '', toUserId, catValue: (_priceController.videoCallPrice.value * double.parse(minutes.value)).round());
      }
    }
    if (int.parse(seconds.value) != 0) {
      if ((parseCall.value['IsVoiceCall'] ?? true)) {
        _priceController.coinService('Call', gender.result['Gender'], '', toUserId, catValue: ((_priceController.callPrice.value / 60) * double.parse(seconds.value)).round());
      } else {
        // VIDEO CALL
        _priceController.coinService('VideoCall', gender.result['Gender'], '', toUserId,
            catValue: ((_priceController.videoCallPrice.value / 60) * double.parse(seconds.value)).round());
      }
    }
  }
}
