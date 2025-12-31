import 'dart:async';
import 'package:eypop/Constant/constant.dart';
import 'package:get/get.dart';

class SpecialOfferController extends GetxController {
  Timer? timer;

  @override
  void onInit() {
    if (DateTime.now().isAfter(startTime.value)) {
      startTimer();
    } else {
      remainingTime.value = Duration.zero;
    }
    super.onInit();
  }

  @override
  void onClose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.onClose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      remainingTime.value = endTime.value.difference(DateTime.now());
      if (remainingTime.value.isNegative || remainingTime.value == Duration.zero) {
        t.cancel();
        timer!.cancel();
        remainingTime.value = Duration.zero;
      }
    });
  }
}
