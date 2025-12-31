// ignore_for_file: must_be_immutable

import 'package:card_swiper/card_swiper.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/video_widget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/purchase_nudevideo_api.dart';
import 'package:eypop/back4appservice/repositories/users/provider_post_video_api.dart';
import 'package:eypop/models/user_login/user_postvideo.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ShowVideoScreen extends StatefulWidget {
   const ShowVideoScreen(
      {required this.index,
      required this.vidObjectId,
      required this.toProfileId,
      required this.fromProfileId,
      required this.visitMode,
      required this.userController,
       this.isPictureScreen = false,
      Key? key})
      : super(key: key);
  final int index;
  final bool visitMode;
  final String toProfileId;
  final String vidObjectId;
  final String fromProfileId;
  final UserController userController;
  final bool isPictureScreen;

  @override
  State<ShowVideoScreen> createState() => _ShowVideoScreenState();
}

class _ShowVideoScreenState extends State<ShowVideoScreen> {
  String? objectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          FutureBuilder<List<ApiResponse?>>(
              future: Future.wait([
                PostVideoProviderApi().profileVideoPostQuery(widget.toProfileId),
                PurchaseNudeVideoProviderApi().getById(widget.toProfileId, StorageService.getBox.read('DefaultProfile')),
              ]),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                  final snapshotVideo = snapshot.data![0];
                  final snapshotPurchase = snapshot.data![1];
                  if (snapshotVideo!.results!.isEmpty) {
                    return Shimmer.fromColors(
                      direction: ShimmerDirection.ltr,
                      baseColor: ConstColors.grey,
                      period: const Duration(milliseconds: 1000),
                      highlightColor: ConstColors.shimmerGray,
                      child: Center(child: Container(color: Colors.white)),
                    );
                  } else {
                    final int length = snapshotVideo.results!.length;
                    List<UserPostVideo> video = [];
                    List<bool> purchase = [];
                    for (var i = 0; i < length; i++) {
                      // if [false] video is remove by admin
                      if ((snapshotVideo.results![i]['Status'] ?? true)) {
                        video.add(snapshotVideo.results![i]);
                        if (snapshotPurchase == null) {
                          purchase.add(true);
                        } else {
                          if (snapshotPurchase.results!.toString().contains(snapshotVideo.results![i]['objectId'])) {
                            purchase.add(false);
                          } else {
                            purchase.add(true);
                          }
                        }
                      }
                    }
                    int indexWhere = video.indexWhere((element) => element['objectId'] == widget.vidObjectId);
                    if (indexWhere.isNegative) {
                      indexWhere = widget.index;
                    }
                    return Swiper(
                      index: widget.isPictureScreen == true ? 0 : indexWhere,
                      loop: false,
                      itemCount: video.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, i) {
                        return VideoWidget(
                            userController: widget.userController,
                            purchase: purchase,
                            index: i,
                            toProfileId: widget.toProfileId,
                            userPost: video[i],
                            visitMode: widget.visitMode);
                      },
                    );
                  }
                } else {
                  return Shimmer.fromColors(
                    direction: ShimmerDirection.ltr,
                    baseColor: ConstColors.grey,
                    period: const Duration(milliseconds: 1000),
                    highlightColor: ConstColors.shimmerGray,
                    child: Center(child: Container(color: Colors.white)),
                  );
                }
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
            //       userProfileBlock(context, toProfileId: widget.profileId, fromProfileId: widget.fromProfileId, type: 'VIDEO', objectId: objectId);
            //     },
            //     child: Container(
            //       padding: EdgeInsets.all(10.h.w),
            //       height: 50.w,
            //       width: 50.w,
            //       decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: ConstColors.themeColor.withOpacity(0.40)),
            //       child: SvgPicture.asset('assets/Icons/bookmark.svg'),
            //     ),
            //   ),
          ),
        ],
      ),
    );
  }
}
