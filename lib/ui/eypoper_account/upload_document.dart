import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/bankdetails_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class UploadDocuments extends GetView {
  const UploadDocuments({Key? key}) : super(key: key);
  static BankDetailsController get _bc => Get.find<BankDetailsController>();

  @override
  Widget build(BuildContext context) {
    final bool isPassport = _bc.selectDoc >= 2;
    _bc.docType.value = _bc.documentList[_bc.selectDoc.value]['id'];
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 28.w, width: 28.w),
          title: Styles.regular("Document".tr, c: ConstColors.closeColor, fs: 31.sp),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPassport)
                  Styles.regular('National_Passport_Attach'.tr, c: Theme.of(context).primaryColor, fw: FontWeight.bold, fs: 18.sp, ff: "HB", key: const ValueKey(0))
                else
                  Styles.regular('National_Document_Attach'.tr, c: Theme.of(context).primaryColor, fw: FontWeight.bold, fs: 18.sp, ff: "HB", key: const ValueKey(1)),
                SizedBox(height: 11.h),
                Styles.regular('${'Side'.tr} A', c: Theme.of(context).primaryColor, fs: 16.sp),
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topRight,
                  children: [
                    InkWell(
                      onTap: () async {
                        await _bc.uploadDocs().then((value) {
                          if (value != null) {
                            _bc.selectDocList
                                .update('A', (x) => {'Path': value.path, 'Save': false, 'Type': "File"}, ifAbsent: () => {'Path': value.path, 'Save': false, 'Type': "File"});
                          }
                        });
                      },
                      child: Obx(() {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 375),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: _bc.selectDocList['A'] == null
                              ? Container(
                                  key: const ValueKey(0),
                                  height: isPassport ? 416.h : 240.h,
                                  width: MediaQuery.sizeOf(context).width,
                                  margin: EdgeInsets.only(top: 23.h),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).dialogBackgroundColor,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.6)),
                                  ),
                                  child: Styles.regular('A', c: Theme.of(context).primaryColor.withOpacity(0.3), fs: 110.sp, ff: "HB", fw: FontWeight.bold),
                                )
                              : Container(
                                  key: const ValueKey(1),
                                  height: isPassport ? 416.h : 240.h,
                                  width: MediaQuery.sizeOf(context).width,
                                  margin: EdgeInsets.only(top: 23.h),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.6)),
                                      image: DecorationImage(
                                        // Type [Net] when user come second time
                                        // Type [File] when user upload document first time
                                          image: (_bc.selectDocList['A']['Type'].toString().contains('Net')
                                              ? NetworkImage(_bc.selectDocList['B']['Path'])
                                              : FileImage(File(_bc.selectDocList['A']['Path']))) as ImageProvider,
                                          fit: BoxFit.cover)),
                                ),
                        );
                      }),
                    ),
                    Positioned(
                        top: 0,
                        right: 11.w,
                        child: SvgView(
                          'assets/Icons/cancel_document.svg',
                          height: 33.w,
                          width: 33.w,
                          fit: BoxFit.scaleDown,
                          color: Theme.of(context).primaryColor,
                          onTap: () {
                            if (_bc.selectDocList['A'] != null) {
                              _bc.selectDocList.remove('A');
                            }
                          },
                        )),
                  ],
                ),
                if (!isPassport) ...[
                  SizedBox(height: 11.h),
                  Styles.regular('${'Side'.tr} B', c: Theme.of(context).primaryColor, fs: 16.sp),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topRight,
                    children: [
                      InkWell(
                        onTap: () async {
                          await _bc.uploadDocs().then((value) {
                            if (value != null) {
                              _bc.selectDocList
                                  .update('B', (x) => {'Path': value.path, 'Save': false, 'Type': "File"}, ifAbsent: () => {'Path': value.path, 'Save': false, 'Type': "File"});
                            }
                          });
                        },
                        child: Obx(() {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 375),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: _bc.selectDocList['B'] == null
                                ? Container(
                                    key: const ValueKey(0),
                                    height: isPassport ? 416.h : 240.h,
                                    width: MediaQuery.sizeOf(context).width,
                                    margin: EdgeInsets.only(top: 23.h),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).dialogBackgroundColor,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.6)),
                                    ),
                                    child: Styles.regular('B', c: Theme.of(context).primaryColor.withOpacity(0.3), fs: 110.sp, ff: "HB", fw: FontWeight.bold),
                                  )
                                : Container(
                                    key: const ValueKey(1),
                                    height: isPassport ? 416.h : 240.h,
                                    width: MediaQuery.sizeOf(context).width,
                                    margin: EdgeInsets.only(top: 23.h),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.6)),
                                      image: DecorationImage(
                                        // Type [Net] when user come second time
                                        // Type [File] when user upload document first time
                                          image: (_bc.selectDocList['B']['Type'].toString().contains('Net')
                                              ? NetworkImage(_bc.selectDocList['B']['Path'])
                                              : FileImage(File(_bc.selectDocList['B']['Path']))) as ImageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                          );
                        }),
                      ),
                      Positioned(
                          top: 0,
                          right: 11.w,
                          child: SvgView(
                            'assets/Icons/cancel_document.svg',
                            height: 33.w,
                            width: 33.w,
                            fit: BoxFit.scaleDown,
                            color: Theme.of(context).primaryColor,
                            onTap: () {
                              if (_bc.selectDocList['B'] != null) {
                                _bc.selectDocList.remove('B');
                              }
                            },
                          )),
                    ],
                  ),
                ],
                SizedBox(height: 35.h),
                Obx(() {
                  _bc.selectDocList;
                  return GradientButton(
                      enable: isPassport ? _bc.selectDocList.keys.isNotEmpty : _bc.selectDocList.keys.length == 2,
                      onTap: () {
                        _bc.selectDocList.forEach((key, value) {
                          if (!value['Save']) {
                            value['Save'] = true;
                          }
                        });
                        _bc.selectDocList.refresh();
                        Get.back();
                      },
                      title: 'ACCEPT_SEND'.tr,
                      fontSize: 18.sp);
                }),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ));
  }
}
