import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../Controllers/authentication_controller.dart';
import '../../Controllers/user_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({Key? key}) : super(key: key);

  final AuthController _authController = Get.put(AuthController());

  final UserController _userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GradientWidget(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 58.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: SvgView(
                    "assets/Icons/close.svg",
                    color: ConstColors.closeColor,
                    height: 29.w,
                    width: 29.w,
                    onTap: () {
                      Get.back();
                    },
                  ),
                ),
                SizedBox(height: 22.h),
                Styles.regular('Sms_sent'.tr, c: ConstColors.white, fs: 29.sp, ff: 'HB'),
                SizedBox(height: 25.h),
                Center(child: Styles.regular('Enter_code'.tr, c: ConstColors.white, fs: 14.sp)),
                SizedBox(height: 18.h),
                PinCodeTextField(
                    autoDisposeControllers: false,
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    enableActiveFill: true,
                    obscuringCharacter: '*',
                    onChanged: (String value) {
                      _authController.otp.value = value;
                    },
                    onCompleted: (String otp) {
                      FocusManager.instance.primaryFocus!.unfocus();
                      _authController.otp.value = otp;
                      _authController.isLoading.value = true;
                      _authController.verifyOtp(context).whenComplete(() {
                        _authController.isLoading.value = false;
                      });
                    },
                    cursorColor: ConstColors.black,
                    keyboardType: TextInputType.number,
                    autoFocus: true,
                    textStyle: TextStyle(color: ConstColors.black, fontSize: 15.sp / MediaQuery.of(context).textScaler.scale(1)),
                    pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        activeFillColor: ConstColors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        fieldHeight: 57.h,
                        fieldWidth: 57.h,
                        selectedColor: ConstColors.grey.withOpacity(0.5),
                        activeColor: ConstColors.grey.withOpacity(0.5),
                        inactiveColor: ConstColors.grey.withOpacity(0.5),
                        selectedFillColor: ConstColors.white,
                        inactiveFillColor: ConstColors.white)),
                SizedBox(height: 32.h),
                Obx(() {
                  return Center(
                    child: Styles.regular(
                      '00:${_authController.start.value.toString().padLeft(2, "0")}',
                      fs: 18.sp,
                      ff: 'RM',
                      c: ConstColors.grey,
                    ),
                  );
                }),
                Obx(() => Center(
                    child: Styles.regular(_userController.countryCodeNumber.value + _authController.sms.value.text,
                        ff: 'RM', c: ConstColors.grey, fs: 18.sp))),
                SizedBox(height: 18.h),
                Obx(() {
                  return _authController.isLoading.value
                      ? Lottie.asset("assets/jsons/loading_circle.json", height: 82.w, width: 82.w)
                      : const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),

        // SizedBox(
        //   width: double.infinity,
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       SizedBox(height: 24.h),
        //       Styles.regular(S.of(context).sms_check, c: Theme.of(context).primaryColor, fs: 18.sp, al: TextAlign.center),
        //       SizedBox(height: 25.h),
        //       Styles.regular(S.of(context).enter_code, fs: 14.sp, c: ConstColors.subtitle),
        //       SizedBox(height: 21.h),
        //       Padding(
        //         padding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 17.h),
        //         child: PinCodeTextField(
        //             autoDisposeControllers: false,
        //             appContext: context,
        //             length: 6,
        //             obscureText: false,
        //             obscuringCharacter: '*',
        //             onChanged: (String value) {
        //               _authController.otp.value = value;
        //             },
        //             onCompleted: (String otp) {
        //               _authController.otp.value = otp;
        //               _authController.isLoading.value = true;
        //               _authController.verifyOtp(context).whenComplete(() {
        //                 _authController.isLoading.value = false;
        //               });
        //             },
        //             cursorColor: Theme.of(context).primaryColor,
        //             keyboardType: TextInputType.number,
        //             autoFocus: true,
        //             textStyle: TextStyle(color: Theme.of(context).primaryColor, fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
        //             pinTheme: PinTheme(
        //               shape: PinCodeFieldShape.box,
        //               borderRadius: BorderRadius.circular(10.r),
        //               fieldHeight: 57.h,
        //               fieldWidth: 57.h,
        //               selectedColor: const Color(0xffBABABA),
        //               activeColor: ConstColors.themeColor,
        //               inactiveColor: const Color(0xffBABABA),
        //             )),
        //       ),
        //       Obx(() {
        //         return Styles.regular(
        //           '00 : ${_authController.start.value.toString().padLeft(2, "0")}',
        //           fs: 20.sp,
        //           c: Theme.of(context).primaryColor,
        //         );
        //       }),
        //       Obx(() => Styles.regular(_userController.countryCodeNumber.value + _authController.sms.text, c: Theme.of(context).primaryColor, fs: 20.sp)),
        //       SizedBox(height: 64.h),
        //       Obx(() {
        //         if (_authController.isLoading.value) {
        //           return Lottie.asset("assets/jsons/down-loading.json");
        //         }
        //         if (_authController.otp.value.length < 6) {
        //           return button(width: 387.w, enable: false, context: context, title: S.of(context).following, onTap: () {});
        //         }
        //         return button(
        //             width: 387.w,
        //             context: context,
        //             title: S.of(context).following,
        //             onTap: () async {
        //               _authController.isLoading.value = true;
        //               _authController.verifyOtp(context).whenComplete(() {
        //                 _authController.isLoading.value = false;
        //               });
        //             });
        //       }),
        //       SizedBox(height: 11.h),
        //       Obx(() {
        //         return GestureDetector(
        //           onTap: _authController.start.value <= 0
        //               ? () {
        //                   Get.back();
        //                 }
        //               : null,
        //           child: Styles.regular(S.of(context).resend,
        //               fs: 18.sp, c: _authController.start.value <= 0 ? ConstColors.themeColor : Theme.of(context).scaffoldBackgroundColor, ff: 'RR'),
        //         );
        //       })
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
