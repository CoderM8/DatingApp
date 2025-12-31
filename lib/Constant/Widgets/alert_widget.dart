// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/theme/theme.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';

RxBool isDownloading = false.obs;

Future showAlertDownloadDialog(context, {required Widget down, VoidCallback? onTap, VoidCallback? onCancel}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context2) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          width: 300.w,
          decoration: BoxDecoration(color: ConstColors.white, borderRadius: BorderRadius.circular(20.r)),
          padding: EdgeInsets.only(top: 15.h, bottom: 15.h, left: 12.w, right: 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgView('assets/Icons/zip_download.svg', color: ConstColors.themeColor, height: 44.h, width: 40.w, fit: BoxFit.cover),
              Styles.regular('Downloading_file'.tr, fs: 16.sp, ff: 'HB', c: ConstColors.black),
              SizedBox(height: 8.h),
              Styles.regular('Downloading_file_text'.tr, al: TextAlign.center, c: ConstColors.black, fs: 16.sp),
              SizedBox(height: 7.h),
              Divider(color: ConstColors.closeColor, height: 1),
              SizedBox(height: 15.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: GradientButton(
                  width: MediaQuery.sizeOf(context).width,
                  title: 'Go_to_Downloads'.tr,
                  onTap: onTap,
                ),
              ),
              SizedBox(height: 13.h),
              InkWell(
                onTap: onCancel,
                child: Styles.regular('Not_now'.tr, fs: 16.sp, c: ConstColors.themeColor),
              ),
              Obx(() {
                return isDownloading.value
                    ? down
                    : Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Styles.regular('file_download_successfully'.tr, fs: 16.sp, c: ConstColors.lightGreenColor),
                      );
              }),
            ],
          ),
        ),
      );
    },
  );
}

void showAlertDialog(context, {required String title, String? subtitle, String? buttonText, VoidCallback? onTap}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context2) {
      return Center(
        child: Container(
          width: 388.w,
          decoration: BoxDecoration(color: ConstColors.white, borderRadius: BorderRadius.circular(40.r)),
          padding: EdgeInsets.only(top: 22.h, bottom: 29.h, left: 44.w, right: 44.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Styles.regular('attention'.tr, fs: 20.sp, ff: 'RB', c: ConstColors.black),
              SizedBox(height: 20.h),
              Styles.regular(title, al: TextAlign.center, c: ConstColors.black, fs: 18.sp),
              if (subtitle != null) ...[
                SizedBox(height: 20.h),
                Styles.regular(subtitle, al: TextAlign.center, c: ConstColors.black, fs: 18.sp),
              ],
              SizedBox(height: 25.h),
              GradientButton(
                  width: MediaQuery.sizeOf(context).width,
                  title: buttonText ?? 'confirm'.tr,
                  enable: true,
                  onTap: onTap ??
                      () {
                        Get.back();
                      })
            ],
          ),
        ),
      );
    },
  );
}

void showDeleteDialog(context, {required String title, String? subtitle, String? buttonText, VoidCallback? onTap}) {
  showDialog(
    context: context,
    builder: (BuildContext context2) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
        child: Container(
          width: 300.w,
          height: 238.h,
          decoration: BoxDecoration(color: ConstColors.white, borderRadius: BorderRadius.circular(40.r)),
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 22.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Styles.regular('attention'.tr, fs: 20.sp, ff: 'RB', c: ConstColors.black),
              SizedBox(height: 13.h),
              Styles.regular(title, al: TextAlign.center, c: ConstColors.black, fs: 18.sp),
              SizedBox(height: 18.h),
              GradientButton(width: MediaQuery.sizeOf(context).width, title: 'accept'.tr, onTap: onTap),
              SizedBox(height: 16.h),
              InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Styles.regular('Cancel'.tr.toUpperCase(), fs: 16.sp, ff: 'HR', c: ConstColors.redColor)),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> AlertShow({
  required BuildContext context,
  required Function onConfirm,
  required String text1,
  required String text2,
  String? confirmText,
  String? svg,
  String? userImage,
  String? alert,
  Color? c1,
  Color? c2,
  String? reason,
  bool? forgot,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context2) {
      return Dialog(
        backgroundColor: bottomColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
        insetPadding: EdgeInsets.all(20.r),
        child: Padding(
          padding: EdgeInsets.only(right: 34.w, left: 34.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (forgot == null)
                Center(
                    child:
                        Styles.regular(alert ?? 'attention'.tr, fs: 20.sp, fw: FontWeight.bold, ff: 'RB', c: Theme.of(context).primaryColor, h: 3.h)),
              SizedBox(height: 15.h),
              if (text1.isNotEmpty)
                Center(
                    child: Styles.regular(text1,
                        al: TextAlign.center, c: c1 ?? Theme.of(context).primaryColor, fs: 20.sp, fw: FontWeight.bold, ff: 'RB')),
              if (svg != null) ...[
                SizedBox(height: 20.h),
                SvgPicture.asset(svg, color: ConstColors.themeColor),
              ],
              if (userImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(40.r),
                  child: CachedNetworkImage(
                    imageUrl: userImage,
                    fit: BoxFit.cover,
                    height: 70.h,
                    width: 70.h,
                    fadeInDuration: const Duration(milliseconds: 100),
                    placeholderFadeInDuration: const Duration(milliseconds: 100),
                    errorWidget: (context, url, error) => Center(child: Icon(Icons.error, color: Theme.of(context).primaryColor)),
                  ),
                ),
              SizedBox(height: 24.h),
              Center(
                  child: Styles.regular(
                text2,
                al: TextAlign.center,
                c: c2 ?? Theme.of(context).primaryColor,
                fs: 20.sp,
                fw: FontWeight.w400,
              )),
              Padding(
                padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                child: Column(
                  children: [
                    GradientButton(
                        title: confirmText ?? 'confirm'.tr,
                        fontSize: 20.sp,
                        textColor: ConstColors.white,
                        onTap: () {
                          Get.back();
                          onConfirm();
                        }),
                    SizedBox(height: 15.h),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Center(child: Styles.regular('Cancel'.tr, fs: 20.sp, c: ConstColors.themeColor, ff: 'RR')),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

/// RATE APP 1
Future<void> rateAppDialog1(BuildContext context, {void Function(String)? submit}) async {
  await showDialog(
    context: context,
    builder: (BuildContext c) => Dialog(
      backgroundColor: ConstColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 76.w),
      child: Padding(
        padding: EdgeInsets.only(top: 18.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgView("assets/Icons/eypoplogo.svg", height: 62.w, width: 62.w),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Styles.regular('how_your_experience'.tr, c: ConstColors.black, al: TextAlign.center, ff: 'HB', fs: 16.sp),
            ),
            SizedBox(height: 13.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    rateAppDialog2(c);
                  },
                  child: SvgPicture.asset('assets/Icons/ratelike.svg', height: 60.w, width: 60.w),
                ),
                SizedBox(width: 56.w),
                InkWell(
                  onTap: () {
                    rateAppDialog3(c, submit);
                  },
                  child: SvgPicture.asset('assets/Icons/ratedislike.svg', height: 60.w, width: 60.w),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Divider(height: 0.3.h, color: ConstColors.bottomBorder),
            InkWell(
              onTap: () {
                Get.back();
              },
              child: SizedBox(
                  height: 53.h, child: Align(alignment: Alignment.center, child: Styles.regular('notnow'.tr, c: ConstColors.themeColor, fs: 16.sp))),
            ),
          ],
        ),
      ),
    ),
  );
}

/// RATE APP 2 GIVE REVIEW IF LIKE
Future<void> rateAppDialog2(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext c) => Dialog(
      backgroundColor: ConstColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 76.w),
      child: Padding(
        padding: EdgeInsets.only(top: 18.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgView(
              "assets/Icons/eypoplogo.svg",
              height: 62.w,
              width: 62.w,
            ),
            SizedBox(height: 15.h),
            Styles.regular('do_you_like_eypop'.tr, c: ConstColors.black, ff: 'HB', al: TextAlign.center, fs: 16.sp),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Styles.regular('tap_star_rate_eypop'.tr, c: ConstColors.black, al: TextAlign.center, fs: 16.sp),
            ),
            SizedBox(height: 10.h),
            Divider(height: 0.3.h, color: ConstColors.bottomBorder),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
              child: RatingBar(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemSize: 30.w,
                updateOnDrag: false,
                itemCount: 5,
                glow: false,
                glowColor: Colors.transparent,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
                ratingWidget: RatingWidget(
                  empty: SvgPicture.asset('assets/Icons/emptystar.svg', height: 21.w, width: 21.w),
                  half: SvgPicture.asset('assets/Icons/emptystar.svg', height: 21.w, width: 21.w),
                  full: SvgPicture.asset('assets/Icons/fullstar.svg', height: 21.w, width: 21.w),
                ),
                onRatingUpdate: (rating) async {
                  final ParseObject review = ParseObject('User_Review');
                  review['User'] = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                  review['status'] = 1;
                  review['Rate'] = rating;
                  await review.save();
                  final appId = Platform.isAndroid ? 'com.actuajeriko.eypop' : '1628570550';
                  final url = Uri.parse(Platform.isAndroid ? "market://details?id=$appId" : "https://apps.apple.com/app/id$appId");
                  await launchUrl(url);
                  Get.back();
                  Get.back();
                },
              ),
            ),
            Divider(height: 0.3.h, color: ConstColors.bottomBorder),
            InkWell(
              onTap: () {
                Get.back();
              },
              child: SizedBox(
                  height: 53.h, child: Align(alignment: Alignment.center, child: Styles.regular('notnow'.tr, c: ConstColors.themeColor, fs: 16.sp))),
            ),
          ],
        ),
      ),
    ),
  );
}

/// RATE APP 3 GIVE REVIEW IF DISLIKE
Future<void> rateAppDialog3(BuildContext context, void Function(String)? submit) async {
  final TextEditingController reviewController = TextEditingController();
  await showDialog(
    context: context,
    builder: (BuildContext c) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      backgroundColor: ConstColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
      child: Padding(
        padding: EdgeInsets.only(top: 18.h, left: 44.w, right: 44.w, bottom: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgView(
              "assets/Icons/eypoplogo.svg",
              height: 62.w,
              width: 62.w,
            ),
            SizedBox(height: 19.h),
            Styles.regular('your_opinion'.tr, c: ConstColors.black, al: TextAlign.center, fs: 19.sp),
            SizedBox(height: 20.h),
            TextFieldModel(
              contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
              controllers: reviewController,
              hint: 'what_can_improve'.tr,
              hintTextColor: ConstColors.black.withOpacity(0.4),
              color: ConstColors.black,
              borderColor: ConstColors.black,
              containerColor: Colors.transparent,
              textInputType: TextInputType.text,
            ),
            SizedBox(height: 22.h),
            GradientButton(
                width: double.infinity,
                color1: ConstColors.darkRedColor,
                color2: ConstColors.lightRedColor,
                enable: true,
                title: 'send'.tr,
                onTap: () async {
                  if (reviewController.text.isNotEmpty) {
                    submit!(reviewController.text);
                  }
                }),
            SizedBox(height: 17.h),
            InkWell(
                onTap: () {
                  Get.back();
                },
                child: Styles.regular('notnow'.tr, al: TextAlign.center, fs: 16.sp, c: ConstColors.themeColor))
          ],
        ),
      ),
    ),
  );
}

Future<void> checkUserPermission({bool video = false}) async {
  final PermissionStatus status = await Permission.microphone.status;
  if (status.isDenied) {
    await Permission.microphone.request();
  } else if (status.isPermanentlyDenied) {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        elevation: 0,
        backgroundColor: bottomColor(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 20.w),
                  Icon(Icons.mic, size: 30.sp, color: Theme.of(Get.context!).primaryColor),
                  Flexible(
                      child: Styles.regular('Allow_Permission'.tr,
                          c: Theme.of(Get.context!).primaryColor, al: TextAlign.center, fs: 22.sp, fw: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20.h),
              Styles.regular('Allow_text'.tr, al: TextAlign.center, fs: 16.sp, c: Theme.of(Get.context!).primaryColor),
              SizedBox(height: 27.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 50.h,
                      width: 151.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xff939393),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Styles.regular('Cancel'.tr, fs: 18.sp, c: Colors.white, ff: 'RR'),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await openAppSettings();
                      Get.back();
                    },
                    child: Container(
                      height: 50.h,
                      width: 151.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ConstColors.themeColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Styles.regular('Settings'.tr, fs: 18.sp, c: Colors.white, ff: "RR"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  if (video) {
    final PermissionStatus camera = await Permission.camera.status;
    if (camera.isDenied) {
      await Permission.camera.request();
    } else if (camera.isPermanentlyDenied) {
      await Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          elevation: 0,
          backgroundColor: bottomColor(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 20.w),
                    Icon(Icons.camera_alt, size: 30.sp, color: Theme.of(Get.context!).primaryColor),
                    Flexible(
                        child: Styles.regular('Allow_Permission'.tr,
                            c: Theme.of(Get.context!).primaryColor, al: TextAlign.center, fs: 22.sp, fw: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 20.h),
                Styles.regular('Allow_text_camera'.tr, al: TextAlign.center, fs: 16.sp, c: Theme.of(Get.context!).primaryColor),
                SizedBox(height: 27.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 50.h,
                        width: 151.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xff939393),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Styles.regular('Cancel'.tr, fs: 18.sp, c: Colors.white, ff: 'RR'),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await openAppSettings();
                        Get.back();
                      },
                      child: Container(
                        height: 50.h,
                        width: 151.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ConstColors.themeColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Styles.regular('Settings'.tr, fs: 18.sp, c: Colors.white, ff: "RR"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }
}
