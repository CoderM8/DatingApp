// ignore_for_file: must_be_immutable, invalid_use_of_protected_member, use_build_context_synchronously, deprecated_member_use

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/Widgets/bottom_sheet.dart';
import 'package:eypop/Controllers/Picture_Controller/profile_pic_controller.dart';
import 'package:eypop/Controllers/advertisement_controller.dart';
import 'package:eypop/Controllers/payment_controller.dart';
import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/purchase_nudeimage_api.dart';
import 'package:eypop/back4appservice/repositories/Calls/call_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/delete_conversation_api.dart';
import 'package:eypop/back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/back4appservice/user_provider/vertical_tab/provider_blockuser.dart';
import 'package:eypop/models/call/calls.dart';
import 'package:eypop/models/delete_table.dart';
import 'package:eypop/models/purchase_nudeimage_model.dart';
import 'package:eypop/models/tab_model/heart_like.dart';
import 'package:eypop/models/user_login/user_post.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/verticaltab_model/blockuser.dart';
import 'package:eypop/service/calling.dart';
import 'package:eypop/ui/User_profile/showpicture_screen.dart';
import 'package:eypop/ui/User_profile/showvideo_screen.dart';
import 'package:eypop/ui/call/dial_waiting_page.dart';
import 'package:eypop/ui/store_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

import '../../Constant/Widgets/button.dart';
import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Controllers/price_controller.dart';
import '../../Controllers/translate_controler.dart';
import '../../Controllers/user_controller.dart';
import '../../back4appservice/user_provider/all_notifications/all_notifications.dart';
import '../../back4appservice/user_provider/tab_provider/provider_heartlike.dart';
import '../../models/all_notifications/all_notifications.dart';
import '../../models/new_notification/new_notification_pair.dart';
import '../../models/user_login/user_login.dart';
import '../../service/local_storage.dart';
import '../permission_screen.dart';
import '../tab_pages/conversation_screen.dart';
import 'user_fullprofile_screen.dart';

final UserController _userController = Get.put(UserController());

void getWallData(AppSearchController searchController) {
  searchController.profileIds.value = StorageService.profileBox.values.toList();
  searchController.onLoading().then((value) async {
    if (searchController.finalPost.length <= 3) {
      if (searchController.finalPost.isEmpty) {
        // searchController.page.value = 0;
        for (var element in StorageService.photosBox.values.toList()) {
          if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {
            await StorageService.photosBox.delete(element['id']);
          }
        }
      }
      await searchController.onLoading().then((value) {
        searchController.isPixLoad.value = false;
        searchController.isNearbyLocation.value = false;
      });
    } else {
      searchController.isPixLoad.value = false;
      searchController.isNearbyLocation.value = false;
    }
  });
  searchController.isPixLoad.value = true;
}

class UserPictureScreen extends GetView {
  UserPictureScreen({Key? key}) : super(key: key);

  final PictureController pictureX = Get.put(PictureController());
  final PriceController _priceController = Get.put(PriceController());
  final AppSearchController _searchController = Get.put(AppSearchController());
  final PaymentController paymentController = Get.put(PaymentController());

  final TranslateController translateController = Get.put(TranslateController());
  final AdvertisementController advertisementController = Get.put(AdvertisementController());
  RxBool specialOfferClose = true.obs;
  RxBool status = false.obs;
  int previousIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppSearchController>(builder: (controller) {
      if (!_searchController.load.value) {
        // if (_searchController.profile.isNotEmpty) {
        // _searchController.load.value = true;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          getWallData(_searchController);
        });
      }
      return Obx(() {
        return ModalProgressHUD(
          inAsyncCall: _priceController.isShowConnectCallButton.value == false ? _priceController.isPurchase.value : false,
          blur: 2,
          progressIndicator: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown),
          child: Scaffold(
              body: !_searchController.isPixLoad.value
                  ? _searchController.profileData.isEmpty
                      ? GradientWidget(
                          child: Center(
                            child: Lottie.asset("assets/jsons/fire.json", height: 348.w, width: 348.w, fit: BoxFit.cover),
                          ),
                        )
                      : _searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted == true ||
                              (_searchController.profileData[StorageService.getBox.read('index') ?? 0].isBlocked == true)
                          ? Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.black54,
                              child: Center(
                                child: Styles.regular('your_active_profile_is_deleted'.tr, al: TextAlign.center, c: ConstColors.white),
                              ),
                            )
                          : _searchController.finalPost.isNotEmpty && _searchController.finalPost.length == _searchController.imagePostCount.length
                              ? Swiper(
                                  controller: _searchController.swiperController,
                                  onIndexChanged: (index) {
                                    pictureX.swiperIndex.value = index;

                                    if ((index + 2) < _searchController.finalPost.length) {
                                      DefaultCacheManager().downloadFile(_searchController.finalPost[index + 1]['Post'].url).then((value) {
                                        if ((index + 2) < _searchController.finalPost.length + 1) {
                                          DefaultCacheManager().downloadFile(_searchController.finalPost[index + 2]['Post'].url);
                                        }
                                      });
                                      DefaultCacheManager()
                                          .downloadFile(_searchController.finalPost[index + 1]['Profile']["Imgprofile"].url)
                                          .then((value) {
                                        if ((index + 2) < _searchController.finalPost.length + 1) {
                                          DefaultCacheManager().downloadFile(_searchController.finalPost[index + 2]['Profile']["Imgprofile"].url);
                                        }
                                      });
                                    }

                                    final RxInt index1 =
                                        _searchController.finalPost.indexWhere(((element) => element == _searchController.finalPost.last)).obs;

                                    if (index == (index1.value - 1)) {
                                      for (var element in StorageService.profileBox.values.toList()) {
                                        if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {}
                                      }
                                      _searchController.onLoading().then((value) async {
                                        int total = 0;
                                        for (var element in StorageService.photosBox.values.toList()) {
                                          if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {
                                            total++;
                                          }
                                        }
                                        if (total == _searchController.finalPost.length) {
                                          for (var element in StorageService.photosBox.values.toList()) {
                                            if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {
                                              await StorageService.photosBox.delete(element['id']);
                                            }
                                          }

                                          _searchController.onLoading();
                                        }
                                      });
                                    }
                                    if (index == _searchController.finalPost.length - 5) {
                                      _searchController.onLoading();
                                    }

                                    /// Ads Logic Muro
                                    bool dialogShown = false;
                                    if (!indexMuroList.contains(index)) {
                                      for (var e in advertisementController.adsMuroData) {
                                        if (dialogShown) break;
                                        // Check if Repeat is true and apply the logic
                                        if (e['Repeat'] == true) {
                                          if (index > 0 && (index + 1) % e['EveryXProfiles'] == 0) {
                                            adsDialog(e, index, 'muro');
                                            dialogShown = true;
                                          }
                                        }
                                        // Check the other condition even if Repeat is false
                                        else {
                                          if (index == (e['EveryXProfiles'] - 1)) {
                                            adsDialog(e, index, 'muro');
                                            dialogShown = true;
                                          }
                                        }
                                      }
                                    }
                                  },
                                  loop: pictureX.loop.value,
                                  scrollDirection: Axis.vertical,
                                  itemCount: _searchController.finalPost.length,
                                  index: pictureX.swiperIndex.value,
                                  itemBuilder: (context, index) {
                                    StorageService.photosBox.put(_searchController.finalPost[index]['objectId'], {
                                      'id': '${_searchController.finalPost[index]['objectId']}',
                                      'selfProfileId': StorageService.getBox.read('DefaultProfile'),
                                      'createdAt': '${DateTime.now()}'
                                    });
                                    StorageService.profileBox.put(_searchController.finalPost[index]['Profile']['objectId'], {
                                      'id': '${_searchController.finalPost[index]['Profile']['objectId']}',
                                      'selfProfileId': StorageService.getBox.read('DefaultProfile'),
                                      'createdAt': '${DateTime.now()}'
                                    });

                                    List myLang = [];

                                    for (var language in _searchController.finalPost[index]['Profile']["Language"]) {
                                      for (var element in _userController.langList) {
                                        if (language['objectId'] == element['ObjectId']) {
                                          myLang.add(element);
                                        }
                                      }
                                    }

                                    if (index == _searchController.finalPost.length - 1) {
                                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                        _searchController.page.value = 0;
                                      });

                                      _searchController.onLoading();
                                    }

                                    final RxBool translate = false.obs;
                                    final RxBool isShow = false.obs;

                                    return Stack(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context).size.height,
                                          width: MediaQuery.of(context).size.width,
                                          child: Stack(
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: _searchController.finalPost[index]['Post'].url,
                                                memCacheHeight: 800,
                                                height: MediaQuery.of(context).size.height,
                                                width: MediaQuery.of(context).size.width,
                                                fit: BoxFit.cover,
                                                fadeInDuration: const Duration(seconds: 1),
                                                placeholderFadeInDuration: const Duration(seconds: 1),
                                                placeholder: (context, url) => preCachedFullScreen(UniqueKey()),
                                                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 20.r),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Row(
                                                    //   children: [
                                                    //     Container(
                                                    //       height: 20.h,
                                                    //       width: 20.h,
                                                    //       decoration: BoxDecoration(
                                                    //           color: roundColor(
                                                    //                   _searchController.finalPost[index]['User']['lastOnline'] ??
                                                    //                       DateTime.now().subtract(const Duration(days: 360)),
                                                    //                   context,
                                                    //                   _searchController.finalPost[index]['User']['Gender'])
                                                    //               .color,
                                                    //           shape: BoxShape.circle),
                                                    //     ),
                                                    //     SizedBox(width: 12.w),
                                                    //     Styles.regular(
                                                    //         roundColor(
                                                    //                 _searchController.finalPost[index]['User']['lastOnline'] ??
                                                    //                     DateTime.now().subtract(const Duration(days: 360)),
                                                    //                 context,
                                                    //                 _searchController.finalPost[index]['User']['Gender'])
                                                    //             .title,
                                                    //         fw: FontWeight.bold,
                                                    //         fs: 18.sp,
                                                    //         c: ConstColors.white),
                                                    //   ],
                                                    // ),

                                                    if (_searchController.finalPost[index]['IsNude'] ?? false)
                                                      InkWell(
                                                          onTap: () async {
                                                            isShow.value = false;
                                                            _searchController.showNudeImage[index] = true;
                                                            ApiResponse? response = await PurchaseNudeImageProviderApi().getObjectId(
                                                                _searchController.finalPost[index]['objectId'],
                                                                _searchController.finalPost[index]['Profile']['objectId'],
                                                                StorageService.getBox.read('DefaultProfile'));
                                                            if (response != null) {
                                                              PurchaseNudeImage nudeImage = PurchaseNudeImage();
                                                              nudeImage.objectId = response.results![0]['objectId'];
                                                              await PurchaseNudeImageProviderApi().remove(nudeImage);
                                                            } else {
                                                              print('response null nude image ------');
                                                            }
                                                          },
                                                          child: Align(
                                                            alignment: Alignment.center,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Container(
                                                                  height: 35.h,
                                                                  margin: EdgeInsets.only(bottom: 10.h),
                                                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                                                  decoration: BoxDecoration(
                                                                      color: ConstColors.black, borderRadius: BorderRadius.circular(50.r)),
                                                                  alignment: Alignment.center,
                                                                  child: Styles.regular('Hide'.tr, c: ConstColors.white),
                                                                ),
                                                              ],
                                                            ),
                                                          )),

                                                    Obx(() {
                                                      translate.value;
                                                      return AnimatedSize(
                                                        duration: const Duration(milliseconds: 250),
                                                        curve: Curves.ease,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            if (translate.value == false)
                                                              Expanded(
                                                                  child: Styles.regular(_searchController.finalPost[index]['Profile']['Description'],
                                                                      key: const ValueKey(0),
                                                                      c: ConstColors.white,
                                                                      lns: 3,
                                                                      al: TextAlign.start,
                                                                      fs: translateController.spSize.value.sp,
                                                                      ff: 'RR'))
                                                            else
                                                              FutureBuilder<TranslateLan?>(
                                                                  future: translateController.translateLang(
                                                                      text: _searchController.finalPost[index]['Profile']['Description'],
                                                                      targetLanguage: 'es'),
                                                                  builder: (context, snapshot) {
                                                                    if (snapshot.connectionState == ConnectionState.done) {
                                                                      return Expanded(
                                                                          child: Styles.regular(snapshot.data!.data.translations[0].translatedText,
                                                                              key: const ValueKey(1),
                                                                              c: ConstColors.white,
                                                                              lns: 3,
                                                                              al: TextAlign.start,
                                                                              fs: translateController.spSize.value.sp,
                                                                              ff: 'RR'));
                                                                    } else {
                                                                      return Expanded(
                                                                        child: Shimmer.fromColors(
                                                                            baseColor: ConstColors.subtitle,
                                                                            highlightColor: ConstColors.themeColor,
                                                                            child: Styles.regular(
                                                                                _searchController.finalPost[index]['Profile']['Description'],
                                                                                key: const ValueKey(3),
                                                                                al: TextAlign.start,
                                                                                lns: 3,
                                                                                fs: translateController.spSize.value.sp,
                                                                                c: ConstColors.white,
                                                                                ff: 'RR')),
                                                                      );
                                                                    }
                                                                  }),
                                                            SizedBox(width: 5.w),
                                                            InkWell(
                                                              onTap: () {
                                                                translate.value = !translate.value;
                                                              },
                                                              child: Container(
                                                                height: 40.w,
                                                                width: 40.w,
                                                                alignment: Alignment.center,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(8.r),
                                                                  gradient: LinearGradient(
                                                                      colors: [
                                                                        ConstColors.themeColor.withOpacity(0.3),
                                                                        ConstColors.white.withOpacity(0.3)
                                                                      ],
                                                                      begin: Alignment.topCenter,
                                                                      end: Alignment.bottomCenter,
                                                                      stops: const [0.0, 1.0]),
                                                                ),
                                                                padding: EdgeInsets.all(6.r),
                                                                child: const SvgView('assets/Icons/languageTranslate.svg'),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                                    SizedBox(height: 9.h),
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () async {
                                                            Get.to(
                                                              () => UserFullProfileScreen(
                                                                  toUserId: _searchController.finalPost[index]['User'],
                                                                  toProfileId: _searchController.finalPost[index]['Profile']['objectId']!,
                                                                  fromProfileId: StorageService.getBox.read('DefaultProfile')),
                                                            );
                                                          },
                                                          child: Stack(
                                                            children: [
                                                              Container(
                                                                height: 60.w,
                                                                width: 60.w,
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(color: ConstColors.white, width: 2.w),
                                                                  borderRadius: BorderRadius.circular(30.w),
                                                                  color: ConstColors.white,
                                                                ),
                                                                child: ClipRRect(
                                                                  borderRadius: BorderRadius.circular(30.h),
                                                                  child: CachedNetworkImage(
                                                                    imageUrl: _searchController.finalPost[index]['Profile']["Imgprofile"].url,
                                                                    memCacheHeight: 200,
                                                                    height: 60.w,
                                                                    width: 60.w,
                                                                    fit: BoxFit.cover,
                                                                    fadeInDuration: const Duration(milliseconds: 100),
                                                                    placeholderFadeInDuration: const Duration(milliseconds: 100),
                                                                    placeholder: (context, url) => preCachedSquare(),
                                                                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 0,
                                                                right: 0,
                                                                child: Container(
                                                                  height: 22.h,
                                                                  width: 22.h,
                                                                  decoration: BoxDecoration(color: ConstColors.white, shape: BoxShape.circle),
                                                                  child: CircleAvatar(
                                                                    backgroundImage: AssetImage(
                                                                      'assets/flags/${_searchController.finalPost[index]['Profile']["CountryCode"].toLowerCase()}.png',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(width: 7.w),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                width: 210.w,
                                                                child: Styles.regular(
                                                                    _searchController.finalPost[index]['Profile']["Name"].toString().capitalizeFirst!,
                                                                    fs: 20.sp,
                                                                    ov: TextOverflow.ellipsis,
                                                                    ff: "RB",
                                                                    c: ConstColors.white),
                                                              ),
                                                              SizedBox(
                                                                width: 210.w,
                                                                child: Styles.regular(_searchController.finalPost[index]['Profile']["Location"],
                                                                    lns: 2, ov: TextOverflow.ellipsis, fs: 18.sp, ff: "RR", c: ConstColors.white),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // /// nude show button
                                                        // Container(
                                                        //   height: 40.h,
                                                        //   width: 100.w,
                                                        //   decoration:
                                                        //       BoxDecoration(color: ConstColors.black, borderRadius: BorderRadius.circular(50.r)),
                                                        //   alignment: Alignment.center,
                                                        //   child: Styles.regular('Hide'.tr, c: ConstColors.white),
                                                        // ),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Container(
                                                                alignment: Alignment.center,
                                                                height: 26.h,
                                                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(6.r),
                                                                    color: ConstColors.black.withOpacity(0.50)),
                                                                child: Obx(() {
                                                                  _searchController.profileData;
                                                                  if (_searchController.profileData.isNotEmpty) {
                                                                    return Styles.regular(
                                                                        "${(_searchController.calculateDistance(_searchController.profileData[StorageService.getBox.read('index') ?? 0].locationGeoPoint.latitude, _searchController.profileData[StorageService.getBox.read('index') ?? 0].locationGeoPoint.longitude, _searchController.finalPost[index]['Profile']['LocationGeoPoint'].latitude, _searchController.finalPost[index]['Profile']['LocationGeoPoint'].longitude)).round()} km",
                                                                        fs: 18.sp,
                                                                        c: ConstColors.white);
                                                                  } else {
                                                                    return Styles.regular("0 km", fs: 18.sp, c: ConstColors.white);
                                                                  }
                                                                })),
                                                            SizedBox(
                                                              height: 35.h,
                                                              child: ListView.separated(
                                                                itemCount: myLang.length,
                                                                shrinkWrap: true,
                                                                scrollDirection: Axis.horizontal,
                                                                physics: const NeverScrollableScrollPhysics(),
                                                                separatorBuilder: (context, index) {
                                                                  return SizedBox(width: 5.w);
                                                                },
                                                                itemBuilder: (context, ind) {
                                                                  return Center(
                                                                    child: Image.network(myLang[ind]['image'], height: 22.h, width: 22.w),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 25.h),
                                                    BlurryContainer(
                                                        height: 76.h,
                                                        width: 388.w,
                                                        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 10.h, bottom: 10.h),
                                                        borderRadius: BorderRadius.circular(40.r),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            // CHAT
                                                            Option(
                                                              onTap: (isBusy, isOnline) {
                                                                bool onlineStatus;

                                                                if ((_searchController.finalPost[index]['Profile']['NoChats'] ?? false) == false &&
                                                                    (_searchController.finalPost[index]['User']['HasLoggedIn'] ?? true == true)) {
                                                                  onlineStatus = true;
                                                                  print('online status True ======');
                                                                } else {
                                                                  onlineStatus = false;
                                                                  print('online status False ======');
                                                                }
                                                                // if (_searchController.finalPost[index]['Profile']['NoChats'] ?? false) {
                                                                //   onlineStatus = false;
                                                                // } else {
                                                                //   onlineStatus = true;
                                                                // }
                                                                StorageService.getBox
                                                                    .write('msgFromProfileId', StorageService.getBox.read('DefaultProfile'));
                                                                StorageService.getBox.write(
                                                                    'msgToProfileId', _searchController.finalPost[index]['Profile']['objectId']);
                                                                StorageService.getBox.write('chattablename', 'Chat_Message');
                                                                StorageService.getBox.save();
                                                                Get.to(
                                                                  () => ConversationScreen(
                                                                    fromUserDeleted: false,
                                                                    toUserDeleted: (_searchController.finalPost[index]['Profile']['isDeleted'] ||
                                                                        (_searchController.finalPost[index]['User']['isDeleted'] ?? false)),
                                                                    toUser: _searchController.finalPost[index]['User'],
                                                                    onlineStatus: onlineStatus,
                                                                    tableName: 'Chat_Message',
                                                                    fromUserImg: StorageService.getBox.read('DefaultProfileImg'),
                                                                    toProfileName: _searchController.finalPost[index]['Profile']["Name"],
                                                                    toProfileImg: _searchController.finalPost[index]['Profile']["Imgprofile"].url,
                                                                    fromProfileId: StorageService.getBox.read('DefaultProfile'),
                                                                    toProfileId: _searchController.finalPost[index]['Profile']['objectId'],
                                                                    toUserGender: _searchController.finalPost[index]['User']['Gender'],
                                                                    toUserId: _searchController.finalPost[index]['User']['objectId'],
                                                                  ),
                                                                );
                                                              },
                                                              svg: 'assets/Icons/chat.svg',
                                                              enable: true,
                                                              online: ((_searchController.finalPost[index]['Profile']['NoChats'] ?? false == false) &&
                                                                          (_searchController.finalPost[index]['User']['HasLoggedIn'] ??
                                                                              true == true)) ==
                                                                      false
                                                                  ? true
                                                                  : false,
                                                              userId: _searchController.finalPost[index]['User']['objectId'],
                                                              profileId: _searchController.finalPost[index]['Profile']['objectId'],
                                                              title: 'chat',
                                                            ),

                                                            // AUDIO CALL
                                                            Option(
                                                                onTap: (isBusy, isOnline) async {
                                                                  showBottomSheetAudioVideoCall(
                                                                    context,
                                                                    title: 'call'.tr,
                                                                    callTitle: 'make_call'.tr,
                                                                    description: 'call_description'.tr,
                                                                    isOnline: isOnline,
                                                                    askPermissionOnTap: () {
                                                                      Get.back();
                                                                      bool onlineStatus;

                                                                      if ((_searchController.finalPost[index]['Profile']['NoChats'] ?? false) ==
                                                                              false &&
                                                                          (_searchController.finalPost[index]['User']['HasLoggedIn'] ??
                                                                              true == true)) {
                                                                        onlineStatus = true;
                                                                        print('online status True ======');
                                                                      } else {
                                                                        onlineStatus = false;
                                                                        print('online status False ======');
                                                                      }

                                                                      // if (_searchController.finalPost[index]['Profile']['NoChats'] ?? false) {
                                                                      //   onlineStatus = false;
                                                                      // } else {
                                                                      //   onlineStatus = true;
                                                                      // }
                                                                      StorageService.getBox
                                                                          .write('msgFromProfileId', StorageService.getBox.read('DefaultProfile'));
                                                                      StorageService.getBox.write('msgToProfileId',
                                                                          _searchController.finalPost[index]['Profile']['objectId']);
                                                                      StorageService.getBox.write('chattablename', 'Chat_Message');
                                                                      StorageService.getBox.save();
                                                                      _priceController.chat.text = 'I_can_call_you_now'.tr;
                                                                      Get.to(
                                                                        () => ConversationScreen(
                                                                          fromUserDeleted: false,
                                                                          toUserDeleted: (_searchController.finalPost[index]['Profile']
                                                                                  ['isDeleted'] ||
                                                                              (_searchController.finalPost[index]['User']['isDeleted'] ?? false)),
                                                                          toUser: _searchController.finalPost[index]['User'],
                                                                          onlineStatus: onlineStatus,
                                                                          tableName: 'Chat_Message',
                                                                          fromUserImg: StorageService.getBox.read('DefaultProfileImg'),
                                                                          toProfileName: _searchController.finalPost[index]['Profile']["Name"],
                                                                          toProfileImg:
                                                                              _searchController.finalPost[index]['Profile']["Imgprofile"].url,
                                                                          fromProfileId: StorageService.getBox.read('DefaultProfile'),
                                                                          toProfileId: _searchController.finalPost[index]['Profile']['objectId'],
                                                                          toUserGender: _searchController.finalPost[index]['User']['Gender'],
                                                                          toUserId: _searchController.finalPost[index]['User']['objectId'],
                                                                        ),
                                                                      );
                                                                    },
                                                                    callOnTap: () async {
                                                                      await checkUserPermission();
                                                                      final PermissionStatus status = await Permission.microphone.status;
                                                                      if (status.isGranted) {
                                                                        if (_priceController.isPurchase.value == false) {
                                                                          Navigator.pop(context);
                                                                          _priceController.isShowConnectCallButton.value = true;
                                                                          _priceController.isPurchase.value = true;
                                                                          if (StorageService.getBox.read('Gender') == 'female') {
                                                                            final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                                                                            String fromUserId = StorageService.getBox.read('ObjectId');
                                                                            String toUserId = _searchController.finalPost[index]['User']['objectId'];
                                                                            String channelName = '${fromUserId}_$toUserId';

                                                                            PairNotifications pairNotifications = PairNotifications();

                                                                            pairNotifications.toProfile = ProfilePage()
                                                                              ..objectId = _searchController.finalPost[index]['Profile']['objectId'];
                                                                            pairNotifications.fromProfile = ProfilePage()
                                                                              ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                            pairNotifications.users = [
                                                                              ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'),
                                                                              ProfilePage()
                                                                                ..objectId = _searchController.finalPost[index]['Profile']['objectId']
                                                                            ];
                                                                            pairNotifications.message = '';
                                                                            pairNotifications.notificationType = 'Call';
                                                                            pairNotifications.isPurchased = true;
                                                                            pairNotifications.isRead = true;
                                                                            pairNotifications.fromUser = UserLogin()
                                                                              ..objectId = StorageService.getBox.read('ObjectId');
                                                                            pairNotifications.toUser = UserLogin()..objectId = toUserId;

                                                                            final ApiResponse apiResponse =
                                                                                await PairNotificationProviderApi().add(pairNotifications);
                                                                            if (isBusy) {
                                                                              _priceController.isShowConnectCallButton.value = false;
                                                                              Get.to(() => DialWaitingPage(
                                                                                        img: _searchController
                                                                                            .finalPost[index]['Profile']['Imgprofile'].url,
                                                                                        name: _searchController.finalPost[index]['Profile']['Name'],
                                                                                        pairNotificationsId: apiResponse.result['objectId'],
                                                                                      ))!
                                                                                  .whenComplete(() {
                                                                                _priceController.isPurchase.value = false;
                                                                                _priceController.isShowConnectCallButton.value = false;
                                                                              });
                                                                            } else {
                                                                              final CallModel callModel = CallModel();
                                                                              callModel.reason = 'OffLine';
                                                                              callModel.fromUserId = ProfilePage()
                                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                              callModel.fromUser = UserLogin()..objectId = fromUserId;
                                                                              callModel.toUserID = ProfilePage()
                                                                                ..objectId =
                                                                                    _searchController.finalPost[index]['Profile']['objectId'];
                                                                              callModel.toUser = UserLogin()..objectId = toUserId;
                                                                              callModel.accepted = false;
                                                                              callModel.duration = '00:00:00';
                                                                              callModel.isVoice = true;
                                                                              callModel.status = 0;
                                                                              callModel.channelName = channelName;
                                                                              callModel.isCallEnd = false;
                                                                              callModel.callerType = 'Sender';
                                                                              callModel.pairNotification = PairNotifications()
                                                                                ..objectId = apiResponse.result['objectId'];

                                                                              final save = await userCallProviderApi.add(callModel);
                                                                              pairNotifications.objectId = apiResponse.result['objectId'];
                                                                              pairNotifications["call"] = CallModel()
                                                                                ..objectId = save.result['objectId'];
                                                                              await PairNotificationProviderApi().update(pairNotifications);
                                                                              if (_searchController.finalPost[index]['User']['CallNotification']) {
                                                                                CallService.makeCall(
                                                                                  userId: _searchController.finalPost[index]['User']['objectId'],
                                                                                  type: "Calling you",
                                                                                  callId: save.result['objectId'],
                                                                                  isVoiceCall: true,
                                                                                );
                                                                              }
                                                                            }

                                                                            Notifications notifications = Notifications();
                                                                            notifications.toUser = UserLogin()..objectId = toUserId;
                                                                            notifications.fromUser = UserLogin()
                                                                              ..objectId = StorageService.getBox.read('ObjectId');
                                                                            notifications.toProfile = ProfilePage()
                                                                              ..objectId = _searchController.finalPost[index]['Profile']['objectId'];
                                                                            notifications.fromProfile = ProfilePage()
                                                                              ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                            notifications.notificationType = 'Call';
                                                                            notifications.isRead = false;

                                                                            NotificationsProviderApi().add(notifications);
                                                                            // }
                                                                          } else {
                                                                            if (_priceController.userTotalCoin.value >=
                                                                                _priceController.callPrice.value) {
                                                                              final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                                                                              String fromUserId = StorageService.getBox.read('ObjectId');
                                                                              String toUserId =
                                                                                  _searchController.finalPost[index]['User']['objectId'];
                                                                              String channelName = '${fromUserId}_$toUserId';
                                                                              PairNotifications pairNotifications = PairNotifications();

                                                                              pairNotifications.toProfile = ProfilePage()
                                                                                ..objectId =
                                                                                    _searchController.finalPost[index]['Profile']['objectId'];
                                                                              pairNotifications.fromProfile = ProfilePage()
                                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                              pairNotifications.users = [
                                                                                ProfilePage()
                                                                                  ..objectId = StorageService.getBox.read('DefaultProfile'),
                                                                                ProfilePage()
                                                                                  ..objectId =
                                                                                      _searchController.finalPost[index]['Profile']['objectId']
                                                                              ];
                                                                              pairNotifications.message = '';
                                                                              pairNotifications.notificationType = 'Call';
                                                                              pairNotifications.isPurchased = true;
                                                                              pairNotifications.isRead = true;
                                                                              pairNotifications.fromUser = UserLogin()
                                                                                ..objectId = StorageService.getBox.read('ObjectId');
                                                                              pairNotifications.toUser = UserLogin()..objectId = toUserId;

                                                                              final ApiResponse apiResponse =
                                                                                  await PairNotificationProviderApi().add(pairNotifications);
                                                                              if (isBusy) {
                                                                                _priceController.isShowConnectCallButton.value = false;
                                                                                Get.to(() => DialWaitingPage(
                                                                                          img: _searchController
                                                                                              .finalPost[index]['Profile']['Imgprofile'].url,
                                                                                          name: _searchController.finalPost[index]['Profile']['Name'],
                                                                                          pairNotificationsId: apiResponse.result['objectId'],
                                                                                        ))!
                                                                                    .whenComplete(() {
                                                                                  _priceController.isPurchase.value = false;
                                                                                  _priceController.isShowConnectCallButton.value = false;
                                                                                });
                                                                              } else {
                                                                                CallModel callModel = CallModel();
                                                                                callModel.reason = 'OffLine';
                                                                                callModel.fromUserId = ProfilePage()
                                                                                  ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                                callModel.fromUser = UserLogin()..objectId = fromUserId;
                                                                                callModel.toUserID = ProfilePage()
                                                                                  ..objectId =
                                                                                      _searchController.finalPost[index]['Profile']['objectId'];
                                                                                callModel.toUser = UserLogin()..objectId = toUserId;
                                                                                callModel.accepted = false;
                                                                                callModel.duration = '00:00:00';
                                                                                callModel.isVoice = true;
                                                                                callModel.status = 0;
                                                                                callModel.channelName = channelName;
                                                                                callModel.isCallEnd = false;
                                                                                callModel.callerType = 'Sender';
                                                                                callModel.pairNotification = PairNotifications()
                                                                                  ..objectId = apiResponse.result['objectId'];
                                                                                final save = await userCallProviderApi.add(callModel);
                                                                                pairNotifications.objectId = apiResponse.result['objectId'];
                                                                                pairNotifications["call"] = CallModel()
                                                                                  ..objectId = save.result['objectId'];
                                                                                await PairNotificationProviderApi().update(pairNotifications);
                                                                                if (_searchController.finalPost[index]['User']['CallNotification']) {
                                                                                  CallService.makeCall(
                                                                                    userId: _searchController.finalPost[index]['User']['objectId'],
                                                                                    type: "Calling you",
                                                                                    callId: save.result['objectId'],
                                                                                    isVoiceCall: true,
                                                                                  );
                                                                                }
                                                                              }

                                                                              Notifications notifications = Notifications();
                                                                              notifications.toUser = UserLogin()..objectId = toUserId;
                                                                              notifications.fromUser = UserLogin()
                                                                                ..objectId = StorageService.getBox.read('ObjectId');
                                                                              notifications.toProfile = ProfilePage()
                                                                                ..objectId =
                                                                                    _searchController.finalPost[index]['Profile']['objectId'];
                                                                              notifications.fromProfile = ProfilePage()
                                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                              notifications.notificationType = 'Call';
                                                                              notifications.isRead = false;

                                                                              NotificationsProviderApi().add(notifications);
                                                                            } else {
                                                                              _priceController.isPurchase.value = false;
                                                                              _priceController.isShowConnectCallButton.value = false;
                                                                              Get.to(() => StoreScreen());
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    },
                                                                  );
                                                                },
                                                                svg: 'assets/Icons/call.svg',
                                                                enable: true,
                                                                // online: _searchController.finalPost[index]['Profile']['NoCalls'] ?? false,
                                                                online:
                                                                    ((_searchController.finalPost[index]['Profile']['NoCalls'] ?? false == false) &&
                                                                                (_searchController.finalPost[index]['User']['HasLoggedIn'] ??
                                                                                    true == true)) ==
                                                                            false
                                                                        ? true
                                                                        : false,
                                                                title: 'call',
                                                                profileId: _searchController.finalPost[index]['Profile']['objectId'],
                                                                userId: _searchController.finalPost[index]['User']['objectId']), // VIDEO CALL
                                                            Option(
                                                                onTap: (isBusy, isOnline) async {
                                                                  showBottomSheetAudioVideoCall(
                                                                    context,
                                                                    title: 'videocall'.tr,
                                                                    callTitle: 'make_videocall'.tr,
                                                                    description: 'videocall_description'.tr,
                                                                    isOnline: isOnline,
                                                                    askPermissionOnTap: () {
                                                                      Get.back();
                                                                      bool onlineStatus;

                                                                      if ((_searchController.finalPost[index]['Profile']['NoChats'] ?? false) ==
                                                                              false &&
                                                                          (_searchController.finalPost[index]['User']['HasLoggedIn'] ??
                                                                              true == true)) {
                                                                        onlineStatus = true;
                                                                        print('online status True ======');
                                                                      } else {
                                                                        onlineStatus = false;
                                                                        print('online status False ======');
                                                                      }

                                                                      // if (_searchController.finalPost[index]['Profile']['NoChats'] ?? false) {
                                                                      //   onlineStatus = false;
                                                                      // } else {
                                                                      //   onlineStatus = true;
                                                                      // }
                                                                      StorageService.getBox
                                                                          .write('msgFromProfileId', StorageService.getBox.read('DefaultProfile'));
                                                                      StorageService.getBox.write('msgToProfileId',
                                                                          _searchController.finalPost[index]['Profile']['objectId']);
                                                                      StorageService.getBox.write('chattablename', 'Chat_Message');
                                                                      StorageService.getBox.save();
                                                                      _priceController.chat.text = 'I_can_call_you_now'.tr;
                                                                      Get.to(
                                                                        () => ConversationScreen(
                                                                          fromUserDeleted: false,
                                                                          toUserDeleted: (_searchController.finalPost[index]['Profile']
                                                                                  ['isDeleted'] ||
                                                                              (_searchController.finalPost[index]['User']['isDeleted'] ?? false)),
                                                                          toUser: _searchController.finalPost[index]['User'],
                                                                          onlineStatus: onlineStatus,
                                                                          tableName: 'Chat_Message',
                                                                          fromUserImg: StorageService.getBox.read('DefaultProfileImg'),
                                                                          toProfileName: _searchController.finalPost[index]['Profile']["Name"],
                                                                          toProfileImg:
                                                                              _searchController.finalPost[index]['Profile']["Imgprofile"].url,
                                                                          fromProfileId: StorageService.getBox.read('DefaultProfile'),
                                                                          toProfileId: _searchController.finalPost[index]['Profile']['objectId'],
                                                                          toUserGender: _searchController.finalPost[index]['User']['Gender'],
                                                                          toUserId: _searchController.finalPost[index]['User']['objectId'],
                                                                        ),
                                                                      );
                                                                    },
                                                                    callOnTap: () async {
                                                                      await checkUserPermission(video: true);
                                                                      final PermissionStatus microphone = await Permission.microphone.status;
                                                                      final PermissionStatus camera = await Permission.camera.status;
                                                                      if (microphone.isGranted && camera.isGranted) {
                                                                        if (_priceController.isPurchase.value == false) {
                                                                          Navigator.pop(context);
                                                                          _priceController.isShowConnectCallButton.value = true;
                                                                          _priceController.isPurchase.value = true;
                                                                          if (StorageService.getBox.read('Gender') == 'female') {
                                                                            final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                                                                            final String fromUserId = StorageService.getBox.read('ObjectId');
                                                                            final String toUserId =
                                                                                _searchController.finalPost[index]['User']['objectId'];
                                                                            final String channelName = '${fromUserId}_$toUserId';

                                                                            final PairNotifications pairNotifications = PairNotifications();

                                                                            pairNotifications.toProfile = ProfilePage()
                                                                              ..objectId = _searchController.finalPost[index]['Profile']['objectId'];
                                                                            pairNotifications.fromProfile = ProfilePage()
                                                                              ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                            pairNotifications.users = [
                                                                              ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'),
                                                                              ProfilePage()
                                                                                ..objectId = _searchController.finalPost[index]['Profile']['objectId']
                                                                            ];
                                                                            pairNotifications.message = '';
                                                                            pairNotifications.notificationType = 'VideoCall';
                                                                            pairNotifications.isPurchased = true;
                                                                            pairNotifications.isRead = true;
                                                                            pairNotifications.fromUser = UserLogin()
                                                                              ..objectId = StorageService.getBox.read('ObjectId');
                                                                            pairNotifications.toUser = UserLogin()..objectId = toUserId;

                                                                            final ApiResponse apiResponse =
                                                                                await PairNotificationProviderApi().add(pairNotifications);
                                                                            if (isBusy) {
                                                                              _priceController.isShowConnectCallButton.value = false;
                                                                              Get.to(() => DialWaitingPage(
                                                                                        img: _searchController
                                                                                            .finalPost[index]['Profile']['Imgprofile'].url,
                                                                                        name: _searchController.finalPost[index]['Profile']['Name'],
                                                                                        pairNotificationsId: apiResponse.result['objectId'],
                                                                                      ))!
                                                                                  .whenComplete(() {
                                                                                _priceController.isShowConnectCallButton.value = false;
                                                                                _priceController.isPurchase.value = false;
                                                                              });
                                                                            } else {
                                                                              final CallModel callModel = CallModel();
                                                                              callModel.reason = 'OffLine';
                                                                              callModel.fromUserId = ProfilePage()
                                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                              callModel.fromUser = UserLogin()..objectId = fromUserId;
                                                                              callModel.toUserID = ProfilePage()
                                                                                ..objectId =
                                                                                    _searchController.finalPost[index]['Profile']['objectId'];
                                                                              callModel.toUser = UserLogin()..objectId = toUserId;
                                                                              callModel.accepted = false;
                                                                              callModel.duration = '00:00:00';
                                                                              callModel.isVoice = false;
                                                                              callModel.status = 0;
                                                                              callModel.channelName = channelName;
                                                                              callModel.isCallEnd = false;
                                                                              callModel.callerType = 'Sender';
                                                                              callModel.pairNotification = PairNotifications()
                                                                                ..objectId = apiResponse.result['objectId'];

                                                                              final save = await userCallProviderApi.add(callModel);
                                                                              pairNotifications.objectId = apiResponse.result['objectId'];
                                                                              pairNotifications["call"] = CallModel()
                                                                                ..objectId = save.result['objectId'];
                                                                              await PairNotificationProviderApi().update(pairNotifications);
                                                                              if (_searchController.finalPost[index]['User']['CallNotification']) {
                                                                                CallService.makeCall(
                                                                                  userId: _searchController.finalPost[index]['User']['objectId'],
                                                                                  type: "Calling you",
                                                                                  callId: save.result['objectId'],
                                                                                  isVoiceCall: false,
                                                                                );
                                                                              }
                                                                            }

                                                                            final Notifications notifications = Notifications();
                                                                            notifications.toUser = UserLogin()..objectId = toUserId;
                                                                            notifications.fromUser = UserLogin()
                                                                              ..objectId = StorageService.getBox.read('ObjectId');
                                                                            notifications.toProfile = ProfilePage()
                                                                              ..objectId = _searchController.finalPost[index]['Profile']['objectId'];
                                                                            notifications.fromProfile = ProfilePage()
                                                                              ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                            notifications.notificationType = 'VideoCall';
                                                                            notifications.isRead = false;

                                                                            NotificationsProviderApi().add(notifications);
                                                                            // }
                                                                          } else {
                                                                            if (_priceController.userTotalCoin.value >=
                                                                                _priceController.videoCallPrice.value) {
                                                                              final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                                                                              final String fromUserId = StorageService.getBox.read('ObjectId');
                                                                              final String toUserId =
                                                                                  _searchController.finalPost[index]['User']['objectId'];
                                                                              final String channelName = '${fromUserId}_$toUserId';
                                                                              final PairNotifications pairNotifications = PairNotifications();

                                                                              pairNotifications.toProfile = ProfilePage()
                                                                                ..objectId =
                                                                                    _searchController.finalPost[index]['Profile']['objectId'];
                                                                              pairNotifications.fromProfile = ProfilePage()
                                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                              pairNotifications.users = [
                                                                                ProfilePage()
                                                                                  ..objectId = StorageService.getBox.read('DefaultProfile'),
                                                                                ProfilePage()
                                                                                  ..objectId =
                                                                                      _searchController.finalPost[index]['Profile']['objectId']
                                                                              ];
                                                                              pairNotifications.message = '';
                                                                              pairNotifications.notificationType = 'VideoCall';
                                                                              pairNotifications.isPurchased = true;
                                                                              pairNotifications.isRead = true;
                                                                              pairNotifications.fromUser = UserLogin()
                                                                                ..objectId = StorageService.getBox.read('ObjectId');
                                                                              pairNotifications.toUser = UserLogin()..objectId = toUserId;

                                                                              final ApiResponse apiResponse =
                                                                                  await PairNotificationProviderApi().add(pairNotifications);
                                                                              if (isBusy) {
                                                                                _priceController.isShowConnectCallButton.value = false;
                                                                                Get.to(() => DialWaitingPage(
                                                                                        img: _searchController
                                                                                            .finalPost[index]['Profile']['Imgprofile'].url,
                                                                                        pairNotificationsId: apiResponse.result['objectId'],
                                                                                        name: _searchController.finalPost[index]['Profile']['Name']))!
                                                                                    .whenComplete(() {
                                                                                  _priceController.isPurchase.value = false;
                                                                                  _priceController.isShowConnectCallButton.value = false;
                                                                                });
                                                                              } else {
                                                                                final CallModel callModel = CallModel();
                                                                                callModel.reason = 'OffLine';
                                                                                callModel.fromUserId = ProfilePage()
                                                                                  ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                                callModel.fromUser = UserLogin()..objectId = fromUserId;
                                                                                callModel.toUserID = ProfilePage()
                                                                                  ..objectId =
                                                                                      _searchController.finalPost[index]['Profile']['objectId'];
                                                                                callModel.toUser = UserLogin()..objectId = toUserId;
                                                                                callModel.accepted = false;
                                                                                callModel.duration = '00:00:00';
                                                                                callModel.isVoice = false;
                                                                                callModel.status = 0;
                                                                                callModel.channelName = channelName;
                                                                                callModel.isCallEnd = false;
                                                                                callModel.callerType = 'Sender';
                                                                                callModel.pairNotification = PairNotifications()
                                                                                  ..objectId = apiResponse.result['objectId'];
                                                                                final save = await userCallProviderApi.add(callModel);
                                                                                pairNotifications.objectId = apiResponse.result['objectId'];
                                                                                pairNotifications["call"] = CallModel()
                                                                                  ..objectId = save.result['objectId'];
                                                                                await PairNotificationProviderApi().update(pairNotifications);
                                                                                if (_searchController.finalPost[index]['User']['CallNotification']) {
                                                                                  CallService.makeCall(
                                                                                    userId: _searchController.finalPost[index]['User']['objectId'],
                                                                                    type: "Calling you",
                                                                                    callId: save.result['objectId'],
                                                                                    isVoiceCall: false,
                                                                                  );
                                                                                }
                                                                              }

                                                                              final Notifications notifications = Notifications();
                                                                              notifications.toUser = UserLogin()..objectId = toUserId;
                                                                              notifications.fromUser = UserLogin()
                                                                                ..objectId = StorageService.getBox.read('ObjectId');
                                                                              notifications.toProfile = ProfilePage()
                                                                                ..objectId =
                                                                                    _searchController.finalPost[index]['Profile']['objectId'];
                                                                              notifications.fromProfile = ProfilePage()
                                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                              notifications.notificationType = 'VideoCall';
                                                                              notifications.isRead = false;

                                                                              NotificationsProviderApi().add(notifications);
                                                                            } else {
                                                                              _priceController.isPurchase.value = false;
                                                                              _priceController.isShowConnectCallButton.value = false;
                                                                              Get.to(() => StoreScreen());
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    },
                                                                  );
                                                                },
                                                                svg: 'assets/Icons/video_camera.svg',
                                                                enable: true,
                                                                // online: _searchController.finalPost[index]['Profile']['NoVideocalls'] ?? false,
                                                                online: ((_searchController.finalPost[index]['Profile']['NoVideocalls'] ??
                                                                                false == false) &&
                                                                            (_searchController.finalPost[index]['User']['HasLoggedIn'] ??
                                                                                true == true)) ==
                                                                        false
                                                                    ? true
                                                                    : false,
                                                                title: 'VideoCall',
                                                                profileId: _searchController.finalPost[index]['Profile']['objectId'],
                                                                userId: _searchController.finalPost[index]['User']['objectId']), // MESSAGE
                                                            Option(
                                                                svg: 'assets/Icons/heartMessage.svg',
                                                                enable: false,
                                                                onTap: (isBusy, isOnline) {
                                                                  addBottomOption(
                                                                      controller: pictureX.spam,
                                                                      context: context,
                                                                      isTextField: true,
                                                                      title: 'send_a_message'.tr,
                                                                      description: 'sending_messages'.tr,
                                                                      subTitle: 'break_ice_with_kiss'.tr,
                                                                      buttontitle: 'sendmessage'.tr,
                                                                      ontap: () async {
                                                                        if (pictureX.spam.text.removeAllWhitespace.isNotEmpty) {
                                                                          _priceController.coinService(
                                                                              'HeartMessage',
                                                                              _searchController.finalPost[index]['User']["Gender"],
                                                                              _searchController.finalPost[index]['Profile']['objectId']!,
                                                                              _searchController.finalPost[index]['User']['objectId'],
                                                                              catValue: _priceController.heartMessagePrice.value);
                                                                        }
                                                                      },
                                                                      select: false,
                                                                      hint: 'write_your_message_here'.tr,
                                                                      height: 460.h);
                                                                },
                                                                title: 'message',
                                                                profileId: _searchController.finalPost[index]['Profile']['objectId'],
                                                                userId: _searchController.finalPost[index]['User']['objectId']), // WINK
                                                            Option(
                                                                svg: 'assets/Icons/wink.svg',
                                                                enable: false,
                                                                onTap: (isBusy, isOnline) {
                                                                  addBottomOption(
                                                                      dropdownList: pictureX.winkItems,
                                                                      context: context,
                                                                      controller: pictureX.winkMsg,
                                                                      description: 'sending_winks'.tr,
                                                                      title: 'send_a_wink'.tr,
                                                                      subTitle: 'get_her_attention'.tr,
                                                                      buttontitle: 'sendwink'.tr,
                                                                      ontap: () async {
                                                                        if (pictureX.winkMsg.text.isNotEmpty) {
                                                                          _priceController.coinService(
                                                                              'WinkMessage',
                                                                              _searchController.finalPost[index]['User']["Gender"],
                                                                              _searchController.finalPost[index]['Profile']['objectId']!,
                                                                              _searchController.finalPost[index]['User']['objectId'],
                                                                              catValue: _priceController.winkMessagePrice.value);
                                                                        } else {
                                                                          Get.back();
                                                                        }
                                                                      },
                                                                      select: false,
                                                                      hint: 'click_here'.tr,
                                                                      sufiix: true,
                                                                      height: 460.h);
                                                                },
                                                                title: 'wink',
                                                                profileId: _searchController.finalPost[index]['Profile']['objectId'],
                                                                userId: _searchController.finalPost[index]['User']['objectId']), // LIPLIKE
                                                            Option(
                                                                svg: 'assets/Icons/lipLike.svg',
                                                                enable: false,
                                                                userId: _searchController.finalPost[index]['User']['objectId'],
                                                                profileId: _searchController.finalPost[index]['Profile']['objectId'],
                                                                title: 'lips',
                                                                onTap: (isBusy, isOnline) {
                                                                  showModalBottomSheet(
                                                                    context: context,
                                                                    backgroundColor: Theme.of(context).dialogBackgroundColor,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
                                                                    builder: (context) {
                                                                      return Padding(
                                                                        padding: EdgeInsets.only(
                                                                            top: 14.h,
                                                                            left: 20.w,
                                                                            right: 20.w,
                                                                            bottom: MediaQuery.of(context).padding.bottom + 10),
                                                                        child: Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                                                                            SizedBox(height: 12.h),
                                                                            Styles.regular('send_a_kiss'.tr,
                                                                                c: Theme.of(context).primaryColor, ff: 'HB', fs: 18.sp),
                                                                            SizedBox(height: 20.h),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                                                                              child: Styles.regular('sending_kiss_attention'.tr,
                                                                                  al: TextAlign.center, c: Theme.of(context).primaryColor, fs: 18.sp),
                                                                            ),
                                                                            Lottie.asset('assets/jsons/liplike.json', height: 150.w, width: 150.w),
                                                                            // only male side show this text
                                                                            if (StorageService.getBox.read('Gender') == 'male')
                                                                              Padding(
                                                                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                                                                child: Styles.regular('sending_kiss'.tr,
                                                                                    al: TextAlign.center, c: ConstColors.bottomBorder, fs: 18.sp),
                                                                              ),
                                                                            SizedBox(height: 26.h),
                                                                            GradientButton(
                                                                                title: 'sendkiss'.tr,
                                                                                onTap: () {
                                                                                  if (!pictureX.visible.value) {
                                                                                    Get.back();
                                                                                    _priceController.coinService(
                                                                                        'LipLike',
                                                                                        _searchController.finalPost[index]['User']["Gender"],
                                                                                        _searchController.finalPost[index]['Profile']['objectId']!,
                                                                                        _searchController.finalPost[index]['User']['objectId'],
                                                                                        catValue: _priceController.lipLikePrice.value);
                                                                                  }
                                                                                })
                                                                          ],
                                                                        ),
                                                                      );
                                                                      // });
                                                                    },
                                                                  );
                                                                }),
                                                          ],
                                                        )),
                                                    SizedBox(height: 36.h)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        ///second
                                        Padding(
                                          padding: EdgeInsets.only(top: 70.h, left: 20.w, right: 20.w),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(bottom: 6.h),
                                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                                decoration: BoxDecoration(
                                                  color: boxColor(_searchController.finalPost[index]['Profile']['createdAt']),
                                                  borderRadius: BorderRadius.circular(5.r),
                                                ),
                                                child: Styles.regular(
                                                    boxText(_searchController.finalPost[index]['Profile']['createdAt'], context,
                                                        _searchController.finalPost[index]['User']['Gender']),
                                                    fw: FontWeight.bold,
                                                    fs: 18.sp,
                                                    c: ConstColors.white),
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    children: [
                                                      /// show medal icon
                                                      if (_searchController.finalPost[index]['Profile']['Medal'] != null) ...[
                                                        showMedal(_searchController.finalPost[index]['Profile']['Medal'] ?? ''),
                                                        SizedBox(height: 6.h),
                                                      ],

                                                      /// post count
                                                      InkWell(
                                                        onTap: () {
                                                          Get.to(() => ShowPictureScreen(
                                                                imgObjectId: _searchController.finalPost[index]['objectId'],
                                                                toUserDefaultProfileId:
                                                                    _searchController.finalPost[index]['Profile']['DefaultImg']?['objectId'] ?? '',
                                                                fromProfileId: StorageService.getBox.read('DefaultProfile'),
                                                                visitMode: true,
                                                                index: 0,
                                                                isPictureScreen: true,
                                                                toProfileId: _searchController.finalPost[index]['Profile']['objectId'],
                                                              ));
                                                        },
                                                        child: Container(
                                                          height: 38.h,
                                                          width: 80.w,
                                                          padding: EdgeInsets.only(left: 8.w, right: 15.w),
                                                          decoration: BoxDecoration(
                                                              color: ConstColors.black.withOpacity(0.20), borderRadius: BorderRadius.circular(6.r)),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              SvgView('assets/Icons/gallery2.svg', height: 21.h, width: 26.w),
                                                              Styles.regular(
                                                                  _searchController.wallPostCount
                                                                      .firstWhere(
                                                                        (item) =>
                                                                            item["objectId"] ==
                                                                            _searchController.finalPost[index]['Profile']['objectId'],
                                                                        orElse: () => {"count": 1},
                                                                      )["count"]
                                                                      .toString(),
                                                                  fs: 18.sp,
                                                                  ff: 'HR',
                                                                  c: ConstColors.white)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 6.h),

                                                      /// video count
                                                      if (_searchController.wallVideoPostCount.isNotEmpty &&
                                                          _searchController.wallVideoPostCount.any(
                                                            (item) =>
                                                                item["objectId"] == _searchController.finalPost[index]['Profile']['objectId'] &&
                                                                (item["count"] ?? 0) >= 1,
                                                          ))
                                                        InkWell(
                                                          onTap: () {
                                                            Get.to(() => ShowVideoScreen(
                                                                userController: _userController,
                                                                vidObjectId: _searchController.finalPost[index]['objectId'],
                                                                visitMode: true,
                                                                toProfileId: _searchController.finalPost[index]['Profile']['objectId']!,
                                                                fromProfileId: StorageService.getBox.read('DefaultProfile'),
                                                                index: 0,
                                                                isPictureScreen: true));
                                                          },
                                                          child: Container(
                                                            height: 38.h,
                                                            width: 80.w,
                                                            padding: EdgeInsets.only(left: 8.w, right: 15.w),
                                                            decoration: BoxDecoration(
                                                                color: ConstColors.black.withOpacity(0.20), borderRadius: BorderRadius.circular(6.r)),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                SvgView('assets/Icons/totalvideo.svg', height: 21.h, width: 26.w),
                                                                Styles.regular(
                                                                    _searchController.wallVideoPostCount
                                                                        .firstWhere(
                                                                          (item) =>
                                                                              item["objectId"] ==
                                                                              _searchController.finalPost[index]['Profile']['objectId'],
                                                                          orElse: () => {"count": null},
                                                                        )["count"]
                                                                        .toString(),
                                                                    fs: 18.sp,
                                                                    ff: 'HR',
                                                                    c: ConstColors.white)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      SizedBox(height: 15.h),
                                                      if (StorageService.getBox.read('Gender') == 'male')
                                                        Obx(() {
                                                          if (specialOfferClose.value) {
                                                            if (remainingTime.value != Duration.zero &&
                                                                paymentController.productsOffer.length == priceFlashSale.length) {
                                                              return Stack(
                                                                alignment: Alignment.topRight,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () async {
                                                                      await _priceController.getPaymentData();
                                                                      Get.to(() => StoreScreen(selectPaymentIndex: 6));
                                                                    },
                                                                    child: SvgPicture.network(priceFlashSale[0]['svg'].url,
                                                                        height: 74.w,
                                                                        width: 74
                                                                            .w), /*Image.asset('assets/Icons/specialoffer.png', height: 74.w, width: 74.w)*/
                                                                  ),
                                                                  SvgView('assets/Icons/closeicon.svg', onTap: () {
                                                                    specialOfferClose.value = !specialOfferClose.value;
                                                                  }),
                                                                ],
                                                              );
                                                            } else {
                                                              return const SizedBox.shrink();
                                                            }
                                                          } else {
                                                            return const SizedBox.shrink();
                                                          }
                                                        }),
                                                    ],
                                                  ), // nearby location
                                                  Column(
                                                    children: [
                                                      /// medal wise
                                                      GestureDetector(
                                                        onTap: () async {
                                                          await showModalBottomSheet(
                                                            context: context,
                                                            backgroundColor: Theme.of(context).dialogBackgroundColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
                                                            builder: (context) {
                                                              return Padding(
                                                                padding: EdgeInsets.only(
                                                                    top: 14.h,
                                                                    left: 20.w,
                                                                    right: 20.w,
                                                                    bottom: MediaQuery.of(context).padding.bottom + 10),
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                                                                    SizedBox(height: 12.h),
                                                                    Styles.regular(
                                                                        'show_girls_with_medal'.tr.replaceAll('xxx',
                                                                            StorageService.getBox.read('Gender') == 'male' ? 'girls'.tr : 'boys'.tr),
                                                                        c: Theme.of(context).primaryColor,
                                                                        ff: 'HB',
                                                                        fs: 18.sp),
                                                                    SizedBox(height: 20.h),
                                                                    Obx(() {
                                                                      _searchController.isGoldMedal.value;
                                                                      _searchController.isSilverMedal.value;
                                                                      _searchController.isBronzeMedal.value;
                                                                      return Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          InkWell(
                                                                            onTap: () {
                                                                              _searchController.isGoldMedal.value =
                                                                                  !_searchController.isGoldMedal.value;

                                                                              if (_searchController.isGoldMedal.value == true) {
                                                                                _searchController.selectMedalList.add('gold');
                                                                              } else {
                                                                                _searchController.selectMedalList.remove('gold');
                                                                              }
                                                                            },
                                                                            child: Column(
                                                                              children: [
                                                                                SvgView(
                                                                                  'assets/Icons/gold_medal.svg',
                                                                                  height: 92.w,
                                                                                  width: 77.w,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 5.w,
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Styles.regular(
                                                                                        _searchController.isGoldMedal.value ? 'yes'.tr : 'NO'.tr,
                                                                                        c: _searchController.isGoldMedal.value
                                                                                            ? ConstColors.lightGreenColor
                                                                                            : ConstColors.redColor,
                                                                                        fs: 18.sp,
                                                                                        ff: 'HB'),
                                                                                    SizedBox(width: 10.w),
                                                                                    SvgView('assets/Icons/check.svg',
                                                                                        color: _searchController.isGoldMedal.value
                                                                                            ? ConstColors.lightGreenColor
                                                                                            : ConstColors.redColor),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          InkWell(
                                                                            onTap: () {
                                                                              _searchController.isSilverMedal.value =
                                                                                  !_searchController.isSilverMedal.value;
                                                                              if (_searchController.isSilverMedal.value == true) {
                                                                                _searchController.selectMedalList.add('silver');
                                                                              } else {
                                                                                _searchController.selectMedalList.remove('silver');
                                                                              }
                                                                            },
                                                                            child: Column(
                                                                              children: [
                                                                                SvgView(
                                                                                  'assets/Icons/silver_medal.svg',
                                                                                  height: 92.w,
                                                                                  width: 77.w,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 5.w,
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Styles.regular(
                                                                                        _searchController.isSilverMedal.value ? 'yes'.tr : 'NO'.tr,
                                                                                        c: _searchController.isSilverMedal.value
                                                                                            ? ConstColors.lightGreenColor
                                                                                            : ConstColors.redColor,
                                                                                        fs: 18.sp,
                                                                                        ff: 'HB'),
                                                                                    SizedBox(width: 10.w),
                                                                                    SvgView('assets/Icons/check.svg',
                                                                                        color: _searchController.isSilverMedal.value
                                                                                            ? ConstColors.lightGreenColor
                                                                                            : ConstColors.redColor),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          InkWell(
                                                                            onTap: () {
                                                                              _searchController.isBronzeMedal.value =
                                                                                  !_searchController.isBronzeMedal.value;
                                                                              if (_searchController.isBronzeMedal.value == true) {
                                                                                _searchController.selectMedalList.add('bronze');
                                                                              } else {
                                                                                _searchController.selectMedalList.remove('bronze');
                                                                              }
                                                                            },
                                                                            child: Column(
                                                                              children: [
                                                                                SvgView(
                                                                                  'assets/Icons/bronze_medal.svg',
                                                                                  height: 92.w,
                                                                                  width: 77.w,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 5.w,
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Styles.regular(
                                                                                        _searchController.isBronzeMedal.value ? 'yes'.tr : 'NO'.tr,
                                                                                        c: _searchController.isBronzeMedal.value
                                                                                            ? ConstColors.lightGreenColor
                                                                                            : ConstColors.redColor,
                                                                                        fs: 18.sp,
                                                                                        ff: 'HB'),
                                                                                    SizedBox(width: 10.w),
                                                                                    SvgView('assets/Icons/check.svg',
                                                                                        color: _searchController.isBronzeMedal.value
                                                                                            ? ConstColors.lightGreenColor
                                                                                            : ConstColors.redColor),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ],
                                                                      );
                                                                    }),
                                                                    SizedBox(height: 25.h),
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                                                      child: Styles.regular('users_are_ranked_according'.tr,
                                                                          al: TextAlign.center,
                                                                          c: Theme.of(context).primaryColor,
                                                                          fs: 15.sp,
                                                                          ff: 'HR'),
                                                                    ),
                                                                    SizedBox(height: 10.h),
                                                                    Row(
                                                                      children: [
                                                                        SvgView(
                                                                          'assets/Icons/gold_medal.svg',
                                                                          height: 28.w,
                                                                          width: 24.w,
                                                                        ),
                                                                        SizedBox(width: 10.w),
                                                                        Styles.regular(
                                                                            'the_most_active_girls'.tr.replaceAll(
                                                                                'xxx',
                                                                                StorageService.getBox.read('Gender') == 'male'
                                                                                    ? 'girls'.tr
                                                                                    : 'boys'.tr),
                                                                            al: TextAlign.center,
                                                                            c: Theme.of(context).primaryColor,
                                                                            fs: 16.sp,
                                                                            ff: 'HR')
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 6.h),
                                                                    Row(
                                                                      children: [
                                                                        SvgView(
                                                                          'assets/Icons/silver_medal.svg',
                                                                          height: 28.w,
                                                                          width: 24.w,
                                                                        ),
                                                                        SizedBox(width: 10.w),
                                                                        Styles.regular(
                                                                            'the_moderately_active_girls'.tr.replaceAll(
                                                                                'xxx',
                                                                                StorageService.getBox.read('Gender') == 'male'
                                                                                    ? 'girls'.tr
                                                                                    : 'boys'.tr),
                                                                            al: TextAlign.center,
                                                                            c: Theme.of(context).primaryColor,
                                                                            fs: 16.sp,
                                                                            ff: 'HR')
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 6.h),
                                                                    Row(
                                                                      children: [
                                                                        SvgView(
                                                                          'assets/Icons/bronze_medal.svg',
                                                                          height: 28.w,
                                                                          width: 24.w,
                                                                        ),
                                                                        SizedBox(width: 10.w),
                                                                        Styles.regular(
                                                                            'the_occasional_active_girls'.tr.replaceAll(
                                                                                'xxx',
                                                                                StorageService.getBox.read('Gender') == 'male'
                                                                                    ? 'girls'.tr
                                                                                    : 'boys'.tr),
                                                                            al: TextAlign.center,
                                                                            c: Theme.of(context).primaryColor,
                                                                            fs: 16.sp,
                                                                            ff: 'HR')
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 25.h),
                                                                    GradientButton(
                                                                        title: 'Show'.tr,
                                                                        onTap: () async {
                                                                          Get.back();
                                                                          _searchController.isNearbyLocation.value = true;
                                                                          _searchController.isWallPhotosFetched.value = false;
                                                                          final userLocation = _searchController
                                                                              .profileData[StorageService.getBox.read('index')].locationName;
                                                                          _searchController.locationName.value = userLocation;
                                                                          final List<Location> locations = await locationFromAddress(userLocation);
                                                                          final List<Placemark> placeMarks = await placemarkFromCoordinates(
                                                                              locations[0].latitude, locations[0].longitude);
                                                                          final Placemark place = placeMarks[0];
                                                                          _searchController.locationLatitude.value = locations[0].latitude;
                                                                          _searchController.locationLongitude.value = locations[0].longitude;
                                                                          _searchController.countryCode.value = place.isoCountryCode!;
                                                                          _searchController.likeList.clear();
                                                                          _searchController.imagePostCount.clear();
                                                                          _searchController.wallPostCount.clear();
                                                                          _searchController.wallVideoPostCount.clear();
                                                                          _searchController.videoPostCount.clear();
                                                                          _searchController.finalPost.clear();
                                                                          _searchController.tempGetWallProfileId.clear();
                                                                          _searchController.parseObjectList.clear();
                                                                          _searchController.seenKeys.clear();
                                                                          _searchController.showNudeImage.clear();
                                                                          indexMuroList.clear();
                                                                          _searchController.profileIds.clear();
                                                                          StorageService.profileBox.clear();
                                                                          pictureX.swiperIndex.value = 0;
                                                                          _searchController.page.value = 0;
                                                                          _searchController.load.value = false;
                                                                          _searchController.isPixLoad.value = true;
                                                                          _searchController.getProfileData();
                                                                          _searchController.update();
                                                                          _userController.update();
                                                                          _searchController.isNearbyLocation.value = false;
                                                                        })
                                                                  ],
                                                                ),
                                                              );
                                                              // });
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.all(8.w),
                                                          height: 40.w,
                                                          width: 40.w,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8.r),
                                                              color: _searchController.selectMedalList.isEmpty
                                                                  ? ConstColors.black.withOpacity(0.20)
                                                                  : ConstColors.themeColor),
                                                          child: const SvgView('assets/Icons/medal.svg'),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h),

                                                      ///new location wise
                                                      InkWell(
                                                        onTap: () async {
                                                          _searchController.isNearbyLocation.value = false;
                                                          _searchController.isWallPhotosFetched.value = false;
                                                          final userLocation =
                                                              _searchController.profileData[StorageService.getBox.read('index')].locationName;
                                                          _searchController.locationName.value = userLocation;
                                                          final List<Location> locations = await locationFromAddress(userLocation);
                                                          final List<Placemark> placeMarks =
                                                              await placemarkFromCoordinates(locations[0].latitude, locations[0].longitude);
                                                          final Placemark place = placeMarks[0];
                                                          _searchController.locationLatitude.value = locations[0].latitude;
                                                          _searchController.locationLongitude.value = locations[0].longitude;
                                                          _searchController.countryCode.value = place.isoCountryCode!;
                                                          _searchController.likeList.clear();
                                                          _searchController.imagePostCount.clear();
                                                          _searchController.wallPostCount.clear();
                                                          _searchController.wallVideoPostCount.clear();
                                                          _searchController.videoPostCount.clear();
                                                          _searchController.finalPost.clear();
                                                          _searchController.tempGetWallProfileId.clear();
                                                          _searchController.parseObjectList.clear();
                                                          _searchController.seenKeys.clear();
                                                          _searchController.showNudeImage.clear();
                                                          indexMuroList.clear();
                                                          _searchController.profileIds.clear();
                                                          StorageService.profileBox.clear();
                                                          pictureX.swiperIndex.value = 0;
                                                          _searchController.page.value = 0;
                                                          _searchController.load.value = false;
                                                          _searchController.isPixLoad.value = true;
                                                          _searchController.getProfileData();
                                                          _searchController.update();
                                                          _userController.update();
                                                          _searchController.isNearbyLocation.value = true;
                                                        },
                                                        child: Container(
                                                          height: 40.w,
                                                          width: 40.w,
                                                          alignment: Alignment.center,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8.r),
                                                              gradient: LinearGradient(
                                                                  colors: [
                                                                    ConstColors.themeColor.withOpacity(0.3),
                                                                    ConstColors.white.withOpacity(0.3)
                                                                  ],
                                                                  begin: Alignment.topCenter,
                                                                  end: Alignment.bottomCenter,
                                                                  stops: const [0.0, 1.0])),
                                                          padding: EdgeInsets.all(6.r),
                                                          child: const SvgView('assets/Icons/gps.svg'),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          final LocationPermission permission = await Geolocator.checkPermission();
                                                          if (permission == LocationPermission.denied) {
                                                            Get.to(() => PermissionScreen(
                                                                  onTap: () async {
                                                                    bool serviceEnabled;
                                                                    LocationPermission permission;
                                                                    serviceEnabled = await Geolocator.isLocationServiceEnabled();
                                                                    if (!serviceEnabled) {
                                                                      Geolocator.openLocationSettings();
                                                                      return Future.error('Location services are disabled.');
                                                                    }
                                                                    permission = await Geolocator.checkPermission();
                                                                    if (permission == LocationPermission.denied) {
                                                                      permission = await Geolocator.requestPermission();
                                                                      if (permission == LocationPermission.denied) {
                                                                        return Future.error('Location permissions are denied');
                                                                      }
                                                                    }
                                                                    if (permission == LocationPermission.deniedForever) {
                                                                      return Future.error(
                                                                          'Location permissions are permanently denied, we cannot request permissions.');
                                                                    }
                                                                    Get.back();
                                                                    _searchController.bottomSheetLocation(context);
                                                                  },
                                                                ));
                                                          } else {
                                                            _searchController.bottomSheetLocation(context);
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.all(8.w),
                                                          height: 40.w,
                                                          width: 40.w,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8.r), color: ConstColors.black.withOpacity(0.20)),
                                                          child: const SvgView('assets/Icons/search.svg'),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h),
                                                      Like(
                                                          index: index,
                                                          postId: _searchController.finalPost[index]['objectId'],
                                                          userObjId: _searchController.finalPost[index]['User']['objectId'],
                                                          gender: _searchController.finalPost[index]['User']['Gender'],
                                                          toProfileId: _searchController.finalPost[index]['Profile']['objectId']!),
                                                      SizedBox(height: 10.h),
                                                      GestureDetector(
                                                        onTap: () {
                                                          showBottomSheetBlockReport(context, blockOnTap: () async {
                                                            /// block
                                                            _priceController.isPurchase.value = true;
                                                            _userController.blockloading.value = true;
                                                            BlockUser block = BlockUser();
                                                            block.emailuser = "Block User";
                                                            await UserProfileProviderApi()
                                                                .getById(_searchController.finalPost[index]['Profile']['objectId']!)
                                                                .then((value) async {
                                                              block.toUser = UserLogin()..objectId = value.result['User']['objectId'];

                                                              block.type = "BLOCK";
                                                              block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');

                                                              block.toProfile = ProfilePage()
                                                                ..objectId = _searchController.finalPost[index]['Profile']["objectId"];

                                                              block.fromProfile = ProfilePage()
                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                              await BlockUSerProviderApi().add(block);
                                                              await PairNotificationProviderApi()
                                                                  .getByProfile(StorageService.getBox.read('DefaultProfile'),
                                                                      _searchController.finalPost[index]['Profile']["objectId"], 'BlocUser')
                                                                  .then((val) async {
                                                                PairNotifications pairNotifications = PairNotifications();
                                                                if (val == null) {
                                                                  pairNotifications.toProfile = ProfilePage()
                                                                    ..objectId = _searchController.finalPost[index]['Profile']["objectId"];
                                                                  pairNotifications.fromProfile = ProfilePage()
                                                                    ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                  pairNotifications.users = [
                                                                    ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'),
                                                                    ProfilePage()
                                                                      ..objectId = _searchController.finalPost[index]['Profile']["objectId"]
                                                                  ];
                                                                  pairNotifications.message = '';
                                                                  pairNotifications.notificationType = 'BlocUser';
                                                                  pairNotifications.isPurchased = true;
                                                                  pairNotifications.isRead = true;
                                                                  pairNotifications.fromUser = UserLogin()
                                                                    ..objectId = StorageService.getBox.read('ObjectId');
                                                                  pairNotifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];

                                                                  await PairNotificationProviderApi().add(pairNotifications);
                                                                } else {
                                                                  pairNotifications.objectId = val.result['objectId'];
                                                                  pairNotifications.toProfile = ProfilePage()
                                                                    ..objectId = _searchController.finalPost[index]['Profile']["objectId"];
                                                                  pairNotifications.fromProfile = ProfilePage()
                                                                    ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                  pairNotifications.users = [
                                                                    ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'),
                                                                    ProfilePage()
                                                                      ..objectId = _searchController.finalPost[index]['Profile']["objectId"]
                                                                  ];
                                                                  pairNotifications.message = '';
                                                                  pairNotifications.notificationType = 'BlocUser';
                                                                  pairNotifications.isPurchased = true;
                                                                  pairNotifications.isRead = true;
                                                                  pairNotifications.fromUser = UserLogin()
                                                                    ..objectId = StorageService.getBox.read('ObjectId');
                                                                  pairNotifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];
                                                                  pairNotifications.deletedUsers = [];
                                                                  await PairNotificationProviderApi().update(pairNotifications);
                                                                }
                                                              });
                                                              Notifications notifications = Notifications();
                                                              notifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];
                                                              notifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                                                              notifications.toProfile = ProfilePage()
                                                                ..objectId = _searchController.finalPost[index]['Profile']['objectId'];
                                                              notifications.fromProfile = ProfilePage()
                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                              notifications.notificationType = 'BlocUser';
                                                              notifications.isRead = true;

                                                              NotificationsProviderApi().add(notifications);
                                                            });
                                                            _priceController.isPurchase.value = false;
                                                            _userController.blockloading.value = false;
                                                            _searchController.load.value = false;
                                                            _searchController.likeList.clear();
                                                            _searchController.imagePostCount.clear();
                                                            _searchController.wallPostCount.clear();
                                                            _searchController.wallVideoPostCount.clear();
                                                            _searchController.videoPostCount.clear();
                                                            _searchController.finalPost.clear();
                                                            _searchController.tempGetWallProfileId.clear();
                                                            _searchController.parseObjectList.clear();
                                                            _searchController.showNudeImage.clear();
                                                            indexMuroList.clear();
                                                            _searchController.seenKeys.clear();
                                                            pictureX.swiperIndex.value = 0;
                                                            _searchController.page.value = 0;
                                                            _searchController.update();
                                                            Get.back();
                                                          }, informOnTap: (reason, moreReason) {
                                                            /// just inform
                                                            _userController.blockloading.value = true;

                                                            BlockUser block = BlockUser();
                                                            block.emailuser = reason;
                                                            block['Reason'] = 'Just to Inform';
                                                            block['Description'] = moreReason;
                                                            block.type = "REPORT";

                                                            UserProfileProviderApi()
                                                                .getById(_searchController.finalPost[index]['Profile']['objectId']!)
                                                                .then((value) async {
                                                              block.toUser = UserLogin()..objectId = value.result['User']['objectId'];

                                                              block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');

                                                              block.toProfile = ProfilePage()
                                                                ..objectId = _searchController.finalPost[index]['Profile']["objectId"];

                                                              block.fromProfile = ProfilePage()
                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                              BlockUSerProviderApi().add(block);
                                                            });

                                                            for (var element in reportData) {
                                                              element.isSelected = false;
                                                            }
                                                            _userController.blockloading.value = false;
                                                            Get.back();
                                                            Get.back();
                                                            Get.back();
                                                          }, bothOnTap: (reason, moreReason) async {
                                                            /// report and block
                                                            _priceController.isPurchase.value = true;
                                                            _userController.blockloading.value = true;
                                                            BlockUser block = BlockUser();

                                                            Get.back();
                                                            Get.back();
                                                            Get.back();

                                                            /// BLOCK ENTRY
                                                            block.emailuser = reason;
                                                            block['Reason'] = 'REPORT AND BLOCK';
                                                            block['Description'] = moreReason;
                                                            await UserProfileProviderApi()
                                                                .getById(_searchController.finalPost[index]['Profile']['objectId']!)
                                                                .then((value) async {
                                                              block.toUser = UserLogin()..objectId = value.result['User']['objectId'];

                                                              block.type = "BLOCK";
                                                              block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');

                                                              block.toProfile = ProfilePage()
                                                                ..objectId = _searchController.finalPost[index]['Profile']["objectId"];

                                                              block.fromProfile = ProfilePage()
                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                              await BlockUSerProviderApi().add(block);
                                                              await PairNotificationProviderApi()
                                                                  .getByProfile(StorageService.getBox.read('DefaultProfile'),
                                                                      _searchController.finalPost[index]['Profile']["objectId"], 'BlocUser')
                                                                  .then((val) async {
                                                                PairNotifications pairNotifications = PairNotifications();
                                                                if (val == null) {
                                                                  pairNotifications.toProfile = ProfilePage()
                                                                    ..objectId = _searchController.finalPost[index]['Profile']["objectId"];
                                                                  pairNotifications.fromProfile = ProfilePage()
                                                                    ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                  pairNotifications.users = [
                                                                    ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'),
                                                                    ProfilePage()
                                                                      ..objectId = _searchController.finalPost[index]['Profile']["objectId"]
                                                                  ];
                                                                  pairNotifications.message = '';
                                                                  pairNotifications.notificationType = 'BlocUser';
                                                                  pairNotifications.isPurchased = true;
                                                                  pairNotifications.isRead = true;
                                                                  pairNotifications.fromUser = UserLogin()
                                                                    ..objectId = StorageService.getBox.read('ObjectId');
                                                                  pairNotifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];

                                                                  await PairNotificationProviderApi().add(pairNotifications);
                                                                } else {
                                                                  pairNotifications.objectId = val.result['objectId'];
                                                                  pairNotifications.toProfile = ProfilePage()
                                                                    ..objectId = _searchController.finalPost[index]['Profile']["objectId"];
                                                                  pairNotifications.fromProfile = ProfilePage()
                                                                    ..objectId = StorageService.getBox.read('DefaultProfile');
                                                                  pairNotifications.users = [
                                                                    ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'),
                                                                    ProfilePage()
                                                                      ..objectId = _searchController.finalPost[index]['Profile']["objectId"]
                                                                  ];
                                                                  pairNotifications.message = '';
                                                                  pairNotifications.notificationType = 'BlocUser';
                                                                  pairNotifications.isPurchased = true;
                                                                  pairNotifications.isRead = true;
                                                                  pairNotifications.fromUser = UserLogin()
                                                                    ..objectId = StorageService.getBox.read('ObjectId');
                                                                  pairNotifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];
                                                                  pairNotifications.deletedUsers = [];
                                                                  await PairNotificationProviderApi().update(pairNotifications);
                                                                }
                                                              });
                                                              Notifications notifications = Notifications();
                                                              notifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];
                                                              notifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                                                              notifications.toProfile = ProfilePage()
                                                                ..objectId = _searchController.finalPost[index]['Profile']['objectId'];
                                                              notifications.fromProfile = ProfilePage()
                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                              notifications.notificationType = 'BlocUser';
                                                              notifications.isRead = true;

                                                              NotificationsProviderApi().add(notifications);
                                                            });

                                                            /// REPORT ENTRY
                                                            BlockUser report = BlockUser();
                                                            report.emailuser = reason;
                                                            report['Reason'] = 'Just to Inform';
                                                            report['Description'] = moreReason;
                                                            report.type = "REPORT";

                                                            await UserProfileProviderApi()
                                                                .getById(_searchController.finalPost[index]['Profile']['objectId']!)
                                                                .then((value) async {
                                                              report.toUser = UserLogin()..objectId = value.result['User']['objectId'];

                                                              report.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');

                                                              report.toProfile = ProfilePage()
                                                                ..objectId = _searchController.finalPost[index]['Profile']["objectId"];

                                                              report.fromProfile = ProfilePage()
                                                                ..objectId = StorageService.getBox.read('DefaultProfile');
                                                              BlockUSerProviderApi().add(report);
                                                            });

                                                            _priceController.isPurchase.value = false;
                                                            _userController.blockloading.value = false;
                                                            _searchController.load.value = false;
                                                            _searchController.likeList.clear();
                                                            _searchController.imagePostCount.clear();
                                                            _searchController.wallPostCount.clear();
                                                            _searchController.wallVideoPostCount.clear();
                                                            _searchController.videoPostCount.clear();
                                                            _searchController.finalPost.clear();
                                                            _searchController.tempGetWallProfileId.clear();
                                                            _searchController.parseObjectList.clear();
                                                            _searchController.showNudeImage.clear();
                                                            indexMuroList.clear();
                                                            _searchController.seenKeys.clear();
                                                            pictureX.swiperIndex.value = 0;
                                                            _searchController.page.value = 0;
                                                            _searchController.update();
                                                          });
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.all(8.w),
                                                          height: 40.w,
                                                          width: 40.w,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8.r), color: ConstColors.black.withOpacity(0.20)),
                                                          child: SvgPicture.asset('assets/Icons/bookmark.svg'),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h),
                                                      GestureDetector(
                                                          onTap: () {
                                                            try {
                                                              _priceController.isPurchase.value = true;
                                                              pictureX
                                                                  .share(
                                                                      _searchController.finalPost[index]['Post'].url,
                                                                      _searchController.finalPost[index]['Profile']['Name'],
                                                                      _searchController.finalPost[index]['Profile']['Description'],
                                                                      _searchController.finalPost[index]['Profile']['objectId'],
                                                                      _searchController.finalPost[index]['User']['objectId'])
                                                                  .whenComplete(() {
                                                                _priceController.isPurchase.value = false;
                                                                _priceController.isShowConnectCallButton.value = false;
                                                              });
                                                            } catch (e) {
                                                              _priceController.isPurchase.value = false;
                                                              _priceController.isShowConnectCallButton.value = false;
                                                              if (kDebugMode) {
                                                                print('error: $e');
                                                              }
                                                            }
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.all(8.w),
                                                            height: 40.w,
                                                            width: 40.w,
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(8.r), color: ConstColors.black.withOpacity(0.20)),
                                                            child: const SvgView('assets/Icons/share.svg'),
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        Obx(() {
                                          pictureX.visible.value;
                                          if (pictureX.visible.value) {
                                            return Positioned(
                                                right: -100,
                                                bottom: 100.h,
                                                child: Lottie.asset("assets/jsons/kiss.json", height: 400.w, width: 400.w));
                                          } else {
                                            return const SizedBox.shrink();
                                          }
                                        }),

                                        /// Content warning: Nudity
                                        //  if ((widget.wishPost['IsNude'] ?? false) && widget.controllerX.purchaseNude[widget.index] && !isShow.value)
                                        Obx(() {
                                          isShow.value;
                                          if ((_searchController.finalPost[index]['IsNude'] ?? false) &&
                                              _searchController.showNudeImage[index] &&
                                              !isShow.value) {
                                            return BlurryContainer(
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
                                                  Center(
                                                      child: SvgView('assets/Icons/IsNude.svg',
                                                          fit: BoxFit.cover, color: ConstColors.white, height: 30.w, width: 30.w)),
                                                  SizedBox(height: 50.h),
                                                  Styles.regular("Content_warning".tr,
                                                      fs: 18.sp, c: ConstColors.white, ff: "HR", al: TextAlign.start),
                                                  SizedBox(height: 8.3.h),
                                                  Styles.regular("Content_warning_text".tr,
                                                      fs: 18.sp, c: ConstColors.white, ff: "HR", al: TextAlign.start),
                                                  SizedBox(height: 45.h),
                                                  Center(
                                                    child: InkWell(
                                                      onTap: () async {
                                                        isShow.value = true;
                                                        _searchController.showNudeImage[index] = false;
                                                        PurchaseNudeImage purchase = PurchaseNudeImage();
                                                        purchase.imgPost = UserPost()..objectId = _searchController.finalPost[index]['objectId'];
                                                        purchase.fromprofileId = ProfilePage()
                                                          ..objectId = StorageService.getBox.read('DefaultProfile');
                                                        purchase.fromuserId = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                                                        purchase.toprofileId = ProfilePage()
                                                          ..objectId = _searchController.finalPost[index]['Profile']['objectId'];
                                                        purchase.touserId = UserLogin()
                                                          ..objectId = _searchController.finalPost[index]['User']['objectId'];
                                                        await PurchaseNudeImageProviderApi().add(purchase);
                                                      },
                                                      child: Container(
                                                        height: 40.h,
                                                        width: 131.w,
                                                        alignment: Alignment.center,
                                                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(40.r), color: Colors.black.withOpacity(0.8)),
                                                        child: Styles.regular("Show".tr,
                                                            fs: 18.sp, c: ConstColors.white, ff: "HR", al: TextAlign.center),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 13.h),
                                                ],
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        }),
                                        Obx(() {
                                          _priceController.isShowConnectCallButton.value;
                                          return Center(
                                            child: AnimatedContainer(
                                              width: _priceController.isShowConnectCallButton.value ? 200.0 : 0.0,
                                              height: _priceController.isShowConnectCallButton.value ? 273.0 : 0.0,
                                              alignment: Alignment.center,
                                              duration: const Duration(milliseconds: 150),
                                              child: AnimatedOpacity(
                                                opacity: _priceController.isShowConnectCallButton.value ? 1.0 : 0.0,
                                                duration: const Duration(milliseconds: 150),
                                                child: Container(
                                                    height: 50.h,
                                                    width: 200.w,
                                                    alignment: Alignment.center,
                                                    decoration:
                                                        BoxDecoration(color: ConstColors.themeColor, borderRadius: BorderRadius.circular(10.r)),
                                                    child: Styles.regular('Connecting'.tr, c: Theme.of(context).primaryColor, ff: 'HB')),
                                              ),
                                            ),
                                          );
                                        }),
                                        Obx(
                                          () => Center(
                                            child: AnimatedContainer(
                                              width: pictureX.winkvisible.value ? 200.0 : 0.0,
                                              height: pictureX.winkvisible.value ? 273.0 : 0.0,
                                              alignment: Alignment.center,
                                              duration: const Duration(milliseconds: 150),
                                              // curve: Curves.easeInOut,
                                              child: AnimatedOpacity(
                                                opacity: pictureX.winkvisible.value ? 1.0 : 0.0,
                                                duration: const Duration(milliseconds: 150),
                                                child: Lottie.asset("assets/jsons/wink.json"),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Obx(
                                          () => Center(
                                            child: AnimatedContainer(
                                              width: pictureX.messagevisible.value ? 200.0 : 0.0,
                                              height: pictureX.messagevisible.value ? 273.0 : 0.0,
                                              alignment: Alignment.center,
                                              duration: const Duration(milliseconds: 150),
                                              // curve: Curves.easeInOut,
                                              child: AnimatedOpacity(
                                                opacity: pictureX.messagevisible.value ? 1.0 : 0.0,
                                                duration: const Duration(milliseconds: 150),
                                                child: Lottie.asset("assets/jsons/message.json"),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    final LocationPermission permission = await Geolocator.checkPermission();
                                    if (permission == LocationPermission.denied) {
                                      Get.to(() => const PermissionScreen());
                                    } else {
                                      _searchController.bottomSheetLocation(context);
                                    }
                                  },
                                  child: GradientWidget(
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: 30.w,
                                          top: 80.h,
                                          child: GestureDetector(
                                            onTap: () async {
                                              final LocationPermission permission = await Geolocator.checkPermission();
                                              if (permission == LocationPermission.denied) {
                                                Get.to(() => const PermissionScreen());
                                              } else {
                                                _searchController.bottomSheetLocation(context);
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(10.h.w),
                                              height: 50.w,
                                              width: 50.w,
                                              decoration:
                                                  BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: ConstColors.black.withOpacity(0.20)),
                                              child: const SvgView('assets/Icons/search.svg'),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                                          child: Center(
                                            child: Styles.regular('no_data_found_at_this_location'.tr, al: TextAlign.center, c: ConstColors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                  : GradientWidget(
                      child: Obx(() {
                        return Column(
                          children: [
                            const Spacer(flex: 3),
                            Styles.regular('eypop', fs: 78.sp, ff: 'HL', c: ConstColors.white),
                            Styles.regular(_searchController.isNearbyLocation.value ? 'searching_near_people'.tr : 'Looking_for_people'.tr,
                                fs: 22.sp, ff: 'HL', c: ConstColors.white),
                            const Spacer(flex: 2),
                            Lottie.asset(
                                _searchController.isNearbyLocation.value ? "assets/jsons/gps-location-pointer.json" : "assets/jsons/fire.json",
                                height: 348.w,
                                width: 348.w,
                                fit: BoxFit.cover),
                            const Spacer(flex: 5),
                          ],
                        );
                      }),
                    )),
        );
      });
    });
  }

  /// show medal
  Widget showMedal(String medal) {
    switch (medal) {
      case 'gold':
        return SvgView(
          'assets/Icons/gold_medal.svg',
          height: 48.w,
          width: 40.w,
        );
      case 'silver':
        return SvgView(
          'assets/Icons/silver_medal.svg',
          height: 48.w,
          width: 40.w,
        );
      case 'bronze':
        return SvgView(
          'assets/Icons/bronze_medal.svg',
          height: 48.w,
          width: 40.w,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

Future<void> addBottomOption(
    {context,
    ontap,
    title,
    subTitle,
    description,
    isTextField = false,
    buttontitle,
    select,
    hint,
    height,
    sufiix = false,
    TextEditingController? controller,
    dropdownList}) {
  final PictureController picturex = Get.put(PictureController());

  return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
              padding: EdgeInsets.only(top: 16.h, left: 20.w, right: 20.w, bottom: MediaQuery.of(context).padding.bottom + 10),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                SizedBox(height: 9.h),
                Styles.regular(title, ff: 'HB', fs: 18.sp, c: Theme.of(context).primaryColor),
                SizedBox(height: 22.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Styles.regular(subTitle, al: TextAlign.center, c: Theme.of(context).primaryColor, fs: 18.sp),
                ),
                SizedBox(height: 20.h),
                isTextField == true
                    ? TextFieldModel(
                        containerColor: Colors.transparent,
                        color: Theme.of(context).primaryColor,
                        controllers: controller!,
                        hintTextColor: Theme.of(context).primaryColor,
                        hint: hint,
                        enabled: true,
                        obs: false,
                        maxLan: 180,
                        minLine: 4,
                        maxLine: 5,
                        borderColor: Theme.of(context).primaryColor,
                        textInputAction: TextInputAction.done,
                        numtype: false,
                        cursorColor: Theme.of(context).primaryColor,
                        width: 388.w,
                        onChanged: (value) {
                          controller.text = value.toString();
                        },
                      )
                    : SizedBox(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: PopupMenuButton(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: TextFieldModel(
                                  containerColor: Colors.transparent,
                                  color: Theme.of(context).primaryColor,
                                  controllers: controller!,
                                  hintTextColor: Theme.of(context).primaryColor,
                                  hint: hint,
                                  enabled: false,
                                  obs: false,
                                  borderColor: Theme.of(context).primaryColor,
                                  cursorColor: Theme.of(context).primaryColor,
                                  contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 18.w),
                                  suffixIcon: sufiix
                                      ? ButtonTheme(
                                          alignedDropdown: true,
                                          child: PopupMenuButton(
                                              child: Padding(
                                                padding: EdgeInsets.only(right: 25.w),
                                                child: SvgPicture.asset("assets/Icons/up-down_arrow.svg", color: Theme.of(context).primaryColor),
                                              ),
                                              onSelected: (value) {
                                                controller.text = value.toString();
                                              },
                                              itemBuilder: (context) {
                                                List<PopupMenuItem> list = [];
                                                for (var element in dropdownList) {
                                                  list.add(PopupMenuItem(
                                                      value: element, child: Styles.regular(element, c: Theme.of(context).primaryColor, fs: 20.sp)));
                                                }
                                                return list;
                                              }),
                                        )
                                      : const SizedBox()),
                              onSelected: (value) {
                                controller.text = value.toString();
                              },
                              itemBuilder: (context) {
                                List<PopupMenuItem> list = [];
                                for (var element in dropdownList) {
                                  list.add(
                                      PopupMenuItem(value: element, child: Styles.regular(element, c: Theme.of(context).primaryColor, fs: 20.sp)));
                                }
                                return list;
                              }),
                        ),
                      ),
                if (select == true && select != null) ...[
                  Obx(
                    () => ListTile(
                      onTap: () {
                        picturex.blockUser.value = !picturex.blockUser.value;
                      },
                      leading: Container(
                        height: 30.h,
                        width: 30.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(color: Theme.of(context).primaryColor, width: 1.w),
                        ),
                        child: Center(
                          child: Container(
                            height: 24.h,
                            width: 24.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Theme.of(context).primaryColor, width: 2.w),
                                color: picturex.blockUser.value == false ? Colors.transparent : ConstColors.themeColor),
                          ),
                        ),
                      ),
                      title: Styles.regular('block_this_user'.tr, c: ConstColors.titleColor, fs: 20.sp, ff: 'RB'),
                    ),
                  ),
                ],
                SizedBox(height: 20.h),
                // only male side and message box side show this text
                if (isTextField == false) ...[
                  if (StorageService.getBox.read('Gender') == 'male')
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Styles.regular(description, al: TextAlign.center, c: ConstColors.subtitle, fs: 16.sp),
                    ),
                ] else ...[
                  if (StorageService.getBox.read('Gender') == 'male')
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Styles.regular(description, al: TextAlign.center, c: ConstColors.subtitle, fs: 16.sp),
                    ),
                ],
                SizedBox(height: 15.h),
                Obx(() {
                  return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (_userController.blockloading.value == false) ...[
                      Expanded(child: GradientButton(title: buttontitle, onTap: ontap)),
                    ],
                    if (_userController.blockloading.value == true) ...[Center(child: CircularProgressIndicator(color: ConstColors.themeColor))]
                  ]);
                })
              ])),
        );
      });
}

class Option extends StatefulWidget {
  const Option(
      {Key? key,
      required this.title,
      required this.svg,
      required this.enable,
      this.online = false,
      required this.onTap,
      required this.userId,
      required this.profileId})
      : super(key: key);

  final Function(bool, bool) onTap;
  final bool online;
  final bool enable;
  final String svg;
  final String userId;
  final String profileId;
  final String title;

  @override
  State<Option> createState() => _OptionState();
}

class _OptionState extends State<Option> {
  final LiveQuery liveQuery = LiveQuery(debug: false);
  Subscription<ParseObject>? subscription;

  final LiveQuery liveProfileQuery = LiveQuery(debug: false);
  Subscription<ParseObject>? profileSubscription;
  final RxBool isLive = false.obs;
  final RxBool online = false.obs;
  final RxBool isOnAnotherCall = false.obs;
  final RxBool isHasLoggedIn = false.obs;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      online.value = widget.online;
    });
    if (widget.enable) {
      onlineStatusQuery();
    }
    super.initState();
  }

  @override
  void dispose() {
    try {
      if (widget.enable) {
        liveQuery.client.unSubscribe(subscription!);
        liveProfileQuery.client.unSubscribe(profileSubscription!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('error in widget position $e');
      }
    }

    super.dispose();
  }

  onlineStatusQuery() async {
    // 1.chat  2.call  3.VideoCall (3 options for profile online status)

    try {
      final QueryBuilder<UserLogin> queryData = QueryBuilder<UserLogin>(UserLogin())..whereEqualTo('objectId', widget.userId);
      final QueryBuilder<ProfilePage> queryProfileData = QueryBuilder<ProfilePage>(ProfilePage())
        ..whereEqualTo('objectId', widget.profileId)
        ..includeObject(['User']);

      /// User Login Query
      queryData.query().then((value) {
        isLive.value = (value.result[0]['showOnline'] ?? false);
        if (widget.title == 'call') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            isOnAnotherCall.value = (value.result[0]['IsBusy'] ?? false);
          });
        } else if (widget.title == 'VideoCall') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            isOnAnotherCall.value = (value.result[0]['IsBusy'] ?? false);
          });
        }
      });

      /// User Profile Query
      queryProfileData.query().then((value) {
        if (widget.title == 'chat') {
          // print('hello profile nochats ------ ${value.result[0]['NoChats']}  ----- isHasLoggedIn --- ${value.result[0]['User']['HasLoggedIn']}');
          // print('hello online status ------ ${online.value}');
          // print('hello online status condition ------ ${(online.value != (value.result[0]['NoChats'] ?? false))}');
          if (online.value != !(value.result[0]['NoChats'] ?? false)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if ((value.result[0]['NoChats'] ?? false) == false && (value.result[0]['User']['HasLoggedIn'] ?? true) == true) {
                online.value = true;
              } else {
                online.value = false;
              }
            });
          }
        } else if (widget.title == 'call') {
          if (online.value != !(value.result[0]['NoCalls'] ?? false)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if ((value.result[0]['NoCalls'] ?? false) == false && (value.result[0]['User']['HasLoggedIn'] ?? true) == true) {
                online.value = true;
              } else {
                online.value = false;
              }
            });
          }
        } else if (widget.title == 'VideoCall') {
          if (online.value != !(value.result[0]['NoVideocalls'] ?? false)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if ((value.result[0]['NoVideocalls'] ?? false) == false && (value.result[0]['User']['HasLoggedIn'] ?? true) == true) {
                online.value = true;
              } else {
                online.value = false;
              }
            });
          }
        }
      });

      /// login live query

      subscription = await liveQuery.client.subscribe(queryData);
      subscription!.on(LiveQueryEvent.create, (value) {});
      subscription!.on(LiveQueryEvent.update, (value) {
        isLive.value = (value['showOnline'] ?? false);
        isHasLoggedIn.value = (value['HasLoggedIn'] ?? true);
        //print('hello login  live isHasLoggedIn.value ------ ${isHasLoggedIn.value}');
        if (widget.title == 'call') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            isOnAnotherCall.value = (value['IsBusy'] ?? false);
          });
        } else if (widget.title == 'VideoCall') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            isOnAnotherCall.value = (value['IsBusy'] ?? false);
          });
        }
      });
      subscription!.on(LiveQueryEvent.delete, (value) {});

      /// profile live query

      profileSubscription = await liveProfileQuery.client.subscribe(queryProfileData);
      profileSubscription!.on(LiveQueryEvent.create, (value) {});
      profileSubscription!.on(LiveQueryEvent.update, (value) {
        if (widget.title == 'chat') {
          //print('hello profile  live nochats ------ ${value['NoChats']}  ----- isHasLoggedIn --- ${isHasLoggedIn.value}');
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if ((value['NoChats'] ?? false) == false && isHasLoggedIn.value == true) {
              online.value = true;
            } else {
              online.value = false;
            }
          });
        } else if (widget.title == 'call') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if ((value['NoCalls'] ?? false) == false && isHasLoggedIn.value == true) {
              online.value = true;
            } else {
              online.value = false;
            }
          });
        } else if (widget.title == 'VideoCall') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if ((value['NoVideocalls'] ?? false) == false && isHasLoggedIn.value == true) {
              online.value = true;
            } else {
              online.value = false;
            }
          });
        }
      });
      profileSubscription!.on(LiveQueryEvent.delete, (value) {});
    } catch (trace, error) {
      if (kDebugMode) {
        print("trace ::::: $trace");
        print("error ::::: $error");
      }
    }

    // try {
    //   final QueryBuilder<UserLogin> queryData = QueryBuilder<UserLogin>(UserLogin())..whereEqualTo('objectId', widget.userId);
    //   final QueryBuilder<ProfilePage> queryProfileData = QueryBuilder<ProfilePage>(ProfilePage())..whereEqualTo('objectId', widget.profileId);
    //
    //   /// User Login Query
    //   queryData.query().then((value) {
    //     isLive.value = (value.result[0]['showOnline'] ?? false);
    //     if (widget.title == 'call') {
    //       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //         isOnAnotherCall.value = (value.result[0]['IsBusy'] ?? false);
    //       });
    //     } else if (widget.title == 'VideoCall') {
    //       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //         isOnAnotherCall.value = (value.result[0]['IsBusy'] ?? false);
    //       });
    //     }
    //   });
    //
    //   /// User Profile Query
    //   queryProfileData.query().then((value) {
    //     if (widget.title == 'chat') {
    //       if (online.value != (value.result[0]['NoChats'] ?? false)) {
    //         WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //           online.value = (value.result[0]['NoChats'] ?? false);
    //         });
    //       }
    //     } else if (widget.title == 'call') {
    //       if (online.value != (value.result[0]['NoCalls'] ?? false)) {
    //         WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //           online.value = (value.result[0]['NoCalls'] ?? false);
    //         });
    //       }
    //     } else if (widget.title == 'VideoCall') {
    //       if (online.value != (value.result[0]['NoVideocalls'] ?? false)) {
    //         WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //           online.value = (value.result[0]['NoVideocalls'] ?? false);
    //         });
    //       }
    //     }
    //   });
    //
    //   /// login live query
    //
    //   subscription = await liveQuery.client.subscribe(queryData);
    //   subscription!.on(LiveQueryEvent.create, (value) {});
    //   subscription!.on(LiveQueryEvent.update, (value) {
    //     isLive.value = (value['showOnline'] ?? false);
    //     if (widget.title == 'call') {
    //       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //         isOnAnotherCall.value = (value['IsBusy'] ?? false);
    //       });
    //     } else if (widget.title == 'VideoCall') {
    //       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //         isOnAnotherCall.value = (value['IsBusy'] ?? false);
    //       });
    //     }
    //   });
    //   subscription!.on(LiveQueryEvent.delete, (value) {});
    //
    //   /// profile live query
    //
    //   profileSubscription = await liveProfileQuery.client.subscribe(queryProfileData);
    //   profileSubscription!.on(LiveQueryEvent.create, (value) {});
    //   profileSubscription!.on(LiveQueryEvent.update, (value) {
    //     if (widget.title == 'chat') {
    //       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //         online.value = (value['NoChats'] ?? false);
    //       });
    //     } else if (widget.title == 'call') {
    //       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //         online.value = (value['NoCalls'] ?? false);
    //       });
    //     } else if (widget.title == 'VideoCall') {
    //       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //         online.value = (value['NoVideocalls'] ?? false);
    //       });
    //     }
    //   });
    //   profileSubscription!.on(LiveQueryEvent.delete, (value) {});
    // } catch (trace, error) {
    //   if (kDebugMode) {
    //     print("trace ::::: $trace");
    //     print("error ::::: $error");
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      online.value;
      isOnAnotherCall.value;
      return GestureDetector(
        onTap: () {
          widget.enable
              ? (online.value)
                  ? isOnAnotherCall.value
                      ? widget.onTap(true, isLive.value)
                      : widget.onTap(false, isLive.value)
                  : null
              : widget.onTap(false, isLive.value);
        },
        child: Container(
          height: 50.h,
          width: 50.h,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(color: ConstColors.white, shape: BoxShape.circle),
          child: SvgView(
            widget.svg,
            fit: BoxFit.scaleDown,
            color: widget.enable
                ? (online.value)
                    ? ConstColors.themeColor
                    : ConstColors.offlineColor
                : ConstColors.themeColor,
          ),
        ),
      );
    });
  }
}

class Like extends StatefulWidget {
  const Like({Key? key, required this.postId, required this.toProfileId, required this.gender, required this.userObjId, required this.index})
      : super(key: key);
  final int index;
  final String toProfileId, postId, gender, userObjId;

  @override
  State<Like> createState() => _LikeState();
}

class _LikeState extends State<Like> {
  final RxBool like = false.obs;
  final RxBool heartVisible = false.obs;
  final RxBool clickeable = true.obs;
  HeartLike? selectedUsers;
  final PriceController _priceController = Get.put(PriceController());
  final PictureController pictureX = Get.put(PictureController());
  final AppSearchController _searchController = Get.put(AppSearchController());

  @override
  void initState() {
    if (_searchController.likeList.length > widget.index) {
      like.value = _searchController.likeList[widget.index];
    }
    HeartLikeProviderApi().getByFromProfileId(widget.toProfileId, widget.postId).then((value) {
      if (value != null) {
        like.value = true;
        selectedUsers = value.result;
      } else {
        like.value = false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return InkWell(
        onDoubleTap: () {},
        onTap: clickeable.value
            ? () async {
                clickeable.value = false;
                if (like.value) {
                  HeartLikeProviderApi().remove(selectedUsers!).then((value) {
                    clickeable.value = true;
                    like.value = _searchController.likeList[widget.index] = false;
                  });
                  await DeleteConversationApi()
                      .getSpeceficId(fromId: StorageService.getBox.read("DefaultProfile"), toId: widget.toProfileId, type: "HeartLike")
                      .then((value) {
                    if (value != null) {
                      DeleteConnection deleteConnection = DeleteConnection();
                      deleteConnection.objectId = value.result['objectId'];
                      DeleteConversationApi().update(deleteConnection).whenComplete(() {
                        DeleteConversationApi().getByUserId(StorageService.getBox.read('ObjectId'), "HeartLike");
                      });
                    } else {
                      DeleteConnection deleteConnection = DeleteConnection();
                      deleteConnection.toUser = UserLogin()..objectId = widget.userObjId;
                      deleteConnection.type = "HeartLike";
                      deleteConnection.fromUser = UserLogin()..objectId = StorageService.getBox.read("ObjectId");
                      deleteConnection.toProfile = ProfilePage()..objectId = widget.toProfileId;
                      deleteConnection.fromProfile = ProfilePage()..objectId = StorageService.getBox.read("DefaultProfile");
                      DeleteConversationApi().add(deleteConnection).whenComplete(() {
                        DeleteConversationApi().getByUserId(StorageService.getBox.read('ObjectId'), 'HeartLike').then((value) {
                          _priceController.update();
                        });
                      });
                    }
                  });
                  await PairNotificationProviderApi()
                      .getByProfile(StorageService.getBox.read("DefaultProfile"), widget.toProfileId, "HeartLike")
                      .then((value) {
                    PairNotifications pairNotifications = PairNotifications();
                    if (value == null) {
                    } else {
                      if (value.result['DeletedUsers'] != null && value.result['DeletedUsers'].isNotEmpty) {
                        pairNotifications.objectId = value.result['objectId'];
                        pairNotifications.deletedUsers = [
                          UserLogin()..objectId = StorageService.getBox.read('ObjectId'),
                          UserLogin()..objectId = widget.userObjId
                        ];
                        PairNotificationProviderApi().update(pairNotifications);
                      } else {
                        pairNotifications.objectId = value.result['objectId'];
                        pairNotifications.deletedUsers = [UserLogin()..objectId = StorageService.getBox.read('ObjectId')];
                        PairNotificationProviderApi().update(pairNotifications);
                      }
                    }
                  });
                } else {
                  heartVisible.value = true;
                  _priceController
                      .coinService('HeartLike', widget.gender, widget.toProfileId, widget.userObjId,
                          catValue: _priceController.heartLikePrice.value, postId: widget.postId)
                      .whenComplete(() {
                    HeartLikeProviderApi().getByFromProfileId(widget.toProfileId, widget.postId).then((value2) {
                      if (value2 != null) {
                        selectedUsers = value2.result;
                      }

                      clickeable.value = true;
                      like.value = _searchController.likeList[widget.index] = true;
                      heartVisible.value = false;
                    });
                  });
                }
              }
            : () {},
        child: Stack(
          children: [
            Obx(() {
              heartVisible.value;
              like.value;
              return Container(
                height: 40.w,
                width: 40.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: ConstColors.black.withOpacity(0.20)),
                child: like.value
                    ? const Icon(Icons.favorite_sharp, color: Colors.red)
                    : heartVisible.value
                        ? const SizedBox.shrink()
                        : const Icon(Icons.favorite_border_sharp, color: Colors.white),
              );
            }),
            Obx(() {
              if (heartVisible.value) {
                return Container(
                  height: 40.w,
                  width: 40.w,
                  padding: EdgeInsets.all(8.w),
                  child: Lottie.asset("assets/jsons/like.json", height: 50.w, width: 50.w),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      );
    });
  }
}
