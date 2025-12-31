import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/post_view.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

final UserController _userController = Get.put(UserController());

Future<void> bottomProfile(
    {context, required String profileImage, required String name, required String location, required List languageList, required String description, required String countryCode}) {
  return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageView(
                    profileImage,
                    height: 54.w,
                    width: 54.w,
                    circle: true,alignment: Alignment.topCenter,
                    border: Border.all(color: ConstColors.themeColor, width: 1.w),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Styles.regular(name, fs: 18.sp, lns: 2, ff: "HB")),
                            SizedBox(
                              height: 20.w,
                              child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: languageList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, ind) {
                                    List myLang = [];
                                    for (final language in languageList) {
                                      for (final element in _userController.langList) {
                                        if (language['objectId'] == element['ObjectId']) {
                                          myLang.add(element);
                                        }
                                      }
                                    }
                                    return Container(
                                      height: 35.h,
                                      width: 35.h,
                                      decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                                      child: Image.network(myLang[ind]['image']!, height: 20.w, width: 20.w),
                                    );
                                  }),
                            )
                          ],
                        ),
                        Styles.regular(location, fs: 18.sp, lns: 2),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 9.h),
              Align(
                alignment: Alignment.topLeft,
                child: Styles.regular(description, fs: 18.sp, c: ConstColors.bottomBorder, al: TextAlign.start, lns: 8, ov: TextOverflow.ellipsis),
              ),
              SizedBox(height: 54.h),
            ],
          ),
        );
      });
}

void chatGiftSheet(context, {required List<ParseObject> giftsList, required Function(ParseObject) onTap}) {
  final RxInt selectedIndex = 0.obs;
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(top: 12.h, right: 14.w, left: 14.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 2.h,
              width: 58.w,
              decoration: BoxDecoration(color: ConstColors.offlineColor, borderRadius: BorderRadius.circular(2.r)),
            ),
            SizedBox(height: 14.h),
            Styles.regular('Send_gifts'.tr, ff: 'HB', fs: 18.sp),
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Styles.regular('Send_gifts_text'.tr, fs: 18.sp, al: TextAlign.center),
            ),
            SizedBox(height: 14.h),
            Container(
              height: 178.w,
              alignment: Alignment.centerLeft,
              child: ListView.separated(
                itemCount: giftsList.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (StorageService.getBox.read('Gender') == 'male') {
                        selectedIndex.value = index;
                      } else {
                        if ((giftsList[index]['FreeForWoman'] ?? false)) {
                          selectedIndex.value = index;
                        }
                      }
                    },
                    child: Container(
                      height: MediaQuery.sizeOf(context).height,
                      width: 119.w,
                      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(10.r)),
                      child: Column(
                        children: [
                          SizedBox(height: 7.h),
                          ImageView(
                            giftsList[index]['Image'].url,
                            height: 89.w,
                            width: 89.w,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          SizedBox(height: 7.h),
                          Styles.regular(giftsList[index][StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode],
                              fs: 14.sp, c: Theme.of(context).primaryColor),
                          const Spacer(),
                          Divider(color: Theme.of(context).primaryColor, height: 2.h),
                          Obx(() {
                            selectedIndex.value;
                            return Container(
                              height: 45.w,
                              decoration: BoxDecoration(
                                  color: selectedIndex.value == index ? const Color(0xff88FA9A) : ConstColors.grey,
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(9.r), bottomRight: Radius.circular(9.r))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Styles.regular('${giftsList[index]['Stars']}', fs: 18.sp, c: Colors.black),
                                  SizedBox(width: 10.w),
                                  SvgView('assets/Icons/coin.svg', color: ConstColors.themeColor),
                                ],
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(width: 10.w),
              ),
            ),
            SizedBox(height: 23.h),
            Obx(() {
              selectedIndex.value;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: GradientButton(
                    title: 'Send_gift'.tr,
                    onTap: () {
                      Get.back();
                      onTap(giftsList[selectedIndex.value]);
                    }),
              );
            }),
            SizedBox(height: 40.h),
          ],
        ),
      );
    },
  );
}

void deleteItemSheet(context, {VoidCallback? onTap, String? title}) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (context) {
      return SizedBox(
        height: 201.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 27.h),
          child: Column(
            children: [
              GradientButton(title: title ?? 'Delete'.tr, onTap: onTap),
              SizedBox(height: 32.h),
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Styles.regular('Cancel'.tr.toUpperCase(), ff: 'HB', fs: 18.sp),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class CustomPopupRoute extends PopupRoute {
  final Duration duration;
  final Curve curve;
  final Widget child;
  final Color? color;

  CustomPopupRoute({this.duration = const Duration(milliseconds: 600), this.curve = Curves.ease, required this.child, this.color});

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        // Close the popup
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          // open bottom sheet from bottom
          // position: Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: curve)),
          // open bottom sheet from top
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: curve)),
          child: Material(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40.r), bottomRight: Radius.circular(40.r))),
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
    return FadeTransition(opacity: curvedAnimation, child: child);
  }
}

Future<void> showBottomSheetAudioVideoCall(context,
    {required String title,
    required String callTitle,
    required String description,
    required bool isOnline,
    required VoidCallback askPermissionOnTap,
    required VoidCallback callOnTap}) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).dialogBackgroundColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(top: 16.h, left: 20.w, right: 20.w, bottom: MediaQuery.of(context).padding.bottom + 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
            SizedBox(height: 12.h),
            Styles.regular(title, c: Theme.of(context).primaryColor, ff: 'HB', fs: 18.sp),
            SizedBox(height: 19.h),
            if (isOnline) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Styles.regular('Be_nice_person'.tr, c: Theme.of(context).primaryColor, fs: 18.sp, al: TextAlign.center),
              ),
              SizedBox(height: 30.h),
              GradientButton(title: title, onTap: callOnTap),
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Styles.regular('dont_rush'.tr, c: Theme.of(context).primaryColor, fs: 18.sp, al: TextAlign.center),
              ),
              SizedBox(height: 30.h),
              GradientButton(title: 'go_ask_permission'.tr, onTap: askPermissionOnTap),
              SizedBox(height: 27.h),
              InkWell(onTap: callOnTap, child: Styles.regular(callTitle, al: TextAlign.center, c: ConstColors.redColor, fs: 18.sp, ff: 'HB')),
            ],
            SizedBox(height: 19.h),
            // only male side show this text
            if (StorageService.getBox.read('Gender') == 'male')
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Styles.regular(description, c: ConstColors.bottomBorder, fs: 16.sp, al: TextAlign.center),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showBottomSheetBlockReport(context,
    {VoidCallback? blockOnTap, required Function(String reason, String moreReason) informOnTap, required Function(String reason, String moreReason) bothOnTap}) async {
  String? reportText;
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
    backgroundColor: Theme.of(context).dialogBackgroundColor,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(top: 14.h, left: 20.w, right: 20.w, bottom: 50.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 58.w, height: 2.h, decoration: BoxDecoration(color: ConstColors.closeColor, borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 11.h),
            Styles.regular('you_are_sure'.tr, ff: 'HB', fs: 18.sp, c: Theme.of(context).primaryColor),
            SizedBox(height: 15.h),
            Divider(height: 0.5.h, color: ConstColors.bottomBorder),
            SizedBox(height: 7.h),
            Styles.regular('block_this_profile_text'.tr, al: TextAlign.center, fs: 16.sp, c: Theme.of(context).primaryColor.withOpacity(0.6)),
            Styles.regular('report_if_you_think'.tr, al: TextAlign.center, fs: 16.sp, c: Theme.of(context).primaryColor.withOpacity(0.6)),
            SizedBox(height: 36.h),
            GradientButton(
                title: 'inform'.tr,
                onTap: () {
                  for (var element in reportData) {
                    element.isSelected = false;
                  }
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
                    backgroundColor: Theme.of(context).dialogBackgroundColor,
                    builder: (context) {
                      return DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        expand: false,
                        maxChildSize: 0.8,
                        minChildSize: 0.2,
                        builder: (context, scrollController) {
                          return SingleChildScrollView(
                            controller: scrollController,
                            child: StatefulBuilder(builder: (context, setState) {
                              return Padding(
                                padding: EdgeInsets.only(top: 14.h, left: 20.w, right: 20.w, bottom: 50.h),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 58.w, height: 2.h, decoration: BoxDecoration(color: ConstColors.closeColor, borderRadius: BorderRadius.circular(2.r))),
                                    SizedBox(height: 11.h),
                                    Styles.regular('inform'.tr.toUpperCase(), ff: 'HB', fs: 18.sp, c: Theme.of(context).primaryColor),
                                    SizedBox(height: 15.h),
                                    Divider(height: 0.5.h, color: ConstColors.bottomBorder),
                                    SizedBox(height: 7.h),
                                    Styles.regular('together_we_can_safe_community'.tr, al: TextAlign.center, fs: 16.sp, c: Theme.of(context).primaryColor.withOpacity(0.6)),
                                    SizedBox(height: 40.h),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: reportData.length,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              for (var element in reportData) {
                                                element.isSelected = false;
                                              }
                                              reportData[index].isSelected = true;
                                              reportText = reportData[index].text;
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              SvgView(reportData[index].svg, fit: BoxFit.scaleDown, width: 28.w, color: Theme.of(context).primaryColor),
                                              SizedBox(width: 15.w),
                                              Styles.regular(reportData[index].text, fs: 18.sp, c: Theme.of(context).primaryColor),
                                              const Spacer(),
                                              SvgView('assets/Icons/check.svg', color: reportData[index].isSelected ? ConstColors.maroonColor : ConstColors.greyButtonColor)
                                            ],
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return SizedBox(height: 10.h);
                                      },
                                    ),
                                    SizedBox(height: 20.h),
                                    GradientButton(
                                        title: 'continue'.tr,
                                        enable: reportText != null,
                                        onTap: () {
                                          final TextEditingController reportTextController = TextEditingController();

                                          showModalBottomSheet<void>(
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r)),
                                            ),
                                            backgroundColor: Theme.of(context).dialogBackgroundColor,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return Padding(
                                                  padding: MediaQuery.of(context).viewInsets,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(top: 15.h, left: 20.w, right: 20.w, bottom: 50.h),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                            width: 58.w,
                                                            height: 2.h,
                                                            decoration: BoxDecoration(color: ConstColors.closeColor, borderRadius: BorderRadius.circular(2.r))),
                                                        SizedBox(height: 11.h),
                                                        Styles.regular('report_block'.tr, ff: 'HB', fs: 18.sp, c: Theme.of(context).primaryColor),
                                                        SizedBox(height: 15.h),
                                                        Divider(height: 0.5.h, color: ConstColors.bottomBorder),
                                                        SizedBox(height: 7.h),
                                                        Styles.regular('in_order_more_effectively'.tr,
                                                            al: TextAlign.center, fs: 16.sp, c: Theme.of(context).primaryColor.withOpacity(0.6)),
                                                        SizedBox(height: 28.h),
                                                        TextFieldModel(
                                                          containerColor: Colors.transparent,
                                                          color: Theme.of(context).primaryColor,
                                                          minLine: 4,
                                                          maxLine: 5,
                                                          textInputAction: TextInputAction.done,
                                                          borderColor: Theme.of(context).primaryColor,
                                                          cursorColor: Theme.of(context).primaryColor,
                                                          controllers: reportTextController,
                                                          hint: 'write_the_reason'.tr,
                                                        ),
                                                        SizedBox(height: 14.h),
                                                        GradientButton(
                                                            title: 'just_inform'.tr,
                                                            onTap: () {
                                                              informOnTap(reportText!, reportTextController.text);
                                                            }),
                                                        SizedBox(height: 16.h),
                                                        GradientButton(
                                                            title: 'report_and_block'.tr,
                                                            color1: ConstColors.black,
                                                            color2: ConstColors.lightRedColor,
                                                            onTap: () {
                                                              bothOnTap(reportText!, reportTextController.text);
                                                            }),
                                                        SizedBox(height: 22.h),
                                                        InkWell(
                                                            onTap: () {
                                                              /// bottomsheet 3 cancel
                                                              Get.back();
                                                              Get.back();
                                                              Get.back();
                                                            },
                                                            child: Styles.regular('Cancel'.tr, fs: 18.sp, c: ConstColors.themeColor)),
                                                      ],
                                                    ),
                                                  ));
                                            },
                                          );
                                        }),
                                    SizedBox(height: 22.h),
                                    InkWell(
                                        onTap: () {
                                          /// bottomsheet 2 cancel
                                          Get.back();
                                          Get.back();
                                        },
                                        child: Styles.regular('Cancel'.tr, fs: 18.sp, c: ConstColors.themeColor)),
                                  ],
                                ),
                              );
                            }),
                          );
                        },
                      );
                    },
                  );
                }),
            SizedBox(height: 16.h),
            GradientButton(title: 'Block'.tr, color1: ConstColors.black, color2: ConstColors.lightRedColor, onTap: blockOnTap),
            SizedBox(height: 22.h),
            InkWell(
                onTap: () {
                  /// bottomsheet 1 cancel
                  Get.back();
                },
                child: Styles.regular('Cancel'.tr, fs: 18.sp, c: ConstColors.themeColor)),
          ],
        ),
      );
    },
  );
}
