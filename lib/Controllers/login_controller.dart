import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/PairNotificationController/pair_notification_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_parent.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/block_screen.dart';
import 'package:eypop/ui/bottom_screen.dart';
import 'package:eypop/ui/login_registration_screens/deleted_screen.dart';
import 'package:eypop/ui/login_registration_screens/user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../ui/User_profile/create_user_profile.dart';

class LogInControllers extends GetxController {
  Rx<TextEditingController> email = TextEditingController().obs;
  Rx<TextEditingController> password = TextEditingController().obs;
  Rx<TextEditingController> forgotnEmail = TextEditingController().obs;
  final GlobalKey<FormState> useLoginForm = GlobalKey<FormState>();

  RxBool obs = true.obs;

  RxBool isLoading = false.obs;
  RxBool isEmailValid = false.obs;
  RxBool isPasswordValid = false.obs;
  RxBool isForgetPassValid = false.obs;

  Future<void> validateAndSave(ParseUser parseUser) async {
    final FormState? form = useLoginForm.currentState;
    if (form!.validate()) {
      await Get.to(() => UserDetailScreen(type: 'email', appleEmail: email.value.text, newParseUser: parseUser));
    }
  }

  Future<void> userLogin(context, UserController userController) async {
    final e = email.value.text.trim();
    final p = password.value.text.trim();

    if (e.isNotEmpty && p.isNotEmpty) {
      isLoading.value = true;
      final parseUser = ParseUser(e, p, e);

      await UserLoginProviderApi().checkUserLoginByEmail(id: e).then((userExits) async {
        if (userExits != null) {
          if (userExits.result['Type'] == 'email') {
            final response = await parseUser.login();
            if (response.success) {
              /// CHECK USER DELETED
              if ((userExits.result['isDeleted'] ?? false) == true) {
                StorageService.getBox.write('ObjectId', userExits.result['objectId']);
                Get.offAll(() => DeletedAccountScreen());
                StorageService.getBox.write('isDeleted', true);
              } else if ((userExits.result['IsBlocked'] ?? false) == true) {
                /// CHECK USER BLOCKED
                if (userExits.result['BlockDays'] == 'block_permanent') {
                  Get.to(
                      () => BlockScreen(text1: 'permanent_block'.tr, text2: 'delete_reason'.tr, reason: userExits.result["BlockReason"] ?? 'ok'.tr));
                } else {
                  DateTime date = userExits.result['BlockEndDate'];
                  DateTime currentDate = await currentTime();

                  if (currentDate.isBefore(date)) {
                    final difference = date.difference(currentDate).inDays;

                    Get.to(() => BlockScreen(
                        text1: '${'permanent_block'.tr} $difference ${'days_until'.tr} ${DateFormat('dd/MM/y').format(date)}',
                        text2: 'delete_reason'.tr,
                        reason: userExits.result["BlockReason"] ?? 'ok'.tr));
                  } else {
                    final currentUser = await ParseUser.currentUser() as ParseUser;

                    await UserLoginProviderApi().getByIdPointer(currentUser).then((value, {onError}) async {
                      if (value != null) {
                        List ipList = value.result['IpAddress'] ?? [];
                        List dList = value.result['DeviceId'] ?? [];
                        UserLogin userLogin = UserLogin();
                        userLogin.objectId = value.result['objectId'];
                        userLogin.hasLoggedIn = true;
                        // userLogin.noChats = false;
                        // userLogin.noCalls = false;
                        // userLogin.noVideocalls = false;
                        userLogin.showOnline = true;

                        /// UPDATE BLOCK USER ENTRY WHEN DATE IS PASS
                        userLogin['IsBlocked'] = false;
                        userLogin.blockDays = '0';
                        userLogin.blockEndDate = value.result['BlockStartDate'];
                        final All all = await IP.all;
                        if (all.ip != null) {
                          if (!ipList.contains(all.ip)) {
                            ipList.add(all.ip);
                            userLogin.ipAddress = ipList;
                          }
                        }
                        if (all.deviceId != null) {
                          if (!dList.contains(all.deviceId)) {
                            dList.add(all.deviceId);
                            userLogin.deviceId = dList;
                          }
                        }
                        UserLoginProviderApi().update(userLogin);
                        StorageService.getBox.write('ObjectId', value.result['objectId']);
                        StorageService.getBox
                            .write('DefaultProfile', value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['objectId'] ?? '');
                        StorageService.getBox.write('DefaultProfileImg',
                            value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['Imgprofile'].url ?? '');
                        StorageService.getBox.write('DefaultImgObjectId',
                            value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['DefaultImg']?['objectId'] ?? '');
                        StorageService.getBox.write('Gender', value.result['Gender']);
                        StorageService.getBox.write('AccountType', value.result['AccountType']);
                        initInstallationParseToken();
                        await UserProfileProviderApi().userProfileQuery(value.result['objectId']).then((value2) async {
                          if (value2 != null) {
                            /// cloud function (ReactiveBlockUser) (template 23)
                            final ParseCloudFunction function = ParseCloudFunction('ReactiveBlockUser');
                            final Map<String, dynamic> params = <String, dynamic>{
                              'EmailId': value.result['Email'],
                              'UserId': value.result['objectId'],
                            };
                            await function.execute(parameters: params);

                            List profileList = [];
                            //RxList<ProfilePage> profileData = <ProfilePage>[].obs;
                            //profileData.clear();
                            for (var i = 0; i < value2.results!.length; i++) {
                              profileList.add('${value2.results![i]["objectId"]}');
                              //profileData.add(value2.results![i]);
                            }

                            // /// when user login all profile status Active
                            // for (var e in profileData) {
                            //   final ProfilePage profile = ProfilePage();
                            //   profile.objectId = e['objectId'];
                            //   profile.noCalls = false;
                            //   profile.noChats = false;
                            //   profile.noVideocalls = false;
                            //   UserProfileProviderApi().update(profile);
                            // }

                            final defaultProfile = profileList.indexWhere((element) => element == value.result['DefaultProfile']['objectId']);

                            StorageService.getBox.writeIfNull('index', defaultProfile.isNegative ? 0 : defaultProfile);
                          }
                        });

                        if (value.result['DefaultProfile'] == null) {
                          Get.offAll(() => CreateUserProfileScreen());
                        } else {
                          Get.delete<PairNotificationController>();
                          Get.offAll(() => BottomScreen());
                        }
                      } else {
                        Get.offAll(() => UserDetailScreen(type: 'email', newParseUser: parseUser, appleEmail: e));
                      }
                    });
                  }
                }
              } else {
                /// ALREADY EXITS USER [login]
                List ipList = userExits.result['IpAddress'] ?? [];
                List dList = userExits.result['DeviceId'] ?? [];
                final All all = await IP.all;
                UserLogin userLogin = UserLogin();
                userLogin.objectId = userExits.result['objectId'];
                userLogin.hasLoggedIn = true;
                // userLogin.noChats = false;
                // userLogin.noCalls = false;
                // userLogin.noVideocalls = false;
                userLogin.showOnline = true;
                if (all.ip != null) {
                  if (!ipList.contains(all.ip)) {
                    ipList.add(all.ip);
                    userLogin.ipAddress = ipList;
                  }
                }
                if (all.deviceId != null) {
                  if (!dList.contains(all.deviceId)) {
                    dList.add(all.deviceId);
                    userLogin.deviceId = dList;
                  }
                }
                UserLoginProviderApi().update(userLogin);
                StorageService.getBox.write('ObjectId', userExits.result['objectId']);
                StorageService.getBox
                    .write('DefaultProfile', userExits.result['DefaultProfile'] == null ? '' : userExits.result['DefaultProfile']['objectId'] ?? '');
                StorageService.getBox.write('DefaultProfileImg',
                    userExits.result['DefaultProfile'] == null ? '' : userExits.result['DefaultProfile']['Imgprofile'].url ?? '');
                StorageService.getBox.write('DefaultImgObjectId',
                    userExits.result['DefaultProfile'] == null ? '' : userExits.result['DefaultProfile']['DefaultImg']?['objectId'] ?? '');
                StorageService.getBox.write('Gender', userExits.result['Gender']);
                StorageService.getBox.write('AccountType', userExits.result['AccountType']);
                await UserProfileProviderApi().userProfileQuery(userExits.result['objectId']).then((value2) async {
                  if (value2 != null) {
                    List profileList = [];
                    //RxList<ProfilePage> profileData = <ProfilePage>[].obs;
                    //profileData.clear();
                    for (var i = 0; i < value2.results!.length; i++) {
                      profileList.add('${value2.results![i]["objectId"]}');
                      //profileData.add(value2.results![i]);
                    }

                    // /// when user login all profile status Active
                    // for (var e in profileData) {
                    //   final ProfilePage profile = ProfilePage();
                    //   profile.objectId = e['objectId'];
                    //   profile.noCalls = false;
                    //   profile.noChats = false;
                    //   profile.noVideocalls = false;
                    //   UserProfileProviderApi().update(profile);
                    // }

                    final defaultProfile = profileList.indexWhere((element) => element == userExits.result['DefaultProfile']['objectId']);

                    StorageService.getBox.writeIfNull('index', defaultProfile.isNegative ? 0 : defaultProfile);
                  }
                });

                if (userExits.result['DefaultProfile'] == null) {
                  Get.offAll(() => CreateUserProfileScreen());
                } else {
                  Get.delete<PairNotificationController>();
                  Get.offAll(() => BottomScreen());
                }
              }
            } else {
              if (response.error!.message.contains('User email is not verified')) {
                showAlertDialog(context, title: 'account_not_verified'.tr, subtitle: 'user_email_not_verified'.tr);
              } else {
                showAlertDialog(context, title: 'wrong_email_or_password'.tr, subtitle: 'user_wrong_email_or_password'.tr);
              }
            }
          } else {
            showSnackBar(context, content: '${"email_exits".tr} ${userExits.result['Type']}');
          }
        } else {
          /// CHECK USER EMAIL "_User" CLASS
          await UserLoginProviderApi().checkUserByEmail(e).then((user) async {
            if (user != null) {
              final response = await parseUser.login();
              if (response.success) {
                /// CHECK USER EMAIL "User_login" CLASS
                await UserLoginProviderApi().checkUserLoginByEmail(id: e).then((userExits) async {
                  if (userExits != null) {
                    if (userExits.result['Type'] == 'email') {
                      /// CHECK USER DELETED
                      if ((userExits.result['isDeleted'] ?? false) == true) {
                        StorageService.getBox.write('ObjectId', userExits.result['objectId']);
                        Get.offAll(() => DeletedAccountScreen());
                        StorageService.getBox.write('isDeleted', true);
                      } else if ((userExits.result['IsBlocked'] ?? false) == true) {
                        /// CHECK USER BLOCKED
                        if (userExits.result['BlockDays'] == 'block_permanent') {
                          Get.to(() => BlockScreen(
                              text1: 'permanent_block'.tr, text2: 'delete_reason'.tr, reason: userExits.result["BlockReason"] ?? 'ok'.tr));
                        } else {
                          DateTime date = userExits.result['BlockEndDate'];
                          DateTime currentDate = await currentTime();

                          if (currentDate.isBefore(date)) {
                            final difference = date.difference(currentDate).inDays;

                            Get.to(() => BlockScreen(
                                text1: '${'permanent_block'.tr} $difference ${'days_until'.tr} ${DateFormat('dd/MM/y').format(date)}',
                                text2: 'delete_reason'.tr,
                                reason: userExits.result["BlockReason"] ?? 'ok'.tr));
                          } else {
                            final currentUser = await ParseUser.currentUser() as ParseUser;

                            await UserLoginProviderApi().getByIdPointer(currentUser).then((value, {onError}) async {
                              if (value != null) {
                                List ipList = value.result['IpAddress'] ?? [];
                                List dList = value.result['DeviceId'] ?? [];
                                UserLogin userLogin = UserLogin();
                                userLogin.objectId = value.result['objectId'];
                                userLogin.hasLoggedIn = true;
                                // userLogin.noChats = false;
                                // userLogin.noCalls = false;
                                // userLogin.noVideocalls = false;
                                userLogin.showOnline = true;

                                /// UPDATE BLOCK USER ENTRY WHEN DATE IS PASS
                                userLogin['IsBlocked'] = false;
                                userLogin.blockDays = '0';
                                userLogin.blockEndDate = value.result['BlockStartDate'];
                                final All all = await IP.all;
                                if (all.ip != null) {
                                  if (!ipList.contains(all.ip)) {
                                    ipList.add(all.ip);
                                    userLogin.ipAddress = ipList;
                                  }
                                }
                                if (all.deviceId != null) {
                                  if (!dList.contains(all.deviceId)) {
                                    dList.add(all.deviceId);
                                    userLogin.deviceId = dList;
                                  }
                                }
                                UserLoginProviderApi().update(userLogin);
                                StorageService.getBox.write('ObjectId', value.result['objectId']);
                                StorageService.getBox.write(
                                    'DefaultProfile', value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['objectId'] ?? '');
                                StorageService.getBox.write('DefaultProfileImg',
                                    value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['Imgprofile'].url ?? '');
                                StorageService.getBox.write('DefaultImgObjectId',
                                    value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['DefaultImg']?['objectId'] ?? '');
                                StorageService.getBox.write('Gender', value.result['Gender']);
                                StorageService.getBox.write('AccountType', value.result['AccountType']);
                                initInstallationParseToken();
                                await UserProfileProviderApi().userProfileQuery(value.result['objectId']).then((value2) async {
                                  if (value2 != null) {
                                    /// cloud function (ReactiveBlockUser) (template 23)
                                    final ParseCloudFunction function = ParseCloudFunction('ReactiveBlockUser');
                                    final Map<String, dynamic> params = <String, dynamic>{
                                      'EmailId': value.result['Email'],
                                      'UserId': value.result['objectId'],
                                    };
                                    await function.execute(parameters: params);

                                    List profileList = [];
                                    //RxList<ProfilePage> profileData = <ProfilePage>[].obs;
                                    //profileData.clear();
                                    for (var i = 0; i < value2.results!.length; i++) {
                                      profileList.add('${value2.results![i]["objectId"]}');
                                      //profileData.add(value2.results![i]);
                                    }

                                    // /// when user login all profile status Active
                                    // for (var e in profileData) {
                                    //   final ProfilePage profile = ProfilePage();
                                    //   profile.objectId = e['objectId'];
                                    //   profile.noCalls = false;
                                    //   profile.noChats = false;
                                    //   profile.noVideocalls = false;
                                    //   UserProfileProviderApi().update(profile);
                                    // }

                                    final defaultProfile = profileList.indexWhere((element) => element == value.result['DefaultProfile']['objectId']);

                                    StorageService.getBox.writeIfNull('index', defaultProfile.isNegative ? 0 : defaultProfile);
                                  }
                                });

                                if (value.result['DefaultProfile'] == null) {
                                  Get.offAll(() => CreateUserProfileScreen());
                                } else {
                                  Get.delete<PairNotificationController>();
                                  Get.offAll(() => BottomScreen());
                                }
                              } else {
                                Get.offAll(() => UserDetailScreen(type: 'email', newParseUser: parseUser, appleEmail: e));
                              }
                            });
                          }
                        }
                      } else {
                        /// ALREADY EXITS USER [login]
                        final currentUser = await ParseUser.currentUser() as ParseUser;
                        await UserLoginProviderApi().getByIdPointer(currentUser).then((value, {onError}) async {
                          if (value != null) {
                            List ipList = value.result['IpAddress'] ?? [];
                            List dList = value.result['DeviceId'] ?? [];
                            final All all = await IP.all;
                            final UserLogin userLogin = UserLogin();
                            userLogin.objectId = value.result['objectId'];
                            userLogin.hasLoggedIn = true;
                            // userLogin.noChats = false;
                            // userLogin.noCalls = false;
                            // userLogin.noVideocalls = false;
                            userLogin.showOnline = true;
                            if (all.ip != null) {
                              if (!ipList.contains(all.ip)) {
                                ipList.add(all.ip);
                                userLogin.ipAddress = ipList;
                              }
                            }
                            if (all.deviceId != null) {
                              if (!dList.contains(all.deviceId)) {
                                dList.add(all.deviceId);
                                userLogin.deviceId = dList;
                              }
                            }
                            UserLoginProviderApi().update(userLogin);
                            StorageService.getBox.write('ObjectId', value.result['objectId']);
                            StorageService.getBox.write(
                                'DefaultProfile', value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['objectId'] ?? '');
                            StorageService.getBox.write('DefaultProfileImg',
                                value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['Imgprofile'].url ?? '');
                            StorageService.getBox.write('DefaultImgObjectId',
                                value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['DefaultImg']?['objectId'] ?? '');
                            StorageService.getBox.write('Gender', value.result['Gender']);
                            StorageService.getBox.write('AccountType', value.result['AccountType']);
                            await UserProfileProviderApi().userProfileQuery(value.result['objectId']).then((value2) async {
                              if (value2 != null) {
                                List profileList = [];
                                //RxList<ProfilePage> profileData = <ProfilePage>[].obs;
                                //profileData.clear();
                                for (var i = 0; i < value2.results!.length; i++) {
                                  profileList.add('${value2.results![i]["objectId"]}');
                                  //profileData.add(value2.results![i]);
                                }

                                // /// when user login all profile status Active
                                // for (var e in profileData) {
                                //   final ProfilePage profile = ProfilePage();
                                //   profile.objectId = e['objectId'];
                                //   profile.noCalls = false;
                                //   profile.noChats = false;
                                //   profile.noVideocalls = false;
                                //   UserProfileProviderApi().update(profile);
                                // }

                                final defaultProfile = profileList.indexWhere((element) => element == value.result['DefaultProfile']['objectId']);

                                StorageService.getBox.writeIfNull('index', defaultProfile.isNegative ? 0 : defaultProfile);
                              }
                            });

                            if (value.result['DefaultProfile'] == null) {
                              Get.offAll(() => CreateUserProfileScreen());
                            } else {
                              Get.delete<PairNotificationController>();
                              Get.offAll(() => BottomScreen());
                            }
                          } else {
                            Get.offAll(() => UserDetailScreen(type: 'email', appleEmail: e, newParseUser: currentUser));
                          }
                        });
                      }
                    } else {
                      showSnackBar(context, content: '${"email_exits".tr} ${userExits.result['Type']}');
                    }
                  } else {
                    validateAndSave(parseUser);
                  }
                });
              } else {
                if (response.error!.message.contains('User email is not verified')) {
                  showAlertDialog(context, title: 'account_not_verified'.tr, subtitle: 'user_email_not_verified'.tr);
                } else {
                  showAlertDialog(context, title: 'wrong_email_or_password'.tr, subtitle: 'user_wrong_email_or_password'.tr);
                }
              }
            } else {
              /// CREATE NEW USER [signUp]
              final All all = await IP.all;
              if (blockByIP.value && (blockIpAddress.contains(all.ip) || blockDeviceId.contains(all.deviceId))) {
                showAlertDialog(context, title: 'user_ip_blocked'.tr);
              } else {
                final user = ParseUser.createUser(e, p, e);
                final ParseResponse response = await user.signUp();
                if (response.success) {
                  UserParent userParent = UserParent();
                  userParent.objectId = user.objectId;
                  userParent['Type'] = 'email';
                  await userParent.save();
                  showAlertDialog(context, title: 'send_mail_text'.tr, buttonText: 'already_validate'.tr);
                } else {
                  showSnackBar(context, content: response.error!.message);
                }
              }
            }
          });
        }
      });
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    email.value.text = "";
    super.onInit();
  }
}
