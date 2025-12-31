// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Controllers/toktok_contoller.dart';
import 'package:eypop/back4appservice/purchase_nudeimage_api.dart';
import 'package:eypop/back4appservice/user_provider/wishes/wish_provider_api.dart';
import 'package:eypop/models/purchase_nudeimage_model.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/wishes_model/toktok_model.dart';
import 'package:eypop/models/wishes_model/wish_model.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/wishes_pages/create_wish_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Constant/constant.dart';
import '../../Controllers/Picture_Controller/profile_pic_controller.dart';
import '../../Controllers/user_controller.dart';
import '../../back4appservice/base/api_response.dart';
import '../../back4appservice/user_provider/users/provider_post_api.dart';
import '../../back4appservice/user_provider/users/provider_profileuser_api.dart';
import '../../models/user_login/user_post.dart';

class ShowPictureScreen extends StatefulWidget {
  const ShowPictureScreen(
      {required this.index,
      required this.imgObjectId,
      required this.toProfileId,
      required this.toUserDefaultProfileId,
      required this.fromProfileId,
      required this.visitMode,
      this.deleteEnable = true,
      this.isPictureScreen = false,
      Key? key})
      : super(key: key);
  final int index;
  final String imgObjectId;
  final String toProfileId;
  final String fromProfileId;
  final String toUserDefaultProfileId;
  final bool visitMode, deleteEnable, isPictureScreen;

  @override
  State<ShowPictureScreen> createState() => _ShowPictureScreenState();
}

class _ShowPictureScreenState extends State<ShowPictureScreen> {
  final UserController _userController = Get.put(UserController());

  final PictureController pictureX = Get.put(PictureController());

  //String? objectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          FutureBuilder<List<ApiResponse?>>(
              future: Future.wait([
                PostProviderApi().profilePostQuery(widget.toProfileId),
                PurchaseNudeImageProviderApi().getById(widget.toProfileId, StorageService.getBox.read('DefaultProfile')),
              ]),
              builder: (context, snapshot) {
                Widget child;
                if (snapshot.connectionState == ConnectionState.done) {
                  final snapshotPhoto = snapshot.data![0];
                  final snapshotPurchase = snapshot.data![1];

                  if (snapshotPhoto!.results!.isEmpty) {
                    child = preCachedFullScreen(const ValueKey(0));
                  } else {
                    final int length = snapshotPhoto.results!.length;
                    List<UserPost> image = [];
                    List<bool> purchase = [];
                    try {
                      dynamic first;
                      final int index = snapshotPhoto.results!.indexWhere((element) => element['objectId'] == widget.toUserDefaultProfileId);
                      for (var element in snapshotPhoto.results!) {
                        if (element['objectId'] == widget.toUserDefaultProfileId) {
                          first = element;
                        }
                      }
                      if (!index.isNegative) {
                        snapshotPhoto.results!.removeAt(index);
                        snapshotPhoto.results!.insert(0, first);
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                    for (var i = 0; i < length; i++) {
                      if ((snapshotPhoto.results![i]['Status'] ?? true)) {
                        image.add(snapshotPhoto.results![i]);
                        if (snapshotPurchase == null) {
                          purchase.add(true);
                        } else {
                          if (snapshotPurchase.results!.toString().contains(snapshotPhoto.results![i]['objectId'])) {
                            purchase.add(false);
                          } else {
                            purchase.add(true);
                          }
                        }
                      }
                    }
                    int indexWhere = image.indexWhere((element) => element['objectId'] == widget.imgObjectId);
                    if (indexWhere.isNegative) {
                      indexWhere = widget.index;
                    }
                    child = Swiper(
                      key: const ValueKey(1),
                      index: widget.isPictureScreen == true ? 0 : indexWhere,
                      loop: false,
                      scrollDirection: Axis.vertical,
                      itemCount: image.length,
                      itemBuilder: (context, i) {
                        //objectId = image[i]['objectId'];
                        return ImageVisible(
                            userController: _userController,
                            purchase: purchase,
                            index: i,
                            toProfileId: widget.toProfileId,
                            userPost: image[i],
                            visitMode: widget.visitMode,
                            deleteEnable: widget.deleteEnable);
                      },
                    );
                  }
                } else {
                  child = preCachedFullScreen(const ValueKey(3));
                }
                return AnimatedSwitcher(duration: const Duration(milliseconds: 500), child: child);
              }),

          ///second
          Padding(
            padding: EdgeInsets.only(top: 46.h, left: 20.w, right: 20.w),
            child: SvgView(
              "assets/Icons/cancelbutton.svg",
              height: 45.w,
              width: 45.w,
              onTap: () {
                Get.back();
              },
            ),

            /// report button change
            // if (widget.visitMode)
            //   GestureDetector(
            //     onTap: () {
            //       userProfileBlock(context, toProfileId: widget.profileId, fromProfileId: widget.fromProfileId, type: 'IMAGE', objectId: objectId);
            //     },
            //     child: Container(
            //       padding: EdgeInsets.all(10.h.w),
            //       height: 50.w,
            //       width: 50.w,
            //       decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: ConstColors.themeColor.withOpacity(0.40)),
            //       child: SvgPicture.asset('assets/Icons/bookmark.svg'),
            //     ),
            //   ),
          )
        ],
      ),
    );
  }
}

class ImageVisible extends StatefulWidget {
  final UserPost userPost;
  final bool visitMode, deleteEnable;
  final UserController userController;
  final List<bool> purchase;
  final int index;
  final String toProfileId;

  const ImageVisible(
      {Key? key,
      required this.toProfileId,
      required this.userController,
      required this.userPost,
      required this.visitMode,
      this.deleteEnable = true,
      required this.purchase,
      required this.index})
      : super(key: key);

  @override
  State<ImageVisible> createState() => _ImageVisibleState();
}

class _ImageVisibleState extends State<ImageVisible> {
  bool visible = false;

  static TokTokController get tokTokController => Get.find<TokTokController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CachedNetworkImage(
              imageUrl: widget.userPost.imgPost.url!,
              memCacheHeight: 800,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(seconds: 1),
              placeholder: (context, url) => preCachedFullScreen(UniqueKey()),
              placeholderFadeInDuration: const Duration(seconds: 1),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
            ),

            /// nude show button
            if (widget.visitMode == true && (widget.userPost['IsNude'] ?? false) && !widget.purchase[widget.index])
              InkWell(
                onTap: () async {
                  setState(() {
                    widget.purchase[widget.index] = true;
                    visible = false;
                  });
                  ApiResponse? response = await PurchaseNudeImageProviderApi()
                      .getObjectId(widget.userPost['objectId'], widget.toProfileId, StorageService.getBox.read('DefaultProfile'));
                  if (response != null) {
                    PurchaseNudeImage nudeImage = PurchaseNudeImage();
                    nudeImage.objectId = response.results![0]['objectId'];
                    await PurchaseNudeImageProviderApi().remove(nudeImage);
                  } else {
                    print('response null image ------');
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
          // visitMode == false --> when i open my own posted image from my profile
          Positioned(
            top: 50.h,
            right: 20.w,
            child: Column(
              children: [
                Obx(() {
                  final bool isTWish = tokTokController.tokTokTotalImage.toString().contains(widget.userPost.objectId.toString());
                  tokTokController.tokTokObject;
                  tokTokController.isProcessing.value;
                  return SvgButton(
                    svg: 'assets/Icons/bottomWish.svg',
                    svgColor: isTWish ? ConstColors.redColor : ConstColors.bottomBorder,
                    onTap: tokTokController.isProcessing.value
                        ? null
                        : () async {
                            if (isTWish) {
                              // remove from User_Wish table
                              final index = tokTokController.tokTokTotalImage
                                  .indexWhere((element) => element['Img_Post'] == widget.userPost.objectId.toString());
                              if (!index.isNegative) {
                                final WishModel wishModel = WishModel();
                                wishModel.objectId = tokTokController.tokTokTotalImage[index]['Users_Wish'];
                                await WishesApi().remove(wishModel).then((value) {
                                  tokTokController.tokTokTotalImage.removeAt(index);
                                  tokTokController.tokTokTotalImage.refresh();
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
                                // check user create ToTok account or not
                                final bool addTokTok = tokTokController.tokTokTotalImage.length < tokTokImageLimit;
                                // check user profile rich limit of upload image
                                if (addTokTok) {
                                  // add in User_Wish table
                                  tokTokController.isProcessing.value = true;
                                  final WishModel wishModel = WishModel();
                                  wishModel.user = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                                  wishModel.profile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
                                  wishModel.imgPost = UserPost()..objectId = widget.userPost.objectId;
                                  wishModel.gender = StorageService.getBox.read('Gender');
                                  wishModel.post = widget.userPost.imgPost;
                                  wishModel.isNude = widget.userPost['IsNude'] != null ? widget.userPost.isNude : false; // some imgpost in IsNude are NULL
                                  wishModel.tokTok = TokTokModel()..objectId = tokTokController.tokTokObject.objectId;
                                  wishModel.time = tokTokController.tokTokObject.time;
                                  wishModel.wishList = tokTokController.tokTokObject.wishList;
                                  wishModel.isVisible = true;
                                  wishModel.status = 0; // 0 means all wishes are accepted // 1 means pending request // 2 means reject // 3 means Nude
                                  wishModel.postType = 'Image';
                                  await WishesApi().add(wishModel).then((value) {
                                    if (value.success) {
                                      tokTokController.isProcessing.value = false;
                                      tokTokController.tokTokTotalImage
                                          .add({"Users_Wish": value.result['objectId'], "Img_Post": widget.userPost.objectId});
                                      tokTokController.tokTokTotalImage.refresh();
                                      gradientSnackBar(context, title: 'Shown_on_TikTok'.tr, image: 'assets/Icons/bottomWish.svg');
                                    }
                                    tokTokController.isProcessing.value = false;
                                  });
                                } else {
                                  gradientSnackBar(
                                    context,
                                    title: 'you_will_only_able_3_photos'.tr.replaceAll('xxx', tokTokImageLimit.toString()),
                                    image: 'assets/Icons/bottomWish.svg',
                                    color1: ConstColors.darkRedBlackColor,
                                    color2: ConstColors.redColor,
                                  );
                                }
                              } else {
                                Get.to(() => const CreateWishScreen());
                              }
                            }
                          },
                  );
                }),
                SizedBox(height: 11.h),
                // FAKE profile delete there photo if [widget.deleteEnable] true
                if (widget.deleteEnable) ...[
                  SvgButton(
                    svg: 'assets/Icons/delete_post.svg',
                    svgColor: ConstColors.black,
                    onTap: () {
                      showDeleteDialog(
                        context,
                        title: 'permanent_delete_photo'.tr,
                        onTap: () async {
                          final bool isDefault = (StorageService.getBox.read('DefaultImgObjectId') != null &&
                              StorageService.getBox.read('DefaultImgObjectId') == widget.userPost['objectId']);
                          // remove from User_Wish table
                          final index =
                              tokTokController.tokTokTotalImage.indexWhere((element) => element['Img_Post'] == widget.userPost.objectId.toString());
                          if (!index.isNegative) {
                            final WishModel wishModel = WishModel();
                            wishModel.objectId = tokTokController.tokTokTotalImage[index]['Users_Wish'];
                            await WishesApi().remove(wishModel).then((value) {
                              tokTokController.tokTokTotalImage.removeAt(index);
                              tokTokController.tokTokTotalImage.refresh();
                            });
                          }
                          if (isDefault) {
                            final UserPost userPost = UserPost();
                            userPost.objectId = widget.userPost['objectId'];
                            userPost.status = false;
                            await PostProviderApi().update(userPost);
                            final ProfilePage profilePage = ProfilePage();
                            profilePage.objectId = StorageService.getBox.read('DefaultProfile');
                            profilePage.imgStatus = false;
                            await UserProfileProviderApi().update(profilePage);
                          } else {
                            await PostProviderApi().remove(widget.userPost);
                          }
                          widget.userController.update();
                          Get.back();
                          Get.back();
                        },
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                ],
                if ((widget.userPost['IsNude'] ?? false) == true && !visible) ...[
                  if (!widget.visitMode) SvgButton(svg: 'assets/Icons/xxx.svg', svgColor: ConstColors.redColor)
                ]
              ],
            ),
          ),
        if ((widget.userPost['IsNude'] ?? false) == true && widget.purchase[widget.index] && !visible) ...[
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
                        PurchaseNudeImage purchase = PurchaseNudeImage();
                        purchase.imgPost = UserPost()..objectId = widget.userPost['objectId'];
                        purchase.fromprofileId = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
                        purchase.fromuserId = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                        purchase.toprofileId = ProfilePage()..objectId = widget.toProfileId;
                        purchase.touserId = UserLogin()..objectId = widget.userPost['User']['objectId'];
                        await PurchaseNudeImageProviderApi().add(purchase);
                        userProfileRefresh.value = !userProfileRefresh.value;
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
