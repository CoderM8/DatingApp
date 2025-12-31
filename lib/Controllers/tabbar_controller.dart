import 'dart:async';
import 'dart:io';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/Picture_Controller/porn_moderation_controller.dart';
import 'package:eypop/Controllers/bottom_controller.dart';
import 'package:eypop/Controllers/toktok_contoller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_post_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/back4appservice/user_provider/wishes/wish_provider_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_post.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/wishes_model/toktok_model.dart';
import 'package:eypop/models/wishes_model/wish_model.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/image_crop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class MyTabController extends GetxController with GetSingleTickerProviderStateMixin {
  final RxDouble one204 = 204.0.obs;
  final RxInt selectedIndex = 0.obs;
  TabController? tabController;
  ScrollController? scrollController;

  _scrollListener() {}

  _smoothScrollToTop() {
    selectedIndex.value = tabController!.index;
  }

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController!.addListener(_scrollListener);
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(_smoothScrollToTop);
  }
}

class ControllerX extends GetxController with GetTickerProviderStateMixin {
  static UserController get _userController => Get.find<UserController>();

  static BottomControllers get _bottomControllers => Get.find<BottomControllers>();

  static MyTabController get _tabController => Get.find<MyTabController>();

  static TokTokController get tokTokController => Get.find<TokTokController>();

  static PornModerationController get _pornModerationController => Get.put(PornModerationController());
  final cropKeySpec = GlobalKey<CropState>();
  AnimationController? animationController;
  final RxBool isUploading = false.obs;

  Future<File?> cropImage({required File fileTest, context}) async {
    isUploading.value = true;
    final scale = cropKeySpec.currentState!.scale;
    final area = cropKeySpec.currentState!.area;
    final sample = await ImageCrop.sampleImage(file: fileTest, preferredSize: (2000 / scale).round());

    final file = await ImageCrop.cropImage(file: sample, area: area!);
    sample.delete();
    return file;
  }

  Future<void> fromGallery(context, {ImageSource source = ImageSource.gallery}) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) {
      return;
    }
    final File val = File(pickedFile.path);
    if (val.lengthSync() < imageLimit) {
      Get.to(() => ShowImage(file: val));
    } else {
      gradientSnackBar(context, image: 'assets/Icons/imagePost.svg', title: 'upload_image_less_20mb'.tr, color1: ConstColors.darkRedBlackColor, color2: ConstColors.redColor);
    }
  }

  Future<void> uploadImgPost(context, {required File file}) async {
    animationController = AnimationController(vsync: this, duration: Duration(seconds: _bottomControllers.isWishPost.value ? 15 : 12))
      ..forward().whenComplete(() => animationController!.repeat());
    await cropImage(fileTest: file, context: context).then((cropFile) async {
      try {
        bool isNude = false;
        final UserPost userPost = UserPost();
        userPost.imgPost = ParseFile(cropFile);
        userPost.profileId = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
        userPost.userId = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
        userPost.accountType = StorageService.getBox.read('AccountType');
        userPost.type = 'FREE';
        userPost.status = true;

        ProfilePage profilePage = ProfilePage();
        profilePage.objectId = StorageService.getBox.read('DefaultProfile');
        profilePage.imgStatus = true;
        await UserProfileProviderApi().update(profilePage);


        if (_bottomControllers.isNudePost.value) {
          // when user select nude image option
          isNude = true;
        } else {
          // when user not select any option
          final Map<String, dynamic> jsonData = await _pornModerationController.asyncFileUpload(file: cropFile);
          if (!jsonData['porn_moderation']["porn_content"]) {
            isNude = false;
          } else {
            if (kDebugMode) {
              print('Hello image post upload failed api isNude = true');
            }
            isUploading.value = false;
            Get.back();
            gradientSnackBar(context,
                image: 'assets/Icons/camera_cancel.svg', title: 'uploaded_photo_include_porn_content'.tr, color1: ConstColors.darkRedBlackColor, color2: ConstColors.redColor);
            return;
          }
        }
        userPost.isNude = isNude;
        final res = await PostProviderApi().add(userPost);
        if (res.success) {
          if (_bottomControllers.isWishPost.value) {
            final bool addTokTok = tokTokController.tokTokTotalImage.length < tokTokImageLimit;
            // check user profile rich limit of upload image
            if (addTokTok) {
              // add in User_Wish table
              final WishModel wishModel = WishModel();
              wishModel.user = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
              wishModel.profile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
              wishModel.imgPost = UserPost()..objectId = res.result['objectId'];
              wishModel.gender = StorageService.getBox.read('Gender');
              wishModel.post = ParseFile(cropFile);
              wishModel.tokTok = TokTokModel()..objectId = tokTokController.tokTokObject.objectId;
              wishModel.time = tokTokController.tokTokObject.time;
              wishModel.wishList = tokTokController.tokTokObject.wishList;
              wishModel.isNude = isNude;
              wishModel.isVisible = true;
              wishModel.status = 0; // 0 means all wishes are accepted // 1 means pending request // 2 means reject // 3 means Nude
              wishModel.postType = 'Image';
              await WishesApi().add(wishModel).then((wish) {
                if (wish.success) {
                  tokTokController.tokTokTotalImage.add({"Users_Wish": wish.result['objectId'], "Img_Post": res.result['objectId']});
                  tokTokController.tokTokTotalImage.refresh();
                }
              });
            } else {
              if (kDebugMode) {
                print('Hello image post upload failed: ${'you_will_only_able_3_photos'.tr.replaceAll('xxx', tokTokImageLimit.toString())}');
              }
            }
          }
          _userController.update();
          _bottomControllers.bottomIndex.value = 4;
          _bottomControllers.currentIndex.value = 3;
          _tabController.selectedIndex.value = 0;
          _tabController.tabController!.animateTo(0, duration: const Duration(microseconds: 300), curve: Curves.ease);
          await HapticFeedback.vibrate();
          if (animationController != null) {
            animationController!.dispose();
          }
          _bottomControllers.isNudePost.value = false;
          _bottomControllers.isWishPost.value = false;
          if (kDebugMode) {
            print('Hello image post upload success isNude = $isNude isTWish = ${_bottomControllers.isWishPost.value} objectId ${res.result['objectId']}');
          }
        }
        Get.back();
        isUploading.value = false;
      } catch (e) {
        if (kDebugMode) {
          print('Hello image post upload failed catch $e');
        }
        isUploading.value = false;
        Get.back();
        gradientSnackBar(context, image: 'assets/Icons/camera_cancel.svg', title: 'Upload_photo_smaller'.tr, color1: ConstColors.darkRedBlackColor, color2: ConstColors.redColor);
      }
    });
  }

  @override
  void dispose() {
    if (animationController != null) {
      animationController!.dispose();
    }
    super.dispose();
  }
}
