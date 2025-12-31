// ignore_for_file: deprecated_member_use

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/user_controller/update_user_controller.dart';
import 'package:eypop/back4appservice/user_provider/users/update_user_provider.dart';
import 'package:eypop/models/user_login/update_user.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/ui/login_registration_screens/user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UpdateUserDetailScreen extends GetView {
  const UpdateUserDetailScreen({Key? key}) : super(key: key);

  static UpdateUserController get _updateUserController => Get.find<UpdateUserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientWidget(
        child: Padding(
          padding: EdgeInsets.only(top: 58.h, left: 20.w, right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Obx(() {
                    return !_updateUserController.status.value
                        ? SvgView(
                            "assets/Icons/info.svg",
                            color: ConstColors.closeColor,
                            height: 40.w,
                            width: 40.w,
                            onTap: () {
                              showDialog(
                                context: Get.context!,
                                builder: (context) {
                                  return Dialog(
                                    backgroundColor: ConstColors.white,
                                    insetPadding: EdgeInsets.symmetric(horizontal: 70.w),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 30.h),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Styles.regular('attention'.tr, c: ConstColors.black, ff: 'HB', fs: 20.sp),
                                          SizedBox(height: 20.h),
                                          Styles.regular(
                                              'You have to restart the application after your gender change request is accepted by the admin.'.tr,
                                              al: TextAlign.center,
                                              c: ConstColors.black,
                                              fs: 18.sp),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : const SizedBox.shrink();
                  }),
                ],
              ),
              SizedBox(height: 80.h),
              Styles.regular('my_account'.tr, c: ConstColors.white, fs: 29.sp, ff: 'HB'),
              SizedBox(height: 12.h),
              Obx(() {
                return conButton(
                  context,
                  title: 'i_man_looking_woman'.tr,
                  color1: ConstColors.blueColor,
                  color2: ConstColors.purpleColor,
                  clicked: _updateUserController.male.value,
                  ontap: () {
                    _updateUserController.male.value = true;
                    _updateUserController.female.value = false;
                  },
                );
              }),
              SizedBox(height: 15.h),
              Obx(() {
                return conButton(
                  context,
                  title: 'i_woman_looking_man'.tr,
                  color1: ConstColors.purpleColor,
                  color2: ConstColors.darkBlueColor,
                  clicked: _updateUserController.female.value,
                  ontap: () {
                    _updateUserController.male.value = false;
                    _updateUserController.female.value = true;
                  },
                );
              }),
              SizedBox(height: 17.h),
              Styles.regular('birthday'.tr, c: ConstColors.white, fs: 18.sp),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: () async {
                  datePick(context);
                },
                child: Container(
                  height: 57.h,
                  width: 386.w,
                  decoration: BoxDecoration(
                      color: Colors.transparent, borderRadius: BorderRadius.circular(6.r), border: Border.all(color: ConstColors.white, width: 1.w)),
                  child: Padding(
                    padding: EdgeInsets.only(left: 24.w, right: 11.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Styles.regular(_updateUserController.finalDate.value, c: ConstColors.white, fs: 22.sp)),
                        SvgPicture.asset('assets/Icons/date.svg')
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 65.h),
              Obx(() {
                return GradientButton(
                  enable: _updateUserController.status.value &&
                          (_updateUserController.gender.value != (_updateUserController.male.value ? 'male' : 'female') ||
                              _updateUserController.birthdate.value != _updateUserController.selectedDate.value)
                      ? true
                      : false,
                  title: _updateUserController.status.value ? 'confirm'.tr : 'pending'.tr,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context2) {
                        return Dialog(
                          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
                          backgroundColor: ConstColors.white,
                          child: Padding(
                            padding: EdgeInsets.only(top: 22.h, left: 44.w, right: 44.w, bottom: 18.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Styles.regular('attention'.tr, c: ConstColors.black, fs: 20.sp, ff: 'RB'),
                                    SizedBox(height: 20.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                      child: RichText(
                                          textScaleFactor: 1,
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                              text: 'these_data_about'.tr,
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                color: ConstColors.black,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'not_modify'.tr,
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    color: ConstColors.redColor,
                                                  ),
                                                )
                                              ])),
                                    ),
                                    SizedBox(height: 20.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Styles.regular("${'am'.tr} ", c: ConstColors.black, fs: 18.sp, ff: 'HB'),
                                        Styles.regular(_updateUserController.male.value ? 'man'.tr : 'woman'.tr,
                                            c: ConstColors.orangeColor, fs: 18.sp, ff: 'HB'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Styles.regular("${'birthday'.tr} ", c: ConstColors.black, fs: 18.sp, ff: 'HB'),
                                        Styles.regular(_updateUserController.finalDate.value, c: ConstColors.orangeColor, fs: 18.sp, ff: 'HB'),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 19.h),
                                GradientButton(
                                    width: MediaQuery.sizeOf(context).width,
                                    title: 'accept'.tr,
                                    onTap: () async {
                                      UpdateUser updateUser = UpdateUser();
                                      updateUser.newDate = _updateUserController.selectedDate.value;
                                      updateUser.newGender = _updateUserController.male.value ? 'male' : 'female';
                                      updateUser.oldGender = _updateUserController.userData!.result['Gender'];
                                      updateUser.oldDate = _updateUserController.userData!.result['BirthDate'];
                                      updateUser.user = UserLogin()..objectId = _updateUserController.userData!.result['objectId'];
                                      updateUser.status = 'PENDING';
                                      _updateUserController.status.value = false;
                                      await UpdateUserProviderApi().add(updateUser).then((value) {
                                        Get.back();
                                        // Get.back();
                                      });
                                    }),
                                SizedBox(height: 22.h),
                                InkWell(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Styles.regular('Cancel'.tr.toUpperCase(), c: ConstColors.redColor, fs: 18.sp, ff: 'HB')),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void datePick(BuildContext context) async {
    showModalBottomSheet(
        backgroundColor: ConstColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
        context: context,
        builder: (BuildContext c) {
          return Padding(
            padding: EdgeInsets.only(top: 15.h, bottom: 48.h, left: 20.w, right: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                SizedBox(height: 9.h),
                Styles.regular('date_birthday'.tr, c: ConstColors.black, fs: 18.sp, ff: 'HB'),
                Padding(
                  padding: EdgeInsets.only(left: 45.w, right: 45.w, top: 35.h),
                  child: DatePickerWidget(
                    looping: false,
                    firstDate: DateTime(1920),
                    lastDate: DateTime.now().subtract(const Duration(days: 6570)),
                    initialDate: _updateUserController.selectedDate.value,

                    /// Localization in date picker
                    // locale: DateTimePickerLocale.es,
                    dateFormat: "dd-MMM-yyyy",
                    onChange: (DateTime newDate, _) {
                      _updateUserController.selectedDate.value = newDate;
                      _updateUserController.finalDate.value = DateFormat('dd/MM/yyyy').format(_updateUserController.selectedDate.value).toString();
                    },
                    pickerTheme: DateTimePickerTheme(
                      backgroundColor: ConstColors.white,
                      itemTextStyle:
                          TextStyle(color: ConstColors.black, fontSize: 24.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
                      dividerColor: ConstColors.themeColor.withOpacity(0.5),
                    ),
                  ),
                ),
                GradientButton(
                    width: MediaQuery.sizeOf(context).width,
                    color1: ConstColors.darkRedColor,
                    color2: ConstColors.lightRedColor,
                    enable: true,
                    title: 'accept'.tr,
                    onTap: () {
                      Get.back();
                    }),
                SizedBox(height: 16.h),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Styles.regular('Cancel'.tr.toUpperCase(), c: ConstColors.redColor, fs: 18.sp, ff: 'HB'),
                ),
              ],
            ),
          );
        });
  }
}
