import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/videocontroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class ShowVideo extends GetView {
  const ShowVideo({Key? key}) : super(key: key);

  static VideoController get videoController => Get.find<VideoController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 40.h, bottom: 20.h),
        child: Column(
          children: [
            GetBuilder<VideoController>(
              builder: (logic) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: logic.videoPlayerController != null
                        ? Stack(
                            children: [
                              VideoPlayer(logic.videoPlayerController!),
                              Obx(() {
                                logic.isPlay.value;
                                return GestureDetector(
                                  onTap: () {
                                    logic.isPlay.value = !logic.isPlay.value;
                                    if (logic.videoPlayerController!.value.isPlaying) {
                                      logic.videoPlayerController!.pause();
                                    } else {
                                      // If the video is paused, play it.
                                      logic.videoPlayerController!.play();
                                    }
                                  },
                                );
                              }),
                            ],
                          )
                        : Shimmer.fromColors(
                            direction: ShimmerDirection.ltr,
                            baseColor: ConstColors.grey,
                            period: const Duration(milliseconds: 1000),
                            highlightColor: ConstColors.shimmerGray,
                            child: Center(child: Container(color: Colors.white)),
                          ),
                  ),
                );
              },
            ),
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: videoController.fromGallery,
                    child: Column(
                      children: [
                        SvgView("assets/Icons/edit.svg", color: Theme.of(context).primaryColor),
                        SizedBox(height: 10.h),
                        Styles.regular('Edit_cover'.tr, fs: 12.sp, c: Theme.of(context).primaryColor, ff: 'HM'),
                      ],
                    ),
                  ),
                  Obx(() {
                    videoController.videoThumbnail.value;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: videoController.videoThumbnail.isEmpty
                          ? Container(
                              key: ValueKey<bool>(videoController.videoThumbnail.isEmpty),
                              height: 150.w,
                              width: 150.w,
                              decoration: BoxDecoration(color: ConstColors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10.r)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image, size: 30.w, color: Theme.of(context).primaryColor),
                                  SizedBox(height: 10.h),
                                  Styles.regular("No_cover".tr, fs: 12.sp, c: Theme.of(context).primaryColor, ff: 'HR', lns: 2),
                                ],
                              ),
                            )
                          : Container(
                              key: ValueKey<bool>(videoController.videoThumbnail.isEmpty),
                              height: 150.w,
                              width: 150.w,
                              decoration: BoxDecoration(
                                color: ConstColors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10.r),
                                image: DecorationImage(image: FileImage(File(videoController.videoThumbnail.value)), fit: BoxFit.cover),
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Obx(() {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: videoController.isUploading.value
                    ? Padding(
                        key: ValueKey<bool>(videoController.isUploading.value),
                        padding: EdgeInsets.only(right: 10.w, bottom: 10.h),
                        child: Lottie.asset('assets/jsons/videoProgress.json', height: 42.h, width: 300.w, controller: videoController.animationController),
                      )
                    : Row(
                        key: ValueKey<bool>(videoController.isUploading.value),
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {
                              Get.back();
                              if (videoController.videoPlayerController != null) {
                                videoController.videoPlayerController!.dispose();
                              }
                              if (videoController.animationController != null) {
                                videoController.animationController!.dispose();
                              }
                              videoController.selectedVideoPath.value = "";
                              videoController.videoThumbnail.value = "";
                            },
                            icon: SvgView('assets/Icons/cancel.svg', color: Theme.of(context).primaryColor),
                          ),
                          IconButton(
                            onPressed: videoController.uploadVideoPost,
                            icon: SvgView('assets/Icons/ok.svg', color: Theme.of(context).primaryColor),
                          )
                        ],
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
