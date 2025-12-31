// ignore_for_file: prefer_typing_uninitialized_variables
// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:io';

import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/bottom_controller.dart';
import 'package:eypop/Controllers/tabbar_controller.dart';
import 'package:eypop/Controllers/toktok_contoller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/repositories/users/provider_post_video_api.dart';
import 'package:eypop/back4appservice/user_provider/wishes/wish_provider_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_postvideo.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/wishes_model/toktok_model.dart';
import 'package:eypop/models/wishes_model/wish_model.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/show_video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController with GetTickerProviderStateMixin {
  static UserController get _userController => Get.find<UserController>();

  static BottomControllers get _bottomControllers => Get.find<BottomControllers>();

  static MyTabController get _tabController => Get.find<MyTabController>();

  static TokTokController get tokTokController => Get.find<TokTokController>();

  final RxString selectedVideoPath = ''.obs;
  final RxString videoThumbnail = "".obs;
  final RxBool isUploading = false.obs;
  final RxBool isPlay = false.obs;
  final ImagePicker _imagePicker = ImagePicker();
  VideoPlayerController? videoPlayerController;
  AnimationController? animationController;

  Future<void> videoPicker(context, {ImageSource source = ImageSource.gallery}) async {
    final XFile? pickedFile = await _imagePicker.pickVideo(source: source);
    if (pickedFile == null) {
      selectedVideoPath.value = "";
      return;
    }

    final File file = renameFile(file: File(pickedFile.path), name: "profileVideo", extension: pickedFile.path.split('.').last);
    // CHECK VIDEO SIZE [40MB] MAX LIMIT
    if (file.lengthSync() < videoLimit) {
      selectedVideoPath.value = file.path;
      await initializedPlayer(file.path);
      Get.to(() => const ShowVideo());
    } else {
      selectedVideoPath.value = "";
      gradientSnackBar(context,
          image: 'assets/Icons/video_cancel.svg',
          title: 'upload_video_less_40mb'.tr,
          color1: ConstColors.darkRedBlackColor,
          color2: ConstColors.redColor);
    }
    update();
  }

  Future<void> fromGallery({ImageSource source = ImageSource.gallery}) async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      videoThumbnail.value = pickedFile.path;
    }
  }

  Future<void> initializedPlayer(String path) async {
    if (path.isNotEmpty) {
      videoPlayerController = VideoPlayerController.file(File(path))
        ..initialize()
        ..setLooping(true);
      final String? xFile = await ThumbUrl.file(path);
      if (xFile != null) {
        videoThumbnail.value = xFile;
      }
    }
    update();
  }

  Future<void> uploadVideoPost() async {
    isUploading.value = true;
    animationController = AnimationController(vsync: this, duration: Duration(seconds: _bottomControllers.isWishVideo.value ? 20 : 18))
      ..forward().whenComplete(() => animationController!.repeat());
    final UserPostVideo userVideoPost = UserPostVideo();
    userVideoPost.userId = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
    userVideoPost.profileId = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
    userVideoPost.accountType = StorageService.getBox.read('AccountType');
    userVideoPost.status = true;
    userVideoPost.type = 'FREE';
    userVideoPost.isNude = _bottomControllers.isNudeVideo.value;
    final videoFile = File(selectedVideoPath.value);
    userVideoPost.videoPost = ParseFile(videoFile);
    if (videoThumbnail.isNotEmpty) {
      // when user select him self new video cover image
      userVideoPost.videoPostThumbnail = ParseFile(File(videoThumbnail.value));
    } else {
      // auto video cover image
      final String? fileX = await ThumbUrl.file(selectedVideoPath.value);
      if (fileX != null) {
        userVideoPost.videoPostThumbnail = ParseFile(File(fileX));
      }
    }
    final res = await PostVideoProviderApi().add(userVideoPost);
    if (res.success) {
      if (_bottomControllers.isWishVideo.value) {
        final bool addTokTok = tokTokController.tokTokTotalVideo.length < tokTokVideoLimit;
        // check user profile rich limit of upload video
        if (addTokTok) {
          // add in User_Wish table
          final WishModel wishModel = WishModel();
          wishModel.user = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
          wishModel.profile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
          wishModel.videoPost = UserPostVideo()..objectId = res.result['objectId'];
          wishModel.gender = StorageService.getBox.read('Gender');
          wishModel.post = ParseFile(videoFile);
          wishModel.thumbnail = userVideoPost.videoPostThumbnail;
          wishModel.isNude = _bottomControllers.isNudeVideo.value;
          wishModel.tokTok = TokTokModel()..objectId = tokTokController.tokTokObject.objectId;
          wishModel.time = tokTokController.tokTokObject.time;
          wishModel.wishList = tokTokController.tokTokObject.wishList;
          wishModel.isVisible = true;
          wishModel.status = 0; // 0 means all wishes are accepted // 1 means pending request // 2 means reject // 3 means Nude
          wishModel.postType = 'Video';
          await WishesApi().add(wishModel).then((wish) {
            if (wish.success) {
              tokTokController.tokTokTotalVideo.add({"Users_Wish": wish.result['objectId'], "Video_Post": res.result['objectId']});
              tokTokController.tokTokTotalVideo.refresh();
            }
          });
        } else {
          if (kDebugMode) {
            print('Hello video post upload failed: ${'you_will_only_able_5_videos'.tr.replaceAll('xxx', tokTokVideoLimit.toString())}');
          }
        }
      }
      _userController.update();
      _bottomControllers.bottomIndex.value = 4;
      _bottomControllers.currentIndex.value = 3;
      _tabController.selectedIndex.value = 1;
      _tabController.tabController!.animateTo(1, duration: const Duration(microseconds: 300), curve: Curves.ease);
      await HapticFeedback.vibrate();
      _bottomControllers.isWishVideo.value = false;
      _bottomControllers.isNudeVideo.value = false;
      if (kDebugMode) {
        print(
            'Hello video post upload success isNude = ${_bottomControllers.isNudeVideo.value} isTWish = ${_bottomControllers.isWishVideo.value} objectId ${res.result['objectId']}');
      }
    }
    Get.back();
    isUploading.value = false;
    videoPlayerController!.dispose();
    if (animationController != null) {
      animationController!.dispose();
    }
    selectedVideoPath.value = "";
    videoThumbnail.value = "";
  }

  @override
  void onClose() {
    if (videoPlayerController != null) {
      videoPlayerController!.dispose();
    }
    if (animationController != null) {
      animationController!.dispose();
    }
    super.onClose();
  }
}
