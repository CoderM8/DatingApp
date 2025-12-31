// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/Picture_Controller/porn_moderation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_crop/image_crop.dart';
import 'package:lottie/lottie.dart';

import '../../Controllers/tabbar_controller.dart';
import '../../Controllers/user_controller.dart';

class SquareCropScreen extends GetView {
  final File file;
  const SquareCropScreen({Key? key, required this.file}) : super(key: key);

  static UserController get _userController => Get.find<UserController>();
  static PornModerationController get _pornModerationController => Get.put(PornModerationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ControllerX>(
          init: ControllerX(),
          builder: (_) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
              child: Column(
                children: [
                  Expanded(
                    child: Crop.file(
                      file,
                      key: _userController.cropKeySpec,
                      aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Obx(() {
                      if (_userController.isProcessI.value) {
                        return Padding(
                          key: ValueKey<bool>(_userController.isProcessI.value),
                          padding: EdgeInsets.only(right: 10.w),
                          child: Lottie.asset('assets/jsons/postProgress.json', height: 50.h, width: 213.w),
                        );
                      } else {
                        return Row(
                          key: ValueKey<bool>(_userController.isProcessI.value),
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: SvgView('assets/Icons/cancel.svg',color: Theme.of(context).primaryColor),
                            ),
                            IconButton(
                              onPressed: () async {
                                try {
                                  _userController.isProcessI.value = true;
                                  _userController.isLoading.value = true;
                                  final Map<String, dynamic> jsonData = await _pornModerationController.asyncFileUpload(file: file);
                                  if (!jsonData['porn_moderation']["porn_content"]) {
                                    final scale = _userController.cropKeySpec.currentState!.scale;
                                    final area = _userController.cropKeySpec.currentState!.area;
                                    final sample = await ImageCrop.sampleImage(file: file, preferredSize: (2000 / scale).round());
                                    final fileT = await ImageCrop.cropImage(file: sample, area: area!);
                                    sample.delete();
                                    _userController.imageProfile.value = fileT.path;
                                  } else {
                                    _userController.selectedImage = null;
                                    _userController.isProcessI.value = false;
                                    Get.back();
                                    gradientSnackBar(
                                      context,
                                      image: 'assets/Icons/camera_cancel.svg',
                                      title: 'uploaded_photo_include_porn_content'.tr,
                                      color1: ConstColors.darkRedBlackColor,
                                      color2: ConstColors.redColor,
                                    );
                                  }
                                } catch (e) {
                                  _userController.selectedImage = null;
                                  _userController.isProcessI.value = false;
                                  gradientSnackBar(
                                    context,
                                    image: 'assets/Icons/camera_cancel.svg',
                                    title: 'Upload_photo_smaller'.tr,
                                    color1: ConstColors.darkRedBlackColor,
                                    color2: ConstColors.redColor,
                                  );
                                }
                                _userController.isProcessI.value = false;
                                _userController.update();
                                Get.back();
                              },
                              icon: SvgView('assets/Icons/ok.svg',color: Theme.of(context).primaryColor),
                            ),
                          ],
                        );
                      }
                    }),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
