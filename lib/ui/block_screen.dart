import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/setting_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class BlockScreen extends StatelessWidget {
  const BlockScreen({Key? key, required this.text1, required this.text2, this.reason, this.onTap}) : super(key: key);
  final String text1;
  final String text2;
  final String? reason;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      isBlockLogoutLoading.value;
      return Scaffold(
        backgroundColor: ConstColors.black,
        appBar: AppBar(
            backgroundColor: ConstColors.black,
            // leadingWidth: 45.w,
            leading: isBlockLogoutLoading.value
                ?  Lottie.asset('assets/jsons/three-dot-loading.json', height: 60.w, width: 60.w, fit: BoxFit.scaleDown)
                : Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: SvgView(
                      "assets/Icons/cancelbutton.svg",
                      height: 45.w,
                      width: 45.w,
                      onTap: onTap ??
                          () {
                            Get.back();
                          },
                    ),
                  )),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Center(child: Styles.regular('attention'.tr, fs: 18.sp, ff: 'HB', c: ConstColors.white)),
              SizedBox(height: 15.h),
              Styles.regular(text1, c: ConstColors.white, fs: 18.sp),
              SizedBox(height: 24.h),
              Styles.regular(
                text2,
                c: ConstColors.white,
                fs: 18.sp,
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: onTap ??
                    () {
                      Get.back();
                    },
                child: Styles.regular(reason ?? 'ok'.tr, c: ConstColors.redColor, ff: "RB", fs: 18.sp),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      );
    });
  }
}
