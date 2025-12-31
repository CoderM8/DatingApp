import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/setting_controllers.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../service/local_storage.dart';

class DeletedAccountScreen extends StatelessWidget {
  DeletedAccountScreen({Key? key}) : super(key: key);
  final SettingController _settingController = Get.put(SettingController());
  final UserController _userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ConstColors.black,
        leading: const SizedBox.shrink(),
        actions: [
          TextButton(
            child: Styles.regular('logout'.tr, c: ConstColors.white),
            onPressed: () async {
              _settingController.logout().whenComplete(() {
                StorageService.getBox.write('isDeleted', false);
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 1),
            SvgView(
              "assets/Icons/clock.svg",
              height: 92.w,
              width: 92.w,
            ),
            SizedBox(height: 28.h),
            Styles.regular('attention'.tr, fs: 18.sp, c: ConstColors.white, ff: 'HB'),
            SizedBox(height: 16.h),
            Styles.regular('Your_account_is_scheduled_to_be_deleted'.tr, al: TextAlign.center, fs: 18.sp, c: ConstColors.white, ff: 'HB'),
            SizedBox(height: 36.h),
            Styles.regular('cancel_restore_please_contact_support'.tr, al: TextAlign.center, fs: 18.sp, c: ConstColors.white),
            SizedBox(height: 18.h),
            Obx(() {
              return InkWell(
                  onTap: () async {
                    final String subject = Uri.encodeComponent('mail_subject'.tr);
                    final String body = Uri.encodeComponent('mail_body'.tr);
                    final Uri mail = Uri.parse("mailto:${_userController.email.value}?subject=$subject&body=$body");

                    await launchUrl(mail);
                  },
                  child: Styles.regular(_userController.email.value, c: ConstColors.themeColor, fs: 18.sp));
            }),
            const Spacer(flex: 2)
          ],
        ),
      ),
    );
  }
}
