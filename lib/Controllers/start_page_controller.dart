// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class StartVideoController extends GetxController {
  VideoPlayerController? videoController;

  @override
  void onInit() {
    super.onInit();
    videoController = VideoPlayerController.asset('assets/videos/eypop_video.mp4')
      ..initialize()
      ..play()
      ..setLooping(true);
  }

  @override
  void onClose() {
    super.onClose();
    if (videoController != null && videoController!.value.isInitialized) {
      videoController!.dispose();
    }
  }
}
