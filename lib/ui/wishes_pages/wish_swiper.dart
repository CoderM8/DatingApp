// ignore_for_file: invalid_use_of_protected_member, deprecated_member_use
import 'dart:io';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Constant/translate.dart';
import 'package:eypop/Controllers/advertisement_controller.dart';
import 'package:eypop/Controllers/bottom_controller.dart';
import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/Controllers/wish_controllers/wish_swiper_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/purchase_nudeimage_api.dart';
import 'package:eypop/back4appservice/purchase_nudevideo_api.dart';
import 'package:eypop/back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import 'package:eypop/models/new_notification/new_notification_pair.dart';
import 'package:eypop/models/purchase_nudeimage_model.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_post.dart';
import 'package:eypop/models/user_login/user_postvideo.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/wishes_model/purchase_nudevideo_model.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/User_profile/user_fullprofile_screen.dart';
import 'package:eypop/ui/tab_pages/conversation_screen.dart';
import 'package:eypop/ui/wishes_pages/wish_video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../back4appservice/user_provider/wishes/wish_provider_api.dart';

class WishSwiper extends StatefulWidget {
  const WishSwiper({Key? key}) : super(key: key);

  @override
  State<WishSwiper> createState() => _WishSwiperState();
}

class _WishSwiperState extends State<WishSwiper> {
  WishSwiperController swiperController = WishSwiperController();
  final AppSearchController _searchController = Get.put(AppSearchController());
  final UserController _userController = Get.put(UserController());
  final RefreshController refreshController = Get.put(RefreshController());
  final AdvertisementController advertisementController = Get.put(AdvertisementController());
  int previousIndex = 0;

  @override
  void initState() {
    if (!swiperController.initialized) {
      swiperController = Get.put(WishSwiperController());
    }
    advertisementController.getAdvertisementData('toktok');
    swiperController.getMyWishes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RefreshController>(
      builder: (logic) {
        return GetBuilder<AppSearchController>(builder: (logic) {
          swiperController.isSwiperLoading.value = true;
          if (_userController.initialLink == null) {
            swiperController.wishSwiperList.clear();
            seenWishIds.clear();
            searchRadiusKm.value = 10;
            swiperController.purchaseNude.clear();
            indexTokTokList.clear();
            swiperController.wishSwiperObjectIdList.clear();
            swiperController.wishSwiperProfileIdList.clear();
          }
          if (_userController.initialLink != null) {
            Future.delayed(const Duration(seconds: 5), () {
              swiperController.isSwiperLoading.value = false;
            });
          }
          swiperController.loadPage.value = 0;
          swiperController.wishSwiperIndex.value = 0;
          swiperController.wishIds.value = StorageService.wishBox.values.toList();
          swiperController.local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
          swiperController.getSwiperData().then((value) async {
            if (swiperController.wishSwiperList.length < 5) {
              if (!value) {
                for (var element in StorageService.wishBox.values) {
                  if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {
                    await StorageService.wishBox.delete(element['id']);
                  }
                }
                swiperController.wishIds.value = StorageService.wishBox.values.toList();
                swiperController.loadPage.value = 0;
                swiperController.getSwiperData();
              } else {
                do {
                  swiperController.isSwiperLoading.value = true;
                  await swiperController.getSwiperData();
                  if (swiperController.isGlobalSearch.value == false) {
                    break;
                  }
                } while (swiperController.wishSwiperList.length < 5);
              }
            }
            _userController.initialLink = null;
          });
          return Scaffold(
            body: Obx(() {
              swiperController.wishSwiperList.value;
              swiperController.isSwiperLoading.value;
              if (swiperController.isSwiperLoading.value) {
                return GradientWidget(
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      Styles.regular('eypop', fs: 78.sp, ff: 'HL', c: ConstColors.white),
                      Styles.regular('looking_for_toktok'.tr, fs: 22.sp, ff: 'HL', c: ConstColors.white),
                      const Spacer(flex: 2),
                      Lottie.asset("assets/jsons/bulleye.json", height: 348.w, width: 348.w, fit: BoxFit.cover),
                      const Spacer(flex: 5),
                    ],
                  ),
                );
              }

              if (_searchController.profileData.isNotEmpty &&
                  (_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted == true ||
                      (_searchController.profileData[StorageService.getBox.read('index') ?? 0].isBlocked == true))) {
                return GradientWidget(
                  child: Center(
                    child: Styles.regular('your_active_profile_is_deleted'.tr, al: TextAlign.center, c: ConstColors.white),
                  ),
                );
              }

              if (swiperController.wishSwiperList.isEmpty) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    GradientWidget(
                      child: Center(
                        child: Styles.regular('no_wishes_found'.tr, al: TextAlign.center, c: ConstColors.white),
                      ),
                    ),
                    Positioned(
                      bottom: 40.h,
                      child: InkWell(
                        onTap: () {
                          swiperController.isGlobalSearch.value = true;
                          swiperController.wishSwiperList.clear();
                          seenWishIds.clear();
                          searchRadiusKm.value = 50;
                          swiperController.purchaseNude.clear();
                          indexTokTokList.clear();
                          swiperController.wishSwiperObjectIdList.clear();
                          swiperController.wishSwiperProfileIdList.clear();
                          swiperController.wishSwiperIndex.value = 0;
                          swiperController.loadPage.value = 0;
                          refreshController.update();
                        },
                        child: const SvgView('assets/Icons/global.svg'),
                      ),
                    ),
                  ],
                );
              }
              return Swiper(
                scrollDirection: Axis.vertical,
                loop: false,
                onIndexChanged: (index) async {
                  swiperController.wishSwiperIndex.value = index;
                  if ((index + 2) < swiperController.wishSwiperList.length) {
                    DefaultCacheManager().downloadFile(swiperController.wishSwiperList[index + 1]['Post'].url).then((value) {
                      if ((index + 2) < swiperController.wishSwiperList.length + 1) {
                        DefaultCacheManager().downloadFile(swiperController.wishSwiperList[index + 2]['Post'].url);
                      }
                    });
                    DefaultCacheManager().downloadFile(swiperController.wishSwiperList[index + 1]['Profile']['Imgprofile'].url).then((value) {
                      if ((index + 2) < swiperController.wishSwiperList.length + 1) {
                        DefaultCacheManager().downloadFile(swiperController.wishSwiperList[index + 2]['Profile']['Imgprofile'].url);
                      }
                    });
                  }
                  if (index == swiperController.wishSwiperList.length - 8) {
                    if (!swiperController.isLoading.value) {
                      swiperController.getSwiperData().then((value) async {
                        if (!value) {
                          for (var element in StorageService.wishBox.values) {
                            if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {
                              await StorageService.wishBox.delete(element['id']);
                            }
                          }
                          swiperController.wishIds.value = StorageService.wishBox.values.toList();
                          swiperController.loadPage.value = 0;
                          swiperController.getSwiperData();
                        }
                      });
                    }
                  }

                  bool dialogShown = false;

                  /// Ads Logic TokTok
                  if (!indexTokTokList.contains(index)) {
                    for (var e in advertisementController.adsTokTokData) {
                      if (dialogShown) break;
                      // Check if Repeat is true and apply the logic
                      if (e['Repeat'] == true) {
                        if (index > 0 && (index + 1) % e['EveryXProfiles'] == 0) {
                          adsDialog(e, index, 'toktok');
                          dialogShown = true;
                        }
                      }
                      // Check the other condition even if Repeat is false
                      else {
                        if (index == (e['EveryXProfiles'] - 1)) {
                          adsDialog(e, index, 'toktok');
                          dialogShown = true;
                        }
                      }
                    }
                  }
                },
                controller: swiperController.swiperController,
                itemCount: swiperController.wishSwiperList.length,
                index: swiperController.wishSwiperIndex.value,
                itemBuilder: (context, index) {
                  if (index == swiperController.wishSwiperList.length - 1) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      _searchController.page.value = 0;
                    });
                    swiperController.getSwiperData();
                  }
                  return WishContent(
                      wishPost: swiperController.wishSwiperList[index],
                      searchController: _searchController,
                      controllerX: swiperController,
                      index: index);
                },
              );
            }),
          );
        });
      },
    );
  }
}

class WishContent extends StatefulWidget {
  const WishContent({Key? key, required this.wishPost, required this.searchController, required this.controllerX, required this.index})
      : super(key: key);
  final WishSwiperController controllerX;
  final AppSearchController searchController;
  final ParseObject wishPost;
  final int index;

  @override
  State<WishContent> createState() => _WishContentState();
}

class _WishContentState extends State<WishContent> {
  final UserController userController = Get.put(UserController());
  final BottomControllers _bottomController = Get.find<BottomControllers>();

  final RefreshController refreshController = Get.find<RefreshController>();
  String localeFlag = SchedulerBinding.instance.platformDispatcher.locale.countryCode!.toLowerCase();
  late VideoPlayerHandler videoPlayerHandler;
  final RxBool isShow = false.obs;
  final RxBool _isVisible = false.obs;

  @override
  void initState() {
    StorageService.wishBox.put(widget.wishPost['Profile']['objectId'], {
      'id': '${widget.wishPost['Profile']['objectId']}',
      'selfProfileId': StorageService.getBox.read('DefaultProfile'),
      'createdAt': '${DateTime.now()}'
    });

    if (widget.wishPost['Profile']["CountryCode"].toString().isNotEmpty) {
      localeFlag = widget.wishPost['Profile']["CountryCode"].toString().toLowerCase();
    }

    if (widget.wishPost['Type'].toString().contains('Video')) {
      // Initialize with a video URL
      videoPlayerHandler = VideoPlayerHandler(
          videoUrl: widget.wishPost['Post'].url,
          autoPlay: _bottomController.bottomIndex.value == 1 && !((widget.wishPost['IsNude'] ?? false) && !isShow.value),
          onVideoEnd: () {
            videoPlayerHandler.play();
          });
    }
    ever(widget.controllerX.isGlobalSearch, (isGlobalSearch) {
      _isVisible.value = !(isGlobalSearch as bool); // Use .value and cast appropriately
    });
    super.initState();
  }

  @override
  void dispose() {
    if (widget.wishPost['Type'].toString().contains('Video') && !videoPlayerHandler.hasError) {
      videoPlayerHandler.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List wishList = (widget.wishPost['Wish_List'] ?? []);
    return Obx(() {
      isShow.value;
      return Stack(
        alignment: Alignment.center,
        children: [
          Stack(
            children: [
              if (widget.wishPost['Type'].toString().contains('Video'))
                VisibilityDetector(
                  key: ObjectKey(videoPlayerHandler),
                  onVisibilityChanged: (visibilityInfo) async {
                    if ((widget.wishPost['IsNude'] ?? false) && !isShow.value) {
                      videoPlayerHandler.pause();
                      if (kDebugMode) {
                        print('Hello is nude content');
                      }
                    } else {
                      if (visibilityInfo.visibleFraction > 0.8) {
                        videoPlayerHandler.play();
                      } else {
                        videoPlayerHandler.pause();
                      }
                    }
                  },
                  child: VideoPlayerScreen(
                    handler: videoPlayerHandler,
                    controls: FlickVideoProgressBar(
                      flickProgressBarSettings: FlickProgressBarSettings(
                          padding: EdgeInsets.only(bottom: 12.h),
                          height: 3.h,
                          handleRadius: 8.r,
                          playedColor: ConstColors.themeColor,
                          handleColor: ConstColors.white,
                          backgroundColor: ConstColors.white,
                          bufferedColor: ConstColors.white),
                    ),
                    placeholder: widget.wishPost['VideoThumbnail'] != null
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(widget.wishPost['VideoThumbnail'].url.toString(),
                                  height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width, fit: BoxFit.cover),
                              Center(child: CircularProgressIndicator(color: ConstColors.themeColor))
                            ],
                          )
                        : null,
                  ),
                )
              else
                CachedNetworkImage(
                  imageUrl: widget.wishPost['Post'].url,
                  memCacheHeight: 800,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(seconds: 1),
                  placeholderFadeInDuration: const Duration(seconds: 1),
                  placeholder: (context, url) => preCachedFullScreen(UniqueKey()),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                ),
              Obx(() {
                return ModalProgressHUD(
                  inAsyncCall: widget.controllerX.isSharing.value,
                  blur: 2,
                  progressIndicator: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown),
                  child: Positioned(
                    bottom: 30.h,
                    left: 8.w,
                    right: 9.w,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// wish list
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(wishList.length, ((index) {
                                    bool isDone = false;
                                    widget.controllerX.fillWishes.clear();
                                    for (final element in widget.controllerX.myWishes) {
                                      if (element['ToProfile']['objectId'] == widget.wishPost['Profile']['objectId']) {
                                        widget.controllerX.fillWishes.add(element);
                                      }
                                    }
                                    if (widget.controllerX.fillWishes.isNotEmpty) {
                                      ///[isDone] TRUE WHEN USER FILL FULL WISH
                                      isDone = (widget.controllerX.fillWishes.toString().contains(widget.wishPost['Profile']['objectId']) &&
                                          widget.controllerX.fillWishes.toString().contains(wishList[index]['objectId']));
                                    }

                                    return WishBox(
                                      svg: wishList[index]['Lottie_File'].url,
                                      title: wishList[index][widget.controllerX.local],
                                      isDone: isDone,
                                      onTap: !isDone
                                          ? () {
                                              widget.controllerX.fullFillWish(
                                                  widget.wishPost['User']['Gender'],
                                                  widget.wishPost['Profile']['objectId'],
                                                  widget.wishPost['User']['objectId'],
                                                  wishList[index]['objectId']);
                                            }
                                          : () async {
                                              dynamic value = widget.controllerX.fillWishes.firstWhere((element) =>
                                                  element.toString().contains(widget.wishPost['Profile']['objectId']) &&
                                                  element.toString().contains(wishList[index]['objectId']));
                                              if (value != null) {
                                                widget.controllerX.isWishRemove.value = true;
                                                PairNotifications pair = PairNotifications();
                                                pair.objectId = value['objectId'];
                                                await PairNotificationProviderApi().remove(pair);
                                                widget.controllerX.fillWishes.remove(value);
                                                widget.controllerX.myWishes.remove(value);
                                                widget.controllerX.isWishRemove.value = false;
                                              }
                                            },
                                    );
                                  })),
                                ),

                                /// time
                                Container(
                                  height: 30.h,
                                  padding: EdgeInsets.only(right: 10.w, left: 5.w),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r), color: ConstColors.themeColor),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Lottie.asset('assets/jsons/bulleye.json', height: 28.w, width: 28.w),
                                      SizedBox(width: 5.w),
                                      Styles.regular(
                                          Languages().keys[widget.controllerX.local]![widget.wishPost['Time']] ??
                                              Languages().keys[widget.controllerX.local]!['Tonight']!,
                                          c: ConstColors.white,
                                          ov: TextOverflow.ellipsis,
                                          fs: 14.sp),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                /// Social media
                                Padding(
                                  padding: EdgeInsets.only(right: 15.0.w),
                                  child: Column(
                                    children: [
                                      if (widget.wishPost['TokTok'] != null) ...[
                                        if (widget.wishPost['TokTok']['Telephone_Enable'] && widget.wishPost['TokTok']['Telephone'] != null) ...[
                                          SvgView(
                                            'assets/Icons/telephone.svg',
                                            height: 50.w,
                                            width: 50.w,
                                            onTap: () async {
                                              final url = Uri.parse("tel:${widget.wishPost['TokTok']['Telephone'].toString().removeAllWhitespace}");
                                              await canLaunchUrl(url).then((valid) async {
                                                if (valid) {
                                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                                } else {
                                                  gradientSnackBar(
                                                    context,
                                                    title: 'inválido Telephone',
                                                    image: 'assets/Icons/call_outline.svg',
                                                    color1: ConstColors.darkRedColor,
                                                    color2: ConstColors.redColor,
                                                  );
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(height: 9.h),
                                        ],
                                        if (widget.wishPost['TokTok']['Whatsapp_Enable'] && widget.wishPost['TokTok']['Whatsapp'] != null) ...[
                                          SvgView(
                                            'assets/Icons/whatsapp.svg',
                                            height: 50.w,
                                            width: 50.w,
                                            onTap: () async {
                                              final contact = widget.wishPost['TokTok']['Whatsapp_DialCode'] +
                                                  widget.wishPost['TokTok']['Whatsapp'].toString().removeAllWhitespace;
                                              final url = Uri.parse(Platform.isIOS ? "https://wa.me/$contact" : "whatsapp://send?phone=$contact");
                                              await canLaunchUrl(url).then((valid) async {
                                                if (valid) {
                                                  await launchUrl(url);
                                                } else {
                                                  gradientSnackBar(
                                                    context,
                                                    title: 'WhatsApp ${'Is_not_installed_on_the_device'.tr}',
                                                    image: 'assets/Icons/whatsapp_outline.svg',
                                                    color1: ConstColors.darkRedColor,
                                                    color2: ConstColors.redColor,
                                                  );
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(height: 9.h)
                                        ],
                                        if (widget.wishPost['TokTok']['Telegram_Enable'] && widget.wishPost['TokTok']['Telegram'] != null) ...[
                                          SvgView(
                                            'assets/Icons/telegram.svg',
                                            height: 50.w,
                                            width: 50.w,
                                            onTap: () async {
                                              String id = widget.wishPost['TokTok']['Telegram'].toString().removeAllWhitespace;
                                              if (id.contains('https://t.me/')) {
                                                await launchUrl(Uri.parse('$id?text=${'hello_i_writing_eypop'.tr}'),
                                                    mode: LaunchMode.externalApplication);
                                              } else {
                                                await launchUrl(
                                                    Uri.parse('${'https://t.me/'}${id.replaceAll('@', '')}?text=${'hello_i_writing_eypop'.tr}'),
                                                    mode: LaunchMode.externalApplication);
                                              }
                                            },
                                          ),
                                          SizedBox(height: 9.h)
                                        ],
                                        if (widget.wishPost['TokTok']['OnlyFans_Enable'] && widget.wishPost['TokTok']['OnlyFans'] != null) ...[
                                          SvgView(
                                            'assets/Icons/onlyfans.svg',
                                            height: 50.w,
                                            width: 50.w,
                                            onTap: () async {
                                              String id = widget.wishPost['TokTok']['OnlyFans'].toString().removeAllWhitespace;
                                              if (id.contains('https://onlyfans.com/')) {
                                                if (await canLaunchUrl(Uri.parse(id))) {
                                                  await launchUrl(Uri.parse(id));
                                                }
                                              } else {
                                                await launchUrl(Uri.parse('${'https://onlyfans.com/'}${id.replaceAll('@', '')}'));
                                              }
                                            },
                                          ),
                                          SizedBox(height: 9.h)
                                        ],
                                        if (widget.wishPost['TokTok']['Facebook_Enable'] && widget.wishPost['TokTok']['Facebook'] != null) ...[
                                          SvgView(
                                            'assets/Icons/facebook.svg',
                                            height: 50.w,
                                            width: 50.w,
                                            onTap: () async {
                                              String id = widget.wishPost['TokTok']['Facebook'].toString().removeAllWhitespace;
                                              if (id.contains('https://www.facebook.com/')) {
                                                final url = Uri.parse(id);
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                                } else {
                                                  await launchUrl(url);
                                                }
                                              } else {
                                                final url = Uri.parse('${'https://www.facebook.com/'}$id');
                                                await launchUrl(url, mode: LaunchMode.externalApplication);
                                              }
                                            },
                                          ),
                                          SizedBox(height: 9.h)
                                        ],
                                        if (widget.wishPost['TokTok']['Instagram_Enable'] && widget.wishPost['TokTok']['Instagram'] != null) ...[
                                          SvgView(
                                            'assets/Icons/instagram.svg',
                                            height: 50.w,
                                            width: 50.w,
                                            onTap: () async {
                                              String id = widget.wishPost['TokTok']['Instagram'].toString().removeAllWhitespace;
                                              if (id.contains('https://www.instagram.com/')) {
                                                final url = Uri.parse(id);
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                                } else {
                                                  await launchUrl(url);
                                                }
                                              } else {
                                                final url = Uri.parse('${'https://www.instagram.com/'}$id');
                                                await launchUrl(url, mode: LaunchMode.externalApplication);
                                              }
                                            },
                                          ),
                                          SizedBox(height: 9.h)
                                        ],
                                        if (widget.wishPost['TokTok']['Skype_Enable'] && widget.wishPost['TokTok']['Skype'] != null) ...[
                                          SvgView(
                                            'assets/Icons/skype.svg',
                                            height: 50.w,
                                            width: 50.w,
                                            onTap: () async {
                                              String id = widget.wishPost['TokTok']['Skype'].toString().removeAllWhitespace;
                                              try {
                                                if (id.removeAllWhitespace.contains('live:.cid.')) {
                                                  final Uri url = Uri(
                                                      scheme: 'skype',
                                                      path: id.removeAllWhitespace,
                                                      queryParameters: {'chat': 'true', 'text': 'hello_i_writing_eypop'.tr});
                                                  await launchUrl(url);
                                                } else {
                                                  final Uri url = Uri(
                                                      scheme: 'skype',
                                                      path: '${'live:.cid.'}${id.removeAllWhitespace}',
                                                      queryParameters: {'chat': 'true', 'text': 'hello_i_writing_eypop'.tr});
                                                  await launchUrl(url);
                                                }
                                              } catch (e) {
                                                gradientSnackBar(
                                                  context,
                                                  title: 'Skype ${'Is_not_installed_on_the_device'.tr}',
                                                  image: 'assets/Icons/skype_outline.svg',
                                                  color1: ConstColors.darkRedColor,
                                                  color2: ConstColors.redColor,
                                                );
                                              }
                                            },
                                          ),
                                          SizedBox(height: 9.h)
                                        ],
                                      ],
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(right: 15.0.w),
                                  child: SvgView(
                                    'assets/Icons/chatwish.svg',
                                    height: 50.w,
                                    width: 50.w,
                                    onTap: () {
                                      bool onlineStatus;
                                      if (widget.wishPost['Profile']['NoChats'] ?? false) {
                                        onlineStatus = false;
                                      } else {
                                        onlineStatus = true;
                                      }
                                      StorageService.getBox.write('msgFromProfileId', StorageService.getBox.read('DefaultProfile'));
                                      StorageService.getBox.write('msgToProfileId', widget.wishPost['Profile']['objectId']);
                                      StorageService.getBox.write('chattablename', 'Chat_Message');
                                      StorageService.getBox.save();
                                      Get.to(
                                        () => ConversationScreen(
                                          fromUserDeleted: false,
                                          toUserDeleted: (widget.wishPost['Profile']['isDeleted'] || (widget.wishPost['User']['isDeleted'] ?? false)),
                                          toUser: widget.wishPost['User'],
                                          onlineStatus: onlineStatus,
                                          tableName: 'Chat_Message',
                                          fromUserImg: StorageService.getBox.read('DefaultProfileImg'),
                                          toProfileName: widget.wishPost['Profile']["Name"],
                                          toProfileImg: widget.wishPost['Profile']["Imgprofile"].url,
                                          fromProfileId: StorageService.getBox.read('DefaultProfile'),
                                          toProfileId: widget.wishPost['Profile']['objectId'],
                                          toUserGender: widget.wishPost['User']['Gender'],
                                          toUserId: widget.wishPost['User']['objectId'],
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                SizedBox(height: 9.h),

                                /// location
                                /*  Obx(() {
                                  widget.controllerX.isGlobalSearch.value;
                                  return Column(
                                    children: [
                                      if (widget.controllerX.isGlobalSearch.value)
                                        SvgView(
                                          'assets/Icons/locationchange.svg',
                                          height: 50.w,
                                          width: 50.w,
                                          onTap: () {
                                            widget.controllerX.isGlobalSearch.value = false;
                                            widget.controllerX.wishSwiperList.clear();
                                            seenWishIds.clear();
                                            widget.controllerX.purchaseNude.clear();
                                            indexTokTokList.clear();
                                            widget.controllerX.wishSwiperObjectIdList.clear();
                                            widget.controllerX.wishSwiperProfileIdList.clear();
                                            widget.controllerX.wishSwiperIndex.value = 0;
                                            widget.controllerX.loadPage.value = 0;
                                            widget.controllerX.wishIds.clear();
                                            StorageService.wishBox.clear();
                                            refreshController.update();
                                          },
                                        ),
                                      if (!widget.controllerX.isGlobalSearch.value)
                                        InkWell(
                                          onTap: () {
                                            widget.controllerX.isGlobalSearch.value = true;
                                            widget.controllerX.wishSwiperList.clear();
                                            seenWishIds.clear();
                                            widget.controllerX.purchaseNude.clear();
                                            indexTokTokList.clear();
                                            widget.controllerX.wishSwiperObjectIdList.clear();
                                            widget.controllerX.wishSwiperProfileIdList.clear();
                                            widget.controllerX.wishSwiperIndex.value = 0;
                                            widget.controllerX.loadPage.value = 0;
                                            refreshController.update();
                                          },
                                          child: Container(
                                            height: 50.w,
                                            width: 50.w,
                                            decoration: BoxDecoration(color: ConstColors.themeColor, shape: BoxShape.circle),
                                            padding: EdgeInsets.all(9.r),
                                            child: SvgPicture.asset('assets/Icons/global.svg', color: ConstColors.white),
                                          ),
                                        ),
                                    ],
                                  );
                                }),*/

                                Obx(() {
                                  _isVisible.value;
                                  return Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _isVisible.value = false;
                                          widget.controllerX.isGlobalSearch.value = true;
                                          widget.controllerX.wishSwiperList.clear();
                                          widget.controllerX.purchaseNude.clear();
                                          indexTokTokList.clear();
                                          widget.controllerX.wishSwiperObjectIdList.clear();
                                          widget.controllerX.wishSwiperProfileIdList.clear();
                                          widget.controllerX.wishSwiperIndex.value = 0;
                                          widget.controllerX.loadPage.value = 0;
                                          refreshController.update();
                                        },
                                        child: AnimatedOpacity(
                                          opacity: _isVisible.value ? 1 : 0,
                                          duration: const Duration(milliseconds: 300),
                                          child: AnimatedContainer(
                                            decoration: BoxDecoration(
                                              color: widget.controllerX.isGlobalSearch.value ? ConstColors.themeColor : ConstColors.subtitle,
                                              shape: BoxShape.circle,
                                            ),
                                            duration: const Duration(milliseconds: 300),
                                            height: _isVisible.value ? 50.w : 0,
                                            width: _isVisible.value ? 50.w : 0,
                                            child: Padding(
                                              padding: EdgeInsets.all(9.r),
                                              child: SvgPicture.asset(
                                                'assets/Icons/global.svg',
                                                color: ConstColors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          _isVisible.value = false;
                                          widget.controllerX.isGlobalSearch.value = false;
                                          widget.controllerX.wishSwiperList.clear();
                                          widget.controllerX.purchaseNude.clear();
                                          indexTokTokList.clear();
                                          widget.controllerX.wishSwiperObjectIdList.clear();
                                          widget.controllerX.wishSwiperProfileIdList.clear();
                                          widget.controllerX.wishSwiperIndex.value = 0;
                                          widget.controllerX.loadPage.value = 0;
                                          widget.controllerX.wishIds.clear();
                                          StorageService.wishBox.clear();
                                          refreshController.update();
                                        },
                                        child: AnimatedOpacity(
                                          opacity: _isVisible.value ? 1 : 0,
                                          duration: const Duration(milliseconds: 300),
                                          child: AnimatedContainer(
                                            decoration: BoxDecoration(
                                              color: widget.controllerX.isGlobalSearch.value ? ConstColors.subtitle : ConstColors.themeColor,
                                              shape: BoxShape.circle,
                                            ),
                                            duration: const Duration(milliseconds: 300),
                                            height: _isVisible.value ? 50.w : 0,
                                            width: _isVisible.value ? 50.w : 0,
                                            child: SvgView(
                                              'assets/Icons/locationChangeWishSwiper.svg',
                                              height: 50.w,
                                              width: 50.w,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 15.0.w),
                                        child: InkWell(
                                          onTap: () {
                                            _isVisible.value = true;
                                            Future.delayed(const Duration(seconds: 3), () {
                                              _isVisible.value = false;
                                            });
                                          },
                                          child: AnimatedOpacity(
                                            opacity: _isVisible.value ? 0 : 1,
                                            duration: const Duration(milliseconds: 300),
                                            child: AnimatedContainer(
                                                decoration: BoxDecoration(
                                                  color: ConstColors.themeColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                duration: const Duration(milliseconds: 300),
                                                height: _isVisible.value ? 0 : 50.w,
                                                width: _isVisible.value ? 0 : 50.w,
                                                child: widget.controllerX.isGlobalSearch.value
                                                    ? Padding(
                                                        padding: EdgeInsets.all(9.r),
                                                        child: SvgPicture.asset(
                                                          'assets/Icons/global.svg',
                                                          color: ConstColors.white,
                                                        ),
                                                      )
                                                    : SvgView(
                                                        'assets/Icons/locationChangeWishSwiper.svg',
                                                        height: 70.w,
                                                        width: 70.w,
                                                      )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                SizedBox(height: 8.h),

                                /// profile photo
                                Padding(
                                  padding: EdgeInsets.only(right: 15.0.w),
                                  child: GestureDetector(
                                    onTap: () async {
                                      Get.to(
                                        () => UserFullProfileScreen(
                                          toUserId: widget.wishPost['User'],
                                          toProfileId: widget.wishPost['Profile']['objectId'],
                                          fromProfileId: StorageService.getBox.read('DefaultProfile'),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      alignment: AlignmentDirectional.topEnd,
                                      children: [
                                        Container(
                                          height: 50.w,
                                          width: 50.w,
                                          margin: EdgeInsets.only(top: 5.h),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: ConstColors.white, width: 2.w),
                                            borderRadius: BorderRadius.circular(30.w),
                                            color: ConstColors.white,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(30.h),
                                            child: CachedNetworkImage(
                                              imageUrl: widget.wishPost['Profile']['Imgprofile'].url,
                                              memCacheHeight: 200,
                                              height: 50.w,
                                              width: 50.w,
                                              fit: BoxFit.cover,
                                              fadeInDuration: const Duration(seconds: 1),
                                              placeholderFadeInDuration: const Duration(seconds: 1),
                                              placeholder: (context, url) => preCachedSquare(),
                                              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            height: 20.w,
                                            width: 20.w,
                                            decoration: BoxDecoration(color: ConstColors.white, shape: BoxShape.circle),
                                            child: CircleAvatar(
                                              backgroundImage: AssetImage(
                                                'assets/flags/$localeFlag.png',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                /// km
                                Container(
                                  height: 30.h,
                                  width: 80.w,
                                  padding: EdgeInsets.only(right: 10.w, left: 5.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.r),
                                    color: ConstColors.themeColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Obx(() {
                                        if (widget.searchController.profileData.isEmpty) {
                                          return Styles.regular("0 km", c: ConstColors.white);
                                        }
                                        return Styles.regular(
                                            "${(widget.searchController.calculateDistance(widget.searchController.profileData[StorageService.getBox.read('index') ?? 0].locationGeoPoint.latitude, widget.searchController.profileData[StorageService.getBox.read('index') ?? 0].locationGeoPoint.longitude, widget.wishPost['Profile']['LocationGeoPoint'].latitude, widget.wishPost['Profile']['LocationGeoPoint'].longitude)).round()} km",
                                            c: ConstColors.white,
                                            fs: 14.sp);
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // /// report
                            // Positioned(
                            //     right: 8.w,
                            //     top: 62.h,
                            //     child: InkWell(
                            //       onTap: () {
                            //         widget.controllerX.reportBlock(context, toProfileId: widget.wishPost['Profile']['objectId']);
                            //       },
                            //       child: Container(
                            //         height: 50.w,
                            //         width: 50.w,
                            //         padding: EdgeInsets.all(12.w),
                            //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.w), color: ConstColors.black.withOpacity(0.50)),
                            //         child: SvgPicture.asset(
                            //           "assets/Icons/bookmark.svg",
                            //           color: ConstColors.white,
                            //           fit: BoxFit.scaleDown,
                            //         ),
                            //       ),
                            //     )),///
                            // /// profile details
                            // Container(
                            //             margin: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
                            //             padding: EdgeInsets.only(left: 12.w, right: 16.w, top: 7.h, bottom: 7.h),
                            //             height: 82.h,
                            //             width: double.infinity,
                            //             decoration: BoxDecoration(color: ConstColors.black.withOpacity(0.20), borderRadius: BorderRadius.circular(6.r)),
                            //             child: Row(
                            //               children: [
                            //                 Expanded(
                            //                   child: Column(
                            //                     crossAxisAlignment: CrossAxisAlignment.start,
                            //                     children: [
                            //                       Column(
                            //                         crossAxisAlignment: CrossAxisAlignment.start,
                            //                         children: [
                            //                           /// Name
                            //                           SizedBox(
                            //                             width: 210.w,
                            //                             child: Styles.regular(widget.wishPost['Profile']['Name'].toString().capitalizeFirst!,
                            //                                 fs: 20.sp, ov: TextOverflow.ellipsis, fw: FontWeight.bold, ff: "RB", c: ConstColors.white),
                            //                           ),
                            //                           SizedBox(
                            //                             width: 210.w,
                            //                             child: Styles.regular(widget.wishPost['Profile']['Location'],
                            //                                 lns: 2, ov: TextOverflow.ellipsis, fs: 18.sp, ff: "RR", c: ConstColors.white),
                            //                           ),
                            //                         ],
                            //                       ),
                            //                     ],
                            //                   ),
                            //                 ),
                            //                 Column(
                            //                   children: [
                            //                     SizedBox(
                            //                       width: 35.h * myLang.length,
                            //                       height: 35.h,
                            //                       child: ListView.builder(
                            //                         itemCount: myLang.length,
                            //                         shrinkWrap: true,
                            //                         scrollDirection: Axis.horizontal,
                            //                         physics: const NeverScrollableScrollPhysics(),
                            //                         itemBuilder: (context, ind) {
                            //                           return Container(
                            //                             height: 35.h,
                            //                             width: 35.h,
                            //                             decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                            //                             child: Center(
                            //                               child: Image.network(
                            //                                 myLang[ind]['image'],
                            //                                 height: 22.h,
                            //                                 width: 22.w,
                            //                               ),
                            //                             ),
                            //                           );
                            //                         },
                            //                       ),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ],
                            //             ),
                            //           ),///
                          ],
                        ),

                        /// nude show button
                        if (widget.wishPost['IsNude'] ?? false)
                          InkWell(
                            onTap: () async {
                              if (widget.wishPost['Type'].toString().contains('Video')) {
                                ApiResponse? response = await PurchaseNudeVideoProviderApi().getObjectId(widget.wishPost['Video_Post']['objectId'],
                                    widget.wishPost['Profile']['objectId'], StorageService.getBox.read('DefaultProfile'));
                                if (response != null) {
                                  PurchaseNudeVideo nudeVideo = PurchaseNudeVideo();
                                  nudeVideo.objectId = response.results![0]['objectId'];
                                  await PurchaseNudeVideoProviderApi().remove(nudeVideo);
                                } else {
                                  print('response null video ------');
                                }
                              } else {
                                ApiResponse? response = await PurchaseNudeImageProviderApi().getObjectId(widget.wishPost['Img_Post']['objectId'],
                                    widget.wishPost['Profile']['objectId'], StorageService.getBox.read('DefaultProfile'));
                                if (response != null) {
                                  PurchaseNudeImage nudeImage = PurchaseNudeImage();
                                  nudeImage.objectId = response.results![0]['objectId'];
                                  await PurchaseNudeImageProviderApi().remove(nudeImage);
                                } else {
                                  print('response null image ------');
                                }
                              }

                              widget.controllerX.purchaseNude[widget.index] = true;
                              isShow.value = false;
                              if (widget.wishPost['Type'].toString().contains('Video')) {
                                videoPlayerHandler.pause();
                              }
                            },
                            child: Container(
                              height: 40.h,
                              width: 110.w,
                              decoration: BoxDecoration(color: ConstColors.black, borderRadius: BorderRadius.circular(50.r)),
                              alignment: Alignment.center,
                              child: Styles.regular('Hide'.tr, c: ConstColors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              Obx(() {
                if (widget.controllerX.isWishSending.value) {
                  return Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                    child: Lottie.asset(
                      'assets/jsons/wishadd.json',
                      height: 205.h,
                      width: 188.w, repeat: false,
                      // onLoaded: (composition) {
                      //   widget.controllerX.controller!
                      //     ..duration = composition.duration
                      //     ..forward().whenComplete(() {});
                      // },
                    ),
                  );
                }
                if (widget.controllerX.isWishRemove.value) {
                  return Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                    child: Lottie.asset(
                      'assets/jsons/wishremove.json',
                      height: 163.w,
                      width: 163.w,
                      onLoaded: (composition) {
                        widget.controllerX.controller!
                          ..duration = composition.duration
                          ..forward().whenComplete(() {});
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              })
            ],
          ),

          /// Content warning: Nudity
          if ((widget.wishPost['IsNude'] ?? false) && widget.controllerX.purchaseNude[widget.index] && !isShow.value)
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
                        isShow.value = true;
                        widget.controllerX.purchaseNude[widget.index] = false;

                        if (widget.wishPost['Type'].toString().contains('Video') && !videoPlayerHandler.hasError) {
                          PurchaseNudeVideo purchase = PurchaseNudeVideo();
                          purchase.imgPost = UserPostVideo()..objectId = widget.wishPost['Video_Post']['objectId'];
                          purchase.fromprofileId = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
                          purchase.fromuserId = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                          purchase.toprofileId = ProfilePage()..objectId = widget.wishPost['Profile']['objectId'];
                          purchase.touserId = UserLogin()..objectId = widget.wishPost['User']['objectId'];
                          await PurchaseNudeVideoProviderApi().add(purchase);
                          videoPlayerHandler.play();
                        } else {
                          PurchaseNudeImage purchase = PurchaseNudeImage();
                          purchase.imgPost = UserPost()..objectId = widget.wishPost['Img_Post']['objectId'];
                          purchase.fromprofileId = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
                          purchase.fromuserId = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                          purchase.toprofileId = ProfilePage()..objectId = widget.wishPost['Profile']['objectId'];
                          purchase.touserId = UserLogin()..objectId = widget.wishPost['User']['objectId'];
                          await PurchaseNudeImageProviderApi().add(purchase);
                        }
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
        ],
      );
    });
  }
}
