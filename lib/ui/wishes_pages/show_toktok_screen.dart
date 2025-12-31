// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Constant/translate.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/wishes_pages/toktokvideo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../Controllers/wish_controllers/create_wish_controller.dart';

class ShowToktokScreen extends StatelessWidget {
  ShowToktokScreen({Key? key, required this.seeTokTok}) : super(key: key);
  List seeTokTok = [];

  static CreateWishController get controllerX => Get.find();

  @override
  Widget build(BuildContext context) {
    String local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
    String localeFlag = SchedulerBinding.instance.platformDispatcher.locale.countryCode!.toLowerCase();
    return Scaffold(
      body: Stack(
        children: [
          Swiper(
            key: const ValueKey(1),
            loop: false,
            scrollDirection: Axis.vertical,
            itemCount: seeTokTok.length,
            itemBuilder: (context, i) {
              if (seeTokTok[i]['Type'].toString().contains('Image')) {
                return CachedNetworkImage(
                    imageUrl: seeTokTok[i]['Data']['Post'].url,
                    memCacheHeight: 800,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(seconds: 1),
                    placeholderFadeInDuration: const Duration(seconds: 1),
                    placeholder: (context, url) => preCachedFullScreen(UniqueKey()),
                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)));
              } else {
                return TokTokVideoScreen(videos: seeTokTok[i]['Data']);
              }
            },
          ),
          SvgView(
            "assets/Icons/cancelbutton.svg",
            height: 45.w,
            padding: EdgeInsets.only(top: 50.h, left: 15.w),
            width: 45.w,
            onTap: () {
              Get.back();
            },
          ),
          Positioned(
            bottom: 30.h,
            left: 8.w,
            right: 9.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// wish list
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(controllerX.selectedWishes.length, ((index) {
                        return WishBox(
                          svg: controllerX.selectedWishes[index]['Lottie_File'].url,
                          title: controllerX.selectedWishes[index][local],
                          isDone: false,
                          onTap: null,
                        );
                      })),
                    ),

                    /// time
                    Container(
                      height: 30.h,
                      padding: EdgeInsets.only(right: 10.w, left: 5.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        color: ConstColors.themeColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/jsons/bulleye.json', height: 28.w, width: 28.w),
                          SizedBox(width: 5.w),
                          Styles.regular(Languages().keys[local]![controllerX.wishTimeForDisplay.value] ?? Languages().keys[local]!['Tonight']!,
                              c: ConstColors.white, ov: TextOverflow.ellipsis, fs: 14.sp),
                        ],
                      ),
                    ),
                  ],
                ),

                Column(
                  children: [
                    /// Social media
                    //if (controllerX.isVisible.value) ...[
                      if (controllerX.isTelephone.value) ...[
                        SvgView(
                          'assets/Icons/telephone.svg',
                          height: 50.w,
                          width: 50.w,
                        ),
                        SizedBox(height: 9.h),
                      ],
                      if (controllerX.isWhatsapp.value) ...[
                        SvgView(
                          'assets/Icons/whatsapp.svg',
                          height: 50.w,
                          width: 50.w,
                        ),
                        SizedBox(height: 9.h)
                      ],
                      if (controllerX.isTelegram.value) ...[
                        SvgView(
                          'assets/Icons/telegram.svg',
                          height: 50.w,
                          width: 50.w,
                        ),
                        SizedBox(height: 9.h)
                      ],
                      if (controllerX.isOnlyfans.value) ...[
                        SvgView(
                          'assets/Icons/onlyfans.svg',
                          height: 50.w,
                          width: 50.w,
                        ),
                        SizedBox(height: 9.h)
                      ],
                      if (controllerX.isFacebook.value) ...[
                        SvgView(
                          'assets/Icons/facebook.svg',
                          height: 50.w,
                          width: 50.w,
                        ),
                        SizedBox(height: 9.h)
                      ],
                      if (controllerX.isInstagram.value) ...[
                        SvgView(
                          'assets/Icons/instagram.svg',
                          height: 50.w,
                          width: 50.w,
                        ),
                        SizedBox(height: 9.h)
                      ],
                      if (controllerX.isSkype.value) ...[
                        SvgView(
                          'assets/Icons/skype.svg',
                          height: 50.w,
                          width: 50.w,
                        ),
                        SizedBox(height: 9.h)
                      ],
                   // ],

                    SvgView(
                      'assets/Icons/chatwish.svg',
                      height: 50.w,
                      width: 50.w,
                    ),

                    SizedBox(height: 9.h),

                    /// location
                    SvgView(
                      'assets/Icons/locationchange.svg',
                      height: 50.w,
                      width: 50.w,
                    ),

                    SizedBox(height: 8.h),

                    /// profile photo
                    Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: [
                        Container(
                          height: 50.w,
                          width: 50.w,
                          margin: EdgeInsets.only(top: 5.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: ConstColors.white, width: 2.w),
                            borderRadius: BorderRadius.circular(30.w),
                            color: ConstColors.white,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.h),
                            child: CachedNetworkImage(
                              imageUrl: controllerX.toktokData['User_Profile']['Imgprofile'].url,
                              memCacheHeight: 200,
                              height: 50.w,
                              width: 50.w,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(seconds: 1),
                              placeholderFadeInDuration: const Duration(seconds: 1),
                              placeholder: (context, url) => preCachedSquare(),
                              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 20.w,
                            width: 20.w,
                            decoration: BoxDecoration(color: ConstColors.white, shape: BoxShape.circle),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/flags/$localeFlag.png',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    /// km
                    Container(
                      height: 30.h,
                      width: 80.w,
                      padding: EdgeInsets.only(right: 10.w, left: 5.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        color: ConstColors.themeColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Styles.regular("0 km", c: ConstColors.white),
                        ],
                      ),
                    ),
                  ],
                ),

                // /// report
                // Positioned(
                //     right: 8.w,
                //     top: 62.h,
                //     child: InkWell(
                //       onTap: () {
                //         widget.controllerX.reportBlock(context, toProfileId: widget.wishPost['Profile']['objectId']);
                //       },
                //       child: Container(
                //         height: 50.w,
                //         width: 50.w,
                //         padding: EdgeInsets.all(12.w),
                //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.w), color: ConstColors.black.withOpacity(0.50)),
                //         child: SvgPicture.asset(
                //           "assets/Icons/bookmark.svg",
                //           color: ConstColors.white,
                //           fit: BoxFit.scaleDown,
                //         ),
                //       ),
                //     )),///
                // /// profile details
                // Container(
                //             margin: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
                //             padding: EdgeInsets.only(left: 12.w, right: 16.w, top: 7.h, bottom: 7.h),
                //             height: 82.h,
                //             width: double.infinity,
                //             decoration: BoxDecoration(color: ConstColors.black.withOpacity(0.20), borderRadius: BorderRadius.circular(6.r)),
                //             child: Row(
                //               children: [
                //                 Expanded(
                //                   child: Column(
                //                     crossAxisAlignment: CrossAxisAlignment.start,
                //                     children: [
                //                       Column(
                //                         crossAxisAlignment: CrossAxisAlignment.start,
                //                         children: [
                //                           /// Name
                //                           SizedBox(
                //                             width: 210.w,
                //                             child: Styles.regular(widget.wishPost['Profile']['Name'].toString().capitalizeFirst!,
                //                                 fs: 20.sp, ov: TextOverflow.ellipsis, fw: FontWeight.bold, ff: "RB", c: ConstColors.white),
                //                           ),
                //                           SizedBox(
                //                             width: 210.w,
                //                             child: Styles.regular(widget.wishPost['Profile']['Location'],
                //                                 lns: 2, ov: TextOverflow.ellipsis, fs: 18.sp, ff: "RR", c: ConstColors.white),
                //                           ),
                //                         ],
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //                 Column(
                //                   children: [
                //                     SizedBox(
                //                       width: 35.h * myLang.length,
                //                       height: 35.h,
                //                       child: ListView.builder(
                //                         itemCount: myLang.length,
                //                         shrinkWrap: true,
                //                         scrollDirection: Axis.horizontal,
                //                         physics: const NeverScrollableScrollPhysics(),
                //                         itemBuilder: (context, ind) {
                //                           return Container(
                //                             height: 35.h,
                //                             width: 35.h,
                //                             decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                //                             child: Center(
                //                               child: Image.network(
                //                                 myLang[ind]['image'],
                //                                 height: 22.h,
                //                                 width: 22.w,
                //                               ),
                //                             ),
                //                           );
                //                         },
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ],
                //             ),
                //           ),///
              ],
            ),
          ),
        ],
      ),
    );
  }
}
