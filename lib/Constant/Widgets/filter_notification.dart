import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/PairNotificationController/pair_notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AllFilters extends StatelessWidget {
  const AllFilters({Key? key, required this.onTap, required this.title, required this.filter}) : super(key: key);
  final Function(String) onTap;
  final String title;
  final String filter;

  @override
  Widget build(BuildContext context) {
    final FilterModel filters = filterSwitch(title, context);
    return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 20.h, right: 20.w, top: 10.h, bottom: 30.h),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(40.r), bottomLeft: Radius.circular(40.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      onTap('filter1');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      margin: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          filters.filter1svg,
                          SizedBox(width: 22.w),
                          Styles.regular(filters.filter1, c: Theme.of(context).primaryColor, fs: 18.sp, al: TextAlign.center),
                          if (filter.contains('filter1')) ...[
                            const Spacer(),
                            SvgView("assets/Icons/check.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor)
                          ]
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      onTap('filter2');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      margin: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          filters.filter2svg,
                          SizedBox(width: 22.w),
                          Styles.regular(filters.filter2, c: Theme.of(context).primaryColor, fs: 18.sp, al: TextAlign.center),
                          if (filter.contains('filter2')) ...[
                            const Spacer(),
                            SvgView("assets/Icons/check.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor)
                          ]
                        ],
                      ),
                    ),
                  ),
                  if (title == 'Llamadas' || title == 'Videollamada') ...[
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        onTap('filter3');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        margin: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            SvgView("assets/Icons/call_miss.svg", width: 26.w, fit: BoxFit.scaleDown, color: Theme.of(context).primaryColor),
                            SizedBox(width: 22.w),
                            Styles.regular("Missed_received".tr, c: Theme.of(context).primaryColor, fs: 18.sp, al: TextAlign.center),
                            if (filter.contains('filter3')) ...[
                              const Spacer(),
                              SvgView("assets/Icons/check.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor)
                            ]
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        onTap('filter4');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        margin: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            SvgView("assets/Icons/cancel.svg", width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.redColor),
                            SizedBox(width: 22.w),
                            Styles.regular("Busy_responding".tr, c: Theme.of(context).primaryColor, fs: 18.sp, al: TextAlign.center),
                            if (filter.contains('filter4')) ...[
                              const Spacer(),
                              SvgView("assets/Icons/check.svg", height: 26.w, width: 26.w, fit: BoxFit.scaleDown, color: ConstColors.themeColor)
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 15.h),
                  GradientButton(
                    onTap: () {
                      Get.back();
                      onTap('all');
                    },
                    title: "View_all".tr,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

// Future filterNotification(
//     {required BuildContext context,
//     required VoidCallback? inComingOnTap,
//     required VoidCallback? outGoingOnTap,
//     required VoidCallback? allOnTap,
//     required String inComingTitle,
//     required String outGoingTitle,
//     required String type,
//     required String allTitle}) {
//   return showModalBottomSheet(
//     backgroundColor: Colors.transparent,
//     context: context,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30.r), topRight: Radius.circular(30.r))),
//     builder: (BuildContext context1) {
//       return Container(
//           height: 316.h,
//           padding: EdgeInsets.only(top: 16.h),
//           decoration:
//               BoxDecoration(color: bottomColor(), borderRadius: BorderRadius.only(topLeft: Radius.circular(10.r), topRight: Radius.circular(10.r))),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SvgPicture.asset('assets/Icons/Line.svg'),
//               SizedBox(height: 20.h),
//               Styles.regular('Select_an_option'.tr, c: Theme.of(context).primaryColor, fs: 20.sp, al: TextAlign.center),
//               // Divider(color: const Color(0xFFE5E5E5), height: 1.0.w),
//               GestureDetector(
//                 onTap: inComingOnTap,
//                 child: Container(
//                   width: 397.w,
//                   height: 52.w,
//                   margin: EdgeInsets.only(bottom: 15.0.h, top: 25.0.h),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: type == 'inComing' ? const Color(0xffB4B4B4) : ConstColors.themeColor,
//                     borderRadius: BorderRadius.circular(10.0.r),
//                   ),
//                   child: Center(child: Styles.regular(inComingTitle, c: Colors.white, fs: 20.sp, al: TextAlign.center)),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: outGoingOnTap,
//                 child: Container(
//                   width: 397.w,
//                   height: 52.w,
//                   margin: EdgeInsets.only(bottom: 15.0.h),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: type == 'outGoing' ? const Color(0xffB4B4B4) : ConstColors.themeColor,
//                     borderRadius: BorderRadius.circular(10.0.r),
//                   ),
//                   child: Center(
//                     child: Styles.regular(outGoingTitle, c: Colors.white, fs: 20.sp, al: TextAlign.center),
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: allOnTap,
//                 child: Container(
//                   width: 397.w,
//                   height: 52.w,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: type.isEmpty ? const Color(0xffB4B4B4) : ConstColors.themeColor,
//                     borderRadius: BorderRadius.circular(10.0.r),
//                   ),
//                   child: Styles.regular(allTitle, fs: 15, c: Colors.white),
//                 ),
//               ),
//             ],
//           ));
//     },
//   );
// }
