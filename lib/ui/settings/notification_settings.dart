// ignore_for_file: must_be_immutable

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/setting_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';

class NotificationSettings extends GetView {
  const NotificationSettings({Key? key}) : super(key: key);
  static SettingController get _settingController => Get.find<SettingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 29.w, width: 29.w),
        centerTitle: true,
        title: Styles.regular('notifications'.tr, c: ConstColors.closeColor, fs: 31.sp, ff: 'HM'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.only(top: 5.h),
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, i) => Divider(height: 1, color: ConstColors.closeColor),
        itemCount: _settingController.switchTitle.length,
        itemBuilder: (context, i) {
          return Obx(() {
            return InkWell(
              onTap: () {
                _settingController.button(i);
              },
              child: Container(
                height: 58.h,
                color: Theme.of(context).dialogBackgroundColor,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    SvgView(_settingController.switchTitle[i]['svg'], color: Theme.of(context).primaryColor),
                    SizedBox(width: 26.w),
                    Styles.regular(_settingController.switchTitle[i]['title'], c: Theme.of(context).primaryColor, fs: 18.sp),
                    const Spacer(),
                    SvgView('assets/Icons/check.svg', color: _settingController.switchValues[i] ? ConstColors.lightGreenColor : ConstColors.closeColor)
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
