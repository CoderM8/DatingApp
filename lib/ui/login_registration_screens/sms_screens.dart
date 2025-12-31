import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/authentication_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/ui/login_registration_screens/otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EnterSmsScreen extends GetView {
  final AuthController _authController = Get.put(AuthController());

  final UserController _userController = Get.put(UserController());

  EnterSmsScreen({Key? key}) : super(key: key);

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
                    _authController.sms.value.clear();
                    Get.back();
                  },
                ),
                GetBuilder<UserController>(
                  builder: (logic) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 80.h),
                        Styles.regular('Your_number'.tr, c: ConstColors.white, fs: 29.sp, ff: 'HB'),
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor: ConstColors.white,
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
                                    context: context,
                                    builder: (BuildContext c) {
                                      return DraggableScrollableSheet(
                                        initialChildSize: 0.6,
                                        expand: false,
                                        maxChildSize: 0.8,
                                        minChildSize: 0.2,
                                        builder: (context, scrollController) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(height: 25.h),
                                                Container(height: 1.h, width: 58.w, color: ConstColors.bottomBorder),
                                                SizedBox(height: 10.h),
                                                Styles.regular('Choose_country'.tr, fs: 18.sp, ff: 'HB', c: ConstColors.black),
                                                SizedBox(height: 28.h),
                                                _authController.apiResponse != null && _authController.apiResponse!.results != null
                                                    ? Expanded(
                                                        child: ListView.separated(
                                                          itemCount: _authController.apiResponse!.results!.length,
                                                          shrinkWrap: true,
                                                          controller: scrollController,
                                                          separatorBuilder: (context, index) => SizedBox(height: 17.h),
                                                          itemBuilder: (context, index) {
                                                            return InkWell(
                                                              onTap: () {
                                                                _userController.countryCodeNumber.value =
                                                                    _authController.apiResponse!.results![index]['DialCode'];
                                                                Get.back();
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 45.w,
                                                                    child: Styles.regular(_authController.apiResponse!.results![index]['DialCode'],
                                                                        fs: 18.sp, c: ConstColors.black),
                                                                  ),
                                                                  SizedBox(width: 27.w),
                                                                  Styles.regular(_authController.apiResponse!.results![index]['Name'],
                                                                      fs: 18.sp, c: ConstColors.black, ff: 'HB'),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : Center(child: CircularProgressIndicator(color: ConstColors.themeColor))
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    });
                              },
                              child: Obx(() {
                                return TextFieldModel(
                                  containerColor: Colors.transparent,
                                  width: 88.w,
                                  borderColor:ConstColors.white,
                                  color: ConstColors.white,
                                  enabled: false,
                                  controllers: TextEditingController(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 18.w),
                                  textAlign: TextAlign.center,
                                  hint: _userController.countryCodeNumber.value,
                                  hintTextColor: ConstColors.white,
                                  hintTextSize: 18.sp,
                                );
                              }),
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: TextFieldModel(
                                containerColor: Colors.transparent,
                                cursorColor: ConstColors.white,
                                borderColor: ConstColors.white,
                                color: ConstColors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 18.w),
                                controllers: _authController.sms.value,
                                hint: 'xxx-xxx-xxx',
                                onChanged: (v) {
                                  if (v.length < 5 || v.length > 12 || v.isEmpty) {
                                    _authController.isValid.value = false;
                                  } else {
                                    _authController.isValid.value = true;
                                  }
                                },
                                textInputType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        Styles.regular('Your_Number_Text'.tr, c: ConstColors.white, fs: 15.sp, al: TextAlign.center),
                        SizedBox(height: 70.h),
                        Obx(() {
                          _authController.isValid.value;
                          return Center(
                              child: GradientButton(
                                  title: 'Sendcode'.tr,
                                  width: 189.w,
                                  onTap: () async {
                                    if (_authController.sms.value.text.isNotEmpty) {
                                      await _authController.verifyPhone(
                                          _userController.countryCodeNumber.value + _authController.sms.value.text, context);
                                      FocusManager.instance.primaryFocus!.unfocus();
                                      Get.to(() => OtpVerificationScreen());
                                    }
                                  },
                                  enable: _authController.isValid.value,
                                  color1: ConstColors.darkRedColor,
                                  color2: ConstColors.lightRedColor));
                        }),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
