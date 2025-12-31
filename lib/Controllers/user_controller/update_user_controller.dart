import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/back4appservice/user_provider/users/update_user_provider.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UpdateUserController extends GetxController {
  final RxBool male = false.obs;
  final RxBool female = false.obs;
  final RxString gender = ''.obs;
  final Rx<DateTime> birthdate = DateTime.now().obs;
  final RxString finalDate = DateFormat('dd/MM/yyyy').format(DateTime.now()).toString().obs;
  final Rx<DateTime> selectedDate = DateTime.now().subtract(const Duration(days: 6570)).obs;
  final RxBool status = true.obs;
  ApiResponse? userData;

  Future<void> userDataFunc() async {
    await UserLoginProviderApi().getById(StorageService.getBox.read('ObjectId')).then((value) {
      userData = value;
      if (value.result['Gender'] == 'male') {
        male.value = true;
        gender.value = 'male';
      } else {
        female.value = true;
        gender.value = 'female';
      }
      finalDate.value = DateFormat('dd/MM/yyyy').format(value.result['BirthDate']).toString();
      selectedDate.value = value.result['BirthDate'];
      birthdate.value = value.result['BirthDate'];
    });
  }

  Future<void> updateData() async {
    final updateUserData = await UpdateUserProviderApi().getByIdPointer(UserLogin()..objectId = StorageService.getBox.read('ObjectId'));
    if (updateUserData != null) {
      status.value = updateUserData.result['Status'] != 'PENDING' ? true : false;
    } else {
      status.value = true;
    }
  }

  @override
  void onInit() {
    userDataFunc();
    updateData();
    super.onInit();
  }
}
