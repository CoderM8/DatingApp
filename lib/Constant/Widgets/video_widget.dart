// ignore_for_file: must_be_immutable, depend_on_referenced_packages

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/toktok_contoller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/purchase_nudevideo_api.dart';
import 'package:eypop/back4appservice/repositories/users/provider_post_video_api.dart';
import 'package:eypop/back4appservice/user_provider/wishes/wish_provider_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_postvideo.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/wishes_model/purchase_nudevideo_model.dart';
import 'package:eypop/models/wishes_model/toktok_model.dart';
import 'package:eypop/models/wishes_model/wish_model.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/wishes_pages/create_wish_screen.dart';
import 'package:eypop/ui/wishes_pages/wish_video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'button.dart';

class VideoWidget extends StatefulWidget {
  final UserPostVideo userPost;
  final bool visitMode;
  final UserController userController;
  final List<bool> purchase;
  final int index;
  final String toProfileId;

  const VideoWidget(
      {Key? key,
      required this.userController,
      required this.userPost,
      required this.visitMode,
      required this.purchase,
      required this.index,
      required this.toProfileId})
      : super(key: key);

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  bool visible = false;
  late VideoPlayerHandler videoPlayerHandler;

  static TokTokController get tokTokController => Get.find<TokTokController>();

  @override
  void initState() {
    // Initialize with a video URL
    videoPlayerHandler = VideoPlayerHandler(
        videoUrl: widget.userPost.videoPost.url.toString(),
        autoPlay: widget.visitMode == false ? true : !((widget.userPost['IsNude'] ?? false) == true && !visible),
        onVideoEnd: () {
          videoPlayerHandler.play();
        });
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        if (!videoPlayerHandler.hasError)
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayerScreen(
                handler: videoPlayerHandler,
                controls: FlickVideoProgressBar(
                  flickProgressBarSettings: FlickProgressBarSettings(
                      padding: EdgeInsets.only(bottom: 29.h),
                      height: 3.h,
                      handleRadius: 8.r,
                      playedColor: const Color(0xFFFF74A4),
                      handleColor: ConstColors.white,
                      backgroundColor: ConstColors.white,
                      bufferedColor: ConstColors.white),
                ),
                volumePadding: EdgeInsets.only(bottom: 40.h, right: 10.w),
                placeholder: widget.userPost.videoPostThumbnail.url != null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(widget.userPost.videoPostThumbnail.url.toString(),
                              height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width, fit: BoxFit.cover),
                          Center(child: CircularProgressIndicator(color: ConstColors.themeColor))
                        ],
                      )
                    : null,
              ),

              /// nude show button
              if (widget.visitMode == true && (widget.userPost['IsNude'] ?? false) && !widget.purchase[widget.index])
                InkWell(
                  onTap: () async {
                    setState(() {
                      widget.purchase[widget.index] = true;
                      visible = false;
                    });
                    videoPlayerHandler.pause();
                    ApiResponse? response = await PurchaseNudeVideoProviderApi()
                        .getObjectId(widget.userPost['objectId'], widget.toProfileId, StorageService.getBox.read('DefaultProfile'));
                    if (response != null) {
                      PurchaseNudeVideo nudeVideo = PurchaseNudeVideo();
                      nudeVideo.objectId = response.results![0]['objectId'];
                      await PurchaseNudeVideoProviderApi().remove(nudeVideo);
                    } else {
                      print('response null video ------');
                    }
                    userProfileRefresh.value = !userProfileRefresh.value;
                  },
                  child: Container(
                    height: 40.h,
                    width: 110.w,
                    margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20.h),
                    decoration: BoxDecoration(color: ConstColors.black, borderRadius: BorderRadius.circular(50.r)),
                    alignment: Alignment.center,
                    child: Styles.regular('Hide'.tr, c: ConstColors.white),
                  ),
                ),
            ],
          ),
        if (widget.visitMode == false)
          Positioned(
            top: 50.h,
            right: 20.w,
            child: Column(
              children: [
                Obx(() {
                  final bool isTWish = tokTokController.tokTokTotalVideo.toString().contains(widget.userPost.objectId.toString());
                  return SvgButton(
                      svg: 'assets/Icons/bottomWish.svg',
                      svgColor: isTWish ? ConstColors.redColor : ConstColors.bottomBorder,
                      onTap: tokTokController.isProcessing.value
                          ? null
                          : () async {
                              if (isTWish) {
                                // remove from User_Wish table
                                final index = tokTokController.tokTokTotalVideo
                                    .indexWhere((element) => element['Video_Post'] == widget.userPost.objectId.toString());
                                if (!index.isNegative) {
                                  final WishModel wishModel = WishModel();
                                  wishModel.objectId = tokTokController.tokTokTotalVideo[index]['Users_Wish'];
                                  await WishesApi().remove(wishModel).then((value) {
                                    tokTokController.tokTokTotalVideo.removeAt(index);
                                    tokTokController.tokTokTotalVideo.refresh();
                                    gradientSnackBar(
                                      context,
                                      title: 'Hidden_on_TikTok'.tr,
                                      image: 'assets/Icons/bottomWish.svg',
                                      color1: ConstColors.darkRedBlackColor,
                                      color2: ConstColors.redColor,
                                    );
                                  });
                                }
                              } else {
                                if (tokTokController.tokTokObjectId.isNotEmpty) {
                                  final bool addTokTok = tokTokController.tokTokTotalVideo.length < tokTokVideoLimit;
                                  // check user profile rich limit of upload video
                                  if (addTokTok) {
                                    // add in User_Wish table
                                    tokTokController.isProcessing.value = true;
                                    final WishModel wishModel = WishModel();
                                    wishModel.user = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                                    wishModel.profile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
                                    wishModel.videoPost = UserPostVideo()..objectId = widget.userPost.objectId;
                                    wishModel.gender = StorageService.getBox.read('Gender');
                                    wishModel.post = widget.userPost.videoPost;
                                    wishModel.thumbnail = widget.userPost.videoPostThumbnail;
                                    wishModel.isNude = widget.userPost['IsNude'] != null ? widget.userPost.isNude : false; // some videopost in IsNude are NULL
                                    wishModel.tokTok = TokTokModel()..objectId = tokTokController.tokTokObject.objectId;
                                    wishModel.time = tokTokController.tokTokObject.time;
                                    wishModel.wishList = tokTokController.tokTokObject.wishList;
                                    wishModel.isVisible = true;
                                    wishModel.status = 0; // 0 means all wishes are accepted // 1 means pending request // 2 means reject // 3 means Nude
                                    wishModel.postType = 'Video';
                                    await WishesApi().add(wishModel).then((value) {
                                      if (value.success) {
                                        tokTokController.isProcessing.value = false;
                                        tokTokController.tokTokTotalVideo
                                            .add({"Users_Wish": value.result['objectId'], "Video_Post": widget.userPost.objectId});
                                        tokTokController.tokTokTotalVideo.refresh();
                                        gradientSnackBar(context, title: 'Shown_on_TikTok'.tr, image: 'assets/Icons/bottomWish.svg');
                                      }
                                      tokTokController.isProcessing.value = false;
                                    });
                                  } else {
                                    gradientSnackBar(
                                      context,
                                      title: 'you_will_only_able_5_videos'.tr.replaceAll('xxx', tokTokVideoLimit.toString()),
                                      image: 'assets/Icons/bottomWish.svg',
                                      color1: ConstColors.darkRedBlackColor,
                                      color2: ConstColors.redColor,
                                    );
                                  }
                                } else {
                                  Get.to(() => const CreateWishScreen());
                                }
                              }
                            });
                }),
                SizedBox(height: 11.h),
                SvgButton(
                    svg: 'assets/Icons/delete_post.svg',
                    svgColor: ConstColors.black,
                    onTap: () {
                      showDeleteDialog(
                        context,
                        title: 'permanent_delete_video'.tr,
                        onTap: () async {
                          // remove from User_Wish table
                          final index =
                              tokTokController.tokTokTotalVideo.indexWhere((element) => element['Video_Post'] == widget.userPost.objectId.toString());
                          if (!index.isNegative) {
                            final WishModel wishModel = WishModel();
                            wishModel.objectId = tokTokController.tokTokTotalVideo[index]['Users_Wish'];
                            await WishesApi().remove(wishModel).then((value) {
                              tokTokController.tokTokTotalVideo.removeAt(index);
                              tokTokController.tokTokTotalVideo.refresh();
                            });
                          }
                          await PostVideoProviderApi().remove(widget.userPost).then((value) {
                            widget.userController.update();
                            Get.back();
                            Get.back();
                          });
                        },
                      );
                    }),
                SizedBox(height: 11.h),
                if ((widget.userPost['IsNude'] ?? false) && !visible) ...[if (!widget.visitMode) const SvgButton(svg: 'assets/Icons/xxx.svg')]
              ],
            ),
          ),

        /// Content warning: Nudity
        if ((widget.userPost['IsNude'] ?? false) && widget.purchase[widget.index] && !visible) ...[
          // visitMode = false --> when i open my own posted video from my profile
          if (widget.visitMode)
            BlurryContainer(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              blur: 30,
              padding: EdgeInsets.symmetric(horizontal: 35.w),
              borderRadius: BorderRadius.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: SvgView('assets/Icons/IsNude.svg', fit: BoxFit.cover, color: ConstColors.white, height: 30.w, width: 30.w)),
                  SizedBox(height: 50.h),
                  Styles.regular("Content_warning".tr, fs: 18.sp, c: ConstColors.white, ff: "HR", al: TextAlign.start),
                  SizedBox(height: 8.3.h),
                  Styles.regular("Content_warning_text".tr, fs: 18.sp, c: ConstColors.white, ff: "HR", al: TextAlign.start),
                  SizedBox(height: 45.h),
                  Center(
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          visible = true;
                          widget.purchase[widget.index] = false;
                        });
                        PurchaseNudeVideo purchase = PurchaseNudeVideo();
                        purchase.imgPost = UserPostVideo()..objectId = widget.userPost['objectId'];
                        purchase.fromprofileId = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
                        purchase.fromuserId = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                        purchase.toprofileId = ProfilePage()..objectId = widget.toProfileId;
                        purchase.touserId = UserLogin()..objectId = widget.userPost['User']['objectId'];
                        await PurchaseNudeVideoProviderApi().add(purchase);
                        userProfileRefresh.value = !userProfileRefresh.value;
                        videoPlayerHandler.play();
                      },
                      child: Container(
                        height: 40.h,
                        width: 131.w,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(40.r), color: Colors.black.withOpacity(0.8)),
                        child: Styles.regular("Show".tr, fs: 18.sp, c: ConstColors.white, ff: "HR", al: TextAlign.center),
                      ),
                    ),
                  ),
                  SizedBox(height: 13.h),
                ],
              ),
            ),
        ]
      ],
    );
  }
}
