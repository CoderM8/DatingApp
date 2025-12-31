// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_crop/image_crop.dart';

import '../../Constant/constant.dart';
import '../../Controllers/wish_controllers/create_wish_controller.dart';
import '../../Controllers/wish_controllers/wish_crop_controller.dart';

class WishCropScreen extends GetView {
  final CropController _cropController = Get.put(CropController());
  final CreateWishController _controllerX = Get.put(CreateWishController());

  WishCropScreen({Key? key, required this.file}) : super(key: key);

  bool status = false;
  File file;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          _controllerX.pickedFile.value = "";
          _controllerX.update();
        }
      },
      child: Scaffold(
        body: Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Column(
            children: [
              Expanded(
                child: Crop.file(
                  file,
                  key: _cropController.cropKeySpec,
                  aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20.0),
                alignment: AlignmentDirectional.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Obx(() {
                      if (_cropController.isProcessI.value == false) {
                        return IconButton(
                          onPressed: () {
                            _controllerX.pickedFile.value = "";
                            _controllerX.update();
                            Get.back();
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.white,
                            size: 39,
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }),
                    Obx(() => _cropController.isProcessI.value == true
                        ? Center(
                            child: CircularProgressIndicator(color: ConstColors.themeColor),
                          )
                        : IconButton(
                            onPressed: () {
                              _cropController.cropImage(fileTest: file).then((value) {
                                if (value!.lengthSync() > 20000000) {
                                  showSnackBar(context, content: 'very_big_photo'.tr);
                                  _controllerX.pickedFile.value = '';
                                } else {
                                  final newFile = renameFile(file: File(value.path), name: "image", extension: 'jpg');
                                  _controllerX.pickedFile.value = newFile.path;
                                }
                                _controllerX.update();
                                Get.back();
                              });
                            },
                            icon: const Icon(Icons.done, color: Colors.white, size: 39),
                          )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
