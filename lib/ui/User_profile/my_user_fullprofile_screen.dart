// ignore_for_file: must_be_immutable, non_constant_identifier_names, invalid_use_of_protected_member, deprecated_member_use, depend_on_referenced_packages
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/post_view.dart';
import 'package:eypop/Controllers/PairNotificationController/pair_notification_controller.dart';
import 'package:eypop/Controllers/bottom_controller.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/Controllers/toktok_contoller.dart';
import 'package:eypop/back4appservice/user_provider/wishes/wish_provider_api.dart';
import 'package:eypop/models/user_login/user_post.dart';
import 'package:eypop/models/wishes_model/wish_model.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/User_profile/create_user_profile.dart';
import 'package:eypop/ui/User_profile/showpicture_screen.dart';
import 'package:eypop/ui/User_profile/showvideo_screen.dart';
import 'package:eypop/ui/settings/setting_screen.dart';
import 'package:eypop/ui/store_screen.dart';
import 'package:eypop/ui/token_screen.dart';
import 'package:eypop/ui/wishes_pages/create_wish_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Controllers/Picture_Controller/profile_pic_controller.dart';
import '../../Controllers/tabbar_controller.dart';
import '../../Controllers/user_controller.dart';
import '../../back4appservice/base/api_response.dart';
import '../../back4appservice/repositories/users/provider_post_video_api.dart';
import '../../back4appservice/user_provider/users/provider_post_api.dart';
import '../../back4appservice/user_provider/users/provider_profileuser_api.dart';
import '../../back4appservice/user_provider/users/provider_user_api.dart';
import '../../models/user_login/user_login.dart';
import '../../models/user_login/user_profile.dart';
import 'edit_profile.dart';

class MyUserFullProfileScreen extends GetView {
  MyUserFullProfileScreen({Key? key}) : super(key: key);

  final MyTabController _tabx = Get.put(MyTabController());
  final UserController _userController = Get.put(UserController());
  final PriceController _priceController = Get.put(PriceController());
  final PictureController pictureX = Get.put(PictureController());
  final PairNotificationController _pairNotificationController = Get.put(PairNotificationController());
  final AppSearchController _searchController = Get.put(AppSearchController());

  static TokTokController get tokTokController => Get.put(TokTokController());

  @override
  Widget build(BuildContext context) {
    StorageService.getBox.writeIfNull('index', 0);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.2,
        title: Styles.regular('eypop', ff: "HR", fs: 35.sp, c: ConstColors.themeColor),
        leadingWidth: 130.w,
        leading: InkWell(
          onTap: () async {
            if (StorageService.getBox.read('Gender') == 'male') {
              Get.to(() => StoreScreen());
            } else {
              Get.to(() => TokenView());
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 31.h,
                padding: EdgeInsets.only(left: 16.w),
                child: SvgView('assets/Icons/bluestar.svg', height: 26.w, width: 26.w),
              ),
              SizedBox(width: 8.w),
              Obx(() {
                _priceController.userTotalCoin.value;
                return Styles.regular(_priceController.userTotalCoin.value.toString(), fs: 19.sp, c: Theme.of(context).primaryColor);
              })
            ],
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Get.to(() => const CreateWishScreen());
            },
            child: SvgView('assets/Icons/bottomWish.svg', color: ConstColors.themeColor),
          ),
          InkWell(
            onTap: () {
              Get.to(() => Settings());
            },
            child: SvgView('assets/Icons/setting.svg', padding: EdgeInsets.only(right: 20.w, left: 16.w), color: ConstColors.themeColor),
          ),
        ],
      ),
      body: NestedScrollView(
        controller: _tabx.scrollController,
        headerSliverBuilder: (context, value) {
          return [
            GetBuilder<UserController>(
              builder: (logic) {
                return SliverToBoxAdapter(
                  child: Obx(() {
                    _searchController.profileData.value;
                    return FutureBuilder<ApiResponse?>(
                        future: UserProfileProviderApi().userProfileQuery(StorageService.getBox.read('ObjectId')),
                        builder: (context, snap) {
                          if (_searchController.profileData.isNotEmpty) {
                            if (StorageService.getBox.read('index') < 0) {
                              StorageService.getBox.write('index', 0);
                            }

                            if (snap.hasData) {
                              final int length = ((snap.data != null && snap.data!.results != null) ? snap.data!.results!.length : 0);
                              for (int i = 0; i < length; i++) {
                                if (snap.data!.results![i]['IsBlocked'] == true) {
                                  if (snap.data!.results![i]['BlockEndDate'] != null) {
                                    final DateTime date = snap.data!.results![i]['BlockEndDate'];
                                    final DateTime currentDate = DateTime.now();
                                    if (!currentDate.isBefore(date)) {
                                      final ProfilePage userprofile = ProfilePage();
                                      userprofile.objectId = snap.data!.results![i]['objectId'];
                                      userprofile.isBlocked = false;
                                      userprofile['BlockEndDate'] = snap.data!.results![i]['BlockStartDate'];
                                      userprofile['BlockDays'] = '0';
                                      UserProfileProviderApi().update(userprofile).then((val) {
                                        if ((length - 1) == i) {
                                          Future.delayed(const Duration(seconds: 5), () {
                                            _userController.update();
                                          });
                                        }
                                      });
                                    } else if (_searchController.profileData[i]['IsBlocked'] != snap.data!.results![i]['IsBlocked']) {
                                      _searchController.profileData[i].isBlocked = snap.data!.results![i]['IsBlocked'];
                                      _searchController.profileData[i]['BlockEndDate'] = snap.data!.results![i]['BlockStartDate'];
                                      _searchController.profileData[i]['BlockDays'] = '0';
                                    }
                                  }
                                } else if (snap.data!.results![i]['IsBlocked'] == false &&
                                    _searchController.profileData[i]['IsBlocked'] != snap.data!.results![i]['IsBlocked']) {
                                  _searchController.profileData[i].isBlocked = snap.data!.results![i]['IsBlocked'];
                                  _searchController.profileData[i]['BlockEndDate'] = snap.data!.results![i]['BlockStartDate'];
                                  _searchController.profileData[i]['BlockDays'] = '0';
                                }
                              }

                              /// for end
                            }

                            var defaultImgObjectId =
                                _searchController.profileData[StorageService.getBox.read('index')]['DefaultImg']?['objectId'] ?? '';

                            if (StorageService.getBox.read('DefaultImgObjectId') == null ||
                                StorageService.getBox.read('DefaultImgObjectId') != defaultImgObjectId) {
                              StorageService.getBox.write('DefaultImgObjectId', defaultImgObjectId);
                            }

                            // if (StorageService.getBox.read('DefaultImgObjectId') == null ||
                            //     StorageService.getBox.read('DefaultImgObjectId') !=
                            //         _searchController.profileData[StorageService.getBox.read('index')]['DefaultImg']['objectId']) {
                            //   StorageService.getBox.write(
                            //       'DefaultImgObjectId', _searchController.profileData[StorageService.getBox.read('index')]['DefaultImg']['objectId']);
                            // }
                            return Column(
                              key: ValueKey<bool>(_searchController.profileData.isNotEmpty),
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 13.h, bottom: 19.h),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 20.w, right: 20.w),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 80.h,
                                                  width: 80.h,
                                                  margin: EdgeInsets.only(top: 5.h),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(80.h),
                                                      border: Border.all(color: ConstColors.themeColor, width: 2.w)),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(80.h),
                                                    child: CachedNetworkImage(
                                                      alignment: Alignment.topCenter,
                                                      imageUrl: _searchController.profileData[StorageService.getBox.read('index')].imgProfile.url!,
                                                      memCacheHeight: 400,
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
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _userController.imageProfile.value = '';
                                                      Get.to(() => EditProfile(
                                                            userProfile: _searchController.profileData[StorageService.getBox.read('index')],
                                                            location: _searchController.profileData[StorageService.getBox.read('index')].locationName,
                                                            language: _searchController.profileData[StorageService.getBox.read('index')].language,
                                                            image: _searchController.profileData[StorageService.getBox.read('index')].imgProfile,
                                                            description:
                                                                _searchController.profileData[StorageService.getBox.read('index')].description,
                                                            name: _searchController.profileData[StorageService.getBox.read('index')].name,
                                                            userLogin: _searchController.profileData[StorageService.getBox.read('index')].userId,
                                                          ));
                                                    },
                                                    child: Container(
                                                      height: 32.w,
                                                      width: 32.w,
                                                      padding: EdgeInsets.all(7.r),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(color: ConstColors.black.withOpacity(0.20), blurRadius: 10.0, spreadRadius: 0.5),
                                                        ],
                                                      ),
                                                      child: SvgView('assets/Icons/edit.svg', color: ConstColors.themeColor),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(left: 9.w, top: 20.h),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    /// Name
                                                    Styles.regular(
                                                        '${_searchController.profileData[StorageService.getBox.read('index')].name.capitalizeFirst}',
                                                        fs: 18.sp,
                                                        c: Theme.of(context).primaryColor,
                                                        ff: 'RB'),
                                                    Styles.regular(_searchController.profileData[StorageService.getBox.read('index')].locationName,
                                                        fs: 16.sp, c: Theme.of(context).primaryColor, ff: 'RR'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (_searchController.profileData[StorageService.getBox.read('index')].language.isNotEmpty)
                                              SizedBox(
                                                height: 20.h,
                                                child: ListView.separated(
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: _searchController.profileData[StorageService.getBox.read('index')].language.length,
                                                  separatorBuilder: (BuildContext context, int index) => SizedBox(width: 5.w),
                                                  itemBuilder: (context, ind) {
                                                    return Image.network(
                                                        _searchController.profileData[StorageService.getBox.read('index')].language[ind]['Image']
                                                            ['url'],
                                                        height: 20.h,
                                                        width: 22.w);
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 7.h, bottom: 15.h),
                                        width: MediaQuery.sizeOf(context).width,
                                        child: Styles.regular(_searchController.profileData[StorageService.getBox.read('index')].description,
                                            fs: 18.sp, c: Theme.of(context).primaryColor, ff: 'RR'),
                                      ),
                                      SizedBox(
                                        height: 80.h,
                                        child: ListView.separated(
                                          controller: pictureX.controller,
                                          padding: EdgeInsets.only(left: 20.w),
                                          scrollDirection: Axis.horizontal,
                                          separatorBuilder: (context, index) => SizedBox(width: 10.w),
                                          itemCount: _searchController.profileData.length <
                                                  (StorageService.getBox.read('Gender') == 'female'
                                                      ? _userController.womanMaxProfile.value
                                                      : _userController.manMaxProfile.value)
                                              ? _searchController.profileData.length + 1
                                              : _searchController.profileData.length,
                                          itemBuilder: (context, index) {
                                            if (index == _searchController.profileData.length &&
                                                _searchController.profileData.length <
                                                    (StorageService.getBox.read('Gender') == 'female'
                                                        ? _userController.womanMaxProfile.value
                                                        : _userController.manMaxProfile.value)) {
                                              return Container(
                                                height: 80.h,
                                                width: 80.h,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle, border: Border.all(color: ConstColors.themeColor, width: 2.w)),
                                                child: IconButton(
                                                  icon: const SvgView('assets/Icons/add.svg'),
                                                  onPressed: () {
                                                    if (_searchController.profileData.length <
                                                        (StorageService.getBox.read('Gender') == 'female'
                                                            ? _userController.womanMaxProfile.value
                                                            : _userController.manMaxProfile.value)) {
                                                      _userController.imageProfile.value = '';
                                                      _userController.newName.text = '';
                                                      _userController.newDescription.text = '';
                                                      _userController.locationName.value = '';
                                                      _userController.newLangList.clear();
                                                      _userController.km.value = 1000.0;
                                                      _userController.selectedLanguages.value = [];

                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Dialog(
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
                                                            insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
                                                            child: Container(
                                                              height: 731.h,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(40.r),
                                                                  image: const DecorationImage(
                                                                      image: AssetImage('assets/images/cities.jpg'), fit: BoxFit.cover)),
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(top: 23.h, left: 10.w, right: 22.w),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsets.only(top: 25.h, left: 10.w),
                                                                          child: Transform.rotate(
                                                                            angle: -math.pi / 12,
                                                                            child: Styles.regular('New_traveler_managed_profile'.tr,
                                                                                lns: 3,
                                                                                ff: 'HB',
                                                                                al: TextAlign.start,
                                                                                fs: 37.sp,
                                                                                c: const Color(0xFF0A6C83)),
                                                                          ),
                                                                        ),
                                                                        SvgView(
                                                                          "assets/Icons/cancelbutton.svg",
                                                                          height: 45.w,
                                                                          width: 45.w,
                                                                          onTap: () {
                                                                            Get.back();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const Spacer(),
                                                                  Padding(
                                                                    padding: EdgeInsets.symmetric(horizontal: 44.w),
                                                                    child: GradientButton(
                                                                        title: 'create_profile'.tr,
                                                                        onTap: () {
                                                                          Get.back();
                                                                          Get.to(() => CreateUserProfileScreen(buttonTitle: 'create'.tr));
                                                                        }),
                                                                  ),
                                                                  SizedBox(height: 40.h),
                                                                  GradientButton(
                                                                      title: 'to_travel_another_city'.tr,
                                                                      height: 107.h,
                                                                      fontSize: 22.sp,
                                                                      circleRadius: 40.r,
                                                                      color1: const Color(0xFF868FFF),
                                                                      color2: const Color(0xFFE69791)),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                ),
                                              );
                                            }
                                            return GestureDetector(
                                              onTap: _searchController.profileLoading.value
                                                  ? () {}
                                                  : _searchController.profileData[index].isDeleted ||
                                                          (_searchController.profileData[index]['IsBlocked'] ?? false)
                                                      ? () {
                                                          if (_searchController.profileData[index].isDeleted) {
                                                            AlertShow(
                                                                context: context,
                                                                onConfirm: () async {
                                                                  final ProfilePage profile = ProfilePage();
                                                                  profile.isDeleted = false;
                                                                  profile.objectId = _searchController.profileData[index].objectId;
                                                                  final ApiResponse val = await UserProfileProviderApi().update(profile);
                                                                  _searchController.profileData[index].isDeleted = val.result['isDeleted'];
                                                                  List meBlocked = [];
                                                                  meBlocked = _pairNotificationController.meBlocked.value;
                                                                  _pairNotificationController.meBlocked.clear();
                                                                  _pairNotificationController.meBlocked.value = meBlocked;
                                                                  _userController.update();
                                                                },
                                                                userImage: _searchController.profileData[index].imgProfile.url,
                                                                alert:
                                                                    '${'active'.tr.toUpperCase()} ${'my'.tr.toUpperCase()} ${'profile'.tr.toUpperCase()}!',
                                                                text1: '',
                                                                text2: 'are_you_sure_you_want_to_active_the_profile'.tr);
                                                          }
                                                        }
                                                      : () async {
                                                          _searchController.profileLoading.value = true;
                                                          _searchController.loadIndex.value = index;
                                                          StorageService.getBox.write('index', index);
                                                          StorageService.getBox
                                                              .write('DefaultProfileImg', _searchController.profileData[index].imgProfile.url!);
                                                          StorageService.getBox
                                                              .write('DefaultProfile', _searchController.profileData[index].objectId);
                                                          StorageService.getBox.write('DefaultImgObjectId',
                                                              _searchController.profileData[index]['DefaultImg']?['objectId'] ?? '');
                                                          tokTokController.getAllWishByProfile();
                                                          StorageService.getBox
                                                              .write('AccountType', _searchController.profileData[index]['AccountType']);
                                                          _userController.locationLatitude.value =
                                                              _searchController.profileData[index].locationGeoPoint.latitude;
                                                          _userController.locationLongitude.value =
                                                              _searchController.profileData[index].locationGeoPoint.longitude;
                                                          _userController.locationName.value = _searchController.profileData[index].locationName;
                                                          UserLogin userLogin = UserLogin();

                                                          userLogin.objectId = StorageService.getBox.read("ObjectId");
                                                          userLogin.locationGeoPoint = _searchController.profileData[index].locationGeoPoint;
                                                          userLogin.locationName = _searchController.profileData[index].locationName;
                                                          userLogin.locationRadius = _searchController.profileData[index].locationRadius;
                                                          userLogin.defaultProfileId = ProfilePage()
                                                            ..objectId = _searchController.profileData[index].objectId;
                                                          await UserLoginProviderApi().update(userLogin);
                                                          print('Hello DefaultProfile Id -------- ${StorageService.getBox.read('DefaultProfile')}');
                                                          await updateLastOnlineProfile();
                                                          await getDefaultProfile();
                                                          bottomRefresh.value = !bottomRefresh.value;
                                                          _searchController.isPixLoad.value = false;
                                                          _searchController.load.value = false;
                                                          _searchController.page.value = 0;
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
                                                          _searchController.profileLoading.value = false;
                                                          _searchController.update();
                                                          _userController.update();
                                                          _searchController.seenKeys.clear();
                                                        },
                                              onLongPress: _searchController.profileData.length <= 1 ||
                                                      _searchController.profileData[index]['AccountType'] == 'FAKE'
                                                  ? null
                                                  : _searchController.profileData[index].isDeleted ||
                                                          (_searchController.profileData[index]['IsBlocked'] ?? false)
                                                      ? null
                                                      : () {
                                                          AlertShow(
                                                              context: context,
                                                              onConfirm: () {
                                                                final ProfilePage profile = ProfilePage();
                                                                profile.isDeleted = true;
                                                                profile.objectId = _searchController.profileData[index].objectId;
                                                                UserProfileProviderApi().update(profile).then((val) async {
                                                                  StorageService.getBox.write('index', 0);
                                                                  _searchController.profileData[index].isDeleted = val.result['isDeleted'];
                                                                  if (val.result['objectId'] == StorageService.getBox.read('DefaultProfile')) {
                                                                    for (int i = 0; i < _searchController.profileData.length; i++) {
                                                                      if (_searchController.profileData[i].isDeleted == false &&
                                                                          !(_searchController.profileData[index]['IsBlocked'] ?? false)) {
                                                                        StorageService.getBox.write('index', i);
                                                                        break;
                                                                      }
                                                                    }
                                                                  }
                                                                  List meBlocked = [];
                                                                  meBlocked = _pairNotificationController.meBlocked.value;
                                                                  _pairNotificationController.meBlocked.clear();
                                                                  _pairNotificationController.meBlocked.value = meBlocked;
                                                                  final int ind = StorageService.getBox.read('index');
                                                                  StorageService.getBox
                                                                      .write('DefaultProfileImg', _searchController.profileData[ind].imgProfile.url!);
                                                                  StorageService.getBox
                                                                      .write('DefaultProfile', _searchController.profileData[ind].objectId);
                                                                  StorageService.getBox.write('DefaultImgObjectId',
                                                                      _searchController.profileData[ind]['DefaultImg']['objectId']);
                                                                  tokTokController.getAllWishByProfile();
                                                                  StorageService.getBox
                                                                      .write('AccountType', _searchController.profileData[ind]['AccountType']);
                                                                  _userController.locationLatitude.value =
                                                                      _searchController.profileData[ind].locationGeoPoint.latitude;
                                                                  _userController.locationLongitude.value =
                                                                      _searchController.profileData[ind].locationGeoPoint.longitude;
                                                                  _userController.locationName.value =
                                                                      _searchController.profileData[ind].locationName;
                                                                  final UserLogin userLogin = UserLogin();
                                                                  userLogin.objectId = StorageService.getBox.read("ObjectId");
                                                                  userLogin.locationGeoPoint = _searchController.profileData[ind].locationGeoPoint;
                                                                  userLogin.locationName = _searchController.profileData[ind].locationName;
                                                                  userLogin.locationRadius = _searchController.profileData[ind].locationRadius;
                                                                  userLogin.defaultProfileId = ProfilePage()
                                                                    ..objectId = _searchController.profileData[ind].objectId;

                                                                  await UserLoginProviderApi().update(userLogin);
                                                                  _searchController.isPixLoad.value = false;
                                                                  _searchController.load.value = false;
                                                                  _searchController.page.value = 0;
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
                                                                  _searchController.update();
                                                                  _userController.update();
                                                                });
                                                              },
                                                              c1: Theme.of(context).primaryColor,
                                                              forgot: true,
                                                              svg: 'assets/Icons/popup_delete.svg',
                                                              confirmText: 'remove'.tr.replaceAll('¡', ''),
                                                              text1: '${'remove'.tr.toUpperCase()} ${'profile'.tr.toUpperCase()}!',
                                                              text2: '${'want_to_delete_this'.tr} ${'profile'.tr.toLowerCase()}?');
                                                        },
                                              child: Container(
                                                height: 80.h,
                                                width: 80.h,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(40.h),
                                                    border: Border.all(color: ConstColors.themeColor, width: 2.w)),
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(40.h),
                                                      child: CachedNetworkImage(
                                                        imageUrl: _searchController.profileData[index].imgProfile.url!,
                                                        alignment: Alignment.topCenter,
                                                        memCacheHeight: 400,
                                                        //this line
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => preCachedSquare(),
                                                        fadeInDuration: const Duration(milliseconds: 100),
                                                        placeholderFadeInDuration: const Duration(milliseconds: 100),
                                                        errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                                      ),
                                                    ),
                                                    if (_searchController.profileData[index].isDeleted ||
                                                        (_searchController.profileData[index]['IsBlocked'] ?? false))
                                                      SvgView("assets/Icons/deletesign.svg", height: 42.w, width: 42.w, fit: BoxFit.scaleDown),
                                                    Obx(() {
                                                      if (_searchController.profileLoading.value && _searchController.loadIndex.value == index) {
                                                        return Center(child: CircularProgressIndicator(color: ConstColors.themeColor));
                                                      } else {
                                                        return const SizedBox();
                                                      }
                                                    })
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Container(
                              key: ValueKey<bool>(_searchController.profileData.isNotEmpty),
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(bottom: 100.h),
                              child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown),
                            );
                          }
                        });
                  }),
                );
              },
            ),
          ];
        },
        body: Column(
          children: [
            Obx(() {
              return Container(
                height: 48.h,
                width: MediaQuery.sizeOf(context).width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  boxShadow: [
                    BoxShadow(color: ConstColors.grey, offset: const Offset(0.0, 0.1), blurRadius: 0.1, spreadRadius: 0.1), //BoxShadow
                  ],
                ),
                child: TabBar(
                  controller: _tabx.tabController,
                  padding: EdgeInsets.symmetric(horizontal: 65.5.h),
                  indicatorColor: ConstColors.themeColor,
                  labelColor: ConstColors.themeColor,
                  indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 4.0, color: ConstColors.themeColor), insets: EdgeInsets.only(left: 10.w, right: 10.w)),
                  tabs: <Widget>[
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.only(right: 10.w, left: 10.w),
                        child: SvgView('assets/Icons/gallery2.svg',
                            color: _tabx.selectedIndex.value == 0 ? ConstColors.themeColor : ConstColors.themeColor.withOpacity(0.57)),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.w, right: 10.w),
                        child: SvgView('assets/Icons/video.svg',
                            color: _tabx.selectedIndex.value == 1 ? ConstColors.themeColor : ConstColors.themeColor.withOpacity(0.57)),
                      ),
                    ),
                  ],
                ),
              );
            }),
            divider(),
            Expanded(
              child: GetBuilder<UserController>(
                  init: UserController(),
                  builder: (logic) {
                    final BottomControllers bottomController = Get.put(BottomControllers());
                    return AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: TabBarView(
                        controller: _tabx.tabController,
                        children: [
                          FutureBuilder<ApiResponse?>(
                              future: PostProviderApi().profilePostQuery(StorageService.getBox.read('DefaultProfile')),
                              builder: (context, snapPhoto) {
                                if (snapPhoto.connectionState == ConnectionState.waiting) {
                                  return Center(
                                    key: const ValueKey(0),
                                    child: Container(
                                        padding: EdgeInsets.all(10.r),
                                        height: 250.h,
                                        child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown)),
                                  );
                                }
                                if(snapPhoto.connectionState == ConnectionState.none){
                                  return Center(
                                    key: const ValueKey(0),
                                    child: Container(
                                        padding: EdgeInsets.all(10.r),
                                        height: 250.h,
                                        child: Lottie.asset('assets/jsons/fire.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown)),
                                  );
                                }
                                if (snapPhoto.connectionState == ConnectionState.done && snapPhoto.hasData && snapPhoto.data?.results != null) {
                                  print('Hello User Default Profile ----- ${StorageService.getBox.read('DefaultProfile')}');
                                  return Photos(context, images: snapPhoto.data?.results ?? [], key: const ValueKey(1));
                                } else {
                                  return Obx(() {
                                    return Padding(
                                      key: const ValueKey(2),
                                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
                                      child: Column(
                                        children: [
                                          Styles.regular('Upload_your_best_photos'.tr, fs: 18.sp, c: Theme.of(context).primaryColor),
                                          SizedBox(height: 15.h),
                                          bottomController.uploadPhoto(context, isBack: false),
                                        ],
                                      ),
                                    );
                                  });
                                }
                              }),
                          FutureBuilder<ApiResponse?>(
                              future: PostVideoProviderApi().profileVideoPostQuery(StorageService.getBox.read('DefaultProfile')),
                              builder: (context, snapshotVideo) {
                                if (snapshotVideo.connectionState == ConnectionState.waiting) {
                                  return Center(
                                    key: const ValueKey(3),
                                    child: Container(
                                        padding: EdgeInsets.all(10.r),
                                        height: 250.h,
                                        child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown)),
                                  );
                                }
                                if(snapshotVideo.connectionState == ConnectionState.none){
                                  return Center(
                                    key: const ValueKey(3),
                                    child: Container(
                                        padding: EdgeInsets.all(10.r),
                                        height: 250.h,
                                        child: Lottie.asset('assets/jsons/fire.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown)),
                                  );
                                }
                                if (snapshotVideo.connectionState == ConnectionState.done &&
                                    snapshotVideo.hasData &&
                                    snapshotVideo.data?.results != null) {
                                  return Videos(context, videos: snapshotVideo.data?.results ?? [], key: const ValueKey(4));
                                } else {
                                  return Obx(() {
                                    return Padding(
                                      key: const ValueKey(5),
                                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
                                      child: Column(
                                        children: [
                                          Styles.regular('Upload_your_best_videos'.tr, fs: 18.sp, c: Theme.of(context).primaryColor),
                                          SizedBox(height: 15.h),
                                          bottomController.uploadVideo(context, isBack: false),
                                        ],
                                      ),
                                    );
                                  });
                                }
                              }),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget Photos(context, {required List images, required Key key}) {
    try {
      if (StorageService.getBox.read('DefaultImgObjectId') != null) {
        dynamic first;
        final int index = images.indexWhere((element) => element['objectId'] == StorageService.getBox.read('DefaultImgObjectId'));
        for (var element in images) {
          if (element['objectId'] == StorageService.getBox.read('DefaultImgObjectId')) {
            first = element;
          }
        }
        if (!index.isNegative) {
          images.removeAt(index);
          images.insert(0, first);
        }
      }
    } catch (e) {
      debugPrint('Hello get index error $e');
    }

    return GridView.builder(
        key: key,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisExtent: _tabx.one204.value, crossAxisCount: 3),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: images.length,
        itemBuilder: (context, index) {
          bool showDelete = false;
          final bool status = (images[index]['Status'] ?? true);
          final bool isDefault = StorageService.getBox.read('DefaultImgObjectId') == images[index]['objectId'];
          // FAKE USER CAN DELETE OWN POST WHEN [EnableDeletePhoto] true
          if (enableDeletePhoto.value) {
            showDelete = true;
          } else {
            if (images[index]['User']['AccountType'] == 'REAL' ||
                images[index]['AccountType'] == 'REAL' ||
                images[index]['Profile']['AccountType'] == 'REAL') {
              showDelete = true;
            } else {
              showDelete = false;
            }
          }
          return Obx(() {
            tokTokController.tokTokTotalImage;
            return PostView(
              key: ValueKey(images[index]['objectId']),
              isMe: true,
              imgStatus: status,
              memCacheHeight: 600,
              isNude: (images[index]['IsNude'] ?? false),
              isTWish: tokTokController.tokTokTotalImage.toString().contains(images[index]['objectId']),
              img: images[index]['Post'] != null ? images[index]['Post'].url.toString() : "",
              onTap: () {
                Get.to(
                  () => ShowPictureScreen(
                    imgObjectId: images[index]['objectId'],
                    toUserDefaultProfileId: StorageService.getBox.read('DefaultImgObjectId'),
                    fromProfileId: StorageService.getBox.read('DefaultProfile'),
                    toProfileId: StorageService.getBox.read('DefaultProfile'),
                    deleteEnable: (showDelete && status),
                    visitMode: false,
                    index: index,
                  ),
                );
              },
              onTapX: () {
                showDeleteDialog(
                  context,
                  title: 'permanent_delete_photo'.tr,
                  onTap: () async {
                    // remove from User_Wish table
                    final indexTok = tokTokController.tokTokTotalImage.indexWhere((element) => element['Img_Post'] == images[index]['objectId']);
                    if (!indexTok.isNegative) {
                      final WishModel wishModel = WishModel();
                      wishModel.objectId = tokTokController.tokTokTotalImage[indexTok]['Users_Wish'];
                      await WishesApi().remove(wishModel).then((value) {
                        tokTokController.tokTokTotalImage.removeAt(indexTok);
                        tokTokController.tokTokTotalImage.refresh();
                      });
                    }
                    if (isDefault) {
                      final UserPost userPost = UserPost();
                      userPost.objectId = images[index]['objectId'];
                      userPost.status = false;
                      await PostProviderApi().update(userPost);
                      final ProfilePage profilePage = ProfilePage();
                      profilePage.objectId = StorageService.getBox.read('DefaultProfile');
                      profilePage.imgStatus = false;
                      await UserProfileProviderApi().update(profilePage);
                    } else {
                      await PostProviderApi().remove(images[index]);
                    }
                    _userController.update();
                    Get.back();
                  },
                );
              },
              // onLongPress: () {
              // AlertShow(
              //   context: context,
              //   onConfirm: () {
              //     final bool isDefault = (_userController.profilePage['DefaultImg'] != null &&
              //         _userController.profilePage['DefaultImg']['objectId'] == snapPhoto.data!.results![index]['objectId']);
              //
              //     if (isDefault) {
              //       final UserPost userPost = UserPost();
              //       userPost.objectId = snapPhoto.data!.results![index]['objectId'];
              //       userPost.status = false;
              //       PostProviderApi().update(userPost);
              //       final ProfilePage profilePage = ProfilePage();
              //       profilePage.objectId = _userController.profileeId.value;
              //       profilePage['img_status'] = false;
              //       UserProfileProviderApi().update(profilePage);
              //       _userController.update();
              //     } else {
              //       PostProviderApi().remove(snapPhoto.data!.results![index]).then((value) {
              //         _userController.update();
              //       });
              //     }
              //   },
              //   forgot: true,
              //   c1: ConstColors.themeColor,
              //   svg: 'assets/Icons/popup_delete.svg',
              //   confirmText: 'remove'.tr.replaceAll('¡', ''),
              //   text1: '${'remove'.tr.toUpperCase()} ${'photo'.tr.toUpperCase()}!',
              //   text2: '${'want_to_delete_this'.tr} ${'photo'.tr}?',
              // );
              // }
            );
          });
        });
  }

  Widget Videos(context, {required List videos, required Key key}) {
    return GridView.builder(
        key: key,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisExtent: _tabx.one204.value, crossAxisCount: 3),
        shrinkWrap: true,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final bool status = (videos[index]['Status'] ?? true);
          return Obx(() {
            tokTokController.tokTokTotalVideo;
            return PostView(
              key: ValueKey(videos[index]['objectId']),
              isMe: true,
              isVideo: true,
              memCacheHeight: 600,
              imgStatus: status,
              isNude: (videos[index]['IsNude'] ?? false),
              isTWish: tokTokController.tokTokTotalVideo.toString().contains(videos[index]['objectId']),
              img: videos[index]['PostThumbnail'] != null ? videos[index]['PostThumbnail'].url.toString() : "",
              onTap: () {
                Get.to(
                  () => ShowVideoScreen(
                    userController: _userController,
                    vidObjectId: videos[index]['objectId'],
                    visitMode: false,
                    toProfileId: StorageService.getBox.read('DefaultProfile'),
                    fromProfileId: StorageService.getBox.read('DefaultProfile'),
                    index: index,
                  ),
                );
              },
              onTapX: () async {
                showDeleteDialog(
                  context,
                  title: 'permanent_delete_video'.tr,
                  onTap: () async {
                    // remove from User_Wish table
                    final indexTok = tokTokController.tokTokTotalVideo.indexWhere((element) => element['Video_Post'] == videos[index]['objectId']);
                    if (!indexTok.isNegative) {
                      final WishModel wishModel = WishModel();
                      wishModel.objectId = tokTokController.tokTokTotalVideo[indexTok]['Users_Wish'];
                      await WishesApi().remove(wishModel).then((value) {
                        tokTokController.tokTokTotalVideo.removeAt(indexTok);
                        tokTokController.tokTokTotalVideo.refresh();
                      });
                    }
                    await PostVideoProviderApi().remove(videos[index]).then((value) {
                      _userController.update();
                      Get.back();
                    });
                  },
                );
              },
              // onLongPress: () {
              // AlertShow(
              //   context: context,
              //   onConfirm: () {
              //     PostVideoProviderApi().remove(snapshot.data!.results![index]).then((value) {
              //       _userController.update();
              //     });
              //   },
              //   forgot: true,
              //   c1: ConstColors.themeColor,
              //   svg: 'assets/Icons/popup_delete.svg',
              //   confirmText: 'remove'.tr.replaceAll('¡', ''),
              //   text1: '${'remove'.tr.toUpperCase()} ${'video'.tr.toUpperCase()}!',
              //   text2: '${'want_to_delete_this'.tr} ${'video'.tr}?',
              // );
              // },
            );
          });
        });
  }
}
