import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/user_controller.dart';

import 'package:eypop/ui/web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Constant/Widgets/textwidget.dart';
import '../Constant/constant.dart';

class CookiePolicy extends GetView {
  CookiePolicy({Key? key}) : super(key: key);
  final UserController _userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientWidget(
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 58.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgView(
                "assets/Icons/cancelbutton.svg",
                height: 45.w,
                width: 45.w,
                onTap: () {
                  Get.back();
                },
              ),
              SizedBox(height: 8.h),
              Styles.regular("cookies".tr.replaceAll('.', ''), c: ConstColors.white, fs: 29.sp, ff: 'HB'),
              SizedBox(height: 8.h),
              Expanded(
                child: WebViewPage(
                  url: _userController.cookiePolicy.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}