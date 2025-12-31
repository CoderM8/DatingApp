// ignore_for_file: must_be_immutable, implementation_imports, invalid_use_of_protected_member

import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/ui/bottom_screen.dart';
import 'package:eypop/ui/web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../Constant/Widgets/textwidget.dart';
import '../Constant/constant.dart';
import '../Controllers/payment_controller.dart';
import '../Controllers/price_controller.dart';
import '../service/local_storage.dart';
import 'coin_history/price_interactions_boys.dart';

class StoreScreen extends GetView {
  final bool isFromNotification;
  final int? selectPaymentIndex;
  StoreScreen({Key? key, this.isFromNotification = false, this.selectPaymentIndex = 2}) : super(key: key);
  final PriceController _priceController = Get.put(PriceController());
  final PaymentController _paymentController = Get.put(PaymentController());

  final RxInt isSelect = 2.obs;

  bool payWithCardandPaypal(String cardUrl, int select, String columName) {
    if (cardUrl.isEmpty) {
      return false;
    } else {
      if (select == 6) {
        if (priceFlashSale[0][columName] == true) {
          return true;
        } else {
          return false;
        }
      } else {
        if (pricePlans[select][columName] == true) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  bool payWithAppStore(int select) {
    if (select == 6) {
      if (priceFlashSale[0]['via_app_store'] == true) {
        return true;
      } else {
        return false;
      }
    } else {
      if (pricePlans[select]['via_app_store'] == true) {
        return true;
      } else {
        return false;
      }
    }
  }
  Future<void> _willPopCallback(context) async {
    if(isFromNotification == true){
      Get.offAll(()=>BottomScreen());
    }else{
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    isSelect.value = selectPaymentIndex!;
      return PopScope(
        canPop: false,
        onPopInvoked: (canPop) async {
          if (!canPop) {
            await _willPopCallback(context);
          }
        },
        child: Stack(
              alignment: Alignment.center,
              children: [
                Scaffold(
                  appBar: AppBar(
                    elevation: 0.3,
                    leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 28.w, width: 28.w,onTap: () {
                      if(isFromNotification == true){
                        Get.offAll(()=>BottomScreen());
                      }else{
                        Get.back();
                      }
                    },),
                    title: Styles.regular('store'.tr, c: ConstColors.closeColor, fs: 31.sp, ff: 'HM'),
                    centerTitle: true,
                    actions: [
                      InkWell(
                        onTap: () {
                          Get.to(() => const PriceInteractionBoys());
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 23.h),
                          child: Styles.regular('prices'.tr, c: ConstColors.themeColor, fs: 18.sp),
                        ),
                      ),
                      SizedBox(width: 28.w),
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 30.h),
                          Obx(() {
                            if (remainingTime.value == Duration.zero || _paymentController.productsOffer.length != priceFlashSale.length) {
                              return SvgView('assets/Icons/bluestar.svg', height: 100.w, width: 100.w);
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  isSelect.value = 6;
                                  _paymentController.coinPriceObjectId = priceFlashSale[0]; // FlashSale ma 1 j data levano che etle 0 value che
                                },
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.h),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 5.h),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r), color: const Color(0xFFBF0049)),
                                        child: Column(
                                          children: [
                                            Styles.regular(_priceController.getFormattedTime(remainingTime.value), c: ConstColors.white, ff: 'HB', fs: 30.sp),
                                            Padding(
                                              padding: EdgeInsets.only(left: 13.w, right: 45.w),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.network(priceFlashSale[0]['svg'].url, height: 104.w, width: 104.w),
                                                  //Image.asset('assets/Icons/specialoffer.png', height: 104.w, width: 104.w),
                                                  Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      SizedBox(height: 8.h),
                                                      Styles.regular(priceFlashSale[0]['Coins'].toString(),
                                                          h: 0.8.h, c: const Color(0xFFFFFF6C), ff: 'HB', fs: 60.sp, fontStyle: FontStyle.italic),
                                                      SizedBox(height: 5.h),
                                                      Styles.regular(_paymentController.productsOffer[0].price.toString(),
                                                          h: 1.h, c: const Color(0xFFBEFFF0), ff: 'HB', fs: 40.sp, fontStyle: FontStyle.italic),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (isSelect.value == 6)
                                      Positioned(
                                        child: SvgView('assets/Icons/pricecheck.svg', height: 26.w, width: 26.w),
                                      )
                                  ],
                                ),
                              );
                            }
                          }),
                          SizedBox(height: 20.h),
                          Obx(() {
                            isSelect.value;
                            _paymentController.products.value;
                            if (_paymentController.products.length != pricePlans.length) {
                              return GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, childAspectRatio: 184 / 180, crossAxisSpacing: 20.w, mainAxisSpacing: 25.h),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: 6,
                                  itemBuilder: (context, index) {
                                    return ClipRRect(borderRadius: BorderRadius.circular(16.r), child: preCachedImage(const ValueKey(0)));
                                  });
                            }
                            return Column(
                              children: [
                                GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, childAspectRatio: 184 / 180, crossAxisSpacing: 20.w, mainAxisSpacing: 25.h),
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: pricePlans.length,
                                    itemBuilder: (context, index) {
                                      RxInt index1 = _paymentController.products
                                          .indexWhere(
                                              ((element) => element.id == (Platform.isIOS ? pricePlans[index]['AppleId'] : pricePlans[index]['GoogleId'])))
                                          .obs;

                                      return GestureDetector(
                                        onTap: () async {
                                          isSelect.value = index;
                                          _paymentController.coinPriceObjectId = pricePlans[index];
                                        },
                                        child: Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 10.h),
                                              child: Container(
                                                height: 184.h,
                                                width: MediaQuery.sizeOf(context).width,
                                                decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius: BorderRadius.circular(16.r),
                                                    border: Border.all(
                                                        width: 1.w, color: isSelect.value == index ? ConstColors.priceGreenColor : ConstColors.border)),
                                                padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 10.w),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    if (pricePlans[index]['Index'] == '3')
                                                      Column(
                                                        children: [
                                                          Container(
                                                            height: 27.h,
                                                            width: 113.w,
                                                            alignment: Alignment.center,
                                                            decoration:
                                                                BoxDecoration(color: ConstColors.priceGreenColor, borderRadius: BorderRadius.circular(30.r)),
                                                            child: Styles.regular('popular'.tr, c: ConstColors.white, ff: 'HB', fs: 12.sp),
                                                          ),
                                                          SizedBox(height: 11.h),
                                                          SvgPicture.network(pricePlans[index]['svg'].url, height: 30.w, width: 30.w),
                                                        ],
                                                      )
                                                    else
                                                      SvgPicture.network(pricePlans[index]['svg'].url, height: 60.w, width: 60.w),
                                                    const Spacer(),
                                                    Styles.regular(
                                                        pricePlans[index][StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode],
                                                        c: Theme.of(context).primaryColor,
                                                        fs: 18.sp,
                                                        al: TextAlign.center),
                                                    const Spacer(),
                                                    Styles.regular(_paymentController.products[index1.value].price.toString(),
                                                        c: Theme.of(context).primaryColor, fs: 18.sp, ff: 'HB'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (isSelect.value == index)
                                              Positioned(
                                                child: SvgView('assets/Icons/pricecheck.svg', height: 26.w, width: 26.w),
                                              )
                                          ],
                                        ),
                                      );
                                    }),
                              ],
                            );
                          }),
                          SizedBox(height: 20.h)
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: Container(
                    padding: EdgeInsets.only(top: 16.h, left: 20.w, right: 20.w),
                    decoration: BoxDecoration(
                        color: Theme.of(context).dialogBackgroundColor,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30.r), topRight: Radius.circular(30.r))),
                    child: Obx(() {
                      isSelect.value;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GradientButton(
                              title: 'continue'.tr,
                              enable: payWithAppStore(isSelect.value),
                              onTap: () {
                                if (isSelect.value == 6) {
                                  RxInt index = _paymentController.productsOffer
                                      .indexWhere(
                                          ((element) => element.id == (Platform.isIOS ? priceFlashSale[0]['AppleId'] : priceFlashSale[0]['GoogleId'])))
                                      .obs;
                                  _priceController.isPurchase.value = true;
                                  _paymentController.buyProduct(_paymentController.productsOffer[index.value]);
                                } else {
                                  RxInt index1 = _paymentController.products
                                      .indexWhere(((element) =>
                                          element.id == (Platform.isIOS ? pricePlans[isSelect.value]['AppleId'] : pricePlans[isSelect.value]['GoogleId'])))
                                      .obs;
                                  if (isSelect.value == 2) {
                                    _paymentController.coinPriceObjectId = pricePlans[isSelect.value];
                                  }
                                  _priceController.isPurchase.value = true;
                                  _paymentController.buyProduct(_paymentController.products[index1.value]);
                                }
                              }),
                          if (_priceController.cardEnable.value) ...[
                            SizedBox(height: 12.h),
                            GradientButton(
                                title: 'buy_with_card'.tr,
                                color1: ConstColors.black,
                                color2: const Color(0xFFE69791),
                                enable: payWithCardandPaypal(_priceController.cardUrl.value, isSelect.value, 'via_card'),
                                // Table Name ('Coin_Price') Column Name ('via_card')
                                onTap: () {
                                  if (_priceController.cardUrl.value.isNotEmpty) {
                                    String coinPriceId = isSelect.value == 6 ? priceFlashSale[0]['objectId'] : pricePlans[isSelect.value]['objectId'];
                                    Get.to(() => PaymentVew(
                                        title: 'card'.tr,
                                        url:
                                            "https://lenap.eypop.app/secure/card-payment-gateway.php?user_login_id=${StorageService.getBox.read("ObjectId")}&coin_price_id=$coinPriceId"));
                                  }
                                }),
                          ],
                          if (_priceController.payPalEnable.value) ...[
                            SizedBox(height: 12.h),
                            GradientButton(
                                title: 'buy_with_paypal'.tr,
                                color1: const Color(0xFF0028CE),
                                color2: const Color(0xFFE69791),
                                enable: payWithCardandPaypal(_priceController.payPalUrl.value, isSelect.value, 'via_paypal'),
                                // Table Name ('Coin_Price') Column Name ('via_paypal')
                                onTap: () {
                                  if (_priceController.payPalUrl.value.isNotEmpty) {
                                    String coinPriceId = isSelect.value == 6 ? priceFlashSale[0]['objectId'] : pricePlans[isSelect.value]['objectId'];
                                    Get.to(() => PaymentVew(
                                        title: 'paypal'.tr,
                                        url:
                                            "https://lenap.eypop.app/secure/paypal-payment-gateway.php?user_login_id=${StorageService.getBox.read("ObjectId")}&coin_price_id=$coinPriceId"));
                                  }
                                }),
                          ],
                          SizedBox(height: 40.h),
                        ],
                      );
                    }),
                  ),
                ),
                Obx(() {
                  _priceController.isPurchase.value;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 375),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _priceController.isPurchase.value
                        ? Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                            alignment: Alignment.center,
                            key: ValueKey<bool>(_priceController.isPurchase.value),
                            child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown),
                          )
                        : SizedBox.shrink(key: ValueKey<bool>(_priceController.isPurchase.value)),
                  );
                })
              ],
            ),
      );

  }
}
