// ignore_for_file: invalid_use_of_protected_member

import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class WithdrawPaymentController extends GetxController {
  RxList paymentList = [].obs;
  final RxBool isLoading = false.obs;

  Future getWithdrawPaymentMethod() async {
    paymentList.clear();
    final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('WithdrawPaymentMethod'))..orderByAscending('createdAt');
    final ParseResponse apiResponse = await query.query();
    if (apiResponse.results != null) {
      for(var e in apiResponse.results ?? []){
        paymentList.value.add(e);
      }
    }
  }

  @override
  Future<void> onInit() async {
    isLoading.value = true;
    await getWithdrawPaymentMethod().whenComplete(() => isLoading.value = false);
    super.onInit();
  }
}
