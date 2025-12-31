import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TotalTokenGirls extends GetView {
  const TotalTokenGirls({Key? key}) : super(key: key);
  static PriceController get _priceController => Get.find<PriceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 28.w, width: 28.w),
        centerTitle: true,
        title: Styles.regular('Receive'.tr, c: ConstColors.closeColor, fs: 31.sp),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Obx(() {
            _priceController.chatMessagePrice.value;
            return Column(
              children: [
                Styles.regular('You_receive_stars_for_interacting'.tr, c: Theme.of(context).primaryColor, ff: "HM"),
                SizedBox(height: 15.h),
                tile('assets/Icons/chat.svg', 'Chat_Received'.tr, _priceController.chatMessagePrice.value.toString()),
                tile('assets/Icons/heartMessage.svg', 'Message_Received'.tr, _priceController.heartMessagePrice.value.toString()),
                tile('assets/Icons/call.svg', 'Audio_Call_Received'.tr, _priceController.callPrice.value.toString()),
                tile('assets/Icons/video_camera.svg', "Video_Call_Received".tr, _priceController.videoCallPrice.value.toString()),
                tile('assets/Icons/wink.svg', 'Wink_Received'.tr, _priceController.winkMessagePrice.value.toString()),
                tile('assets/Icons/lipLike.svg', 'LipLike_Received'.tr, _priceController.lipLikePrice.value.toString()),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget tile(String svg, String title, String count) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgView(svg, fit: BoxFit.scaleDown, width: 22.h),
          SizedBox(width: 10.w),
          Expanded(child: Styles.regular(title, fs: 16.sp)),
          SizedBox(width: 20.w),
          Styles.regular(count, fs: 20.sp, ff: 'HB'),
        ],
      ),
    );
  }
}
