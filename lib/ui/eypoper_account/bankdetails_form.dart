import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/bankdetails_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/ui/contract_details.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'upload_document.dart';

class BankDetailsForm extends GetView {
  const BankDetailsForm({Key? key}) : super(key: key);

  static BankDetailsController get _bc => Get.find<BankDetailsController>();

  static UserController get _uc => Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 28.w, width: 28.w),
          title: Styles.regular("eypopers", c: ConstColors.closeColor, fs: 31.sp),
        ),
        body: SingleChildScrollView(
          child: Obx(() {
            _bc.enable.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Styles.regular('Billing_information'.tr, c: Theme.of(context).primaryColor, fw: FontWeight.bold, fs: 20.sp, ff: "HB"),
                      SizedBox(height: 5.h),
                      if (_bc.dataExits.value) ...[
                        if (_bc.requestStatus.value.contains('PENDING'))
                          Row(
                            key: UniqueKey(),
                            children: [
                              CircleAvatar(radius: 8.r, backgroundColor: ConstColors.deepBlueColor, key: UniqueKey()),
                              SizedBox(width: 5.w),
                              Styles.regular('IN_REVIEW'.tr, c: Theme.of(context).primaryColor, fs: 16.sp, ff: "HB"),
                            ],
                          )
                        else if (_bc.requestStatus.value.contains('REJECTED'))
                          Column(
                            key: UniqueKey(),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(radius: 8.r, backgroundColor: ConstColors.redColor, key: UniqueKey()),
                                  SizedBox(width: 5.w),
                                  Styles.regular('REJECTED'.tr, c: Theme.of(context).primaryColor, fs: 16.sp, ff: "HB"),
                                ],
                              ),
                              Styles.regular(_bc.rejectReason.value, c: ConstColors.redColor, fs: 16.sp),
                            ],
                          )
                        else
                          Row(
                            key: UniqueKey(),
                            children: [
                              CircleAvatar(radius: 8.r, backgroundColor: ConstColors.lightGreenColor, key: UniqueKey()),
                              SizedBox(width: 5.w),
                              Styles.regular('ACTIVE'.tr, c: Theme.of(context).primaryColor, fs: 16.sp, ff: "HB"),
                            ],
                          ),
                      ] else
                        Styles.regular('Billing_information_text'.tr, c: Theme.of(context).primaryColor, fs: 16.sp, key: UniqueKey()),
                      SizedBox(height: 22.h),
                      TextFieldModel(
                          hint: "",
                          label: 'First_name'.tr,
                          enabled: _bc.enable.value,
                          controllers: _bc.nameController,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                          onChanged: (val) {
                            _bc.isName.value = val;
                          }),
                      TextFieldModel(
                          hint: "",
                          label: 'Last_name'.tr,
                          enabled: _bc.enable.value,
                          controllers: _bc.surnameController,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                          onChanged: (val) {
                            _bc.isSurname.value = val;
                          }),
                      TextFieldModel(
                          hint: '',
                          label: 'ID_number'.tr,
                          enabled: _bc.enable.value,
                          controllers: _bc.taxNumberController,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                          onChanged: (val) {
                            _bc.isTaxNUmber.value = val;
                          }),
                      TextFieldModel(
                          hint: '',
                          label: 'Phone_number'.tr,
                          enabled: _bc.enable.value,
                          controllers: _bc.telephoneNumberController,
                          textInputType: TextInputType.number,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                          onChanged: (val) {
                            _bc.isTelephoneNumber.value = val;
                          }),
                      TextFieldModel(
                          hint: '',
                          label: 'Email_address'.tr,
                          enabled: _bc.enable.value,
                          controllers: _bc.emailController,
                          textInputType: TextInputType.emailAddress,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                          onChanged: (val) {
                            _bc.isEmail.value = val;
                          }),
                      TextFieldModel(
                        hint: '',
                        label: 'Address'.tr,
                        cursorColor: ConstColors.themeColor,
                        maxLine: 5,
                        minLine: 5,
                        enabled: _bc.enable.value,
                        controllers: _bc.homeController,
                        onChanged: (val) {
                          _bc.isHome.value = val;
                        },
                      ),
                      TextFieldModel(
                          hint: "",
                          label: 'Postal_code'.tr,
                          controllers: _bc.postalCodeController,
                          enabled: _bc.enable.value,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                          textInputType: TextInputType.number,
                          onChanged: (val) {
                            _bc.isPostalCode.value = val;
                          }),
                      TextFieldModel(
                          hint: "",
                          label: 'City'.tr,
                          controllers: _bc.cityController,
                          enabled: _bc.enable.value,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                          onChanged: (val) {
                            _bc.isCity.value = val;
                          }),
                      TextFieldModel(
                          hint: "",
                          label: 'Country'.tr,
                          controllers: _bc.countryController,
                          enabled: _bc.enable.value,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                          onChanged: (val) {
                            _bc.isCountry.value = val;
                          }),
                    ],
                  ),
                ),
                // Show when user come first time
                if (_bc.enable.value) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Styles.regular('Attach_document'.tr, fs: 18.sp, c: Theme.of(context).primaryColor, al: TextAlign.center, ff: "HL"),
                        SizedBox(height: 20.h),
                        GradientButton(
                          onTap: () {
                            _widgetSheet(context);
                          },
                          title: 'ID_document'.tr,
                          fontSize: 18.sp,
                          color1: ConstColors.deepBlueColor,
                          color2: ConstColors.deepBlueColor,
                        ),
                      ],
                    ),
                  ),
                ],
                Obx(() {
                  final items = _bc.selectDocList.values.where((element) => element['Save'] == true).toList();
                  if (items.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        key: UniqueKey(),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),
                          Styles.regular('National_Document'.tr, fs: 18.sp, c: Theme.of(context).primaryColor, al: TextAlign.start, ff: "HB"),
                          SizedBox(height: 5.h),
                          SizedBox(
                            height: _bc.selectDoc.value == 2 ? 182.h : 116.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              separatorBuilder: (context, index) => SizedBox(width: 10.w),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  key: UniqueKey(),
                                  height: MediaQuery.sizeOf(context).height,
                                  width: 182.w,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: ConstColors.border, width: 2.w),
                                      image: DecorationImage(
                                          // Type [Net] when user come second time
                                          // Type [File] when user upload document first time
                                          image: (items[index]['Type'].toString().contains('Net') ? NetworkImage(items[index]['Path']) : FileImage(File(items[index]['Path'])))
                                              as ImageProvider,
                                          fit: BoxFit.cover)),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox.shrink(key: UniqueKey());
                  }
                }),
                if (_bc.enable.value) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Obx(() {
                              _bc.isAcceptCondition.value;
                              return InkWell(
                                onTap: () {
                                  _bc.isAcceptCondition.value = !_bc.isAcceptCondition.value;
                                },
                                child: Dots(select: _bc.isAcceptCondition.value, selectColor: ConstColors.deepBlueColor, key: UniqueKey(), width: 40.w, height: 40.w),
                              );
                            }),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: 'Influencer_contract'.tr,
                                  style: TextStyle(fontFamily: "HR", fontSize: 16.sp, color: Theme.of(context).primaryColor),
                                  children: [
                                    TextSpan(
                                      text: " ${'SEE_CONTRACT'.tr}",
                                      style: TextStyle(fontFamily: "HB", fontSize: 14.sp, color: ConstColors.themeColor),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.to(() => const ContractDetails());
                                        },
                                    ),
                                  ],
                                ),
                                textScaler: const TextScaler.linear(1),
                                maxLines: 3,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 29.h),
                        Obx(() {
                          _bc.isButtonEnable.value;
                          final items = _bc.selectDocList.values.where((element) => element['Save'] == true).toList();
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 375),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: _bc.isButtonEnable.value
                                ? GradientButton(
                                    key: ValueKey<bool>(_bc.isButtonEnable.value),
                                    onTap: _bc.sendEypoperRequest,
                                    title: 'ACCEPT_SEND'.tr,
                                    enable: (_bc.isButtonEnable.value &&
                                        _bc.isName.value.isNotEmpty &&
                                        _bc.isSurname.value.isNotEmpty &&
                                        _bc.isTaxNUmber.value.isNotEmpty &&
                                        _bc.isTelephoneNumber.value.isNotEmpty &&
                                        _bc.isEmail.value.isNotEmpty &&
                                        _bc.isHome.value.isNotEmpty &&
                                        _bc.isCity.value.isNotEmpty &&
                                        _bc.isPostalCode.value.isNotEmpty &&
                                        _bc.isCountry.value.isNotEmpty &&
                                        _bc.isAcceptCondition.value &&
                                        items.isNotEmpty),
                                    fontSize: 18.sp)
                                : Align(
                                    alignment: Alignment.topCenter,
                                    key: ValueKey<bool>(_bc.isButtonEnable.value),
                                    child: Lottie.asset('assets/jsons/load_more.json', height: 50.w, width: 50.w, fit: BoxFit.cover),
                                  ),
                          );
                        }),
                      ],
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Styles.regular('Request_billing'.tr, c: Theme.of(context).primaryColor, fw: FontWeight.bold, fs: 20.sp, ff: "HB"),
                        SizedBox(height: 5.h),
                        Styles.regular('Contact_us'.tr, c: Theme.of(context).primaryColor, fs: 18.sp),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  ),
                  Divider(color: ConstColors.closeColor, height: 0),
                  InkWell(
                    onTap: () async {
                      final contact = _uc.contactNumber.value.removeAllWhitespace;
                      final url = Uri.parse(Platform.isIOS ? "https://wa.me/$contact" : "whatsapp://send?phone=$contact");
                      await canLaunchUrl(url).then((value) async {
                        if (value) {
                          await launchUrl(url);
                        } else {
                          gradientSnackBar(context,
                              title: 'WhatsApp ${'Is_not_installed_on_the_device'.tr}',
                              image: 'assets/Icons/whatsapp_outline.svg',
                              color1: ConstColors.darkRedColor,
                              color2: ConstColors.redColor);
                        }
                      });
                    },
                    child: Container(
                      height: 58.h,
                      color: Theme.of(context).dialogBackgroundColor,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgView('assets/Icons/whatsapp_outline.svg', width: 22.w, fit: BoxFit.cover, color: Theme.of(context).primaryColor),
                          SizedBox(width: 26.w),
                          Styles.regular('WhatsApp', c: Theme.of(context).primaryColor, fs: 18.sp),
                          const Spacer(),
                          SvgView('assets/Icons/arrow_right.svg', height: 20.w, width: 20.w, fit: BoxFit.cover, color: Theme.of(context).primaryColor)
                        ],
                      ),
                    ),
                  ),
                  Divider(color: ConstColors.closeColor, height: 0),
                  InkWell(
                    onTap: () async {
                      final url = Uri.parse('${'https://t.me/'}${_uc.telegramId.value}');
                      await launchUrl(url);
                    },
                    child: Container(
                      height: 58.h,
                      color: Theme.of(context).dialogBackgroundColor,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgView('assets/Icons/telegram_outline.svg', width: 22.w, fit: BoxFit.cover, color: Theme.of(context).primaryColor),
                          SizedBox(width: 26.w),
                          Styles.regular('Telegram', c: Theme.of(context).primaryColor, fs: 18.sp),
                          const Spacer(),
                          SvgView('assets/Icons/arrow_right.svg', height: 20.w, width: 20.w, fit: BoxFit.cover, color: Theme.of(context).primaryColor)
                        ],
                      ),
                    ),
                  ),
                  Divider(color: ConstColors.closeColor, height: 0),
                  InkWell(
                    onTap: () async {
                      try {
                        final Uri url = Uri(scheme: 'skype', path: _uc.skypeId.value.removeAllWhitespace, queryParameters: {'chat': 'true'});
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
                    },
                    child: Container(
                      height: 58.h,
                      color: Theme.of(context).dialogBackgroundColor,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgView('assets/Icons/skype_outline.svg', width: 22.w, fit: BoxFit.cover, color: Theme.of(context).primaryColor),
                          SizedBox(width: 26.w),
                          Styles.regular('Skype', c: Theme.of(context).primaryColor, fs: 18.sp),
                          const Spacer(),
                          SvgView('assets/Icons/arrow_right.svg', height: 20.w, width: 20.w, fit: BoxFit.cover, color: Theme.of(context).primaryColor)
                        ],
                      ),
                    ),
                  ),
                  Divider(color: ConstColors.closeColor, height: 0),
                  InkWell(
                    onTap: () async {
                      final contact = _uc.email.value.removeAllWhitespace;
                      final androidUrl = "mailto:$contact";
                      await launchUrl(Uri.parse(androidUrl));
                    },
                    child: Container(
                      height: 58.h,
                      color: Theme.of(context).dialogBackgroundColor,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgView('assets/Icons/email_outline.svg', width: 22.w, fit: BoxFit.cover, color: Theme.of(context).primaryColor),
                          SizedBox(width: 26.w),
                          Styles.regular('email'.tr, c: Theme.of(context).primaryColor, fs: 18.sp),
                          const Spacer(),
                          SvgView('assets/Icons/arrow_right.svg', height: 20.w, width: 20.w, fit: BoxFit.cover, color: Theme.of(context).primaryColor)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ]
              ],
            );
          }),
        ));
  }

  void _widgetSheet(context) {
    showModalBottomSheet<void>(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r)),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 48.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 3.h, width: 58.w, decoration: BoxDecoration(color: ConstColors.offlineColor, borderRadius: BorderRadius.circular(2.r))),
              SizedBox(height: 12.5.h),
              Styles.regular('Choose_document'.tr, ff: 'HB', fs: 18.sp, c: Theme.of(context).primaryColor),
              SizedBox(height: 14.5.h),
              Divider(color: Theme.of(context).primaryColor),
              SizedBox(height: 10.h),
              Styles.regular('Choose_document_text'.tr, fs: 16.sp, c: Theme.of(context).primaryColor.withOpacity(0.6), al: TextAlign.center),
              SizedBox(height: 10.h),
              ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 18.h),
                itemCount: _bc.documentList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final Map<String, dynamic> item = _bc.documentList[index];
                  return InkWell(
                    onTap: () {
                      _bc.selectDoc.value = index;
                    },
                    child: Row(
                      children: [
                        SvgView(item['svg'], width: 29.w, fit: BoxFit.cover, color: Theme.of(context).primaryColor),
                        SizedBox(width: 12.w),
                        Styles.regular(item['title'], c: Theme.of(context).primaryColor, fs: 18.sp),
                        const Spacer(),
                        Obx(() {
                          _bc.selectDoc.value;
                          return SvgView("assets/Icons/check.svg",
                              color: _bc.selectDoc.value == index ? ConstColors.darkRedColor : ConstColors.closeColor, height: 24.w, width: 24.w);
                        }),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 35.h),
              GradientButton(
                  title: 'Continue'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const UploadDocuments());
                  }),
              SizedBox(height: 12.h),
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Styles.regular('Cancel'.tr, fs: 18.sp, ff: 'HR', c: ConstColors.deepBlueColor),
              ),
            ],
          ),
        );
      },
    );
  }
}
