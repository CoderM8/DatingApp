import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/ui/transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PriceInteractionGirls extends GetView {
   PriceInteractionGirls({Key? key}) : super(key: key);
  final PriceController _priceController = Get.find();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        leading: SvgView(
          "assets/Icons/close.svg",
          color: ConstColors.closeColor,
          height: 29.w,
          width: 29.w,
          padding: EdgeInsets.only(left: 20.w),
          fit: BoxFit.scaleDown,
          onTap: () {
            Get.back();
          },
        ),
        centerTitle: true,
        title: Styles.regular('Rewards'.tr, c: ConstColors.closeColor, fs: 31.sp),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Obx(() {
            _priceController.userTotalCoin.value;
            return Column(
              children: [
                itemTile(
                  context,
                  price: _priceController.chatMessagePrice.value,
                  svg: 'assets/Icons/chat_outline.svg',
                  title: 'Chat_Received'.tr,
                  total: _priceController.chatGirlMessageToken.value,
                ),
                itemTile(
                  context,
                  price: _priceController.heartMessagePrice.value,
                  svg: 'assets/Icons/email_outline.svg',
                  title: 'Message_Received'.tr,
                  total: _priceController.heartGirlMessageToken.value,
                ),
                itemTile(
                  context,
                  price: _priceController.callPrice.value,
                  svg: 'assets/Icons/call_outline.svg',
                  title: 'Audio_Call_Received'.tr,
                  total: _priceController.callGirlToken.value,
                ),
                itemTile(
                  context,
                  price: _priceController.videoCallPrice.value,
                  svg: 'assets/Icons/video_outline.svg',
                  title: 'Video_Call_Received'.tr,
                  total: _priceController.videoCalGirlToken.value,
                ),
                itemTile(
                  context,
                  price: _priceController.winkMessagePrice.value,
                  svg: 'assets/Icons/wink_outline.svg',
                  title: 'Wink_Received'.tr,
                  total: _priceController.winkGirlToken.value,
                ),
                itemTile(
                  context,
                  price: _priceController.lipLikePrice.value,
                  svg: 'assets/Icons/kiss_outline.svg',
                  title: 'LipLike_Received'.tr,
                  total: _priceController.lipLikeGirlToken.value,
                ),
                itemTile(
                  context,
                  price: '?',
                  svg: 'assets/Icons/gift_outline.svg',
                  title: 'Gift_Received'.tr,
                  total: _priceController.giftGirlToken.value,
                ),
                SizedBox(height: 15.h),
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: Text.rich(
                //     TextSpan(
                //       text: 'Last withdrawal on: '.tr,
                //       style: TextStyle(fontFamily: "HR", fontSize: 18.sp),
                //       children: [
                //         TextSpan(text: DateFormat('dd/MM/y').format(DateTime.now()), style: TextStyle(fontFamily: "HB", fontSize: 18.sp)),
                //       ],
                //     ),
                //     textScaler: const TextScaler.linear(1),
                //   ),
                // ),
                // SizedBox(height: 15.h),
                GradientButton(
                  title: 'Payment_history'.tr,
                  onTap: () {
                    Get.to(() => const TransactionView());
                  },
                ),
                SizedBox(height: 15.h),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget itemTile(context, {required String svg, required price, required int total, required String title}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.r),
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(width: 1.w, color: Theme.of(context).primaryColor.withOpacity(0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgView(svg, width: 29.w, fit: BoxFit.cover, color: Theme.of(context).primaryColor),
              SizedBox(height: 6.5.h),
              Styles.regular(price.toString(), fs: 22.sp, ff: "HB", fw: FontWeight.bold, c: Theme.of(context).primaryColor),
            ],
          ),
          SizedBox(width: 13.w),
          Expanded(child: Styles.regular(title, fs: 18.sp, lns: 3, c: Theme.of(context).primaryColor)),
          SizedBox(width: 20.w),
          Styles.regular(total.toString(), fs: 35.sp, ff: "HB", fw: FontWeight.bold, c: Theme.of(context).primaryColor),
        ],
      ),
    );
  }
}
