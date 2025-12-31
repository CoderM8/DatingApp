// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Constant/theme/theme.dart';
import 'package:eypop/Controllers/setting_controllers.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/Controllers/user_controller/update_user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/login_registration_screens/update_user_details.dart';
import 'package:eypop/ui/privacy_policy.dart';
import 'package:eypop/ui/settings/change_language.dart';
import 'package:eypop/ui/settings/changepassword_screen.dart';
import 'package:eypop/ui/settings/download_screen.dart';
import 'package:eypop/ui/settings/notification_settings.dart';
import 'package:eypop/ui/splash_screen_first.dart';
import 'package:eypop/ui/terms_condition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends GetView {
  Settings({Key? key}) : super(key: key);

  static SettingController get _settingController => Get.put(SettingController());

  static UserController get _userController => Get.find<UserController>();

  static UpdateUserController get _updateUserController => Get.put(UpdateUserController());

  @override
  Widget build(BuildContext context) {
    final themeModeNotifier = Provider.of<ThemeModeNotifier>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).hintColor,
      appBar: AppBar(
        elevation: 0.3,
        leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 29.w, width: 29.w),
        centerTitle: true,
        title: Styles.regular('Settings'.tr, c: ConstColors.closeColor, fs: 31.sp, ff: 'HM'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.h),
            divider(),
            Container(
              height: 93.h,
              color: Theme.of(context).dialogBackgroundColor,
              width: MediaQuery.sizeOf(context).width,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgView('assets/Icons/sexIcon.svg', height: 44.h, width: 42.w, color: Theme.of(context).primaryColor),
                  SizedBox(width: 24.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: 35.h,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 10.w, right: 10.w),
                          decoration: BoxDecoration(
                              color: StorageService.getBox.read('Gender') == 'male' ? ConstColors.themeColor : ConstColors.purpleMediumColor,
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: ConstColors.bottomBorder, width: 1.w)),
                          child: Styles.regular(StorageService.getBox.read('Gender') == 'male' ? 'i_am_a_man'.tr : 'i_am_a_woman'.tr,
                              ff: 'HR', fs: 18.sp, c: ConstColors.white),
                        ),
                      ),
                      SizedBox(height: 7.h),
                      Styles.regular(_settingController.birthDate.value, ff: 'HR', fs: 18.sp, c: Theme.of(context).primaryColor),
                    ],
                  ),
                  const Spacer(),
                  Obx(() {
                    return Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: Styles.regular(_updateUserController.status.value ? '' : 'pending'.tr, ff: 'HR', fs: 18.sp, c: ConstColors.redColor));
                  }),
                  SizedBox(width: 17.w),
                  SvgView(
                    'assets/Icons/xenderChange.svg',
                    color: Theme.of(context).primaryColor,
                    onTap: () {
                      Get.to(() => const UpdateUserDetailScreen());
                    },
                  ),
                ],
              ),
            ),
            divider(),
            Obx(() {
              nonVisibleInteractionsOptions.value;
              return nonVisibleInteractionsOptions.value == false
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 7.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Styles.regular('call_chat_videocall'.tr, fs: 20.sp, c: Theme.of(context).primaryColor),
                              Styles.regular('do_you_receivecalls'.tr, al: TextAlign.start, fs: 16.sp, c: ConstColors.closeColor),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        divider(),
                        Obx(() {
                          return callsAndChat(
                              svg: 'assets/Icons/call_outline.svg',
                              title: 'calls'.tr,
                              yesno: accountType.value == 'FAKE' ? !noCallsProfile.value : !noCalls.value,
                              onTap: accountType.value == 'FAKE'
                                  ? () {
                                      /// user_login in "InfluencerCall" == True then change status
                                      if (influencerCall.value == true) {
                                        _settingController.statusChangeInfluencer(0);
                                      } else {
                                        print('*** Hello InfluencerCall False ***');
                                      }
                                    }
                                  : () {
                                      _settingController.statusChange(0);
                                    });
                        }),
                        divider(),
                        Obx(() {
                          return callsAndChat(
                              svg: 'assets/Icons/video_outline.svg',
                              title: 'videocalls'.tr,
                              yesno: accountType.value == 'FAKE' ? !noVideocallsProfile.value : !noVideocalls.value,
                              onTap: accountType.value == 'FAKE'
                                  ? () {
                                      /// user_login in "InfluencerVideocall" == True then change status
                                      if (influencerVideocall.value == true) {
                                        _settingController.statusChangeInfluencer(1);
                                      } else {
                                        print('*** Hello InfluencerVideocall False ***');
                                      }
                                    }
                                  : () {
                                      _settingController.statusChange(1);
                                    });
                        }),
                        divider(),
                        Obx(() {
                          return callsAndChat(
                              svg: 'assets/Icons/chat_outline.svg',
                              title: 'chats'.tr,
                              yesno: accountType.value == 'FAKE' ? !noChatsProfile.value : !noChats.value,
                              onTap: accountType.value == 'FAKE'
                                  ? () {
                                      _settingController.statusChangeInfluencer(2);
                                    }
                                  : () {
                                      _settingController.statusChange(2);
                                    });
                        }),
                        divider(),
                      ],
                    )
                  : const SizedBox.shrink();
            }),
            Padding(
              padding: EdgeInsets.only(top: 17.h, bottom: 9.h, left: 20.w, right: 20.w),
              child: Styles.regular('topics_languages'.tr, fs: 20.sp, c: Theme.of(context).primaryColor),
            ),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/lighttheme_outline.svg',
                title: 'day_mode'.tr,
                yesno: themeMode == 1,
                onTap: () {
                  isDarkMode.value = false;
                  themeMode = 1;
                  StorageService.getBox.write('themeMode', 1);
                  themeModeNotifier.setThemeMode(ThemeMode.light);
                }),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/darktheme_outline.svg',
                title: 'night_mode'.tr,
                yesno: themeMode == 2,
                onTap: () {
                  isDarkMode.value = true;
                  themeMode = 2;
                  StorageService.getBox.write('themeMode', 2);
                  themeModeNotifier.setThemeMode(ThemeMode.dark);
                }),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/systemtheme_outline.svg',
                title: 'system_settings'.tr,
                yesno: themeMode == 0,
                onTap: () {
                  themeMode = 0;
                  StorageService.getBox.write('themeMode', 0);
                  themeModeNotifier.setThemeMode(ThemeMode.system);
                }),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/language_outline.svg',
                title: 'languages'.tr,
                isRightArrow: true,
                onTap: () {
                  Get.to(() => ChangeLanguageScreen());
                }),
            divider(),
            Padding(
              padding: EdgeInsets.only(top: 17.h, bottom: 9.h, left: 20.w, right: 20.w),
              child: Styles.regular('notifications_files'.tr, fs: 20.sp, c: Theme.of(context).primaryColor),
            ),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/notification_outline.svg',
                title: 'notifications'.tr,
                isRightArrow: true,
                onTap: () {
                  Get.to(() => const NotificationSettings());
                }),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/download_outline.svg',
                title: 'downloads'.tr,
                isRightArrow: true,
                onTap: () {
                  Get.to(() => const DownloadScreen());
                }),
            divider(),
            Padding(
              padding: EdgeInsets.only(top: 17.h, bottom: 9.h, left: 20.w, right: 20.w),
              child: Styles.regular('terms'.tr, fs: 20.sp, c: Theme.of(context).primaryColor),
            ),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/privacy_outline.svg',
                title: 'privacypolicy'.tr,
                isRightArrow: true,
                onTap: () {
                  Get.to(() => PrivacyPolicy());
                }),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/terms_outline.svg',
                title: 'terms'.tr,
                isRightArrow: true,
                onTap: () {
                  Get.to(() => TermsCondition());
                }),
            divider(),
            Padding(
              padding: EdgeInsets.only(top: 17.h, bottom: 9.h, left: 20.w, right: 20.w),
              child: Styles.regular('contactus'.tr, fs: 20.sp, c: Theme.of(context).primaryColor),
            ),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/whatsapp_outline.svg',
                title: 'WhatsApp'.tr,
                isRightArrow: true,
                onTap: () async {
                  final contact = _userController.contactNumber.value.removeAllWhitespace;
                  final url = Uri.parse(Platform.isIOS ? "https://wa.me/$contact" : "whatsapp://send?phone=$contact");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    gradientSnackBar(context,
                        title: 'WhatsApp ${'Is_not_installed_on_the_device'.tr}',
                        image: 'assets/Icons/whatsapp_outline.svg',
                        color1: ConstColors.darkRedColor,
                        color2: ConstColors.redColor);
                  }
                }),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/telegram_outline.svg',
                title: 'Telegram'.tr,
                isRightArrow: true,
                onTap: () async {
                  final url = Uri.parse('${'https://t.me/'}${_userController.telegramId.value.replaceAll('@', '').removeAllWhitespace}');
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/skype_outline.svg',
                title: 'Skype'.tr,
                isRightArrow: true,
                onTap: () async {
                  try {
                    final Uri url = Uri(
                        scheme: 'skype',
                        path: _userController.skypeId.value.removeAllWhitespace,
                        queryParameters: {'chat': 'true', 'text': 'hello_i_writing_eypop'.tr});
                    await launchUrl(url);
                  } catch (e) {
                    gradientSnackBar(
                      context,
                      title: 'Skype ${'Is_not_installed_on_the_device'.tr}',
                      image: 'assets/Icons/skype_outline.svg',
                      color1: ConstColors.darkRedColor,
                      color2: ConstColors.redColor,
                    );
                  }
                }),
            divider(),
            listTileWidget(
                svg: 'assets/Icons/email_outline.svg',
                title: 'E-mail'.tr,
                isRightArrow: true,
                onTap: () async {
                  final contact = _userController.email.value.removeAllWhitespace;
                  final androidUrl = "mailto:$contact";
                  await launchUrl(Uri.parse(androidUrl));
                }),
            divider(),
            Padding(
              padding: EdgeInsets.only(top: 17.h, bottom: 9.h, left: 20.w, right: 20.w),
              child: Styles.regular('account_and_app'.tr, fs: 20.sp, c: Theme.of(context).primaryColor),
            ),
            divider(),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      backgroundColor: ConstColors.white,
                      insetPadding: EdgeInsets.symmetric(horizontal: 70.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 18.h),
                              const SvgView('assets/Icons/eypoplogo.svg'),
                              SizedBox(height: 25.h),
                              Styles.regular('do_you_want_logout'.tr, c: ConstColors.black, ff: 'HB', fs: 16.sp),
                              SizedBox(height: 17.h),
                              GradientButton(
                                  title: 'logout'.tr,
                                  width: 220.w,
                                  onTap: () {
                                    _settingController.isLogout.value = true;
                                    _settingController.logout().whenComplete(() {
                                      _settingController.isLogout.value = false;
                                    });
                                  }),
                              SizedBox(height: 12.h),
                              Divider(height: 1.h, color: ConstColors.bottomBorder),
                              InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: Container(
                                    height: 53.h,
                                    alignment: Alignment.center,
                                    child: Styles.regular('Cancel'.tr.toUpperCase(), c: ConstColors.themeColor.withOpacity(0.8), fs: 16.sp)),
                              ),
                            ],
                          ),
                          Obx(() {
                            if (_settingController.isLogout.value) {
                              return Lottie.asset("assets/jsons/loading_circle.json", height: 82.w, width: 82.w);
                            }
                            return const SizedBox.shrink();
                          })
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 74.h,
                color: Theme.of(context).dialogBackgroundColor,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    SvgView('assets/Icons/logout_outline.svg', color: Theme.of(context).primaryColor),
                    SizedBox(width: 25.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Styles.regular('logout'.tr, c: Theme.of(context).primaryColor, fs: 18.sp),
                        SizedBox(height: 5.h),
                        Obx(() {
                          return Styles.regular(userEmail.value, c: Theme.of(context).primaryColor, fs: 14.sp);
                        }),
                      ],
                    ),
                    const Spacer(),
                    SvgView('assets/Icons/arrow_right.svg', color: Theme.of(context).primaryColor)
                  ],
                ),
              ),
            ),
            divider(),
            if (userLoginType.value == 'email')
              listTileWidget(
                  svg: 'assets/Icons/changepassword_outline.svg',
                  title: 'change_password'.tr,
                  isRightArrow: true,
                  onTap: () {
                    Get.to(() => ChangePasswordScreen());
                  }),
            divider(),
            Container(
              height: 74.h,
              color: Theme.of(context).dialogBackgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgView('assets/Icons/version_outline.svg', color: Theme.of(context).primaryColor),
                  SizedBox(width: 25.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Styles.regular('app_version'.tr, c: Theme.of(context).primaryColor, fs: 18.sp),
                      SizedBox(height: 5.h),
                      Styles.regular(_settingController.appVersion.value, c: ConstColors.lightGreenColor, ff: 'HB', fs: 14.sp),
                    ],
                  ),
                ],
              ),
            ),
            divider(),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context2) {
                    return Dialog(
                      backgroundColor: ConstColors.white,
                      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
                      child: Container(
                        padding: EdgeInsets.only(top: 24.h, bottom: 24.h, left: 20.w, right: 20.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SvgView('assets/Icons/eypoplogo.svg'),
                            SizedBox(height: 12.h),
                            Styles.regular('are_you_sure_delete'.tr, al: TextAlign.center, fs: 19.sp, c: ConstColors.black),
                            SizedBox(height: 11.h),
                            Styles.regular('this_action_can_not_undone'.tr, al: TextAlign.center, fs: 19.sp, ff: 'HB', c: ConstColors.redColor),
                            SizedBox(height: 20.h),
                            TextFieldModel(
                              contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                              controllers: textEditingController,
                              hint: 'write_the_reason'.tr,
                              hintTextColor: ConstColors.black.withOpacity(0.4),
                              color: ConstColors.black,
                              borderColor: ConstColors.black,
                              containerColor: Colors.transparent,
                              cursorColor: ConstColors.black,
                              textInputType: TextInputType.text,
                            ),
                            SizedBox(height: 22.h),
                            GradientButton(
                                width: 300.w,
                                enable: true,
                                title: 'Cancel'.tr,
                                onTap: () {
                                  Get.back();
                                }),
                            SizedBox(height: 19.h),
                            InkWell(
                                onTap: () async {
                                  if (textEditingController.text.isNotEmpty) {
                                    UserLogin userLogin = UserLogin();
                                    userLogin.objectId = StorageService.getBox.read('ObjectId');
                                    userLogin.isDeleted = true;
                                    userLogin['DeleteReason'] = textEditingController.text;
                                    userLogin.local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
                                    await UserLoginProviderApi().update(userLogin);

                                    ApiResponse? apiResponse =
                                        await UserProfileProviderApi().userProfileQuery(StorageService.getBox.read('ObjectId'));
                                    List<ProfilePage> profileData = [];
                                    for (var element in apiResponse!.results!) {
                                      ProfilePage userPro = ProfilePage();
                                      userPro.objectId = element['objectId'];
                                      userPro.isDeleted = true;
                                      profileData.add(userPro);
                                    }
                                    await UserProfileProviderApi().updateAll(profileData);
                                    _settingController.logout();
                                  }
                                },
                                child: Styles.regular('yes_delete_my_account'.tr,
                                    al: TextAlign.center, fs: 16.sp, c: ConstColors.themeColor.withOpacity(0.8))),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 58.h,
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgView('assets/Icons/close.svg', color: Theme.of(context).primaryColor, height: 20.w, width: 20.w),
                      SizedBox(width: 26.w),
                      Styles.regular('delete_account'.tr, c: Theme.of(context).primaryColor, fs: 18.sp),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h)
          ],
        ),
      ),
    );
  }

  final TextEditingController textEditingController = TextEditingController();

  Widget callsAndChat({required String title, required bool yesno, required String svg, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 58.h,
        color: Theme.of(Get.context!).dialogBackgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgView(svg, color: Theme.of(Get.context!).primaryColor),
              SizedBox(width: 26.w),
              Styles.regular(title, c: Theme.of(Get.context!).primaryColor, fs: 18.sp),
              const Spacer(),
              Styles.regular(yesno ? 'yes'.tr : 'NO'.tr, c: yesno ? ConstColors.lightGreenColor : ConstColors.redColor, fs: 18.sp, ff: 'HB'),
              SizedBox(width: 13.w),
              SvgView('assets/Icons/check.svg', color: yesno ? ConstColors.lightGreenColor : ConstColors.redColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget listTileWidget({required String title, bool isRightArrow = false, bool? yesno, required String svg, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 58.h,
        color: Theme.of(Get.context!).dialogBackgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgView(svg, color: Theme.of(Get.context!).primaryColor),
              SizedBox(width: 26.w),
              Styles.regular(title, c: Theme.of(Get.context!).primaryColor, fs: 18.sp),
              const Spacer(),
              isRightArrow == true
                  ? SvgView('assets/Icons/arrow_right.svg', color: Theme.of(Get.context!).primaryColor)
                  : yesno == true
                      ? SvgView('assets/Icons/check.svg', color: Theme.of(Get.context!).primaryColor)
                      : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
