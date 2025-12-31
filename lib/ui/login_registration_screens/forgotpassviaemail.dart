// ignore_for_file: use_build_context_synchronously

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../Controllers/login_controller.dart';

class ForgottenPassEmailLoginScreen extends GetView {
  final LogInControllers _logInControllers = Get.put(LogInControllers());

  ForgottenPassEmailLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GradientWidget(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 58.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgView(
                  "assets/Icons/close.svg",
                  color: ConstColors.closeColor,
                  height: 29.w,
                  width: 29.w,
                  onTap: () {
                    Get.back();
                  },
                ),
                SizedBox(height: 81.h),
                Styles.regular('forgot_password'.tr, c: ConstColors.white, fs: 29.sp, ff: 'HB'),
                SizedBox(height: 16.h),
                Center(child: Styles.regular('create_new_password'.tr, al: TextAlign.center, c: ConstColors.white, fs: 16.sp)),
                SizedBox(height: 25.h),
                Styles.regular('email'.tr, c: ConstColors.white, fs: 18.sp),
                SizedBox(height: 5.h),
                TextFieldModel(
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                  controllers: _logInControllers.forgotnEmail.value,
                  hint: 'email'.tr,
                  hintTextColor: ConstColors.black.withOpacity(0.4),
                  color: ConstColors.white,
                  borderColor: ConstColors.white,
                  containerColor: Colors.transparent,
                  textInputType: TextInputType.emailAddress,
                  onChanged: (v) {
                    if (v.contains('@')) {
                      _logInControllers.isForgetPassValid.value = v.isNotEmpty;
                    }
                    if (v.isEmpty) {
                      _logInControllers.isForgetPassValid.value = false;
                    }
                  },
                ),
                SizedBox(height: 27.h),
                Obx(() {
                  return Center(
                    child: GradientButton(
                        width: 243.w,
                        color1: ConstColors.darkRedColor,
                        color2: ConstColors.lightRedColor,
                        enable: _logInControllers.isForgetPassValid.value,
                        title: 'recover_password'.tr,
                        onTap: () async {
                          FocusManager.instance.primaryFocus!.unfocus();
                          final ParseUser user = ParseUser(null, null, _logInControllers.forgotnEmail.value.text.trim());
                          final ParseResponse parseResponse = await user.requestPasswordReset();
                          if (parseResponse.success) {
                            gradientSnackBar(context, title: 'email_sent'.tr,image: 'assets/Icons/email.svg');
                            Get.back();
                          } else {
                            if (kDebugMode) {
                              print('error');
                            }
                          }
                        }),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
