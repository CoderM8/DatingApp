// ignore_for_file: invalid_use_of_protected_member

import 'dart:ui';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/bankdetails_controller.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/Controllers/withdrawpayment_controller.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/coin_history/price_interactions_girls.dart';
import 'package:eypop/ui/eypoper_account/bankdetails_form.dart';
import 'package:eypop/ui/transaction_history.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'coin_history/total_token_girls.dart';

class TokenView extends GetView {
  TokenView({Key? key}) : super(key: key);

  static PriceController get priceController => Get.put(PriceController());

  static BankDetailsController get bc => Get.put(BankDetailsController());

  static UserController get userController => Get.put(UserController());

  final WithdrawPaymentController withdrawPaymentController = Get.put(WithdrawPaymentController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 28.w, width: 28.w),
            title: Styles.regular("eypopers", c: ConstColors.closeColor, fs: 31.sp),
            actions: [
              Center(
                child: InkWell(
                  onTap: () {
                    Get.to(() => const TotalTokenGirls());
                  },
                  child: Styles.regular("Receive".tr, c: ConstColors.themeColor, fs: 18.sp),
                ),
              ),
              SizedBox(width: 20.w)
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 117.h,
                  margin: EdgeInsets.only(top: 18.h, bottom: 20.h, right: 20.w, left: 20.w),
                  padding: EdgeInsets.only(left: 17.w, right: 10.w),
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [BoxShadow(color: ConstColors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 2, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      SvgView('assets/Icons/bluestar.svg', height: 43.w, width: 43.w, fit: BoxFit.cover),
                      SizedBox(width: 23.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              priceController.userTotalCoin.value;
                              return Text.rich(
                                TextSpan(
                                  text: 'Stars_earned'.tr,
                                  style: TextStyle(fontFamily: "HR", fontSize: 18.sp),
                                  children: [
                                    TextSpan(text: ' ${priceController.userTotalCoin.value}', style: TextStyle(fontFamily: "HB", fontSize: 18.sp)),
                                  ],
                                ),
                                textScaler: const TextScaler.linear(1),
                              );
                            }),
                            Obx(() {
                              priceController.userTotalCoin.value;
                              userController.singleStarPrice.value;
                              if (StorageService.getBox.read('languageCode') == 'es') {
                                return Text.rich(
                                  TextSpan(
                                    text: 'You_have_already_accumulated'.tr,
                                    style: TextStyle(fontFamily: "HR", fontSize: 16.sp),
                                    children: [
                                      TextSpan(
                                          text:
                                              " ${(priceController.userTotalCoin.value * double.parse(userController.singleStarPrice.value)).toStringAsFixed(2).replaceAll('.', ',')}€",
                                          style: TextStyle(fontFamily: "HB", fontSize: 18.sp)),
                                    ],
                                  ),
                                  textScaler: const TextScaler.linear(1),
                                  maxLines: 2,
                                  key: UniqueKey(),
                                );
                              }
                              return Text.rich(
                                TextSpan(
                                  text: 'You_have_already_accumulated'.tr,
                                  style: TextStyle(fontFamily: "HR", fontSize: 16.sp),
                                  children: [
                                    TextSpan(
                                        text:
                                            " ${(priceController.userTotalCoin.value * double.parse(userController.singleStarPrice.value)).toStringAsFixed(2)}€",
                                        style: TextStyle(fontFamily: "HB", fontSize: 18.sp)),
                                  ],
                                ),
                                textScaler: const TextScaler.linear(1),
                                maxLines: 2,
                                key: UniqueKey(),
                              );
                            }),
                            Styles.regular('${'Minimum_withdrawal'.tr} ${userController.minimumWithdrawn.value}', fs: 14.sp, c: ConstColors.border),
                            Row(
                              children: [
                                Styles.regular('Price_1_star'.tr, fs: 14.sp, c: ConstColors.border),
                                if (StorageService.getBox.read('languageCode') == 'es') ...[
                                  Obx(() {
                                    return Styles.regular("${userController.singleStarPrice.value.replaceAll('.', ',')}€",
                                        fs: 14.sp, c: ConstColors.border, key: UniqueKey());
                                  })
                                ] else ...[
                                  Obx(() {
                                    return Styles.regular("${userController.singleStarPrice.value}€",
                                        fs: 14.sp, c: ConstColors.border, key: UniqueKey());
                                  })
                                ],
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRect(
                  child: Obx(() {
                    bc.status.value;
                    withdrawPaymentController.isLoading.value;
                    return Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: withdrawPaymentController.isLoading.value
                          ? Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown)
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  children: [
                                    /// WesternUnion
                                    if (withdrawPaymentController.paymentList.value[0]['PaymentName']
                                        .toString()
                                        .contains(PaymentType.WesternUnion.name) &&
                                        (withdrawPaymentController.paymentList.value[0]['CountryList']
                                            .toString()
                                            .contains(PaintingBinding.instance.platformDispatcher.locale.countryCode.toString()) ||
                                            PaintingBinding.instance.platformDispatcher.locale.countryCode.toString().contains('GB')))
                                      paymentTile(context,
                                          img: 'assets/images/western_union.png', title: 'Western_Union'.tr, enable: bc.status.value, onTap: () {
                                            bottomSheetPayment(
                                              context,
                                              type: PaymentType.WesternUnion,
                                              png: 'assets/images/western_union.png',
                                              headLine: 'Western_Union_text'.tr,
                                              hint: 'Western_Union_hint'.tr,
                                              warning: 'Western_Union_warning'.tr,
                                              helper: 'Western_Union_helper'.tr,
                                              init: bc.isWesternUnion.value,
                                              initCode: bc.isWesternUnionName.value,
                                              withdrawTap: (account, code, type) {
                                                bc.makePayment(
                                                  amount: priceController.userTotalCoin.value * double.parse(userController.singleStarPrice.value),
                                                  totalCoin: priceController.userTotalCoin.value,
                                                  type: type,
                                                  account: account,
                                                  code: code,
                                                );
                                              },
                                            );
                                          }),

                                    /// Iban
                                    if (withdrawPaymentController.paymentList.value[1]['PaymentName'].toString().contains(PaymentType.Iban.name) &&
                                        (withdrawPaymentController.paymentList.value[1]['CountryList']
                                            .toString()
                                            .contains(PaintingBinding.instance.platformDispatcher.locale.countryCode.toString())) ||
                                        PaintingBinding.instance.platformDispatcher.locale.countryCode.toString().contains('GB'))
                                      paymentTile(context, img: 'assets/images/iban.png', title: 'IBAN'.tr, enable: bc.status.value, onTap: () {
                                        bottomSheetPayment(
                                          context,
                                          type: PaymentType.Iban,
                                          png: 'assets/images/iban.png',
                                          headLine: 'IBAN_text'.tr,
                                          hint: 'IBAN_hint'.tr,
                                          warning: 'IBAN_warning'.tr,
                                          helper: 'IBAN_helper'.tr,
                                          init: bc.isIban.value,
                                          withdrawTap: (account, code, type) {
                                            bc.makePayment(
                                              amount: priceController.userTotalCoin.value * double.parse(userController.singleStarPrice.value),
                                              totalCoin: priceController.userTotalCoin.value,
                                              type: type,
                                              account: account,
                                              code: code,
                                            );
                                          },
                                        );
                                      }),

                                    /// Swift
                                    if (withdrawPaymentController.paymentList.value[2]['PaymentName'].toString().contains(PaymentType.Swift.name) &&
                                        (withdrawPaymentController.paymentList.value[2]['CountryList']
                                            .toString()
                                            .contains(PaintingBinding.instance.platformDispatcher.locale.countryCode.toString())) ||
                                        PaintingBinding.instance.platformDispatcher.locale.countryCode.toString().contains('GB'))
                                      paymentTile(context, img: 'assets/images/swift.png', title: 'SWIFT'.tr, enable: bc.status.value, onTap: () {
                                        bottomSheetPayment(
                                          context,
                                          type: PaymentType.Swift,
                                          png: 'assets/images/swift.png',
                                          headLine: 'SWIFT_text'.tr,
                                          hint: 'SWIFT_hint'.tr,
                                          warning: 'Payment_warning'.tr,
                                          helper: 'SWIFT_helper'.tr,
                                          init: bc.isSwift.value,
                                          initCode: bc.isSwiftCode.value,
                                          withdrawTap: (account, code, type) {
                                            bc.makePayment(
                                              amount: priceController.userTotalCoin.value * double.parse(userController.singleStarPrice.value),
                                              totalCoin: priceController.userTotalCoin.value,
                                              type: type,
                                              account: account,
                                              code: code,
                                            );
                                          },
                                        );
                                      }),

                                    /// Bizun
                                    if (withdrawPaymentController.paymentList.value[3]['PaymentName'].toString().contains(PaymentType.Bizun.name) &&
                                        (withdrawPaymentController.paymentList.value[3]['CountryList']
                                            .toString()
                                            .contains(PaintingBinding.instance.platformDispatcher.locale.countryCode.toString())) ||
                                        PaintingBinding.instance.platformDispatcher.locale.countryCode.toString().contains('GB'))
                                      paymentTile(context, img: 'assets/images/bizum.png', title: 'BIZUM'.tr, enable: bc.status.value, onTap: () {
                                        bottomSheetPayment(
                                          context,
                                          type: PaymentType.Bizun,
                                          png: 'assets/images/bizum.png',
                                          headLine: 'BIZUM_text'.tr,
                                          hint: 'BIZUM_hint'.tr,
                                          warning: 'Payment_warning'.tr,
                                          helper: 'BIZUM_helper'.tr,
                                          init: bc.isBizun.value,
                                          withdrawTap: (account, code, type) {
                                            bc.makePayment(
                                                amount: priceController.userTotalCoin.value * double.parse(userController.singleStarPrice.value),
                                                totalCoin: priceController.userTotalCoin.value,
                                                type: type,
                                                account: account,
                                                code: code);
                                          },
                                        );
                                      }),

                                    /// Paypal
                                    if (withdrawPaymentController.paymentList.value[4]['PaymentName'].toString().contains(PaymentType.Paypal.name) &&
                                        (withdrawPaymentController.paymentList.value[4]['CountryList']
                                            .toString()
                                            .contains(PaintingBinding.instance.platformDispatcher.locale.countryCode.toString())) ||
                                        PaintingBinding.instance.platformDispatcher.locale.countryCode.toString().contains('GB'))
                                      paymentTile(context, img: 'assets/images/paypal.png', title: 'PayPal'.tr, enable: bc.status.value, onTap: () {
                                        bottomSheetPayment(
                                          context,
                                          type: PaymentType.Paypal,
                                          png: 'assets/images/paypal.png',
                                          headLine: 'PayPal_text'.tr,
                                          hint: 'PayPal_hint'.tr,
                                          warning: 'Payment_warning'.tr,
                                          helper: 'PayPal_helper'.tr,
                                          init: bc.isPaypal.value,
                                          withdrawTap: (account, code, type) {
                                            bc.makePayment(
                                              amount: priceController.userTotalCoin.value * double.parse(userController.singleStarPrice.value),
                                              totalCoin: priceController.userTotalCoin.value,
                                              type: type,
                                              account: account,
                                              code: code,
                                            );
                                          },
                                        );
                                      }),
                                    SizedBox(height: 20.h),
                                  ],
                                ),
                                if (!bc.status.value)
                                  Positioned.fill(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                                      child: Container(
                                        color: Colors.black.withOpacity(0.0),
                                        padding: EdgeInsets.only(top: 25.h, right: 20.w, left: 20.w),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                                              child: Styles.regular("Create_EYPOPER_Account".tr,
                                                  fs: 26.sp, ff: 'HB', c: ConstColors.deepBlueColor, al: TextAlign.center),
                                            ),
                                            const Spacer(),
                                            Styles.regular("Create_EYPOPER_Account_text".tr,
                                                fs: 17.sp, fontStyle: FontStyle.italic, ff: 'HB', al: TextAlign.center),
                                            const Spacer(flex: 3),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                    );
                  }),
                ),
                // Container(
                //   padding: EdgeInsets.only(left: 21.w, right: 21.w),
                //   child: Column(
                //     children: [
                //       SizedBox(height: 51.h),
                //       Obx(() {
                //         return button(
                //             width: 387.w,
                //             context: context,
                //             title: 'Withdraw_to_my_PayPal'.tr,
                //             onTap: () {
                //               // bottomSheetPayment(context, "PayPal");
                //             },
                //             enable: _bankDetailsController.status.value == true &&
                //                 _bankDetailsController.paypalAccountController.text.isNotEmpty &&
                //                 _priceController.userTotalCoin.value >= double.parse(_userController.minimumWithdrawn.value),
                //             svg1: 'assets/Icons/paypal.svg');
                //       }),
                //       SizedBox(height: 15.h),
                //       Obx(() {
                //         return button(
                //             width: 387.w,
                //             context: context,
                //             title: 'Withdraw_to_my_bank'.tr,
                //             onTap: () {
                //               // bottomSheetPayment(context, 'bank'.tr);
                //             },
                //             enable: _bankDetailsController.status.value == true &&
                //                 _bankDetailsController.accountNumberController.text.isNotEmpty &&
                //                 _priceController.userTotalCoin.value >= double.parse(_userController.minimumWithdrawn.value),
                //             svg1: 'assets/Icons/transaction.svg');
                //       }),
                //       SizedBox(height: 10.h),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(top: 28.h, left: 21.w, right: 21.w),
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientButton(
                  title: 'influencer_account'.tr,
                  onTap: () async {
                    await bc.getUserBankDetails();
                    Get.to(() => const BankDetailsForm());
                  },
                ),
                SizedBox(height: 20.h),
                GradientButton(
                    title: 'Rewards'.tr,
                    color1: const Color(0xFF0028CE),
                    color2: const Color(0xFFE69791),
                    onTap: () {
                      Get.to(() => PriceInteractionGirls());
                    }),
                SizedBox(height: 20.h),
                Obx(() {
                  bc.requestStatus.value;
                  return GradientButton(
                    title: 'Payment_history'.tr,
                    enable: bc.status.value,
                    onTap: () {
                      Get.to(() => const TransactionView());
                    },
                  );
                }),
                SizedBox(height: 42.h),
              ],
            ),
          ),
        ),
        Obx(() {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 375),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: (bc.isLoading.value)
                ? Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    key: ValueKey<bool>(bc.isLoading.value),
                    alignment: Alignment.center,
                    child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown),
                  )
                : SizedBox.shrink(key: ValueKey<bool>(bc.isLoading.value)),
          );
        }),
      ],
    );
  }

  /// withdrawTap (String, String, PaymentType)
  /// 1. account number,
  /// 2. code ==> if (type == swift || type == union)
  /// 3. PaymentType
  void bottomSheetPayment(context,
      {required PaymentType type,
      required String headLine,
      required String png,
      required String hint,
      required String warning,
      required String helper,
      required Function(String, String, PaymentType) withdrawTap,
      required String init,
      String? initCode}) {
    final TextEditingController accountController = TextEditingController(text: init);
    final TextEditingController editingController = TextEditingController(text: initCode);
    final RxBool isValid = false.obs;
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r)),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 48.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 3.h,
                      width: 58.w,
                      decoration: BoxDecoration(color: ConstColors.offlineColor, borderRadius: BorderRadius.circular(2.r)),
                    ),
                    SizedBox(height: 12.5.h),
                    Styles.regular("Withdraw_rewards".tr, ff: 'HB', fw: FontWeight.bold, fs: 18.sp),
                    SizedBox(height: 14.5.h),
                    Divider(color: Theme.of(context).primaryColor),
                    SizedBox(height: 22.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 70.w,
                          width: 70.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Theme.of(context).primaryColor),
                            image: DecorationImage(image: AssetImage(png), fit: BoxFit.cover),
                          ),
                        ),
                        SizedBox(width: 17.w),
                        Expanded(
                          child:
                              Styles.regular(headLine, fs: 16.sp, lns: 3, c: Theme.of(context).primaryColor.withOpacity(0.6), al: TextAlign.center),
                        )
                      ],
                    ),
                    Obx(() {
                      priceController.userTotalCoin.value;
                      userController.singleStarPrice.value;
                      if (StorageService.getBox.read('languageCode') == 'es') {
                        return Styles.regular(
                            "${(priceController.userTotalCoin.value * double.parse(userController.singleStarPrice.value)).toString().replaceAll('.', ',')}€",
                            ff: 'HB',
                            fw: FontWeight.bold,
                            fs: 34.sp,
                            key: UniqueKey());
                      }
                      return Styles.regular("${priceController.userTotalCoin.value * double.parse(userController.singleStarPrice.value)}€",
                          ff: 'HB', fw: FontWeight.bold, fs: 34.sp, key: UniqueKey());
                    }),
                    SizedBox(height: 26.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Styles.regular(hint, fs: 16.sp, ff: 'HR'),
                        SizedBox(height: 3.h),
                        TextFieldModel(
                          hint: '',
                          controllers: accountController,
                          cursorColor: Theme.of(context).primaryColor,
                          containerColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                          onChanged: (value) {
                            isValid.value = value.isNotEmpty;
                          },
                        ),
                        SizedBox(height: 5.h),
                        if (type == PaymentType.Swift || type == PaymentType.WesternUnion) ...[
                          Styles.regular(type == PaymentType.Swift ? 'SWIFT / BIC' : 'Western_Union_subHint'.tr, fs: 16.sp, ff: 'HR'),
                          SizedBox(height: 3.h),
                          TextFieldModel(
                            hint: '',
                            controllers: editingController,
                            cursorColor: Theme.of(context).primaryColor,
                            containerColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                            onChanged: (value) {
                              isValid.value = value.isNotEmpty;
                            },
                          ),
                        ],
                        Styles.regular(warning, fs: 14.sp, fontStyle: FontStyle.italic, c: ConstColors.redColor, lns: 2),
                        SizedBox(height: 8.h),
                        Styles.regular(helper, fs: 14.sp, fontStyle: FontStyle.italic, c: Theme.of(context).primaryColor.withOpacity(0.6), lns: 3),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Obx(() {
                              bc.isRemember.value;
                              return InkWell(
                                onTap: () {
                                  bc.isRemember.value = !bc.isRemember.value;
                                },
                                child: Dots(
                                    select: bc.isRemember.value,
                                    selectColor: ConstColors.deepBlueColor,
                                    key: ValueKey<bool>(bc.isRemember.value),
                                    height: 25.w,
                                    width: 25.w),
                              );
                            }),
                            SizedBox(width: 10.w),
                            Styles.regular('Remember_me'.tr, fs: 14.sp, c: Theme.of(context).primaryColor, ff: "HM"),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Obx(() {
                          isValid.value;
                          return GradientButton(
                              title: 'Confirm_Withdraw'.tr,
                              enable: (type == PaymentType.Swift || type == PaymentType.WesternUnion)
                                  ? (accountController.text.isNotEmpty && editingController.text.isNotEmpty)
                                  : accountController.text.isNotEmpty,
                              onTap: () {
                                withdrawTap(accountController.text.trim(), editingController.text.trim(), type);
                                accountController.clear();
                                editingController.clear();
                                Get.back();
                              });
                        }),
                        SizedBox(height: 20.h),
                        Align(
                          child: InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Styles.regular('Cancel'.tr, fs: 18.sp, ff: 'HR', c: ConstColors.themeColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  /// [img] png, [title] String, [enable] boolean
  Widget paymentTile(context, {required String img, required String title, bool enable = true, VoidCallback? onTap}) {
    return InkWell(
      onTap: enable && (priceController.userTotalCoin.value >= double.parse(userController.minimumWithdrawn.value))
          ? onTap
          : () {
              if (kDebugMode) {
                print('Hello payment onTap disable:- coins: ${priceController.userTotalCoin.value}');
              }
            },
      child: Container(
        height: 70.h,
        margin: EdgeInsets.only(top: 8.h, bottom: 8.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(13.r), border: Border.all(color: Theme.of(context).primaryColor)),
        child: Row(
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height,
              width: 70.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), bottomLeft: Radius.circular(12.r)),
                  image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover)),
            ),
            VerticalDivider(width: 0, thickness: 1.w, color: Theme.of(context).primaryColor),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 5.h, bottom: 5.h, right: 5.w, left: 14.w),
                child: Styles.regular(title, fs: 16.sp, lns: 2, c: Theme.of(context).primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// RxList<Map<String, dynamic>> paymentMethods = [
//   {
//     'type': PaymentType.WesternUnion,
//     'typeName': PaymentType.WesternUnion.name,
//     'image': 'assets/images/western_union.png',
//     'title': 'Western_Union'.tr,
//     'headLine': 'Western_Union_text'.tr,
//     'hint': 'Western_Union_hint'.tr,
//     'warning': 'Western_Union_warning'.tr,
//     'helper': 'Western_Union_helper'.tr,
//     'init': bc.isWesternUnion.value,
//     'initCode': bc.isWesternUnionName.value,
//   },
//   {
//     'type': PaymentType.Iban,
//     'typeName': PaymentType.Iban.name,
//     'image': 'assets/images/iban.png',
//     'title': 'IBAN'.tr,
//     'headLine': 'IBAN_text'.tr,
//     'hint': 'IBAN_hint'.tr,
//     'warning': 'IBAN_warning'.tr,
//     'helper': 'IBAN_helper'.tr,
//     'init': bc.isIban.value,
//   },
//   {
//     'type': PaymentType.Swift,
//     'typeName': PaymentType.Swift.name,
//     'image': 'assets/images/swift.png',
//     'title': 'SWIFT'.tr,
//     'headLine': 'SWIFT_text'.tr,
//     'hint': 'SWIFT_hint'.tr,
//     'warning': 'Payment_warning'.tr,
//     'helper': 'SWIFT_helper'.tr,
//     'init': bc.isSwift.value,
//     'initCode': bc.isSwiftCode.value,
//   },
//   {
//     'type': PaymentType.Bizun,
//     'typeName': PaymentType.Bizun.name,
//     'image': 'assets/images/bizum.png',
//     'title': 'BIZUM'.tr,
//     'headLine': 'BIZUM_text'.tr,
//     'hint': 'BIZUM_hint'.tr,
//     'warning': 'Payment_warning'.tr,
//     'helper': 'BIZUM_helper'.tr,
//     'init': bc.isBizun.value,
//   },
//   {
//     'type': PaymentType.Paypal,
//     'typeName': PaymentType.Paypal.name,
//     'image': 'assets/images/paypal.png',
//     'title': 'PayPal'.tr,
//     'headLine': 'PayPal_text'.tr,
//     'hint': 'PayPal_hint'.tr,
//     'warning': 'Payment_warning'.tr,
//     'helper': 'PayPal_helper'.tr,
//     'init': bc.isPaypal.value,
//   },
// ].obs;


// ListView.builder(
// itemCount: paymentMethods.length,
// shrinkWrap: true,
// physics: const NeverScrollableScrollPhysics(),
// itemBuilder: (context, index) {
// final payment = paymentMethods[index];
// final paymentData = withdrawPaymentController.paymentList.value[index];
// final countryCode = PaintingBinding.instance.platformDispatcher.locale.countryCode.toString();
// final isShow = paymentData['PaymentName'].toString().contains(payment['typeName']) &&
// (paymentData['CountryList'].toString().contains(countryCode) || countryCode.contains('GB'));
//
// if (!isShow) return const SizedBox.shrink();
//
// return paymentTile(
// context,
// img: payment['image'],
// title: payment['title'],
// enable: bc.status.value,
// onTap: () {
// bottomSheetPayment(
// context,
// type: payment['type'],
// png: payment['image'],
// headLine: payment['headLine'],
// hint: payment['hint'],
// warning: payment['warning'],
// helper: payment['helper'],
// init: payment['init'],
// initCode: payment['initCode'],
// withdrawTap: (account, code, type) {
//  bc.makePayment(
// amount: priceController.userTotalCoin.value * double.parse(userController.singleStarPrice.value),
// totalCoin: priceController.userTotalCoin.value,
// type: type,
// account: account,
// code: code,
// );
// },
// );
// },
// );
// },
// ),
