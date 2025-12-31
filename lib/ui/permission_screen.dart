// ignore_for_file: deprecated_member_use

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class PermissionScreen extends StatelessWidget {
  final VoidCallback? onTap;
  const PermissionScreen({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GradientWidget(
      child: Padding(
        padding: EdgeInsets.only(top: 58.h, left: 20.w, right: 20.w),
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
            Styles.regular('your_current_location'.tr, fs: 29.sp, c: ConstColors.white, ff: 'HB'),
            Center(child: Lottie.asset('assets/jsons/gps-location-pointer.json', height: 230.w, width: 230.w)),
            Center(child: Styles.regular('location_permission_text'.tr, fs: 24.sp, c: ConstColors.white, al: TextAlign.center)),
            SizedBox(height: 33.h),
            GradientButton(
              onTap: onTap ??
                  () async {
                    bool serviceEnabled;
                    LocationPermission permission;
                    serviceEnabled = await Geolocator.isLocationServiceEnabled();
                    if (!serviceEnabled) {
                      Geolocator.openLocationSettings();
                      return Future.error('Location services are disabled.');
                    }
                    permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.denied) {
                        return Future.error('Location permissions are denied');
                      }
                    }
                    if (permission == LocationPermission.deniedForever) {
                      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
                    }
                    Get.back();
                  },
              title: 'continue'.tr,
              width: MediaQuery.sizeOf(context).width,
            ),
          ],
        ),
      ),
    ));
  }
}
