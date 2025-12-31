// ignore_for_file: must_be_immutable, deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/permission_screen.dart';
import 'package:eypop/ui/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Constant/theme/theme.dart';
import '../../Controllers/user_controller.dart';
import '../../back4appservice/user_provider/language_api.dart';
import '../../service/location_services.dart';

class CreateUserProfileScreen extends GetView {
  CreateUserProfileScreen({Key? key, this.buttonTitle, this.isNewUser = false}) : super(key: key);

  final UserController _userController = Get.put(UserController());
  final PriceController _priceController = Get.put(PriceController());
  final RxBool isLocationPressed = true.obs;
  final PlaceApiProvider apiClient = PlaceApiProvider();
  String? buttonTitle;
  bool? isNewUser;

  RxDouble width = 0.0.obs;
  Timer? timer;

  Future<void> _willPopCallback(canPop) async {
    if (!canPop) {
      _userController.newQuery.clear();
      _userController.newName.clear();
      _userController.newDescription.clear();
      _userController.locationName.value = '';
      _userController.newLangList.clear();
      _userController.searchLanguageTextController.value.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: _willPopCallback,
        child: SingleChildScrollView(
            child: GetBuilder<UserController>(
                init: UserController(),
                builder: (controller) {
                  return GradientWidget(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 58.h),
                      child: Form(
                        key: controller.createProfileForm,
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
                                    _userController.newName.clear();
                                    _userController.newDescription.clear();
                                    _userController.newQuery.clear();
                                    _userController.locationName.value = '';
                                    _userController.clear();
                                    Get.back();
                                  },
                                ),
                                const Spacer(flex: 2),
                                Obx(() {
                                  return Stack(
                                    children: [
                                      if (controller.selectedImage == null || controller.imageProfile.value.isEmpty)
                                        InkWell(
                                          onTap: () async {
                                            await controller.imgFromGallery();
                                          },
                                          child: SvgPicture.asset('assets/Icons/opengallery.svg', height: 144.w, width: 144.w),
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
                                      if (controller.imageProfile.value.isNotEmpty)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await controller.imgFromGallery();
                                            },
                                            child: Center(child: SvgPicture.asset("assets/Icons/reset.svg", height: 48.w, width: 48.w)),
                                          ),
                                        ),
                                    ],
                                  );
                                }),
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
                                hint: '',
                                contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                                textInputAction: TextInputAction.next,
                                color: ConstColors.white,
                                borderColor: ConstColors.white,
                                containerColor: Colors.transparent,
                                textInputType: TextInputType.text,
                                onChanged: (v) {
                                  if (v.isEmpty) {
                                    controller.isNewName.value = false;
                                  } else {
                                    controller.isNewName.value = true;
                                  }
                                },
                                controllers: controller.newName,
                                maxLan: 20),
                            Styles.regular(
                              'what_are_looking'.tr,
                              fs: 18.sp,
                              c: ConstColors.white,
                            ),
                            SizedBox(height: 5.h),
                            TextFieldModel(
                              maxLine: 6,
                              minLine: 4,
                              hint: '',
                              contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                              textInputAction: TextInputAction.done,
                              color: ConstColors.white,
                              borderColor: ConstColors.white,
                              containerColor: Colors.transparent,
                              textInputType: TextInputType.text,
                              controllers: controller.newDescription,
                              onChanged: (v) {
                                if (v.isEmpty) {
                                  controller.isNewDescription.value = false;
                                } else {
                                  controller.isNewDescription.value = true;
                                }
                              },
                              maxLan: 150,
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
                                      SvgView(
                                        "assets/Icons/language.svg",
                                        color: ConstColors.white,
                                        height: 40.w,
                                        width: 40.w,
                                      ),
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
                                      SvgView(
                                        "assets/Icons/translator_unselect.svg",
                                        color: ConstColors.white,
                                        height: 40.w,
                                        width: 40.w,
                                      ),
                                      SizedBox(width: 7.w),
                                      Styles.regular(
                                        'language_3_select'.tr,
                                        fs: 18.sp,
                                        c: ConstColors.white,
                                      ),
                                    ],
                                  )),
                            SizedBox(height: 10.h),
                            GradientButton(
                                width: MediaQuery.sizeOf(context).width,
                                color1: ConstColors.pinkColor,
                                color2: ConstColors.lightPurpleColor,
                                title: 'whereareyou'.tr,
                                onTap: () async {
                                  await Geolocator.checkPermission().then((permission) {
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
                                              bottomSheetLocation(context);
                                            },
                                          ));
                                    } else {
                                      bottomSheetLocation(context);
                                    }
                                  });
                                }),
                            SizedBox(height: 10.h),
                            Obx(
                              () => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgView(
                                    "assets/Icons/location.svg",
                                    color: ConstColors.white,
                                    height: 25.w,
                                    width: 25.w,
                                  ),
                                  SizedBox(width: 7.w),
                                  Expanded(
                                    child: Styles.regular(
                                      _userController.locationName.value.isNotEmpty ? _userController.locationName.value : 'where_are_you'.tr,
                                      fs: 18.sp,
                                      c: ConstColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Obx(() {
                              final bool valid = (_userController.locationName.value.isNotEmpty &&
                                  _userController.selectedLanguages.isNotEmpty &&
                                  controller.isNewName.value &&
                                  controller.isNewDescription.value &&
                                  controller.selectedImage != null);
                              return Column(
                                children: [
                                  GradientButton(
                                      width: 386.w,
                                      color1: ConstColors.darkRedColor,
                                      color2: ConstColors.lightRedColor,
                                      title: buttonTitle ?? 'save_continue'.tr,
                                      onTap: () async {
                                        /// If a new user is creating a profile, then do not open the create profile dialog [isNewUser == true]
                                        if (isNewUser == true) {
                                          _userController.newQuery.clear();
                                          _userController.isProcess.value = true;
                                          await controller.validateAndSave(isNewUser: isNewUser);
                                        } else {
                                          if (StorageService.getBox.read('Gender') == 'male') {
                                            await UserProfileProviderApi().getCheckData().then((apiResponse) async {
                                              if (apiResponse != null) {
                                                await showDialog(
                                                  context: context,
                                                  builder: (BuildContext context2) {
                                                    return Center(
                                                      child: Container(
                                                        decoration: BoxDecoration(color: bottomColor(), borderRadius: BorderRadius.circular(10.r)),
                                                        padding: EdgeInsets.symmetric(
                                                          vertical: 24.h,
                                                        ),
                                                        margin: EdgeInsets.symmetric(
                                                          horizontal: 20.w,
                                                        ),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.only(right: 34.w, left: 34.w),
                                                              child: Column(
                                                                children: [
                                                                  Center(
                                                                      child: Styles.regular('new_profile'.tr,
                                                                          al: TextAlign.center,
                                                                          c: ConstColors.themeColor,
                                                                          fs: 20.sp,
                                                                          fw: FontWeight.bold,
                                                                          ff: 'RB')),
                                                                  SizedBox(height: 15.h),
                                                                  Material(
                                                                      child: SvgView('assets/Icons/add-user.svg',
                                                                          onTap: () {}, color: ConstColors.themeColor, height: 56.h, width: 56.h)),
                                                                  SizedBox(height: 24.h),
                                                                  Center(
                                                                      child: Styles.regular(
                                                                    'are_you_going_to_create_a_new_profile_Managed_or_traveler'.tr,
                                                                    al: TextAlign.center,
                                                                    c: Theme.of(context).primaryColor,
                                                                    fs: 20.sp,
                                                                    fw: FontWeight.w400,
                                                                  )),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 30.h),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Get.back();
                                                                    },
                                                                    child: Container(
                                                                      height: 46.h,
                                                                      width: 172.w,
                                                                      decoration: BoxDecoration(
                                                                          color: ConstColors.grey, borderRadius: BorderRadius.circular(10.r)),
                                                                      child: Center(
                                                                          child: Styles.regular('Cancel'.tr, fs: 20.sp, c: Colors.white, ff: 'RR')),
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () async {
                                                                      Get.back();
                                                                      if (_priceController.userTotalCoin >= _priceController.createProfile.value) {
                                                                        await UserLoginProviderApi().decrement(StorageService.getBox.read('ObjectId'),
                                                                            _priceController.createProfile.value, 'TotalCoin');
                                                                        await UserLoginProviderApi().increment(StorageService.getBox.read('ObjectId'),
                                                                            _priceController.createProfile.value, 'ProfileCoin');
                                                                        _userController.newQuery.clear();
                                                                        _userController.isProcess.value = true;
                                                                        await controller.validateAndSave(isNewUser: false);
                                                                      } else {
                                                                        Get.to(() => StoreScreen());
                                                                      }
                                                                    },
                                                                    child: Container(
                                                                      height: 46.h,
                                                                      width: 172.w,
                                                                      decoration: BoxDecoration(
                                                                          color: ConstColors.themeColor, borderRadius: BorderRadius.circular(10.r)),
                                                                      child: Center(
                                                                          child: Styles.regular('confirm'.tr, fs: 20.sp, c: Colors.white, ff: 'RR')),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {
                                                _userController.newQuery.clear();
                                                _userController.isProcess.value = true;
                                                await controller.validateAndSave(isNewUser: isNewUser);
                                              }
                                            });
                                          } else {
                                            _userController.newQuery.clear();
                                            _userController.isProcess.value = true;
                                            await controller.validateAndSave(isNewUser: isNewUser);
                                          }
                                        }
                                      },
                                      enable: valid),
                                  SizedBox(height: 10.h),
                                  if (_userController.isProcess.value)
                                    Center(
                                      child: Lottie.asset("assets/jsons/loading_circle.json", height: 82.w, width: 82.w),
                                    ),
                                  if (!valid)
                                    Center(
                                        child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                      child:
                                          Styles.regular('all_fields_required'.tr, fs: 16.sp, al: TextAlign.center, c: ConstColors.lightPurpleColor),
                                    ))
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                })),
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

  Future<void> bottomSheetLocation(context) {
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
                        final Position value = await _userController.getCurrentPosition();
                        final List<Placemark> placeMarks = await placemarkFromCoordinates(value.latitude, value.longitude);
                        final Placemark place = placeMarks[0];
                        if (place.subAdministrativeArea == null || place.subAdministrativeArea!.isEmpty) {
                          _userController.address.value = '${place.administrativeArea}, ${place.country}';
                        } else {
                          _userController.address.value = '${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}';
                        }
                        _userController.locationName.value = _userController.address.value;
                        _userController.location = _userController.address.value;
                        _userController.locationLatitude.value = value.latitude;
                        _userController.locationLongitude.value = value.longitude;
                        _userController.countryCode.value = place.isoCountryCode!;
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
                          () => Styles.regular("${'until'.tr} ${_userController.km.value.toStringAsFixed(0)} ${'kilometers'.tr}",
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
                      value: _userController.km.value,
                      onChanged: (value) {
                        _userController.km.value = value;
                      },
                    ),
                  ),
                  GetBuilder<UserController>(
                    init: _userController,
                    builder: (controller) {
                      return TextFormField(
                        controller: _userController.newQuery,
                        autofocus: false,
                        cursorColor: ConstColors.themeColor,
                        style: TextStyle(color: ConstColors.black, fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
                        onChanged: (value) {
                          _userController.searchLocation.value = true;
                          _userController.update();
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'my_city'.tr,
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
                      );
                    },
                  ),
                  GetBuilder<UserController>(
                    init: _userController,
                    builder: (controller) {
                      _userController.searchLocation;
                      return Expanded(
                        child: FutureBuilder<List<Suggestion>?>(
                            future: apiClient.fetchSuggestions(_userController.newQuery.text,
                                StorageService.getBox.read('languageCode') ?? Localizations.localeOf(context).languageCode),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  itemBuilder: (context, index) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: Styles.regular((snapshot.data![index]).description, fs: 15.sp, c: ConstColors.black),
                                    onTap: () async {
                                      _userController.locationName.value = snapshot.data![index].description;

                                      ///crash
                                      final List<Location> locations = await locationFromAddress(snapshot.data![index].description);
                                      final List<Placemark> placeMarks =
                                          await placemarkFromCoordinates(locations[0].latitude, locations[0].longitude);
                                      final Placemark place = placeMarks[0];

                                      _userController.countryCode.value = place.isoCountryCode!;
                                      _userController.location = snapshot.data![index].description;
                                      _userController.locationLatitude.value = locations[0].latitude;
                                      _userController.locationLongitude.value = locations[0].longitude;

                                      Get.back();
                                    },
                                  ),
                                  itemCount: snapshot.data!.length,
                                );
                              } else {
                                if (_userController.newQuery.text.isNotEmpty) {
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
}
