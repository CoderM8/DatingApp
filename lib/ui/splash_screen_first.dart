// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/PairNotificationController/pair_notification_controller.dart';
import 'package:eypop/service/calling.dart';
import 'package:eypop/service/local_notification_services.dart';
import 'package:eypop/ui/login_registration_screens/deleted_screen.dart';
import 'package:eypop/ui/start_page.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../Controllers/notification_controller.dart';
import '../Controllers/user_controller.dart';
import '../Controllers/wish_controllers/wish_swiper_controller.dart';
import '../back4appservice/base/api_response.dart';
import '../back4appservice/user_provider/users/provider_user_api.dart';
import '../back4appservice/user_provider/wishes/wish_provider_api.dart';
import '../service/local_storage.dart';
import 'User_profile/create_user_profile.dart';
import 'User_profile/user_fullprofile_screen.dart';
import 'bottom_screen.dart';

final RxBool isDarkMode = false.obs;
int themeMode = 0;
// Mobile login enable-disable
final RxBool isShowSms = false.obs;
// Mobile number enable when my country match in database
void getCountryIdFromLocal() async {
  final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Country'))..whereEqualTo('Status', true);
  final ParseResponse apiResponse = await query.query();
  final String countryCode = PaintingBinding.instance.platformDispatcher.locale.countryCode ?? 'ES';
  for (var element in apiResponse.results ?? []) {
    if (countryCode.contains(element['CountryCode'])) {
      isShowSms.value = true;
    } else {
      if (countryCode.contains('GB')) {
        isShowSms.value = true;
      }
    }
  }
  debugPrint('HELLO COUNTRY-CODE $countryCode');
}

class SplashScreenFirst extends GetView {
  SplashScreenFirst({Key? key}) : super(key: key);

  final UserController _userController = Get.put(UserController());
  final NotificationController _notificationController = Get.put(NotificationController());
  final PairNotificationController _pairNotificationController = Get.put(PairNotificationController());

  @override
  Widget build(BuildContext context) {
    getCountryIdFromLocal();
    _pairNotificationController;

    /// when app in background and come from dynamic link
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      _userController.initialLink = dynamicLinkData;
      if ((StorageService.getBox.read('isDeleted') ?? false) == true) {
        // check current user is delete by admin
        Get.offAll(() => DeletedAccountScreen());
      } else {
        if (StorageService.getBox.read('ObjectId') == null) {
          // null if user new
          Get.offAll(() => StartScreen());
        } else {
          // null if user not create profile first time
          if (StorageService.getBox.read('DefaultProfile') == null) {
            Get.offAll(() => CreateUserProfileScreen());
          } else {
            switch (dynamicLinkData.link.path) {
              case "/Profile":
                {
                  final ApiResponse fullUser = await UserLoginProviderApi().getById(dynamicLinkData.link.queryParameters["senderid"]!);
                  Get.offAll(() => UserFullProfileScreen(
                      toUserId: fullUser.result,
                      toProfileId: dynamicLinkData.link.queryParameters["profileid"]!,
                      visitType: true,
                      fromProfileId: StorageService.getBox.read('DefaultProfile')));
                }
                break;
              case "/Wish":
                {
                  Get.offAll(() => BottomScreen(index: 1.obs));
                  final ApiResponse? wish = await WishesApi().getByProfileId(dynamicLinkData.link.queryParameters["profileid"]!);
                  final WishSwiperController swiperController = Get.put(WishSwiperController());

                  for (ParseObject wishModel in wish!.results ?? []) {
                    if (!swiperController.wishSwiperList.toString().contains(wishModel['objectId'])) {
                      swiperController.wishSwiperList.insert(0, wishModel);
                    }
                  }
                }
                break;
              default:
                {
                  Get.offAll(() => BottomScreen(), duration: const Duration(seconds: 0));
                }
            }
          }
        }
      }
    });

    Future.delayed(const Duration(seconds: 2), () async {
      Map str = {};
      if (Platform.isAndroid) {
        LocalNotificationService lS = LocalNotificationService();
        if (lS.notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
          lS.selectedNotificationPayload = lS.notificationAppLaunchDetails!.notificationResponse?.payload;
          if (lS.selectedNotificationPayload!.isNotEmpty) {
           print('json data ---- ${lS.selectedNotificationPayload!}');
            str = jsonDecode(lS.selectedNotificationPayload!);

          }
        }
      } else {
        if (receiveNotification.isNotEmpty) {
          str = receiveNotification;
        }
      }

      /// when app kill and user come from notification
      if (str.isNotEmpty) {
        _notificationController.notificationNavSwitch(
          str['translatedAlert'],
          Platform.isIOS ? str['aps']['alert']['body'] : str['alert'],
          str['senderId'],
          str['FromProfileId'],
          str['ToProfileId'],
          str['senderName'],
          str['avatar'],
          str['url'] ??'',
        );
      } else {
        /// first time user come in app
        if (_userController.initialLink == null) {
          // when app kill and user accept call check
          await CallService.checkAndNavigationCallingPage(true, 'Splash build');
          if ((StorageService.getBox.read('isDeleted') ?? false) == true) {
            // check current user is delete by admin
            Get.offAll(() => DeletedAccountScreen(), duration: const Duration(seconds: 0));
          } else {
            if (StorageService.getBox.read('ObjectId') == null) {
              // null if user new
              Get.offAll(() => StartScreen(), duration: const Duration(seconds: 0));
            } else {
              // null if user not create profile first time
              if (StorageService.getBox.read('DefaultProfile') == null) {
                Get.offAll(() => CreateUserProfileScreen(), duration: const Duration(seconds: 0));
              } else {
                Get.offAll(() => BottomScreen(), duration: const Duration(seconds: 0));
              }
            }
          }
        } else {
          /// when app kill and user come from dynamic link
          if ((StorageService.getBox.read('isDeleted') ?? false) == true) {
            // check current user is delete by admin
            Get.offAll(() => DeletedAccountScreen());
          } else {
            if (StorageService.getBox.read('ObjectId') == null) {
              // null if user new
              Get.offAll(() => StartScreen());
            } else {
              if (StorageService.getBox.read('DefaultProfile') == null) {
                // null if user not create profile first time
                Get.offAll(() => CreateUserProfileScreen());
              } else {
                final deepLink = _userController.initialLink!.link;
                switch (deepLink.path) {
                  case "/Profile":
                    {
                      final ApiResponse fullUser = await UserLoginProviderApi().getById(deepLink.queryParameters["senderid"]!);
                      Get.offAll(() => UserFullProfileScreen(
                          toUserId: fullUser.result,
                          toProfileId: deepLink.queryParameters["profileid"]!,
                          visitType: true,
                          fromProfileId: StorageService.getBox.read('DefaultProfile')));
                    }
                    break;
                  case "/Wish":
                    {
                      final ApiResponse? wish = await WishesApi().getByProfileId(deepLink.queryParameters["profileid"]!);
                      final WishSwiperController swiperController = Get.put(WishSwiperController());
                      for (ParseObject wishModel in wish!.results ?? []) {
                        if (!swiperController.wishSwiperObjectIdList.toString().contains(wishModel.objectId!)) {
                          swiperController.wishSwiperList.add(wishModel);
                          swiperController.wishSwiperObjectIdList.add(wishModel.objectId!);
                        }
                      }
                      Get.offAll(() => BottomScreen(index: 1.obs));
                    }
                    break;
                  default:
                    {
                      Get.offAll(() => BottomScreen(), duration: const Duration(seconds: 0));
                    }
                }
              }
            }
          }
        }
      }
    });
    CallService.listenerEvent();
    return Scaffold(
      body: GradientWidget(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Styles.regular('eypop', fs: 78.sp, ff: 'HL', c: ConstColors.white),
            const Spacer(),
            Lottie.asset("assets/jsons/fire.json", height: 214.w, width: 214.w, fit: BoxFit.cover),
            const Spacer(flex: 5),
          ],
        ),
      ),
    );
  }
}
