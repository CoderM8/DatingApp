// ignore_for_file: invalid_use_of_protected_member, deprecated_member_use
// ignore_for_file: depend_on_referenced_packages

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Constant/theme/theme.dart';
import 'package:eypop/Constant/translate.dart';
import 'package:eypop/Controllers/toktok_contoller.dart';
import 'package:eypop/Controllers/wish_controllers/create_wish_controller.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:url_launcher/url_launcher.dart';
import 'show_toktok_screen.dart';

class CreateWishScreen extends StatelessWidget {
  const CreateWishScreen({Key? key}) : super(key: key);

  static CreateWishController get _controllerX => Get.put(CreateWishController());
  static TokTokController get toktokController => Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const Back(),
          centerTitle: true,
          title: Styles.regular('TokTok', ff: 'HB', fs: 68.sp, c: ConstColors.darkGreyColor),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Styles.regular('The_Genies_of_the_wish'.tr, fs: 18.sp, c: Theme.of(context).primaryColor, ff: 'HL'),
                    SizedBox(height: 17.h),
                    Obx(() {
                      return Container(
                          height: 54.h,
                          width: MediaQuery.sizeOf(context).width,
                          padding: EdgeInsets.only(left: 20.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: ConstColors.themeColor, width: 2.w),
                          ),
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: PopupMenuButton(
                              color: bottomColor(),
                              initialValue: 'when'.tr,
                              onSelected: (value) {
                                _controllerX.wishTimeForDisplay.value = value.toString();
                                final String local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
                                final String key = Languages().keys[local]!.keys.firstWhere((k) => Languages().keys[local]![k] == value.toString());
                                _controllerX.wishTimeForDatabase.value = key;
                                _controllerX.isWhen.value = true;
                              },
                              itemBuilder: (context) {
                                List<PopupMenuItem> list = [];
                                for (var element in _controllerX.daysList) {
                                  list.add(PopupMenuItem(
                                      value: element, child: Styles.regular(element, c: Theme.of(context).primaryColor, fs: 20.sp, ff: 'RR')));
                                }
                                return list;
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Styles.regular(_controllerX.wishTimeForDisplay.value, c: Theme.of(context).primaryColor, fs: 16.sp),
                                  ButtonTheme(
                                    alignedDropdown: true,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 20.w),
                                      child: Obx(() {
                                        return SvgPicture.asset("assets/Icons/check.svg",
                                            color: _controllerX.isWhen.value ? ConstColors.lightGreenColor : ConstColors.greyButtonColor);
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ));
                    }),
                    SizedBox(height: 15.h),
                    Obx(() {
                      return Container(
                        height: 110.h,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            addWishesBottomSheet(context);
                          },
                          child: _controllerX.selectedWishes.isEmpty
                              ? Container(
                                  height: 48.h,
                                  width: 243.w,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.r),
                                      gradient: LinearGradient(
                                          colors: [const Color(0xFF98D7FF), const Color(0xFF98D7FF).withOpacity(0.1)],
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.bottomRight,
                                          stops: const [0.0, 1])),
                                  child: Styles.regular('Choose_3_wishes'.tr, c: Theme.of(context).primaryColor, fs: 16.sp),
                                )
                              : InkWell(
                                  onTap: () {
                                    addWishesBottomSheet(context);
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.start,
                                      spacing: 0,
                                      runSpacing: 0,
                                      runAlignment: WrapAlignment.start,
                                      children: List.generate(
                                        _controllerX.selectedWishes.length,
                                        (index) {
                                          final String local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
                                          return Container(
                                            height: 38.h,
                                            padding: EdgeInsets.only(left: 20.w, right: 40.w),
                                            margin: EdgeInsets.only(right: 10.w, bottom: 12.h),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(50.r),
                                                gradient: LinearGradient(
                                                    colors: [const Color(0xFFD2F474), const Color(0xFFD2F474).withOpacity(0.1)],
                                                    begin: Alignment.bottomLeft,
                                                    end: Alignment.bottomRight,
                                                    stops: const [0.0, 1])),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Styles.regular(
                                                  _controllerX.selectedWishes[index][local],
                                                  al: TextAlign.start,
                                                  fs: 14.sp,
                                                  c: Theme.of(context).primaryColor,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      );
                    }),
                    SizedBox(height: 15.h),
                    Styles.regular('you_can_choose_your_phone'.tr, c: Theme.of(context).primaryColor, fs: 16.sp, ff: 'HB'),
                    SizedBox(height: 11.h),
                    Obx(() {
                      return _controllerX.telephoneNumber.value.isEmpty
                          ? Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Container(
                                height: 120.h,
                                padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 12.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: const Color(0xFF33A39F), width: 2.w),
                                  gradient: LinearGradient(
                                      colors: [const Color(0xFF97F5E7), Theme.of(context).scaffoldBackgroundColor],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: const [0, 1]),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SvgView('assets/Icons/phoneotp.svg'),
                                    SizedBox(width: 25.w),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Styles.regular('validate_phone_number'.tr,
                                              al: TextAlign.start, lns: 2, c: Theme.of(context).primaryColor, fs: 22.sp, ff: 'HL'),
                                          SizedBox(height: 4.h),
                                          Styles.regular('to_be_able_receivecall_whatsapp'.tr,
                                              lns: 3, al: TextAlign.start, c: Theme.of(context).primaryColor, fs: 14.sp, ff: 'HL'),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    }),

                    /// Telephone
                    Obx(() {
                      return Row(
                        children: [
                          InkWell(
                            onTap: () {
                              DateTime currentDate = DateTime.now();
                              DateTime lastUpdateDate = _controllerX.phoneNumberDate.value;
                              if (currentDate.day == lastUpdateDate.day) {
                                _controllerX.telephone.value.text = _controllerX.telephoneNumber.value;
                                _controllerX.countryCodeNumber.value = _controllerX.countryCodeTelephone.value;
                                alreadyValidateBottomSheet(context, false);
                              } else {
                                addPhoneNumberBottomSheet(context,
                                    number: _controllerX.telephoneNumber.value, countryCode: _controllerX.countryCodeTelephone.value);
                              }
                            },
                            child: Row(
                              children: [
                                SvgView('assets/Icons/telephone.svg', height: 40.w, width: 40.w),
                                SizedBox(width: 23.w),
                                Styles.regular(
                                    _controllerX.telephoneNumber.value.isNotEmpty
                                        ? '${_controllerX.countryCodeTelephone.value} ${_controllerX.telephoneNumber.value}'
                                        : 'phonenumber'.tr,
                                    fs: 18.sp,
                                    c: _controllerX.telephoneNumber.isNotEmpty ? Theme.of(context).primaryColor : ConstColors.subtitle),
                              ],
                            ),
                          ),
                          const Spacer(),
                          SvgView(
                            'assets/Icons/check.svg',
                            color: _controllerX.isTelephone.value ? ConstColors.lightGreenColor : ConstColors.greyButtonColor,
                            onTap: _controllerX.telephoneNumber.value.isNotEmpty
                                ? () {
                                    _controllerX.isTelephone.value = !_controllerX.isTelephone.value;
                                  }
                                : null,
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 10.h),

                    /// Whatsapp
                    Obx(() {
                      return Row(
                        children: [
                          InkWell(
                            onTap: () {
                              DateTime currentDate = DateTime.now();
                              DateTime lastUpdateDate = _controllerX.phoneNumberDate.value;
                              if (currentDate.day == lastUpdateDate.day) {
                                _controllerX.telephone.value.text = _controllerX.whatsappNumber.value.isNotEmpty
                                    ? _controllerX.whatsappNumber.value
                                    : _controllerX.telephoneNumber.value;
                                _controllerX.countryCodeNumber.value = _controllerX.countryCodeWhatsapp.value.isNotEmpty
                                    ? _controllerX.countryCodeWhatsapp.value
                                    : _controllerX.countryCodeTelephone.value;
                                alreadyValidateBottomSheet(context, true);
                              } else {
                                addPhoneNumberBottomSheet(context,
                                    number: _controllerX.whatsappNumber.value, countryCode: _controllerX.countryCodeWhatsapp.value, isWhatsapp: true);
                              }
                            },
                            child: Row(
                              children: [
                                SvgView('assets/Icons/whatsapp.svg', height: 40.w, width: 40.w),
                                SizedBox(width: 23.w),
                                Styles.regular(
                                    _controllerX.whatsappNumber.value.isNotEmpty
                                        ? '${_controllerX.countryCodeWhatsapp.value} ${_controllerX.whatsappNumber.value}'
                                        : 'phonenumber'.tr,
                                    fs: 18.sp,
                                    c: _controllerX.whatsappNumber.value.isNotEmpty ? Theme.of(context).primaryColor : ConstColors.subtitle),
                              ],
                            ),
                          ),
                          const Spacer(),
                          SvgView(
                            'assets/Icons/check.svg',
                            color: _controllerX.isWhatsapp.value ? ConstColors.lightGreenColor : ConstColors.greyButtonColor,
                            onTap: _controllerX.whatsappNumber.value.isNotEmpty
                                ? () {
                                    _controllerX.isWhatsapp.value = !_controllerX.isWhatsapp.value;
                                  }
                                : null,
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 10.h),

                    /// Instagram
                    Obx(() {
                      _controllerX.isInstagram.value;
                      return Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                addSocialMediaBottomSheet(context,
                                    id: _controllerX.instagramId,
                                    svg: 'assets/Icons/instagram.svg',
                                    title: 'insert_your_name_instagram'.tr,
                                    hintText: 'your_name_instagram'.tr,
                                    idLink: 'https://www.instagram.com/',
                                    idName: 'your_name_id'.tr, prove: (id) async {
                                  if (id.isNotEmpty) {
                                    if (id.toString().removeAllWhitespace.contains('https://www.instagram.com/')) {
                                      if (await canLaunchUrl(Uri.parse(id))) {
                                        await launchUrl(Uri.parse(id), mode: LaunchMode.externalApplication);
                                      }
                                    } else {
                                      await launchUrl(Uri.parse('${'https://www.instagram.com/'}$id'), mode: LaunchMode.externalApplication);
                                    }
                                  }
                                }, keep: (id) {
                                  if (id.isNotEmpty) {
                                    _controllerX.isInstagram.value = false;
                                    _controllerX.instagramId.text = id;
                                    _controllerX.isInstagram.value = true;
                                    Get.back();
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  SvgView('assets/Icons/instagram.svg', height: 40.w, width: 40.w),
                                  SizedBox(width: 23.w),
                                  Expanded(
                                    child: Styles.regular(
                                        _controllerX.instagramId.text.isNotEmpty ? _controllerX.instagramId.text : 'link_your_instagram'.tr,
                                        fs: 18.sp,
                                        lns: 2,
                                        c: _controllerX.instagramId.text.isNotEmpty ? Theme.of(context).primaryColor : ConstColors.subtitle),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SvgView(
                            'assets/Icons/check.svg',
                            color: _controllerX.isInstagram.value ? ConstColors.lightGreenColor : ConstColors.greyButtonColor,
                            onTap: _controllerX.instagramId.text.isNotEmpty
                                ? () {
                                    _controllerX.isInstagram.value = !_controllerX.isInstagram.value;
                                  }
                                : null,
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 10.h),

                    /// Facebook
                    Obx(() {
                      _controllerX.isFacebook.value;
                      return Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                addSocialMediaBottomSheet(context,
                                    id: _controllerX.facebookId,
                                    svg: 'assets/Icons/facebook.svg',
                                    title: 'insert_your_name_facebook'.tr,
                                    hintText: 'your_name_facebook'.tr,
                                    idLink: 'https://www.facebook.com/',
                                    idName: 'your_name_id'.tr, prove: (id) async {
                                  if (id.isNotEmpty) {
                                    if (id.toString().removeAllWhitespace.contains('https://www.facebook.com/')) {
                                      if (!await canLaunchUrl(Uri.parse(id))) {
                                        await launchUrl(Uri.parse(id), mode: LaunchMode.externalApplication);
                                      } else {
                                        await launchUrl(Uri.parse(id));
                                      }
                                    } else {
                                      await launchUrl(Uri.parse('${'https://www.facebook.com/'}$id'), mode: LaunchMode.externalApplication);
                                    }
                                  }
                                }, keep: (id) {
                                  if (id.isNotEmpty) {
                                    _controllerX.isFacebook.value = false;
                                    _controllerX.facebookId.text = id;
                                    _controllerX.isFacebook.value = true;
                                    Get.back();
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  SvgView('assets/Icons/facebook.svg', height: 40.w, width: 40.w),
                                  SizedBox(width: 23.w),
                                  Expanded(
                                    child: Styles.regular(
                                        _controllerX.facebookId.text.isNotEmpty ? _controllerX.facebookId.text : 'link_your_facebook'.tr,
                                        fs: 18.sp,
                                        lns: 2,
                                        c: _controllerX.facebookId.text.isNotEmpty ? Theme.of(context).primaryColor : ConstColors.subtitle),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SvgView(
                            'assets/Icons/check.svg',
                            color: _controllerX.isFacebook.value ? ConstColors.lightGreenColor : ConstColors.greyButtonColor,
                            onTap: _controllerX.facebookId.text.isNotEmpty
                                ? () {
                                    _controllerX.isFacebook.value = !_controllerX.isFacebook.value;
                                  }
                                : null,
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 10.h),

                    /// Telegram
                    Obx(() {
                      _controllerX.isTelegram.value;
                      return Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                addSocialMediaBottomSheet(context,
                                    id: _controllerX.telegramId,
                                    svg: 'assets/Icons/telegram.svg',
                                    title: 'insert_your_name_telegram'.tr,
                                    hintText: 'your_name_telegram'.tr,
                                    idName: 'your_name_id'.tr, prove: (id) async {
                                  if (id.toString().removeAllWhitespace.contains('https://t.me/')) {
                                    await launchUrl(Uri.parse('$id?text=${'hello_i_writing_eypop'.tr}'), mode: LaunchMode.externalApplication);
                                  } else {
                                    await launchUrl(
                                        Uri.parse(
                                            '${'https://t.me/'}${id.replaceAll('@', '').removeAllWhitespace}?text=${'hello_i_writing_eypop'.tr}'),
                                        mode: LaunchMode.externalApplication);
                                  }
                                }, keep: (id) {
                                  if (id.isNotEmpty) {
                                    _controllerX.isTelegram.value = false;
                                    _controllerX.telegramId.text = id;
                                    _controllerX.isTelegram.value = true;
                                    Get.back();
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  SvgView('assets/Icons/telegram.svg', height: 40.w, width: 40.w),
                                  SizedBox(width: 23.w),
                                  Expanded(
                                    child: Styles.regular(
                                        _controllerX.telegramId.text.isNotEmpty ? _controllerX.telegramId.text : 'nombre'.tr.toLowerCase(),
                                        fs: 18.sp,
                                        lns: 2,
                                        c: _controllerX.telegramId.text.isNotEmpty ? Theme.of(context).primaryColor : ConstColors.subtitle),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SvgView(
                            'assets/Icons/check.svg',
                            color: _controllerX.isTelegram.value ? ConstColors.lightGreenColor : ConstColors.greyButtonColor,
                            onTap: _controllerX.telegramId.text.isNotEmpty
                                ? () {
                                    _controllerX.isTelegram.value = !_controllerX.isTelegram.value;
                                  }
                                : null,
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 10.h),

                    /// OnlyFans
                    Obx(() {
                      _controllerX.isOnlyfans.value;
                      return Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                addSocialMediaBottomSheet(context,
                                    id: _controllerX.onlyfansId,
                                    svg: 'assets/Icons/onlyfans_border.svg',
                                    title: 'insert_your_name_onlyfans'.tr,
                                    hintText: 'your_name_onlyfans'.tr,
                                    idName: 'your_name_id'.tr, prove: (id) async {
                                  if (id.isNotEmpty) {
                                    if (id.toString().removeAllWhitespace.contains('https://onlyfans.com/')) {
                                      if (await canLaunchUrl(Uri.parse(id))) {
                                        await launchUrl(Uri.parse(id));
                                      }
                                    } else {
                                      await launchUrl(Uri.parse('${'https://onlyfans.com/'}${id.replaceAll('@', '').removeAllWhitespace}'));
                                    }
                                  }
                                }, keep: (id) {
                                  if (id.isNotEmpty) {
                                    _controllerX.isOnlyfans.value = false;
                                    _controllerX.onlyfansId.text = id;
                                    _controllerX.isOnlyfans.value = true;
                                    Get.back();
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  SvgView('assets/Icons/onlyfans_border.svg', height: 40.w, width: 40.w),
                                  SizedBox(width: 23.w),
                                  Expanded(
                                    child: Styles.regular(
                                        _controllerX.onlyfansId.text.isNotEmpty ? _controllerX.onlyfansId.text : 'nombre'.tr.toLowerCase(),
                                        fs: 18.sp,
                                        c: _controllerX.onlyfansId.text.isNotEmpty ? Theme.of(context).primaryColor : ConstColors.subtitle),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SvgView(
                            'assets/Icons/check.svg',
                            color: _controllerX.isOnlyfans.value ? ConstColors.lightGreenColor : ConstColors.greyButtonColor,
                            onTap: _controllerX.onlyfansId.text.isNotEmpty
                                ? () {
                                    _controllerX.isOnlyfans.value = !_controllerX.isOnlyfans.value;
                                  }
                                : null,
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 10.h),

                    /// Skype
                    Obx(() {
                      _controllerX.isSkype.value;
                      return Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                addSocialMediaBottomSheet(context,
                                    id: _controllerX.skypeId,
                                    svg: 'assets/Icons/skype.svg',
                                    title: 'insert_your_name_skype'.tr,
                                    hintText: 'your_name_skype'.tr,
                                    idName: 'live:.cid.xxxxxxxxxxxxxxxx'.tr, prove: (id) async {
                                  if (id.isNotEmpty) {
                                    try {
                                      if (id.removeAllWhitespace.contains('live:.cid.')) {
                                        final Uri url = Uri(
                                            scheme: 'skype',
                                            path: id.removeAllWhitespace,
                                            queryParameters: {'chat': 'true', 'text': 'hello_i_writing_eypop'.tr});
                                        await launchUrl(url);
                                      } else {
                                        final Uri url = Uri(
                                            scheme: 'skype',
                                            path: '${'live:.cid.'}${id.removeAllWhitespace}',
                                            queryParameters: {'chat': 'true', 'text': 'hello_i_writing_eypop'.tr});
                                        await launchUrl(url);
                                      }
                                    } catch (e) {
                                      Get.back();
                                      gradientSnackBar(
                                        context,
                                        title: 'Skype ${'Is_not_installed_on_the_device'.tr}',
                                        image: 'assets/Icons/skype_outline.svg',
                                        color1: ConstColors.darkRedColor,
                                        color2: ConstColors.redColor,
                                      );
                                    }
                                  }
                                }, keep: (id) {
                                  if (id.isNotEmpty) {
                                    _controllerX.isSkype.value = false;
                                    _controllerX.skypeId.text = id;
                                    _controllerX.isSkype.value = true;
                                    Get.back();
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  SvgView('assets/Icons/skype.svg', height: 40.w, width: 40.w),
                                  SizedBox(width: 23.w),
                                  Expanded(
                                    child: Styles.regular(
                                        _controllerX.skypeId.text.isNotEmpty ? _controllerX.skypeId.text : 'live:.cid.xxxxxxxxxxxxxxxx',
                                        fs: 18.sp,
                                        c: _controllerX.skypeId.text.isNotEmpty ? Theme.of(context).primaryColor : ConstColors.subtitle),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SvgView(
                            'assets/Icons/check.svg',
                            color: _controllerX.isSkype.value ? ConstColors.lightGreenColor : ConstColors.greyButtonColor,
                            onTap: _controllerX.skypeId.text.isNotEmpty
                                ? () {
                                    _controllerX.isSkype.value = !_controllerX.isSkype.value;
                                  }
                                : null,
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 20.h),
                    // Obx(() {
                    //   return InkWell(
                    //     onTap: () {
                    //       _controllerX.isVisible.value = !_controllerX.isVisible.value;
                    //     },
                    //     child: Container(
                    //       height: 64.h,
                    //       padding: EdgeInsets.only(left: 36.w, right: 29.w),
                    //       alignment: Alignment.center,
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(8.r),
                    //         border: Border.all(color: _controllerX.isVisible.value ? const Color(0xFFFA6363) : const Color(0xFF5EED05), width: 2.w),
                    //         gradient: LinearGradient(
                    //             colors: [
                    //               _controllerX.isVisible.value ? const Color(0xFFF597B0) : const Color(0xFF50EF50),
                    //               Theme.of(context).scaffoldBackgroundColor
                    //             ],
                    //             begin: Alignment.topCenter,
                    //             end: Alignment.bottomCenter,
                    //             stops: const [0, 1]),
                    //       ),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Styles.regular(_controllerX.isVisible.value ? 'hide_my_tiktok'.tr : 'show_my_tiktok'.tr, fs: 20.sp, ff: 'HL'),
                    //           SvgView(_controllerX.isVisible.value ? 'assets/Icons/eyeopen.svg' : 'assets/Icons/eyeclose.svg')
                    //         ],
                    //       ),
                    //     ),
                    //   );
                    // }),
                    // SizedBox(height: 9.h),
                    // Obx(() {
                    //   return Center(
                    //       child: Styles.regular(_controllerX.isVisible.value ? 'your_tiktok_visible'.tr : 'your_tiktok_hidden'.tr,
                    //           fs: 16.sp, ff: 'HB', c: _controllerX.isVisible.value ? ConstColors.lightGreenColor : ConstColors.darkRedColor));
                    // }),
                    Padding(
                      padding:  EdgeInsets.only(top: 25.h),
                      child: Obx(() {
                        _controllerX.isLoading.value;
                        return toktokController.seeTokTok.isNotEmpty
                            ? GradientButton(
                                title: 'See_TokTok'.tr,
                                color1: const Color(0xFF0028CE),
                                color2: const Color(0xFFE69791),
                                onTap: () {
                                  Get.to(() => ShowToktokScreen(seeTokTok: toktokController.seeTokTok));
                                })
                            : Padding(
                              padding:  EdgeInsets.symmetric(horizontal: 20.w),
                              child: Center(
                              child: Styles.regular('select_your_profile_photo_videos'.tr,
                                  fs: 16.sp, ff: 'HB',al: TextAlign.center,c: ConstColors.redColor)),
                            );
                      }),
                    ),
                    SizedBox(height: 20.h),
                    Obx(() {
                      if (_controllerX.isWishCreating.value) {
                        return Center(child: Lottie.asset('assets/jsons/loading_circle.json', height: 50.w, width: 50.w));
                      }
                      return GradientButton(
                        enable: _controllerX.selectedWishes.length == 3 && _controllerX.isWhen.value,
                        title: 'save_changes'.tr,
                        onTap: _controllerX.createTokTok,
                      );
                    }),
                    SizedBox(height: 30.h)

                    // Padding(
                    //     padding: EdgeInsets.only(bottom: 13.h),
                    //     child: Styles.regular('Choose_a_photo_or_video'.tr, c: Theme.of(context).primaryColor, ff: 'HR', fs: 18.sp)),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     button(
                    //         svg1: 'assets/Icons/gallery.svg',
                    //         width: 182.w,
                    //         context: context,
                    //         title: 'photo'.tr,
                    //         onTap: () {
                    //           _controllerX.fromGallery('image', context).then((value) {
                    //             if (value != null) {
                    //               Get.to(() => WishCropScreen(file: value));
                    //             }
                    //           });
                    //         }),
                    //     button(
                    //         svg1: 'assets/Icons/play-button.svg',
                    //         width: 182.w,
                    //         context: context,
                    //         title: 'video'.tr,
                    //         onTap: () {
                    //           _controllerX.fromGallery('video', context);
                    //         }),
                    //   ],
                    // ),
                    // Obx(() {
                    //   _controllerX.videoThumbFile.value;
                    //   _controllerX.pickedFile.value;
                    //   return Center(
                    //     child: Container(
                    //       padding: EdgeInsets.symmetric(vertical: 27.h),
                    //       child: _controllerX.videoThumbFile.isNotEmpty
                    //           ? Stack(
                    //         alignment: Alignment.bottomCenter,
                    //         children: [
                    //           Container(
                    //               color: Theme.of(context).primaryColor,
                    //               width: 139.w,
                    //               height: 220.h,
                    //               child: Image.file(File(_controllerX.videoThumbFile.value), fit: BoxFit.cover)),
                    //           InkWell(
                    //             onTap: () {
                    //               _controllerX.imagePick().then((value) {
                    //                 if (value != null) {
                    //                   _controllerX.videoThumbFile.value = value.path;
                    //                 }
                    //               });
                    //             },
                    //             child: Container(
                    //               height: 30.h,
                    //               width: 100.w,
                    //               margin: EdgeInsets.only(bottom: 5.h),
                    //               alignment: Alignment.center,
                    //               padding: EdgeInsets.symmetric(horizontal: 15.w),
                    //               decoration: BoxDecoration(borderRadius: BorderRadius.circular(40.r), color: Colors.black.withOpacity(0.8)),
                    //               child: Styles.regular('Edit_cover'.tr, fs: 10.sp, c: Theme.of(context).primaryColor, ff: 'HR', lns: 1),
                    //             ),
                    //           ),
                    //         ],
                    //       )
                    //           : _controllerX.pickedFile.isNotEmpty
                    //           ? Container(
                    //           color: Theme.of(context).primaryColor,
                    //           width: 139.w,
                    //           height: 220.h,
                    //           child: Image.file(File(_controllerX.pickedFile.value), fit: BoxFit.cover))
                    //           : const SizedBox.shrink(),
                    //     ),
                    //   );
                    // }),
                    // SizedBox(height: 25.h),
                  ],
                ),
              ),
            ),
            Obx(() {
              _controllerX.isLoading.value;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 375),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _controllerX.isLoading.value
                    ? Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        alignment: Alignment.center,
                        key: ValueKey<bool>(_controllerX.isLoading.value),
                        child: Lottie.asset('assets/jsons/bulleye.json', fit: BoxFit.cover, height: 250.w, width: 250.w),
                      )
                    : SizedBox.shrink(key: ValueKey<bool>(_controllerX.isLoading.value)),
              );
            })
          ],
        ));
  }

  /// add phonenumber sheet
  Future<void> addPhoneNumberBottomSheet(context, {bool isWhatsapp = false, required String number, required String countryCode}) async {
    _controllerX.telephone.value.text = number;
    _controllerX.countryCodeNumber.value = countryCode.isNotEmpty ? countryCode : '+34';
    if (_controllerX.telephone.value.text.isNotEmpty) {
      _controllerX.isValid.value = true;
    } else {
      _controllerX.isValid.value = false;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: EdgeInsets.only(top: 14.h, left: 20.w, right: 20.w, bottom: 90.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                SizedBox(height: 38.h),
                const SvgView('assets/Icons/phonewhatsapp.svg'),
                SizedBox(height: 20.h),
                Styles.regular('can_you_give_number'.tr, al: TextAlign.center, fs: 29.sp, ff: 'HB'),
                SizedBox(height: 26.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            backgroundColor: Theme.of(context).dialogBackgroundColor,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
                            context: context,
                            builder: (BuildContext c) {
                              return DraggableScrollableSheet(
                                initialChildSize: 0.6,
                                expand: false,
                                maxChildSize: 0.8,
                                minChildSize: 0.2,
                                builder: (context, scrollController) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 25.h),
                                        Container(height: 1.h, width: 58.w, color: ConstColors.bottomBorder),
                                        SizedBox(height: 10.h),
                                        Styles.regular('Choose_country'.tr, fs: 18.sp, ff: 'HB', c: Theme.of(context).primaryColor),
                                        SizedBox(height: 28.h),
                                        _controllerX.apiResponse != null && _controllerX.apiResponse!.results != null
                                            ? Expanded(
                                                child: ListView.separated(
                                                  itemCount: _controllerX.apiResponse!.results!.length,
                                                  shrinkWrap: true,
                                                  controller: scrollController,
                                                  separatorBuilder: (context, index) => SizedBox(height: 17.h),
                                                  itemBuilder: (context, index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        _controllerX.countryCodeNumber.value = _controllerX.apiResponse!.results![index]['DialCode'];
                                                        Get.back();
                                                      },
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 45.w,
                                                            child: Styles.regular(_controllerX.apiResponse!.results![index]['DialCode'],
                                                                fs: 18.sp, c: Theme.of(context).primaryColor),
                                                          ),
                                                          SizedBox(width: 27.w),
                                                          Styles.regular(_controllerX.apiResponse!.results![index]['Name'],
                                                              fs: 18.sp, c: Theme.of(context).primaryColor, ff: 'HB'),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Center(child: CircularProgressIndicator(color: ConstColors.themeColor))
                                      ],
                                    ),
                                  );
                                },
                              );
                            });
                      },
                      child: Obx(() {
                        return TextFieldModel(
                          containerColor: Colors.transparent,
                          width: 88.w,
                          borderColor: Theme.of(context).primaryColor,
                          color: Theme.of(context).primaryColor,
                          enabled: false,
                          controllers: TextEditingController(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 18.w),
                          textAlign: TextAlign.center,
                          hint: _controllerX.countryCodeNumber.value,
                          hintTextColor: Theme.of(context).primaryColor,
                          hintTextSize: 18.sp,
                        );
                      }),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: TextFieldModel(
                        containerColor: Colors.transparent,
                        borderColor: Theme.of(context).primaryColor,
                        color: Theme.of(context).primaryColor,
                        cursorColor: Theme.of(context).primaryColor,
                        textInputAction: TextInputAction.done,
                        controllers: _controllerX.telephone.value,
                        contentPadding: EdgeInsets.symmetric(horizontal: 18.w),
                        hint: '',
                        onChanged: (v) {
                          if (v.length < 5 || v.length > 12 || v.isEmpty) {
                            _controllerX.isValid.value = false;
                          } else {
                            _controllerX.isValid.value = true;
                          }
                        },
                        textInputType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Styles.regular('Your_Number_Text'.tr, fs: 15.sp, al: TextAlign.center),
                SizedBox(height: 40.h),
                Obx(() {
                  _controllerX.isValid.value;

                  return Center(
                      child: GradientButton(
                          title: 'Sendcode'.tr,
                          width: MediaQuery.sizeOf(context).width,
                          onTap: () async {
                            if (_controllerX.telephone.value.text.isNotEmpty) {
                              await _controllerX.verifyPhone(_controllerX.countryCodeNumber.value + _controllerX.telephone.value.text, context);

                              /// otp bottomsheet open
                              addOTPBottomSheet(context, isWhatsapp);
                            }
                          },
                          enable: _controllerX.isValid.value));
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  /// OTP sheet
  Future<void> addOTPBottomSheet(context, bool isWhatsapp) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: EdgeInsets.only(top: 14.h, left: 20.w, right: 20.w, bottom: 60.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                SizedBox(height: 38.h),
                const SvgView('assets/Icons/phonewhatsapp.svg'),
                SizedBox(height: 20.h),
                Styles.regular('we_have_sent_sms_code'.tr, al: TextAlign.center, fs: 24.sp, ff: 'HB'),
                SizedBox(height: 14.h),
                Styles.regular('enter_the_code_below_verify'.tr, al: TextAlign.center, c: Theme.of(context).primaryColor, fs: 14.sp, ff: 'RR'),
                SizedBox(height: 18.h),
                PinCodeTextField(
                    autoDisposeControllers: false,
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    enableActiveFill: true,
                    obscuringCharacter: '*',
                    onChanged: (String value) {
                      _controllerX.otp.value = value;
                    },
                    onCompleted: (String otp) async {
                      _controllerX.otp.value = otp;
                      _controllerX.isLoadingOTP.value = true;
                      await _controllerX.verifyOtp(context).then((success) {
                        print('PHONE-NUMBER AUTH *** $success isWhatsapp $isWhatsapp');
                        if (success) {
                          if (isWhatsapp) {
                            _controllerX.whatsappNumber.value = _controllerX.telephone.value.text;
                            _controllerX.countryCodeWhatsapp.value = _controllerX.countryCodeNumber.value;
                            _controllerX.phoneNumberDate.value = DateTime.now();
                            _controllerX.isWhatsapp.value = true;
                            _controllerX.telephone.value.clear();
                            _controllerX.countryCodeNumber.value = '+34';
                          } else {
                            _controllerX.telephoneNumber.value = _controllerX.telephone.value.text;
                            _controllerX.countryCodeTelephone.value = _controllerX.countryCodeNumber.value;
                            _controllerX.phoneNumberDate.value = DateTime.now();
                            _controllerX.isTelephone.value = true;
                            _controllerX.telephone.value.clear();
                            _controllerX.countryCodeNumber.value = '+34';
                          }
                          Get.back();
                          Get.back();
                        } else {
                          print('PHONE-NUMBER AUTH **** error $success isWhatsapp $isWhatsapp');
                          gradientSnackBar(context,
                              image: 'assets/Icons/call_outline.svg',
                              title: 'Invalid_otp'.tr,
                              color1: ConstColors.darkRedBlackColor,
                              color2: ConstColors.redColor);
                        }
                        _controllerX.isLoadingOTP.value = false;
                      });
                    },
                    cursorColor: Theme.of(context).primaryColor,
                    keyboardType: TextInputType.number,
                    autoFocus: true,
                    textStyle: TextStyle(color: Theme.of(context).primaryColor, fontSize: 15.sp / MediaQuery.of(context).textScaler.scale(1)),
                    pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        activeFillColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        fieldHeight: 57.h,
                        fieldWidth: 57.h,
                        selectedColor: ConstColors.grey.withOpacity(0.5),
                        activeColor: ConstColors.grey.withOpacity(0.5),
                        inactiveColor: ConstColors.grey.withOpacity(0.5),
                        selectedFillColor: Colors.transparent,
                        inactiveFillColor: Colors.transparent)),
                SizedBox(height: 14.h),
                Obx(() {
                  return Center(
                    child: Styles.regular(
                      '00:${_controllerX.start.value.toString().padLeft(2, "0")}',
                      fs: 18.sp,
                      ff: 'RM',
                      c: ConstColors.grey,
                    ),
                  );
                }),
                Obx(() => Center(
                    child: Styles.regular(_controllerX.countryCodeNumber.value + _controllerX.telephone.value.text,
                        ff: 'RM', c: ConstColors.grey, fs: 18.sp))),
                SizedBox(height: 18.h),
                Obx(() {
                  return _controllerX.isLoadingOTP.value
                      ? Lottie.asset("assets/jsons/loading_circle.json", height: 82.w, width: 82.w)
                      : const SizedBox.shrink();
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  /// already validate phone number
  Future<void> alreadyValidateBottomSheet(context, bool isWhatsapp) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: EdgeInsets.only(top: 14.h, bottom: 75.h, left: 50.w, right: 50.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                SizedBox(height: 14.h),
                const SvgView('assets/Icons/phonewhatsapp.svg'),
                SizedBox(height: 21.h),
                Styles.regular('your_number_already_validated'.tr, ff: 'HB', fs: 20.sp, c: Theme.of(context).primaryColor),
                SizedBox(height: 21.h),
                Styles.regular('${_controllerX.countryCodeNumber.value} ${_controllerX.telephone.value.text}'.tr,
                    fs: 20.sp, c: ConstColors.themeColor),
                SizedBox(height: 20.h),
                Styles.regular("${'to_validate_another_number'.tr} ${DateFormat('dd/MM/yyyy').format(DateTime.now().add(const Duration(days: 1)))}",
                    fs: 18.sp, c: Theme.of(context).primaryColor),
                SizedBox(height: 21.h),
                GradientButton(
                    title: 'ok'.tr,
                    onTap: () {
                      Get.back();
                    }),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Add Social Media Id
  Future<void> addSocialMediaBottomSheet(context,
      {required TextEditingController id,
      required String svg,
      required String title,
      required String hintText,
      String? idLink,
      required String idName,
      required Function(String reason) prove,
      required Function(String reason) keep}) async {
    final TextEditingController textController = TextEditingController(text: id.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: EdgeInsets.only(top: 14.h, bottom: 40.h, left: 50.w, right: 50.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                SizedBox(height: 38.h),
                SvgView(svg, height: 54.w, width: 54.w),
                SizedBox(height: 7.h),
                Styles.regular(title, fs: 19.sp),
                SizedBox(height: 20.h),
                TextFieldModel(
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                    hint: hintText,
                    textInputAction: TextInputAction.done,
                    color: Theme.of(context).primaryColor,
                    cursorColor: Theme.of(context).primaryColor,
                    borderColor: Theme.of(context).primaryColor,
                    containerColor: Colors.transparent,
                    textInputType: TextInputType.text,
                    controllers: textController),
                SizedBox(height: 4.h),
                RichText(
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: idLink,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: ConstColors.subtitle,
                        ),
                        children: [
                          TextSpan(
                            text: idName,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextSpan(
                            text: idLink != null ? '/' : null,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: ConstColors.subtitle,
                            ),
                          ),
                        ])),
                SizedBox(height: 26.h),
                GradientButton(
                    title: 'prove'.tr,
                    color1: const Color(0xFF3347E3),
                    color2: const Color(0xFFE69791),
                    onTap: () {
                      prove(textController.text);
                    }),
                SizedBox(height: 12.h),
                GradientButton(
                    title: 'keep'.tr,
                    onTap: () {
                      keep(textController.text);
                    }),
                SizedBox(height: 12.h),
                InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Styles.regular('Cancel'.tr, fs: 16.sp, c: ConstColors.themeColor.withOpacity(0.8))),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Add wishes
  Future<void> addWishesBottomSheet(context) async {
    showModalBottomSheet<void>(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r)),
      ),
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          expand: false,
          maxChildSize: 0.8,
          minChildSize: 0.2,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(top: 14.h),
              child: Column(
                children: [
                  Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                  SizedBox(height: 9.h),
                  Styles.regular('add_up_3_interests'.tr, ff: 'HB', fs: 18.sp, c: Theme.of(context).primaryColor),
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Divider(
                      height: 1.h,
                      color: ConstColors.bottomBorder,
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      final String local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
                      _controllerX.selectedWishes.value;
                      if (_controllerX.allWishes.isNotEmpty) {
                        return ListView.separated(
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          controller: scrollController,
                          padding: EdgeInsets.only(left: 25.w, right: 25.w, top: 5.h, bottom: 25.h),
                          itemCount: _controllerX.allWishes.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                if (_controllerX.selectedWishes.toString().contains(_controllerX.allWishes[index]['objectId'])) {
                                  _controllerX.selectedWishes.removeWhere((item) => item['objectId'] == _controllerX.allWishes[index]['objectId']);
                                } else {
                                  if (_controllerX.selectedWishes.length < 3) {
                                    _controllerX.selectedWishes.add(_controllerX.allWishes[index]);
                                  }
                                }
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 50.w,
                                      child: SvgPicture.network(
                                        _controllerX.allWishes[index]['Svg_Icon'].url,
                                        height: 30.w,
                                        width: 30.w,
                                        color: ConstColors.themeColor,
                                        fit: BoxFit.scaleDown,
                                      )),
                                  SizedBox(width: 20.w),
                                  Styles.regular(_controllerX.allWishes[index][local].toString().trim(),
                                      fs: 18.sp, c: Theme.of(context).primaryColor),
                                  const Spacer(),
                                  SvgPicture.asset('assets/Icons/check.svg',
                                      color: _controllerX.selectedWishes.toString().contains(_controllerX.allWishes[index]['objectId'])
                                          ? ConstColors.themeColor
                                          : ConstColors.greyButtonColor)
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 12.h);
                          },
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(color: ConstColors.themeColor),
                        );
                      }
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
