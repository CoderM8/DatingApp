// ignore_for_file: must_be_immutable, invalid_use_of_protected_member

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/call_controller/call_controller.dart';
import 'package:eypop/Controllers/notification_controller.dart';
import 'package:eypop/Controllers/status_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/service/calling.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/wishes_pages/wish_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:lottie/lottie.dart';

import '../Constant/constant.dart';
import '../Controllers/all_notification_controller/all_notification_controller.dart';
import '../Controllers/bottom_controller.dart';
import '../Controllers/search_controller.dart';
import 'User_profile/my_user_fullprofile_screen.dart';
import 'User_profile/picture_screen.dart';
import 'notification_pages/notification_screen.dart';

class BottomScreen extends GetView {
  BottomScreen({Key? key, this.index}) : super(key: key);
  final RxInt? index;

  final UserController userController = Get.put(UserController());

  final CallController callController = Get.put(CallController());
  final AllNotificationController _allNotificationController = Get.put(AllNotificationController());
  final AppSearchController _searchController = Get.put(AppSearchController());
  final BottomControllers _bottomController = Get.put(BottomControllers());
  final StatusController statusController = Get.put(StatusController());

  /// InApp Notification Show
  inAppNotification(Map onTapMap) async {
    InAppNotification.show(
      context: Get.context!,
      child: NotificationBody(
          notificationAlert: con['alert'], alert: notificationText(con['alert'], Get.context!), name: con['senderName'], image: con['avatar']),
      onTap: () {
        NotificationController().navigationSwitch(onTapMap['alert'], onTapMap['senderId'], onTapMap['FromProfileId'], onTapMap['ToProfileId'],
            onTapMap['senderName'], onTapMap['avatar'], Get.context!);
        InAppNotification.dismiss(context: Get.context!);
      },
    );
    con.value = {}.obs;
    con.clear();
  }

  @override
  Widget build(BuildContext context) {
    CallService.initialNotification();
    _searchController;
    if (index != null) {
      _bottomController.currentIndex.value = index!.value;
      _bottomController.bottomIndex.value = index!.value;
    }
    initInstallationParseToken();
    _bottomController.tabPages = [
      UserPictureScreen(),
      const WishSwiper(),
      const NotificationScreen(),
      MyUserFullProfileScreen(),
    ];

    return Obx(() {
      if (con.isNotEmpty) {
        Map onTapMap = con.value;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (con['alert'] == 'send you Chat Message' || con['alert'] == 'send you Heart Message') {
            if (con['alert'] == 'send you Chat Message' && toChatUser.value != con['senderId']) {
              inAppNotification(onTapMap);
            } else if (con['alert'] == 'send you Heart Message' && toMessageUser.value != con['senderId']) {
              inAppNotification(onTapMap);
            }
          } else {
            inAppNotification(onTapMap);
          }
        });
      }
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (!didPop) {
            await offlineUser();
          }
        },
        child: Scaffold(
          body: Obx(() {
            return IndexedStack(index: _bottomController.currentIndex.value, children: _bottomController.tabPages);
          }),
          bottomNavigationBar: Obx(() {
            return SizedBox(
              height: MediaQuery.of(context).padding.bottom + 57.5.h,
              child: Theme(
                data: Theme.of(context),
                child: BottomNavigationBar(
                  elevation: 0.0,
                  type: BottomNavigationBarType.fixed,
                  onTap: (val) async {
                    if (val == 2) {
                      _bottomController.isNudePost.value = false;
                      _bottomController.isNudeVideo.value = false;
                      _bottomController.isWishPost.value = false;
                      _bottomController.isWishVideo.value = false;
                      _bottomController.uploadPost(context);
                      await HapticFeedback.vibrate();
                    } else {
                      _bottomController.currentIndex.value = val;
                      if (val > 2) {
                        _bottomController.currentIndex.value--;
                      }
                      _bottomController.bottomIndex.value = val;
                    }
                  },
                  currentIndex: _bottomController.bottomIndex.value,
                  items: [
                    BottomNavigationBarItem(
                        label: 'eypop',
                        activeIcon: SvgView("assets/Icons/bottomWall.svg", color: ConstColors.themeColor, height: 25.w, width: 25.w),
                        icon: SvgView("assets/Icons/bottomWall.svg", height: 25.w, width: 25.w)),
                    BottomNavigationBarItem(
                        label: 'TokTok',
                        activeIcon: SvgView("assets/Icons/bottomWish.svg", color: ConstColors.themeColor, height: 25.w, width: 25.w),
                        icon: SvgView("assets/Icons/bottomWish.svg", height: 25.w, width: 25.w)),
                    BottomNavigationBarItem(
                      label: 'content'.tr,
                      icon: SvgView("assets/Icons/bottomAdd.svg", height: 25.w, width: 25.w),
                    ),
                    BottomNavigationBarItem(
                        label: 'DinDon',
                        activeIcon: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            SvgView("assets/Icons/bottomNotification.svg", color: ConstColors.themeColor, height: 25.w, width: 25.w),
                            Obx(() {
                              if (_allNotificationController.userTotalNotification.value != 0) {
                                return Positioned(
                                    top: 0.0,
                                    right: 0.0,
                                    key: const ValueKey(0),
                                    child: Lottie.asset("assets/jsons/notifications.json", height: 12.w, width: 12.w));
                              } else {
                                return const SizedBox.shrink(key: ValueKey(1));
                              }
                            }),
                          ],
                        ),
                        icon: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            SvgView("assets/Icons/bottomNotification.svg", height: 25.w, width: 25.w),
                            Obx(() {
                              if (_allNotificationController.userTotalNotification.value != 0) {
                                return Positioned(
                                    top: 0.0,
                                    right: 0.0,
                                    key: const ValueKey(0),
                                    child: Lottie.asset("assets/jsons/notifications.json", height: 12.w, width: 12.w));
                              } else {
                                return const SizedBox.shrink(key: ValueKey(1));
                              }
                            }),
                          ],
                        )),
                    BottomNavigationBarItem(
                      label: 'profile'.tr,
                      // activeIcon: SvgView("assets/Icons/bottomProfile.svg", height: 25.w, width: 25.w, color: ConstColors.themeColor),
                      activeIcon: Obx(() {
                        bottomRefresh.value;
                        return Container(
                          decoration: BoxDecoration(border: Border.all(color: ConstColors.themeColor, width: 1.w), shape: BoxShape.circle),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.r),
                            child:
                            CachedNetworkImage(
                              alignment: Alignment.topCenter,
                              imageUrl: StorageService.getBox.read('DefaultProfileImg') ?? '',
                              memCacheHeight: 150,
                              height: 25.w,
                              width: 25.w,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(seconds: 1),
                              placeholderFadeInDuration: const Duration(seconds: 1),
                              placeholder: (context, url) => preCachedSquare(),
                              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                            ),
                          ),
                        );
                      }),
                      icon: Obx(() {
                        bottomRefresh.value;
                        return Container(
                          decoration: BoxDecoration(border: Border.all(color: ConstColors.bottomBorder, width: 1.w), shape: BoxShape.circle),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.r),
                            child:
                            CachedNetworkImage(
                                    alignment: Alignment.topCenter,
                                    imageUrl: StorageService.getBox.read('DefaultProfileImg'),
                                    memCacheHeight: 150,
                                    height: 25.w,
                                    width: 25.w,
                                    fit: BoxFit.cover,
                                    fadeInDuration: const Duration(seconds: 1),
                                    placeholderFadeInDuration: const Duration(seconds: 1),
                                    placeholder: (context, url) => preCachedSquare(),
                                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                  ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}
