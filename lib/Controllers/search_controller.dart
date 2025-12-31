// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/Picture_Controller/profile_pic_controller.dart';
import 'package:eypop/Controllers/toktok_contoller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../Constant/Widgets/textwidget.dart';
import '../Constant/constant.dart';
import '../back4appservice/user_provider/users/provider_profileuser_api.dart';
import '../back4appservice/user_provider/users/provider_user_api.dart';
import '../models/user_login/user_login.dart';
import '../models/user_login/user_profile.dart';
import '../service/location_services.dart';

final PictureController pictureX = Get.put(PictureController());

class AppSearchController extends GetxController {
  final RxBool isWallPhotosFetched = false.obs;
    RxList<ParseObject> parseObjectList = <ParseObject>[].obs;
    RxList<String> tempGetWallProfileId = <String>[].obs;
  final TokTokController tokTokController = Get.put(TokTokController()); // do not remove this we load data in onInit
  final TextEditingController query = TextEditingController();
  final SwiperController swiperController = SwiperController();
  final RxList<ProfilePage> profileData = <ProfilePage>[].obs;
  final RxList<String> profileObjectData = <String>[].obs;
  final RxString locationName = ''.obs;
  final RxString address = ''.obs;
  final RxDouble locationLatitude = 0.0.obs;
  final RxDouble locationLongitude = 0.0.obs;
  final RxString countryCode = ''.obs;
  final RxDouble km = 1000.0.obs;
  final RxBool load = false.obs;
  final RxBool isPixLoad = true.obs;
  final RxBool isLocationPressed = true.obs;
  final RxList<String> selectMedalList = <String>[].obs;
  final List allMedalList = [null, '','gold','silver','bronze'];
  final RxBool isGoldMedal = false.obs;
  final RxBool isSilverMedal = false.obs;
  final RxBool isBronzeMedal = false.obs;
  final RxList<int> imagePostCount = <int>[].obs;
  final RxList<Map<String, dynamic>> wallPostCount = <Map<String, dynamic>>[
    {"objectId": "", "count": 0}
  ].obs;
  final RxList<int> videoPostCount = <int>[].obs;
  final RxList<Map<String, dynamic>> wallVideoPostCount = <Map<String, dynamic>>[
    {"objectId": "", "count": 0}
  ].obs;
  final RxList profileIds = [].obs;
  final RxList<bool> likeList = <bool>[].obs;
  final RxList<bool> showNudeImage = <bool>[].obs;
  final RxList<ParseObject> finalPost = <ParseObject>[].obs;
  final RxList<String> reachProfile = <String>[].obs;
  final RxInt page = 0.obs;
  final RxBool profileLoading = false.obs;
  final RxBool searchLocation = false.obs;
  final RxBool isNearbyLocation = false.obs;
  final RxInt loadIndex = 0.obs;

  String location = '';
  List<String> seenKeys = [];

  Future<void> getProfileData() async {
    if (StorageService.getBox.read('ObjectId') != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        profileData.clear();
        profileObjectData.clear();
        await UserProfileProviderApi().userProfileQuery(StorageService.getBox.read('ObjectId')).then((value) {
          if (value != null && value.results != null) {
            for (final ele in value.results ?? []) {
              if (!profileObjectData.toString().contains(ele['objectId'])) {
                profileData.add(ele);
                profileObjectData.add(ele['objectId']);
              }
            }
            /// first time onInit toktok data default Profile (don't remove this line)
            Get.put(TokTokController()).onInit();
          }
        });
      });
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    const py = 0.017453292519943295;
    const cosTheta = cos;
    final a = 0.5 -
        cosTheta((lat2 - lat1) * py) / 2 +
        cosTheta(lat1 * py) * cosTheta(lat2 * py) * (1 - cosTheta((lon2 - lon1) * py)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> onLoading() async {
    if (kDebugMode) {
      print('Hello Wall Loading Start.... Page: $page');
    }
    await UserLoginProviderApi()
        .getWallPhotos(StorageService.getBox.read('DefaultProfile') ?? '', page.value)
        .then((dd) async {
      if (dd == 0) {
        for (var element in profileIds) {
          if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {
            await StorageService.profileBox.delete(element['id']);
          }
        }
        page.value = 0;
        profileIds.value = StorageService.profileBox.values.toList();
      }
      load.value = true;
    });
    page.value += 10;
    return;
  }

  Future<void> bottomSheetLocation(context) {
    final PlaceApiProvider apiClient = PlaceApiProvider();
    final UserController userController = Get.put(UserController());
    isLocationPressed.value = true;
    query.clear();
    return showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r)),
      ),
      backgroundColor: ConstColors.white,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SizedBox(
              height: 500.h,
              child: Padding(
                padding:
                    EdgeInsets.only(top: 14.h, left: 20.w, right: 20.w, bottom: MediaQuery.of(context).padding.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset("assets/jsons/gps-location-pointer.json", height: 60.h, width: 80.w),
                        const Spacer(),
                        Styles.regular('whereareyou'.tr, ff: 'HB', fs: 18.sp, c: ConstColors.black),
                        const Spacer(
                          flex: 3,
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    GradientButton(
                      title: 'actual_position'.tr,
                      onTap: () async {
                        if (isLocationPressed.value) {
                          Get.back();
                          isLocationPressed.value = false;
                          final Position value = await userController.getCurrentPosition();
                          final List<Placemark> placeMarks =
                              await placemarkFromCoordinates(value.latitude, value.longitude);

                          final Placemark place = placeMarks[0];
                          if (place.subAdministrativeArea == null || place.subAdministrativeArea!.isEmpty) {
                            address.value = '${place.administrativeArea}, ${place.country}';
                          } else {
                            address.value =
                                '${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}';
                          }
                          locationName.value = address.value;
                          location = address.value;

                          locationLatitude.value = value.latitude;
                          locationLongitude.value = value.longitude;
                          countryCode.value = place.isoCountryCode!;

                          final ProfilePage userprofile = ProfilePage();
                          final UserLogin userLogin = UserLogin();

                          userprofile.objectId = StorageService.getBox.read('DefaultProfile');
                          userprofile.locationGeoPoint =
                              ParseGeoPoint(latitude: locationLatitude.value, longitude: locationLongitude.value);
                          userprofile.locationRadius = km.value.toString();
                          userprofile.locationName = locationName.value;
                          userprofile.countryCode = place.isoCountryCode!;
                          userLogin.objectId = StorageService.getBox.read('ObjectId');
                          userLogin.locationName = locationName.value;
                          userLogin.locationGeoPoint =
                              ParseGeoPoint(latitude: locationLatitude.value, longitude: locationLongitude.value);
                          userLogin.locationRadius = km.value.toString();
                          userLogin.local =
                              StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;

                          await UserProfileProviderApi().update(userprofile);
                          await UserLoginProviderApi().update(userLogin);

                          likeList.clear();
                          imagePostCount.clear();
                          videoPostCount.clear();
                          finalPost.clear();
                          tempGetWallProfileId.clear();
                          parseObjectList.clear();
                          pictureX.swiperIndex.value = 0;
                          page.value = 0;
                          load.value = false;
                          isPixLoad.value = true;
                          getProfileData();
                          update();
                          userController.update();
                          query.clear();
                          isLocationPressed.value = true;
                        }
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.h, left: 25.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Styles.regular('distance'.tr, c: ConstColors.black, fs: 18.sp, ff: 'RB'),
                          SizedBox(width: 12.w),
                          Obx(() {
                            return Styles.regular("${'until'.tr} ${km.value.toStringAsFixed(0)} ${'kilometers'.tr}",
                                c: ConstColors.subtitle, fs: 18.sp);
                          })
                        ],
                      ),
                    ),
                    Obx(
                      () => Slider(
                        min: 0,
                        max: 1000,
                        activeColor: ConstColors.themeColor,
                        inactiveColor: ConstColors.grey,
                        value: km.value,
                        onChanged: (value) {
                          km.value = value;
                        },
                      ),
                    ),
                    GetBuilder<AppSearchController>(
                      // init: userController,
                      builder: (controller) {
                        return TextFormField(
                          controller: query,
                          autofocus: false,
                          cursorColor: ConstColors.themeColor,
                          style: TextStyle(
                              color: ConstColors.black,
                              fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
                          onChanged: (value) {
                            searchLocation.value = true;
                            update();
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'my_city'.tr,
                            hintStyle: TextStyle(
                                color: ConstColors.black,
                                fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
                            prefixIcon: Icon(Icons.search, color: ConstColors.black),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ConstColors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ConstColors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
                      },
                    ),
                    GetBuilder<AppSearchController>(
                      builder: (controller) {
                        searchLocation.value;
                        return Expanded(
                          child: FutureBuilder<List<Suggestion>?>(
                              future: apiClient.fetchSuggestions(
                                  query.text,
                                  StorageService.getBox.read('languageCode') ??
                                      Localizations.localeOf(context).languageCode),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                    itemBuilder: (context, index) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      title: Styles.regular((snapshot.data![index]).description,
                                          fs: 15.sp, c: ConstColors.black),
                                      onTap: () async {
                                        locationName.value = snapshot.data![index].description;
                                        final List<Location> locations =
                                            await locationFromAddress(snapshot.data![index].description);
                                        location = snapshot.data![index].description;
                                        final List<Placemark> placeMarks = await placemarkFromCoordinates(
                                            locations[0].latitude, locations[0].longitude);
                                        final Placemark place = placeMarks[0];

                                        countryCode.value = place.isoCountryCode!;

                                        locationLatitude.value = locations[0].latitude;
                                        locationLongitude.value = locations[0].longitude;

                                        final ProfilePage userprofile = ProfilePage();
                                        final UserLogin userLogin = UserLogin();

                                        userprofile.objectId = StorageService.getBox.read('DefaultProfile');
                                        userprofile.locationGeoPoint = ParseGeoPoint(
                                            latitude: locationLatitude.value, longitude: locationLongitude.value);
                                        userprofile.locationRadius = km.value.toString();
                                        userprofile.locationName = locationName.value;
                                        userprofile.countryCode = place.isoCountryCode!;

                                        userLogin.objectId = StorageService.getBox.read('ObjectId');
                                        userLogin.locationName = locationName.value;
                                        userLogin.locationGeoPoint = ParseGeoPoint(
                                            latitude: locationLatitude.value, longitude: locationLongitude.value);
                                        userLogin.locationRadius = km.value.toString();
                                        userLogin.local = StorageService.getBox.read('languageCode') ??
                                            Get.deviceLocale!.languageCode;
                                        await UserProfileProviderApi().update(userprofile);
                                        await UserLoginProviderApi().update(userLogin);

                                        likeList.clear();
                                        imagePostCount.clear();
                                        videoPostCount.clear();
                                        finalPost.clear();
                                        tempGetWallProfileId.clear();
                                        seenKeys.clear();
                                        parseObjectList.clear();
                                        pictureX.swiperIndex.value = 0;
                                        isPixLoad.value = true;
                                        load.value = false;
                                        page.value = 0;
                                        query.clear();
                                        getProfileData();
                                        update();
                                        userController.update();
                                        Get.back();
                                      },
                                    ),
                                    itemCount: snapshot.data!.length,
                                  );
                                } else {
                                  if (query.text.isNotEmpty) {
                                    return SizedBox(
                                      height: 250.h,
                                      child: Center(
                                        child: CircularProgressIndicator(color: ConstColors.themeColor),
                                      ),
                                    );
                                  } else {
                                    return SizedBox(
                                      height: 250.h,
                                      child: Center(
                                          child: Styles.regular('search_places'.tr, fs: 15.sp, c: ConstColors.black)),
                                    );
                                  }
                                }
                              }),
                        );
                      },
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }
}
