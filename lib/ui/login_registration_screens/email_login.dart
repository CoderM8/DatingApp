// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../Constant/Widgets/button.dart';
import '../../Controllers/login_controller.dart';
import '../../Controllers/user_controller.dart';
import 'forgotpassviaemail.dart';

class EmailLoginScreen extends GetView {
  EmailLoginScreen({Key? key}) : super(key: key);
  final LogInControllers _loginController = Get.put(LogInControllers());
  final UserController _userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ModalProgressHUD(
        inAsyncCall: _loginController.isLoading.value,
        progressIndicator: Lottie.asset("assets/jsons/loading_circle.json", height: 82.w, width: 82.w),
        child: Scaffold(
          body: Form(
            key: _loginController.useLoginForm,
            child: SingleChildScrollView(
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
                      Styles.regular('Welcome'.tr, c: ConstColors.white, fs: 29.sp, ff: 'HB'),
                      SizedBox(height: 25.h),
                      Styles.regular('email'.tr, c: ConstColors.white, fs: 18.sp),
                      SizedBox(height: 5.h),
                      TextFieldModel(
                        obs: false,
                        controllers: _loginController.email.value,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.h),
                        hint: 'email'.tr,
                        hintTextColor: ConstColors.black.withOpacity(0.4),
                        color: ConstColors.white,cursorColor: ConstColors.white,
                        borderColor: ConstColors.white,
                        containerColor: Colors.transparent,
                        textInputType: TextInputType.emailAddress,
                        onChanged: (v) {
                          if (v.contains('@')) {
                            _loginController.isEmailValid.value = v.isNotEmpty;
                          }
                          if (v.isEmpty) {
                            _loginController.isEmailValid.value = false;
                          }
                        },
                      ),
                      SizedBox(height: 19.h),
                      Styles.regular('password'.tr, c: ConstColors.white, fs: 18.sp),
                      SizedBox(height: 5.h),
                      Obx(
                        () => TextFieldModel(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.h),
                          obs: _loginController.obs.value,
                          color: ConstColors.white,cursorColor: ConstColors.white,
                          borderColor: ConstColors.white,
                          hintTextColor: ConstColors.black.withOpacity(0.4),
                          containerColor: Colors.transparent,
                          controllers: _loginController.password.value,
                          hint: 'password'.tr,
                          onChanged: (v) {
                            _loginController.isPasswordValid.value = v.isNotEmpty;
                          },
                          suffixIcon: Align(
                            widthFactor: 2.0,
                            heightFactor: 1.0,
                            child: GestureDetector(
                              onTap: () {
                                _loginController.obs.value = !_loginController.obs.value;
                              },
                              child: SvgPicture.asset(
                                'assets/Icons/eye.svg',
                                width: 26.w,
                                height: 11.w,
                                color: ConstColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 21.h),
                      Obx(() {
                        bool valid = (_loginController.isEmailValid.value && _loginController.isPasswordValid.value);
                        return Center(
                          child: GradientButton(
                              width: 189.w,
                              color1: ConstColors.darkRedColor,
                              color2: ConstColors.lightRedColor,
                              enable: valid,
                              title: 'following'.tr,
                              onTap: () async {
                                FocusManager.instance.primaryFocus!.unfocus();
                                await _loginController.userLogin(context, _userController);
                              }),
                        );
                      }),
                      SizedBox(height: 26.h),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => ForgottenPassEmailLoginScreen());
                        },
                        child: Center(child: Styles.regular('Forget_password'.tr, fs: 16.sp, c: ConstColors.white)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
