// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Constant/theme/theme.dart';
import 'package:eypop/Controllers/SpecialOfferController.dart';
import 'package:eypop/Controllers/call_controller/call_controller.dart';
import 'package:eypop/Controllers/payment_controller.dart';
import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/Controllers/tabbar_controller.dart';
import 'package:eypop/Controllers/toktok_contoller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/Controllers/videocontroller.dart';
import 'package:eypop/back4appservice/user_provider/coins/provider_coinprices_api.dart';
import 'package:eypop/service/calling.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/User_profile/my_user_fullprofile_screen.dart';
import 'package:eypop/ui/User_profile/picture_screen.dart';
import 'package:eypop/ui/notification_pages/notification_screen.dart';
import 'package:eypop/ui/splash_screen_first.dart';
import 'package:eypop/ui/wishes_pages/create_wish_screen.dart';
import 'package:eypop/ui/wishes_pages/wish_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BottomControllers extends FullLifeCycleController with FullLifeCycleMixin, GetSingleTickerProviderStateMixin {
  final AppSearchController _searchController = Get.put(AppSearchController());
  final PaymentController paymentController = Get.put(PaymentController());

  static TokTokController get tokTokController => Get.find<TokTokController>();
  final RxInt currentIndex = 0.obs;
  final RxInt bottomIndex = 0.obs;
  final RxBool isNudePost = false.obs;
  final RxBool isNudeVideo = false.obs;
  final RxBool isWishPost = false.obs;
  final RxBool isWishVideo = false.obs;
  List<Widget> tabPages = [UserPictureScreen(), const WishSwiper(), const NotificationScreen(), MyUserFullProfileScreen()];

  @override
  Future<void> onInit() async {
    WidgetsBinding.instance.addObserver(this);
    await paymentController.getAllPrices().whenComplete(() {
      for (var element in paymentController.priceList) {
        paymentController.getUserProducts(element);
      }
    });

    await CoinPricesProviderApi().getFlashSale().then((value) {
      paymentController.productsOffer.clear();
      priceFlashSale.clear();
      if (value != null) {
        priceFlashSale.addAll(value.results ?? []);
        if (priceFlashSale.isNotEmpty) {
          startTime.value = priceFlashSale[0]['StartDate'].toLocal();
          endTime.value = priceFlashSale[0]['EndDate'].toLocal();
          paymentController.getUserProductsOffer(Platform.isIOS ? priceFlashSale[0]['AppleId'] : priceFlashSale[0]['GoogleId']);
          Get.put(SpecialOfferController());
        }
      }
    });

    await CallService.checkAndNavigationCallingPage(false, 'Bottom Init');
    _searchController.getProfileData();
    super.onInit();
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future uploadPost(context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(40.r), topLeft: Radius.circular(40.r)),
      ),
      builder: (BuildContext c) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          expand: false,
          maxChildSize: 0.7,
          minChildSize: 0.2,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Obx(() {
                return Padding(
                  padding: EdgeInsets.only(top: 14.5.h, left: 22.w, right: 22.w, bottom: 31.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(height: 2.h, width: 58.w, color: ConstColors.closeColor),
                      SizedBox(height: 10.h),
                      Styles.regular('add_content'.tr, fs: 16.sp, c: Theme.of(context).primaryColor, ff: 'HB'),
                      SizedBox(height: 22.h),
                      uploadPhoto(context),
                      SizedBox(height: 18.h),
                      uploadVideo(context),
                    ],
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }

  Widget uploadPhoto(context, {bool isBack = true}) {
    final ControllerX controllerX = Get.put(ControllerX());
    final bool addTokTok = tokTokController.tokTokTotalImage.length < tokTokImageLimit;
    bool active = true;

    // when accountType real [active]
    if (StorageService.getBox.read('AccountType').toString().contains("REAL")) {
      active = true;
    } else {
      // enable option from admin panel
      active = uploadVideoInf.value;
    }
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: EdgeInsets.only(left: 16.w, top: 19.h, right: 24.w, bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFA39F33), width: 2.w),
        gradient: LinearGradient(
          colors: [const Color(0xFFE5D594), const Color(0xFFE5D594).withOpacity(0.5), Theme.of(context).scaffoldBackgroundColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.6, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgView('assets/Icons/imagePost.svg', height: 38.h, width: 46.w, color: Theme.of(context).primaryColor),
              SizedBox(width: 12.w),
              Styles.regular('new_photo'.tr, ff: 'HL', fs: 22.sp, c: Theme.of(context).primaryColor),
              const Spacer(),
              GradientButton(
                title: 'add'.tr,
                textColor: Theme.of(context).primaryColor,
                height: 38.h,
                width: 140.w,
                color1: const Color(0xFFA39F33),
                color2: ConstColors.white,
                enable: active,
                onTap: () {
                  if (isBack) {
                    Get.back();
                  }
                  controllerX.fromGallery(context);
                },
              ),
            ],
          ),
          SizedBox(height: 19.h),
          InkWell(
            onTap: addTokTok && active
                ? () {
                    if (tokTokController.tokTokObjectId.isNotEmpty) {
                      isWishPost.value = !isWishPost.value;
                    } else {
                      if (isBack) {
                        Get.back();
                      }
                      Get.to(() => const CreateWishScreen());
                    }
                  }
                : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Styles.regular('show_this_photo_tiktok'.tr, fs: 16.sp, c: Theme.of(context).primaryColor)),
                SizedBox(width: 30.w),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 30.w,
                      width: 30.w,
                      margin: EdgeInsets.only(top: 4.h),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: addTokTok ? ConstColors.white : ConstColors.offlineColor,
                          border: Border.all(width: 1.w, color: const Color(0xFFA39F33))),
                    ),
                    if (isWishPost.value)
                      Positioned(child: SvgView('assets/Icons/check.svg', height: 23.w, width: 23.w, color: const Color(0xFFA39F33))),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          if (!addTokTok)
            Styles.regular('you_will_only_able_3_photos'.tr.replaceAll('xxx', tokTokImageLimit.toString()),
                al: TextAlign.start, fs: 15.sp, c: ConstColors.darkRedColor, lns: 2),
          SizedBox(height: 10.h),
          InkWell(
            onTap: active
                ? () {
                    isNudePost.value = !isNudePost.value;
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Styles.regular('i_inform_upload_content_sensitive'.tr,
                        lns: 2, al: TextAlign.start, fs: 16.sp, c: Theme.of(context).primaryColor)),
                SizedBox(width: 30.w),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 30.w,
                      width: 30.w,
                      margin: EdgeInsets.only(top: 4.h),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: ConstColors.white, border: Border.all(width: 1.w, color: const Color(0xFFA39F33))),
                    ),
                    if (isNudePost.value)
                      Positioned(child: SvgView('assets/Icons/check.svg', height: 23.w, width: 23.w, color: const Color(0xFFA39F33))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget uploadVideo(context, {bool isBack = true}) {
    final VideoController videoController = Get.put(VideoController());
    final bool addTokTok = tokTokController.tokTokTotalVideo.length < tokTokVideoLimit;
    bool active = true;

    // when accountType real [active]
    if (StorageService.getBox.read('AccountType').toString().contains("REAL")) {
      active = true;
    } else {
      // enable option from admin panel
      active = uploadVideoInf.value;
    }
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: EdgeInsets.only(left: 16.w, top: 19.h, right: 24.w, bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFFAB26A), width: 2.w),
        gradient: LinearGradient(
          colors: [const Color(0xFFE5BD94), const Color(0xFFE5BD94).withOpacity(0.5), Theme.of(context).scaffoldBackgroundColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.6, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgView('assets/Icons/video.svg', height: 40.h, width: 46.w, color: Theme.of(context).primaryColor),
              SizedBox(width: 12.w),
              Styles.regular('new_video'.tr, ff: 'HL', fs: 22.sp, c: Theme.of(context).primaryColor),
              const Spacer(),
              GradientButton(
                title: 'add'.tr,
                textColor: Theme.of(context).primaryColor,
                height: 38.h,
                width: 140.w,
                color1: const Color(0xFFFAB26A),
                color2: ConstColors.white,
                enable: active,
                onTap: () {
                  if (isBack) {
                    Get.back();
                  }
                  videoController.videoPicker(context);
                },
              ),
            ],
          ),
          SizedBox(height: 19.h),
          InkWell(
            onTap: addTokTok && active
                ? () {
                    if (tokTokController.tokTokObjectId.isNotEmpty) {
                      isWishVideo.value = !isWishVideo.value;
                    } else {
                      if (isBack) {
                        Get.back();
                      }
                      Get.to(() => const CreateWishScreen());
                    }
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Styles.regular('show_this_video_tiktok'.tr, fs: 16.sp, c: Theme.of(context).primaryColor)),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 30.w,
                      width: 30.w,
                      margin: EdgeInsets.only(top: 4.h),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: addTokTok ? ConstColors.white : ConstColors.offlineColor,
                          border: Border.all(width: 1.w, color: const Color(0xFFFAB26A))),
                    ),
                    if (isWishVideo.value)
                      Positioned(child: SvgView('assets/Icons/check.svg', height: 23.w, width: 23.w, color: const Color(0xFFFAB26A))),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          if (!addTokTok)
            Styles.regular('you_will_only_able_5_videos'.tr.replaceAll('xxx', tokTokVideoLimit.toString()),
                al: TextAlign.start, fs: 15.sp, c: ConstColors.darkRedColor, lns: 2),
          SizedBox(height: 10.h),
          InkWell(
            onTap: active
                ? () {
                    isNudeVideo.value = !isNudeVideo.value;
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Styles.regular('i_inform_upload_content_sensitive'.tr,
                        lns: 2, al: TextAlign.start, fs: 16.sp, c: Theme.of(context).primaryColor)),
                SizedBox(width: 30.w),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 30.w,
                      width: 30.w,
                      margin: EdgeInsets.only(top: 4.h),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: ConstColors.white, border: Border.all(width: 1.w, color: const Color(0xFFFAB26A))),
                    ),
                    if (isNudeVideo.value)
                      Positioned(child: SvgView('assets/Icons/check.svg', height: 23.w, width: 23.w, color: const Color(0xFFFAB26A))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onResumed() async {
    // WHEN TWO USER JOIN IN CHANNEL AND CALL IS NOT ACCEPTED
    if (parseCall.value['objectId'] != null && parseCall.value['Accepted'] == false) {
      if (kDebugMode) {
        print('HELLO BOTTOM onResumed check call Accepted ${parseCall.value['objectId']}');
      }
      await CallService.checkAndNavigationCallingPage(false, "Bottom onResumed");
    }
    AppTheme.setSystemOverlay(ThemeMode.values[themeMode]);
  }

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}
}
