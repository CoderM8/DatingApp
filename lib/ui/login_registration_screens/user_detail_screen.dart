// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:eypop/back4appservice/user_provider/coins/provider_prices_api.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../Constant/Widgets/button.dart';
import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Controllers/authentication_controller.dart';
import '../../Controllers/user_controller.dart';
import '../../back4appservice/base/api_response.dart';
import '../../back4appservice/user_provider/users/provider_user_api.dart';
import '../../models/user_login/user_login.dart';
import '../User_profile/create_user_profile.dart';

class UserDetailScreen extends GetView {
  String appleEmail;
  String type;
  ParseUser? newParseUser;

  UserDetailScreen({Key? key, required this.appleEmail, required this.type, this.newParseUser}) : super(key: key);

  final UserController _userController = Get.put(UserController());
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientWidget(
        child: Padding(
          padding: EdgeInsets.only(top: 58.h, left: 20.w, right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80.h),
              Styles.regular('my_account'.tr, c: ConstColors.white, fs: 29.sp, ff: 'HB'),
              SizedBox(height: 12.h),
              Obx(() {
                return conButton(
                  context,
                  title: 'i_man_looking_woman'.tr,
                  color1: ConstColors.blueColor,
                  color2: ConstColors.purpleColor,
                  clicked: _userController.male.value,
                  ontap: () {
                    _userController.male.value = true;
                    _userController.female.value = false;
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
                  clicked: _userController.female.value,
                  ontap: () {
                    _userController.male.value = false;
                    _userController.female.value = true;
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
                        Obx(() => Styles.regular(_userController.finaldate.value, c: ConstColors.white, fs: 22.sp)),
                        SvgPicture.asset('assets/Icons/date.svg')
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 65.h),
              Obx(() {
                if (_userController.isProfile.value) {
                  return Center(
                    child: Lottie.asset('assets/jsons/loading_circle.json', height: 82.w, width: 82.w),
                  );
                }
                return GradientButton(
                  enable: ((_userController.male.value || _userController.female.value) && _userController.isDateSelect.value),
                  width: MediaQuery.sizeOf(context).width,
                  title: 'confirm'.tr,
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
                                        Styles.regular(_userController.male.value ? 'man'.tr : 'woman'.tr,
                                            c: ConstColors.orangeColor, fs: 18.sp, ff: 'HB'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Styles.regular("${'birthday'.tr} ", c: ConstColors.black, fs: 18.sp, ff: 'HB'),
                                        Styles.regular(_userController.finaldate.value, c: ConstColors.orangeColor, fs: 18.sp, ff: 'HB'),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 19.h),
                                GradientButton(
                                    width: MediaQuery.sizeOf(context).width,
                                    title: 'accept'.tr,
                                    onTap: () async {
                                      Get.back();
                                      {
                                        _userController.isProfile.value = true;
                                        ParseUser? parseUser = newParseUser;
                                        parseUser ??= await ParseUser.currentUser();

                                        if (parseUser != null) {
                                          /// CHECK USER EMAIL "User_login" CLASS
                                          await UserLoginProviderApi().getByIdPointer(parseUser).then((userExits) async {
                                            if (userExits != null) {
                                              /// USER ALREADY EXITS
                                              final UserLogin userLog = UserLogin();
                                              userLog.objectId = userExits.result['objectId'];
                                              userLog['NewUser'] = 1;
                                              await UserLoginProviderApi().update(userLog);
                                              StorageService.getBox.write('ObjectId', userExits.result['objectId']);
                                              StorageService.getBox.write('Gender', userExits.result['Gender']);
                                              StorageService.getBox.write('AccountType', userExits.result['AccountType']);
                                              StorageService.getBox.write('DefaultProfile', userExits.result['DefaultProfile'] ?? '');
                                              StorageService.getBox.write(
                                                  'DefaultImgObjectId',
                                                  userExits.result['DefaultProfile'] == null
                                                      ? ''
                                                      : userExits.result['DefaultProfile']['DefaultImg']?['objectId'] ?? '');
                                              StorageService.getBox.writeIfNull('index', 0);
                                              initInstallationParseToken();

                                              final ParseObject blockParse = ParseObject('BlockIpAddress');
                                              blockParse['User'] = UserLogin()..objectId = userExits.result['objectId'];
                                              blockParse['DeviceId'] = userExits.result['DeviceId'];
                                              blockParse['IpAddress'] = userExits.result['IpAddress'];
                                              blockParse.save();

                                              _userController.isProfile.value = false;
                                              Get.offAll(() => CreateUserProfileScreen(isNewUser: true));
                                            } else {
                                              /// NEW USER NEW ENTRY IN [User_login]

                                              final UserLogin userLog = UserLogin();
                                              userLog.gender = _userController.male.value ? 'male' : 'female';
                                              userLog['DefaultUser'] = ParseObject('_User')..objectId = parseUser!.objectId;
                                              userLog.email = appleEmail;

                                              if (_authController.sms.value.text.isNotEmpty) {
                                                userLog.number = int.parse(appleEmail);
                                              }

                                              final ApiResponse coins = await PricesProviderApi().getAll();
                                              userLog.dob = _userController.selectedDate;
                                              userLog.chatMessageCoin = 0;
                                              userLog.chatMessageToken = 0;
                                              userLog.heartLikeCoin = 0;
                                              userLog.heartLikeToken = 0;
                                              userLog.lipLikeCoin = 0;
                                              userLog.lipLikeToken = 0;
                                              userLog.winkMessageCoin = 0;
                                              userLog.winkMessageToken = 0;
                                              userLog.heartMessageCoin = 0;
                                              userLog.heartMessageToken = 0;
                                              userLog.callCoin = 0;
                                              userLog.callToken = 0;
                                              userLog.noCalls = false;
                                              userLog.noChats = false;
                                              userLog.noVideocalls = false;
                                              userLog.imageCoin = 0;
                                              userLog.imageToken = 0;
                                              userLog.totalCoin = _userController.male.value ? _userController.defaultGiftCoin.value : 0;
                                              userLog.totalToken = coins.results![0]['DefaultUserToken'];
                                              userLog.lipLike = true;
                                              userLog.heartLike = true;
                                              userLog.wish = true;
                                              userLog.local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
                                              userLog['Type'] = type;
                                              userLog['NewUser'] = 0;
                                              userLog['IsCallEnabled'] = true; // old user required Column
                                              userLog['IsChatEnabled'] = true; // old user required Column
                                              userLog['IsVideoCallEnabled'] = true; // old user required Column

                                              /// FIRST TIME ENTRY CREATE NEW
                                              userLog.nowDate = DateTime.now();
                                              final All all = await IP.all;
                                              if (all.ip != null) {
                                                userLog.ipAddress = [all.ip];
                                              }
                                              if (all.deviceId != null) {
                                                userLog.deviceId = [all.deviceId];
                                              }
                                              try {
                                                ApiResponse apiResponse = await UserLoginProviderApi().add(userLog);
                                                StorageService.getBox.write('ObjectId', apiResponse.result['objectId']);
                                                StorageService.getBox.write('Gender', apiResponse.result['Gender']);
                                                StorageService.getBox.write('AccountType', apiResponse.result['AccountType']);
                                                StorageService.getBox.write('DefaultProfile', apiResponse.result['DefaultProfile'] ?? '');
                                                StorageService.getBox.write(
                                                    'DefaultImgObjectId',
                                                    apiResponse.result['DefaultProfile'] == null
                                                        ? ''
                                                        : apiResponse.result['DefaultProfile']['DefaultImg']?['objectId'] ?? '');
                                                StorageService.getBox.writeIfNull('index', 0);
                                                initInstallationParseToken();
                                                final ParseObject blockParse = ParseObject('BlockIpAddress');
                                                blockParse['User'] = UserLogin()..objectId = apiResponse.result['objectId'];
                                                blockParse['DeviceId'] = apiResponse.result['DeviceId'];
                                                blockParse['IpAddress'] = apiResponse.result['IpAddress'];
                                                blockParse.save();
                                                _userController.isProfile.value = false;
                                                Get.offAll(() => CreateUserProfileScreen(isNewUser: true));
                                              } catch (e,t) {
                                                _userController.isProfile.value = false;
                                                showSnackBar(Get.context, content: t.toString());
                                              }
                                            }
                                          });
                                        } else {
                                          _userController.isProfile.value = false;
                                          if (context.mounted) {
                                            showSnackBar(context, content: 'errorMessage'.tr);
                                          }
                                        }
                                      }
                                    }),
                                SizedBox(height: 22.h),
                                InkWell(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Styles.regular('Cancel'.tr, c: ConstColors.redColor, fs: 18.sp, ff: 'HB')),
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
                    initialDate: _userController.selectedDate,

                    /// Localization in date picker
                    // locale: DateTimePickerLocale.es,
                    dateFormat: "dd-MMM-yyyy",
                    onChange: (DateTime newDate, _) {
                      _userController.selectedDate = newDate;
                      _userController.finaldate.value = DateFormat('dd/MM/yyyy').format(_userController.selectedDate!).toString();
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
                      if (_userController.selectedDate == null) {
                        _userController.selectedDate ??= DateTime.now().subtract(const Duration(days: 6570));
                        _userController.finaldate.value = DateFormat('dd/MM/yyyy').format(_userController.selectedDate!).toString();
                      }
                      _userController.isDateSelect.value = true;
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

Widget conButton(context, {clicked, ontap, title, color1, color2}) {
  return GestureDetector(
    onTap: ontap,
    child: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60.r),
              gradient: LinearGradient(colors: [color1, color2], begin: Alignment.centerLeft, end: Alignment.centerRight, stops: const [0.0, 1.0])),
          height: 50.h,
          margin: EdgeInsets.only(top: 15.h),
          padding: EdgeInsets.only(left: 29.w),
          width: MediaQuery.sizeOf(context).width,
          child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(width: 290.w, child: Styles.regular(title, c: ConstColors.white, ff: 'HB', fs: 18.sp))),
        ),
        Positioned(
          right: 0,
          bottom: 10,
          child: SvgView(
            "assets/Icons/greencheck.svg",
            color: clicked ? ConstColors.lightGreenColor : ConstColors.border,
            height: 50.h,
            width: 64.w,
          ),
        ),
      ],
    ),
  );
}
