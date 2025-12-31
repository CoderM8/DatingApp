// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../Constant/Widgets/button.dart';
import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Controllers/Picture_Controller/profile_pic_controller.dart';
import '../../Controllers/user_controller.dart';
import '../../back4appservice/user_provider/language_api.dart';

import '../../models/user_login/user_login.dart';
import '../../service/location_services.dart';
import '../permission_screen.dart';

class EditProfile extends StatefulWidget {
  const EditProfile(
      {Key? key,
      required this.userLogin,
      required this.name,
      required this.description,
      required this.image,
      required this.language,
      required this.userProfile,
      required this.location})
      : super(key: key);

  final UserLogin userLogin;
  final String name;
  final String description;
  final ParseFileBase image;
  final String location;
  final ProfilePage userProfile;
  final List<dynamic> language;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final UserController _userController = Get.put(UserController());
  final PictureController pictureX = Get.put(PictureController());

  @override
  void initState() {
    super.initState();
    _userController.selectedImage = null;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _userController.selectedLanguages.value = widget.language;
      _userController.locationName.value = widget.location;
    });
    _userController.nameEdit = TextEditingController(text: widget.name);
    _userController.descriptionEdit = TextEditingController(text: widget.description);
    _userController.isNameEdit.value = true;
    _userController.isDescriptionEdit.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GetBuilder<UserController>(builder: (controller) {
          return GradientWidget(
            child: Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 58.h),
              child: Form(
                key: controller.editProfileForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgView(
                          "assets/Icons/close.svg",
                          color: ConstColors.closeColor,
                          height: 29.w,
                          width: 29.w,
                          onTap: () {
                            Get.back();
                          },
                        ),
                        const Spacer(flex: 2),
                        Stack(
                          children: [
                            if (controller.selectedImage == null)
                              SizedBox(
                                height: 144.w,
                                width: 144.w,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.r),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.image.url!,
                                    alignment: Alignment.topCenter,
                                    memCacheHeight: 400,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => preCachedSquare(),
                                    fadeInDuration: const Duration(milliseconds: 100),
                                    placeholderFadeInDuration: const Duration(milliseconds: 100),
                                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                height: 144.w,
                                width: 144.w,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.r),
                                  child: Image.file(File(controller.imageProfile.value), fit: BoxFit.cover, alignment: Alignment.topCenter),
                                ),
                              ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: controller.imgFromGallery,
                                child: Center(child: SvgView("assets/Icons/reset.svg", height: 48.w, width: 48.w)),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(flex: 3),
                      ],
                    ),
                    SizedBox(height: 19.h),
                    Styles.regular(
                      'your_name'.tr,
                      fs: 18.sp,
                      c: ConstColors.white,
                    ),
                    SizedBox(height: 5.h),
                    TextFieldModel(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                        hint: '',
                        textInputAction: TextInputAction.next,
                        color: ConstColors.white,
                        borderColor: ConstColors.white,
                        containerColor: Colors.transparent,
                        textInputType: TextInputType.text,
                        controllers: controller.nameEdit,
                        onChanged: (v) {
                          controller.isNameEdit.value = v.isNotEmpty;
                        },
                        maxLan: 20),
                    Styles.regular('what_are_looking'.tr, fs: 18.sp, c: ConstColors.white),
                    SizedBox(height: 5.h),
                    TextFieldModel(
                      maxLine: 6,
                      minLine: 4,
                      hint: '',
                      contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                      textInputAction: TextInputAction.done,
                      borderColor: ConstColors.white,
                      containerColor: Colors.transparent,
                      textInputType: TextInputType.text,
                      color: ConstColors.white,
                      controllers: controller.descriptionEdit,
                      maxLan: 150,
                      onChanged: (v) {
                        controller.isDescriptionEdit.value = v.isNotEmpty;
                      },
                    ),
                    SizedBox(height: 10.h),
                    GradientButton(
                        width: MediaQuery.sizeOf(context).width,
                        color1: ConstColors.pinkColor,
                        color2: ConstColors.lightPurpleColor,
                        title: 'prefer_Language'.tr,
                        onTap: () async {
                          _userController.getAllLanguage.clear();
                          _userController.searchLanguageTextController.value.clear();
                          _userController.searchLanguage.clear();
                          await LanguageProviderApi().getAll().then((value) {
                            if (value.results != null) {
                              value.results?.forEach((element) {
                                _userController.getAllLanguage.add(element);
                                _userController.searchLanguage.add(element);
                              });
                              bottomShitLanguage(context);
                            }
                          });
                        }),
                    SizedBox(height: 10.h),
                    Obx(() => _userController.selectedLanguages.isNotEmpty
                        ? Row(
                            children: [
                              SvgView("assets/Icons/language.svg", color: ConstColors.white, height: 40.w, width: 40.w),
                              SizedBox(width: 7.w),
                              SizedBox(
                                height: 28.h,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _userController.selectedLanguages.length,
                                  itemBuilder: (context, ind) {
                                    return Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: Image.network(
                                        _userController.selectedLanguages[ind]['Image'].url,
                                        height: 26.h,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              SvgView("assets/Icons/translator_unselect.svg", color: ConstColors.white, height: 40.w, width: 40.w),
                              SizedBox(width: 7.w),
                              Styles.regular('language_3_select'.tr, fs: 18.sp, c: ConstColors.white),
                            ],
                          )),
                    SizedBox(height: 10.h),
                    GradientButton(
                        width: MediaQuery.sizeOf(context).width,
                        color1: ConstColors.pinkColor,
                        color2: ConstColors.lightPurpleColor,
                        title: 'whereareyou'.tr,
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
                                      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
                                    }
                                    Get.back();
                                    bottomSheetEditLocation(context);
                                  },
                                ));
                          } else {
                            bottomSheetEditLocation(context);
                          }
                        }),
                    SizedBox(height: 10.h),
                    Obx(
                      () => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgView("assets/Icons/location.svg", color: ConstColors.white, height: 25.w, width: 25.w),
                          SizedBox(width: 7.w),
                          Expanded(
                            child: Styles.regular(
                                _userController.locationName.value.isNotEmpty ? _userController.locationName.value : 'where_are_you'.tr,
                                fs: 18.sp,
                                c: ConstColors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Obx(() {
                      final bool valid = (_userController.locationName.value.isNotEmpty &&
                          _userController.selectedLanguages.isNotEmpty &&
                          _userController.isNameEdit.value &&
                          _userController.isDescriptionEdit.value);
                      return Column(
                        children: [
                          GradientButton(
                              color1: ConstColors.darkRedColor,
                              color2: ConstColors.lightRedColor,
                              title: 'save'.tr,
                              onTap: () async {
                                controller.editProfile(loginUserModal: widget.userLogin, userProfile: widget.userProfile);
                              },
                              enable: valid),
                          SizedBox(height: 10.h),
                          if (_userController.isProcess2.value)
                            Center(child: Lottie.asset("assets/jsons/loading_circle.json", height: 82.w, width: 82.w)),
                          if (!valid) Center(child: Padding(
                            padding:  EdgeInsets.symmetric(horizontal: 20.w),
                            child: Styles.regular('all_fields_required'.tr,al: TextAlign.center, fs: 16.sp, c: ConstColors.lightPurpleColor),
                          ))
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> bottomShitLanguage(context) {
    return showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r)),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            expand: false,
            maxChildSize: 0.9,
            minChildSize: 0.2,
            builder: (context, scrollController) {
              return Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Column(
                  children: [
                    Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                    SizedBox(height: 18.h),
                    Styles.regular('prefer_Language'.tr, ff: 'HB', fs: 18.sp, c: ConstColors.black),
                    SizedBox(height: 18.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Divider(
                        height: 1.h,
                        color: ConstColors.bottomBorder,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w),
                      child: TextFormField(
                        controller: _userController.searchLanguageTextController.value,
                        autofocus: false,
                        cursorColor: ConstColors.themeColor,
                        style: TextStyle(color: ConstColors.black, fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _userController.searchLanguage.clear();
                            for (var element in _userController.getAllLanguage) {
                              _userController.searchLanguage.add(element);
                            }
                          } else {
                            _userController.searchLanguage.clear();
                            for (var element in _userController.getAllLanguage) {
                              if (element['title'].toString().toLowerCase().contains(value.toLowerCase())) {
                                _userController.searchLanguage.add(element);
                              }
                            }
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search_Language'.tr,
                          hintStyle:
                              TextStyle(color: ConstColors.black, fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
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
                      ),
                    ),
                    Expanded(child: Obx(() {
                      _userController.searchLanguage.stream;
                      if (_userController.searchLanguage.isNotEmpty) {
                        return ListView.separated(
                          itemCount: _userController.searchLanguage.length,
                          shrinkWrap: true,
                          controller: scrollController,
                          physics: const ScrollPhysics(),
                          padding: EdgeInsets.only(top: 26.h, left: 45.w, right: 45.w),
                          separatorBuilder: (context, i) {
                            return SizedBox(height: 15.h);
                          },
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                if (_userController.selectedLanguages.toString().contains(_userController.searchLanguage[index]['objectId'])) {
                                  _userController.selectedLanguages
                                      .removeWhere((item) => item['objectId'] == _userController.searchLanguage[index]['objectId']);
                                } else {
                                  if (_userController.selectedLanguages.length < 3) {
                                    _userController.selectedLanguages.add(_userController.searchLanguage[index]);
                                  }
                                }
                              },
                              child: Row(
                                children: [
                                  Image.network(_userController.searchLanguage[index]['Image'].url, height: 30.w, width: 30.w),
                                  SizedBox(width: 10.w),
                                  Styles.regular(_userController.searchLanguage[index]['title'], c: ConstColors.black, fs: 18.sp),
                                  const Spacer(),
                                  Obx(() {
                                    return SvgView(
                                      "assets/Icons/check.svg",
                                      color: _userController.selectedLanguages.toString().contains(_userController.searchLanguage[index]['objectId'])
                                          ? ConstColors.darkGreenColor
                                          : ConstColors.closeColor,
                                      height: 24.w,
                                      width: 24.w,
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return SizedBox(height: 300.h, child: Center(child: CircularProgressIndicator(color: ConstColors.themeColor)));
                      }
                    })),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

RxBool isLocationPressed = true.obs;

Future<void> bottomSheetEditLocation(context, {bool? wallScreen}) {
  PlaceApiProvider apiClient = PlaceApiProvider();

  final UserController userController = Get.put(UserController());
  isLocationPressed.value = true;

  return showModalBottomSheet<void>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r)),
    ),
    isScrollControlled: true,
    backgroundColor: ConstColors.white,
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          height: 500.h,
          child: Padding(
            padding: EdgeInsets.only(top: 14.h, left: 20.w, right: 20.w, bottom: MediaQuery.of(context).padding.bottom),
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
                      Position value = await userController.getCurrentPosition();
                      List<Placemark> placeMarks = await placemarkFromCoordinates(value.latitude, value.longitude);

                      Placemark place = placeMarks[0];
                      if (place.subAdministrativeArea == null || place.subAdministrativeArea!.isEmpty) {
                        userController.address.value = '${place.administrativeArea}, ${place.country}';
                      } else {
                        userController.address.value = '${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}';
                      }
                      userController.locationName.value = userController.address.value;
                      userController.location = userController.address.value;
                      userController.locationLatitude.value = value.latitude;
                      userController.locationLongitude.value = value.longitude;
                      userController.countryCode.value = place.isoCountryCode!;
                      // _searchController.randImg.clear();
                      // _searchController.post.clear();
                      // _searchController.finalPost.clear();
                      // _searchController.showNudeImage.clear();
                      // indexMuroList.clear();
                      // _searchController.page.value = 0;
                      // _searchController.load.value = false;
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
                      Obx(
                        () => Styles.regular("${'until'.tr} ${userController.km.value.toStringAsFixed(0)} ${'kilometers'.tr}",
                            c: ConstColors.subtitle, fs: 18.sp),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Slider(
                    min: 0,
                    max: 1000,
                    activeColor: ConstColors.themeColor,
                    inactiveColor: ConstColors.grey,
                    value: userController.km.value,
                    onChanged: (value) {
                      userController.km.value = value;
                    },
                  ),
                ),
                GetBuilder<UserController>(
                  init: userController,
                  builder: (controller) {
                    return TextFormField(
                      controller: userController.query,
                      autofocus: false,
                      cursorColor: ConstColors.themeColor,
                      style: TextStyle(color: ConstColors.black, fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
                      onChanged: (value) {
                        userController.searchLocation.value = true;
                        userController.update();
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'my_city'.tr,
                        hintStyle: TextStyle(color: ConstColors.black, fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
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
                GetBuilder<UserController>(
                  init: userController,
                  builder: (controller) {
                    userController.searchLocation;
                    return Expanded(
                      child: FutureBuilder<List<Suggestion>?>(
                          future: apiClient.fetchSuggestions(
                              userController.query.text, StorageService.getBox.read('languageCode') ?? Localizations.localeOf(context).languageCode),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                itemBuilder: (context, index) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  title: Styles.regular((snapshot.data![index]).description, fs: 15.sp, c: ConstColors.black),
                                  onTap: () async {
                                    userController.locationName.value = snapshot.data![index].description;
                                    List<Location> locations = await locationFromAddress(snapshot.data![index].description);
                                    userController.location = snapshot.data![index].description;
                                    List<Placemark> placeMarks = await placemarkFromCoordinates(locations[0].latitude, locations[0].longitude);
                                    Placemark place = placeMarks[0];
                                    userController.countryCode.value = place.isoCountryCode!;
                                    userController.locationLatitude.value = locations[0].latitude;
                                    userController.locationLongitude.value = locations[0].longitude;
                                    Get.back(); /**/
                                  },
                                ),
                                itemCount: snapshot.data!.length,
                              );
                            } else {
                              if (userController.query.text.isNotEmpty) {
                                return SizedBox(
                                  height: 250.h,
                                  child: Center(
                                    child: CircularProgressIndicator(color: ConstColors.themeColor),
                                  ),
                                );
                              } else {
                                return SizedBox(
                                  height: 250.h,
                                  child: Center(child: Styles.regular('search_places'.tr, fs: 15.sp, c: ConstColors.black)),
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
        ),
      );
    },
  );
}
