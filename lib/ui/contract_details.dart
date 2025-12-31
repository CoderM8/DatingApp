import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/ui/splash_screen_first.dart';
import 'package:eypop/ui/web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Constant/Widgets/textwidget.dart';
import '../Constant/constant.dart';

class ContractDetails extends GetView {
  const ContractDetails({Key? key}) : super(key: key);
  static UserController get _userController => Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 28.w, width: 28.w),
        title: Styles.regular("CONTRACT".tr, c: ConstColors.closeColor, fs: 31.sp),
      ),
      body: WebViewPage(
        url: isDarkMode.value ? _userController.contractDark.value : _userController.contractLight.value,
      ),
    );
  }
}
