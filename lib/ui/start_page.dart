// ignore_for_file: must_be_immutable, deprecated_member_use
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/authentication_controller.dart';
import 'package:eypop/ui/login_registration_screens/email_login.dart';
import 'package:eypop/ui/login_registration_screens/sms_screens.dart';
import 'package:eypop/ui/splash_screen_first.dart';
import 'package:eypop/ui/terms_condition.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:video_player/video_player.dart';

import '../Controllers/start_page_controller.dart';
import 'cookie_policy.dart';
import 'privacy_policy.dart';

class StartScreen extends GetView {
  StartScreen({Key? key}) : super(key: key);

  final AuthController _authController = Get.put(AuthController());
  final StartVideoController _videoController = Get.put(StartVideoController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ModalProgressHUD(
        inAsyncCall: _authController.isLoading.value,
        blur: 2,
        progressIndicator: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Stack(children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: VideoPlayer(_videoController.videoController!),
              ),
              Container(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                padding: EdgeInsets.only(top: 85.h, bottom: 65.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        ConstColors.themeColor.withOpacity(0.5),
                        ConstColors.themeColor.withOpacity(0.5),
                        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.1, 0.9]),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Lottie.asset("assets/jsons/fire.json", height: 115.w, width: 115.w, fit: BoxFit.fill),
                        Column(
                          children: [
                            Styles.regular('eypop', fs: 78.sp, ff: 'HL', c: ConstColors.white),
                            Styles.regular('LOVE CANALLA', fs: 29.sp, ff: 'HL', c: ConstColors.white),
                          ],
                        )
                      ],
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            backgroundColor: ConstColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
                            context: context,
                            builder: (BuildContext c) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 15.h),
                                  Container(height: 1.h, width: 58.w, color: ConstColors.bottomBorder),
                                  SizedBox(height: 17.h),
                                  Styles.regular('Enter_with'.tr, fs: 18.sp, ff: 'HB', c: ConstColors.black),
                                  SizedBox(height: 26.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Obx(() {
                                        if (isShowSms.value) {
                                          return Row(
                                            children: [
                                              loginButton(
                                                svg: 'assets/Logos/phone.svg',
                                                onTap: () {
                                                  Get.back();
                                                  Get.to(() => EnterSmsScreen());
                                                },
                                              ),
                                              SizedBox(width: 29.w)
                                            ],
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      }),
                                      if (Platform.isIOS) ...[
                                        loginButton(
                                            svg: 'assets/Logos/apple.svg',
                                            onTap: () {
                                              Get.back();
                                              _authController.doSignInApple(context);
                                            }),
                                        SizedBox(width: 29.w),
                                      ],
                                      loginButton(
                                          svg: 'assets/Logos/facebook.svg',
                                          onTap: () {
                                            Get.back();
                                            _authController.signInWithFacebook(context);
                                          }),
                                      SizedBox(width: 29.w),
                                      loginButton(
                                          svg: 'assets/Logos/google.svg',
                                          onTap: () {
                                            Get.back();
                                            _authController.signupWithGoogle(context);
                                          }),
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  InkWell(
                                    onTap: () {
                                      Get.back();
                                      Get.to(() => EmailLoginScreen());
                                    },
                                    child: Container(
                                      height: 54.h,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(width: 0.3.h, color: ConstColors.bottomBorder))),
                                      child: Styles.regular("Sign_with".tr, fs: 16.sp, ff: 'HB', c: ConstColors.themeColor),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  Padding(
                                    padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
                                    child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                            text: "agree".tr,
                                            children: [
                                              TextSpan(
                                                  text: '${"terms".tr}. ',
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      Get.to(() => TermsCondition());
                                                    },
                                                  style: TextStyle(color: ConstColors.themeColor, fontFamily: "HR", fontSize: 15.sp)),
                                              TextSpan(text: "Learn_more".tr, style: TextStyle(color: ConstColors.bottomBorder, fontFamily: "HR", fontSize: 15.sp)),
                                              TextSpan(
                                                  text: "privacypolicy".tr,
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      Get.to(() => PrivacyPolicy());
                                                    },
                                                  style: TextStyle(color: ConstColors.themeColor, fontFamily: "HR", fontSize: 15.sp)),
                                              TextSpan(text: "and_our".tr, style: TextStyle(color: ConstColors.bottomBorder, fontFamily: "HR", fontSize: 15.sp)),
                                              TextSpan(
                                                  text: "cookies".tr,
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      Get.to(() => CookiePolicy());
                                                    },
                                                  style: TextStyle(color: ConstColors.themeColor, fontFamily: "HR", fontSize: 15.sp)),
                                            ],
                                            style: TextStyle(color: ConstColors.bottomBorder, fontFamily: "HR", fontSize: 15.sp))),
                                  ),
                                ],
                              );
                            });
                      },
                      child: Container(
                        height: 50.h,
                        width: 143.w,
                        alignment: Alignment.center,
                        decoration:
                            BoxDecoration(color: ConstColors.white, borderRadius: BorderRadius.circular(60.r), border: Border.all(width: 1.w, color: ConstColors.bottomBorder)),
                        child: Styles.regular('get_in'.tr, fs: 18.sp, ff: 'HB', c: ConstColors.black),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Styles.regular('@ 2025 eypop, versión ${_authController.version} ${PaintingBinding.instance.platformDispatcher.locale.countryCode}',
                        fs: 15.sp, c: ConstColors.white),
                  ],
                ),
              ),
            ]),
          ),
        ),
      );
    });
  }

  Widget loginButton({required String svg, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(svg, height: 63.w, width: 63.w),
    );
  }
}
