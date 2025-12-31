


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_crop/image_crop.dart';

class CropController extends GetxController{
  RxBool isProcessI = false.obs;
  final cropKeySpec = GlobalKey<CropState>();
  File? lastCroppeded;
  RxString path = ''.obs;

  Future<File?> cropImage({required File fileTest}) async {
    isProcessI.value = true;
    final scale = cropKeySpec.currentState!.scale;
    final area = cropKeySpec.currentState!.area;
    final sample = await ImageCrop.sampleImage(
      file: fileTest,
      preferredSize: (2000 / scale).round(),
      // preferredHeight:  1000,
      // preferredWidth:  1500,
      // preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area! /*const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9)*/,
    );
    sample.delete();

    lastCroppeded?.delete();
    lastCroppeded = file;
    path.value = file.path;

    debugPrint('$file');
    return lastCroppeded;
  }
}