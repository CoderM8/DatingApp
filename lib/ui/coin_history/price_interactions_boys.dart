import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PriceInteractionBoys extends GetView {
  const PriceInteractionBoys({Key? key}) : super(key: key);
  static PriceController get _priceController => Get.put(PriceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 28.w, width: 28.w),
        centerTitle: true,
        title: Styles.regular('interactions'.tr, c: ConstColors.closeColor, fs: 31.sp, ff: 'HM'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              pricesTile(
                  title: '${_priceController.chatMessagePrice.value.toString()} ${"Stars".tr}' , svg: 'assets/Icons/chat_outline.svg', subTitle: 'send_message_photo_video_chats'.tr),
              SizedBox(height: 20.h),
              pricesTile(title: '${_priceController.heartMessagePrice.value.toString()} ${"Stars".tr}', svg: 'assets/Icons/email_outline.svg', subTitle: 'view_received_message'.tr),
              SizedBox(height: 20.h),
              pricesTile(title: '${_priceController.callPrice.value.toString()} ${"Stars".tr}', svg: 'assets/Icons/call_outline.svg', subTitle: 'voice_call_per_minute'.tr),
              SizedBox(height: 20.h),
              pricesTile(title: '${_priceController.videoCallPrice.value.toString()} ${'Stars'.tr}', svg: 'assets/Icons/video_outline.svg', subTitle: 'video_call_per_minute'.tr),
              SizedBox(height: 20.h),
              pricesTile(title: '${_priceController.winkMessagePrice.value.toString()} ${"Stars".tr}', svg: 'assets/Icons/wink_outline.svg', subTitle: 'see_wink_received'.tr),
              SizedBox(height: 20.h),
              pricesTile(title: '${_priceController.lipLikePrice.value.toString()} ${"Stars".tr}', svg: 'assets/Icons/kiss_outline.svg', subTitle: 'send_a_kiss'.tr),
              SizedBox(height: 20.h),
              pricesTile(title: '${_priceController.createProfile.value.toString()} ${"Stars".tr}', svg: 'assets/Icons/addprofile.svg', subTitle: 'create_new_traveler_profile'.tr),
              SizedBox(height: 20.h),
              pricesTile(title: 'view_before_sending'.tr, svg: 'assets/Icons/gift_outline.svg', subTitle: 'send_gift'.tr),
              SizedBox(height: 20.h),
              pricesTile(title: 'free'.tr, svg: 'assets/Icons/bullseye_outline.svg', subTitle: 'complete_tiktok'.tr),
              SizedBox(height: 20.h),
              pricesTile(title: 'free'.tr, svg: 'assets/Icons/heart_outline.svg', subTitle: 'send_like'.tr),
              SizedBox(height: 20.h),
              pricesTile(title: 'free'.tr, svg: 'assets/Icons/eye_outline.svg', subTitle: 'visit_unlimited_profiles'.tr),
              SizedBox(height: 50.h),
            ],
          ),
        ),

        /// stars
      ),
    );
  }
}
