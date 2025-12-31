// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/tabbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_crop/image_crop.dart';
import 'package:lottie/lottie.dart';

class ShowImage extends GetView {
  final File file;

  const ShowImage({Key? key, required this.file}) : super(key: key);

  static ControllerX get _controllerX => Get.find<ControllerX>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ControllerX>(
          init: ControllerX(),
          builder: (_) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
              child: Column(
                children: [
                  Expanded(
                    child: Crop.file(
                      file,
                      key: _controllerX.cropKeySpec,
                      aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Obx(() {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _controllerX.isUploading.value
                          ? Padding(
                              key: ValueKey<bool>(_controllerX.isUploading.value),
                              padding: EdgeInsets.only(right: 10.w),
                              child: Lottie.asset('assets/jsons/postProgress.json', height: 50.h, width: 213.w, controller: _controllerX.animationController),
                            )
                          : Row(
                              key: ValueKey<bool>(_controllerX.isUploading.value),
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  icon: SvgView('assets/Icons/cancel.svg', color: Theme.of(context).primaryColor),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await _controllerX.uploadImgPost(context, file: file);
                                  },
                                  icon: SvgView('assets/Icons/ok.svg', color: Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                    );
                  }),
                ],
              ),
            );
          }),
    );
  }
}
