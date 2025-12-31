import 'dart:async';
import 'dart:io';

import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/Controllers/translate_controler.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/models/user_login/user_parent.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/block_screen.dart';
import 'package:eypop/ui/login_registration_screens/deleted_screen.dart';
import 'package:eypop/ui/login_registration_screens/user_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constant/constant.dart';
import '../back4appservice/base/api_response.dart';
import '../back4appservice/user_provider/users/provider_profileuser_api.dart';
import '../back4appservice/user_provider/users/provider_user_api.dart';
import '../models/user_login/user_login.dart';
import '../ui/User_profile/create_user_profile.dart';
import '../ui/bottom_screen.dart';
import 'PairNotificationController/pair_notification_controller.dart';

class AuthController extends GetxController {
  @override
  Future<void> onInit() async {
    await getCountryCode();
    if (localVersion < newAppVersion) {
      showAlertDialog(
        Get.context,
        title: 'update_from_store'.tr.replaceAll('xxx', Platform.isIOS ? 'AppStore' : 'PlayStore'),
        buttonText: 'update'.tr,
        onTap: () async {
          final appId = Platform.isAndroid ? 'com.actuajeriko.eypop' : '1628570550';
          final url = Uri.parse(
            Platform.isAndroid ? "market://details?id=$appId" : "https://apps.apple.com/app/id$appId",
          );
          await launchUrl(url);
        },
      );
    }
    _userController.getAllBlockIp();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = "${packageInfo.version} (${packageInfo.buildNumber})";
    super.onInit();
  }

  final RxString version = "".obs;
  RxBool isLoading = false.obs;
  ParseResponse? apiResponse;
  Timer? timer;
  RxInt start = 60.obs;

  void startTimer() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    start.value = 60;

    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer time) {
        if (start.value == 0) {
          time.cancel();
          timer!.cancel();
        } else {
          start.value--;
        }
      },
    );
  }

  Future<void> getCountryCode() async {
    final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Country'))..whereEqualTo('Status', true);
    apiResponse = await query.query();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxString verificationCode = ''.obs;
  final Rx<TextEditingController> sms = TextEditingController().obs;
  RxBool isValid = false.obs;
  RxString otp = ''.obs;

  final UserController _userController = Get.put(UserController());
  final PriceController _priceController = Get.put(PriceController());

  Future<void> signupWithGoogle(context) async {
    isLoading.value = true;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential authCredential =
            GoogleAuthProvider.credential(idToken: googleSignInAuthentication.idToken, accessToken: googleSignInAuthentication.accessToken);
        final UserCredential result = await _auth.signInWithCredential(authCredential);
        final GoogleSignInAuthentication authentication = await googleSignInAccount.authentication;
        final String email = result.user!.email!;
        await UserLoginProviderApi().checkUserLoginByEmail(id: email).then((value) async {
          if (value != null) {
            if (value.result['Type'] == 'google') {
              final ParseResponse response =
                  await ParseUser.loginWith('google', google(authentication.accessToken!, googleSignIn.currentUser!.id, authentication.idToken!));
              if (response.success) {
                await successLogin(context, value: value);
              } else {
                showSnackBar(context, content: response.error!.message);
              }
            } else {
              showSnackBar(context, content: '${"email_exits".tr} ${value.result['Type']}');
            }
          } else {
            final ParseResponse response =
                await ParseUser.loginWith('google', google(authentication.accessToken!, googleSignIn.currentUser!.id, authentication.idToken!));
            if (response.success) {
              final ParseUser user = response.result;
              final UserParent userParent = UserParent();
              userParent.objectId = user.objectId;
              userParent['Type'] = 'google';
              await userParent.save();
              UserLoginProviderApi().getByIdPointer(user).then((value, {onError}) async {
                if (value != null) {
                  await successLogin(context, value: value);
                } else {
                  await IP.all.then((all) {
                    if (blockByIP.value && (blockIpAddress.contains(all.ip) || blockDeviceId.contains(all.deviceId))) {
                      showAlertDialog(context, title: 'user_ip_blocked'.tr);
                    } else {
                      Get.offAll(() => UserDetailScreen(type: 'google', newParseUser: user, appleEmail: result.user!.email!));
                    }
                  });
                }
              });
            } else {
              showSnackBar(context, content: response.error!.message);
            }
          }
        });
      }
      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("GOOGLE LOGIN ERROR $e");
      }
      isLoading.value = false;
      final snackBar = SnackBar(content: Styles.regular(e.message.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    isLoading.value = false;
    update();
  }

  Future<void> verifyPhone(phoneNumber, context) async {
    verificationCompleted(AuthCredential phoneAuthCredential) async {
      if (kDebugMode) {
        print("VERIFY PHONE-NUMBER COMPLETED $phoneAuthCredential");
      }
      await _auth.signInWithCredential(phoneAuthCredential).then((value) {
        if (kDebugMode) {
          print("VERIFY PHONE-NUMBER DONE USER ${value.user}");
        }
        Get.offAll(() => UserDetailScreen(type: 'phoneNumber', appleEmail: phoneNumber));
      });
    }

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (authCredential) => verificationCompleted(authCredential),
          verificationFailed: (FirebaseAuthException e) async {
            if (kDebugMode) {
              print("VERIFY PHONE-NUMBER VERIFICATION-FAILED ${e.message}");
            }
            final TranslateLan? translateLan = await TranslateController().translateLang(text: e.message.toString(), targetLanguage: 'es');
            final String error = translateLan!.data.translations[0].translatedText;
            final snackBar = SnackBar(content: Styles.regular(error), duration: const Duration(seconds: 2));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          codeSent: (String? verificationID, int? resendToken) async {
            if (kDebugMode) {
              print("VERIFY PHONE-NUMBER CODE-SEND");
            }
            startTimer();
            verificationCode.value = verificationID!;
          },
          codeAutoRetrievalTimeout: (String verificationID) {
            if (kDebugMode) {
              print("VERIFY PHONE-NUMBER TIMEOUT");
            }
            verificationCode.value = verificationID;
          },
          timeout: const Duration(seconds: 60));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("VERIFY PHONE-NUMBER ERROR $e");
      }
      final TranslateLan? translateLan = await TranslateController().translateLang(text: e.message.toString(), targetLanguage: 'es');
      final String error = translateLan!.data.translations[0].translatedText;
      final snackBar = SnackBar(duration: const Duration(seconds: 2), content: Styles.regular(error));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> signInWithFacebook(context) async {
    isLoading.value = true;
    try {
      await FacebookAuth.instance.logOut();
      final LoginResult result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
      if (kDebugMode) {
        print("FACEBOOK LOGIN STATUS ${result.status}");
      }
      switch (result.status) {
        case LoginStatus.success:
          final AuthCredential facebookCredential = FacebookAuthProvider.credential(result.accessToken!.token);
          final UserCredential authentication = await _auth.signInWithCredential(facebookCredential);
          final userData = await FacebookAuth.instance.getUserData();
          String? email = authentication.user!.email ?? authentication.user!.providerData[0].email;
          //Additional Information in User
          if (userData.containsKey('email')) {
            email = userData['email'];
          }

          /// CHECK USER ALREADY LOGIN WITH SAME EMAIL
          await UserLoginProviderApi().checkUserLoginByEmail(id: email!).then((value) async {
            if (value != null) {
              /// CHECK USER CREATE ACCOUNT WITH FACEBOOK
              if (value.result['Type'] == 'facebook') {
                final ParseResponse response = await ParseUser.loginWith(
                    'facebook', facebook(result.accessToken!.token, result.accessToken!.userId, result.accessToken!.expires));
                if (response.success) {
                  await successLogin(context, value: value);
                } else {
                  showSnackBar(context, content: response.error!.message);
                }
              } else {
                showSnackBar(context, content: '${"email_exits".tr} ${value.result['Type']}');
              }
            } else {
              /// NEW USER WITH FACEBOOK
              final ParseResponse response =
                  await ParseUser.loginWith('facebook', facebook(result.accessToken!.token, result.accessToken!.userId, result.accessToken!.expires));
              if (response.success) {
                final ParseUser user = response.result;
                final UserParent userParent = UserParent();
                userParent.objectId = user.objectId;
                userParent['Type'] = 'facebook';
                await userParent.save();

                /// CHECK DEFAULT-USER ALREADY CREATE
                UserLoginProviderApi().getByIdPointer(user).then((value, {onError}) async {
                  if (value != null) {
                    await successLogin(context, value: value);
                  } else {
                    /// CHECK DEFAULT-USER NOT FOUND CREATE NEW
                    await IP.all.then((all) {
                      /// CHECK ALREADY CREATE MORE THEN ONE
                      if (blockByIP.value && (blockIpAddress.contains(all.ip) || blockDeviceId.contains(all.deviceId))) {
                        showAlertDialog(context, title: 'user_ip_blocked'.tr);
                      } else {
                        Get.offAll(() => UserDetailScreen(type: 'facebook', newParseUser: user, appleEmail: email!));
                      }
                    });
                  }
                });
              } else {
                showSnackBar(context, content: response.error!.message);
              }
            }
          });
          break;
        case LoginStatus.cancelled:
          isLoading.value = false;
          break;
        case LoginStatus.failed:
          isLoading.value = false;
          break;
        default:
          isLoading.value = false;
          break;
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("FACEBOOK LOGIN ERROR $e");
      }
      final snackBar = SnackBar(content: Styles.regular(e.message.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    isLoading.value = false;
  }

  Future<void> doSignInApple(context) async {
    isLoading.value = true;

    try {
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName]);

      final oAuthProvider = OAuthProvider('apple.com');
      final firebaseauth = oAuthProvider.credential(idToken: credential.identityToken, accessToken: credential.authorizationCode);
      final UserCredential authResult = await _auth.signInWithCredential(firebaseauth);
      final String email = authResult.user!.email!;

      /// CHECK DEFAULT-USER ALREADY CREATE
      await UserLoginProviderApi().checkUserLoginByEmail(id: email).then((value) async {
        if (value != null) {
          if (value.result['Type'] == 'apple') {
            final ParseResponse response = await ParseUser.loginWith('apple', apple(credential.identityToken!, credential.userIdentifier!));
            if (response.success) {
              await successLogin(context, value: value);
            } else {
              showSnackBar(context, content: response.error!.message);
            }
          } else {
            showSnackBar(context, content: '${"email_exits".tr} ${value.result['Type']}');
          }
        } else {
          final ParseResponse response = await ParseUser.loginWith('apple', apple(credential.identityToken!, credential.userIdentifier!));
          if (response.success) {
            final ParseUser user = response.result;
            final UserParent userParent = UserParent();
            userParent.objectId = user.objectId;
            userParent['Type'] = 'apple';
            await userParent.save();
            UserLoginProviderApi().getByIdPointer(user).then((value, {onError}) async {
              if (value != null) {
                await successLogin(context, value: value);
              } else {
                await IP.all.then((all) {
                  if (blockByIP.value && (blockIpAddress.contains(all.ip) || blockDeviceId.contains(all.deviceId))) {
                    showAlertDialog(context, title: 'user_ip_blocked'.tr);
                  } else {
                    Get.offAll(() => UserDetailScreen(type: 'apple', newParseUser: user, appleEmail: email));
                  }
                });
              }
            });
          } else {
            showSnackBar(context, content: response.error!.message);
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("APPLE LOGIN AUTH FAIL: ${e.message.toString()} ");
      }
      final TranslateLan? translateLan = await TranslateController().translateLang(text: e.message.toString(), targetLanguage: 'es');
      final String error = translateLan!.data.translations[0].translatedText;
      isLoading.value = false;
      final snackBar = SnackBar(content: Styles.regular(error));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e, stack) {
      if (kDebugMode) {
        print("APPLE LOGIN FIREBASE AUTH EXCEPTION ERROR $e $stack");
      }
      final snackBar = SnackBar(content: Styles.regular('errorMessage'.tr));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      isLoading.value = false;
    }
    isLoading.value = false;
  }

  Future<void> verifyOtp(context) async {
    try {
      await _auth.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationCode.value, smsCode: otp.value)).then((value) async {
        if (value.user != null) {
          final String email = '${sms.value.text}@gmail.com';
          final String mobile = "${_userController.countryCodeNumber.value}${sms.value.text}";
          final UserParent parentUser = UserParent();
          parentUser.fullPhone = value.user?.phoneNumber;
          parentUser.phone = sms.value.text;
          parentUser.country = _userController.countryCodeNumber.value;
          parentUser.username = value.user?.phoneNumber;
          parentUser.password = value.user?.phoneNumber;
          parentUser.email = email;
          parentUser['Type'] = 'phoneNumber';
          await parentUser.save();
          final ApiResponse? checkUser = await UserLoginProviderApi().checkUserByEmail(email);

          ParseResponse response;
          if (checkUser != null) {
            final ParseCloudFunction function = ParseCloudFunction('editUserProperty');
            final Map<String, dynamic> params = <String, dynamic>{
              'objectId': checkUser.result['objectId'],
              'emailverified': true,
            };
            await function.execute(parameters: params);

            final user = ParseUser(value.user?.phoneNumber, value.user?.phoneNumber, email);
            response = await user.login();
          } else {
            final user = ParseUser(value.user?.phoneNumber, value.user?.phoneNumber, email);
            response = await user.signUp();
            final ParseCloudFunction function = ParseCloudFunction('editUserProperty');
            final Map<String, dynamic> params = <String, dynamic>{
              'objectId': response.result['objectId'],
              'emailverified': true,
            };
            await function.execute(parameters: params);
            response = await user.login();
          }

          if (response.success) {
            final currentUser = await ParseUser.currentUser();

            await UserLoginProviderApi().getByIdPointer(currentUser).then((value, {onError}) async {
              if (value != null) {
                await successLogin(context, value: value);
              } else {
                await IP.all.then((all) {
                  if (blockByIP.value && (blockIpAddress.contains(all.ip) || blockDeviceId.contains(all.deviceId))) {
                    showAlertDialog(context, title: 'user_ip_blocked'.tr);
                  } else {
                    Get.offAll(() => UserDetailScreen(type: 'phoneNumber', appleEmail: mobile, newParseUser: response.result));
                  }
                });
              }
            });
          } else {
            showSnackBar(context, content: response.error!.message);
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("PHONE-NUMBER AUTH ERROR ${e.message}");
      }
      final TranslateLan? translateLan = await TranslateController().translateLang(text: e.message.toString(), targetLanguage: 'es');
      final String error = translateLan!.data.translations[0].translatedText;
      final snackBar = SnackBar(content: Styles.regular(error));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> successLogin(context, {required ApiResponse value}) async {
    /// CHECK USER DELETED
    if ((value.result['isDeleted'] ?? false) == true) {
      Get.offAll(() => DeletedAccountScreen());
      StorageService.getBox.write('ObjectId', value.result['objectId']);
      StorageService.getBox.write('isDeleted', true);
    } else if ((value.result['IsBlocked'] ?? false) == true) {
      /// CHECK USER BLOCKED
      if (value.result['BlockDays'] == 'block_permanent') {
        // AlertShow(
        //     context: context,
        //     text1: '${S.of(context).account_blocked} ${S.of(context).permanently_block}',
        //     text2: S.of(context).delete_reason,
        //     reason: value.result["BlockReason"] ?? S.of(context).ok,
        //     onConfirm: () {},
        //     splash: true);

        Get.to(() => BlockScreen(text1: 'permanent_block'.tr, text2: 'delete_reason'.tr, reason: value.result["BlockReason"] ?? 'ok'.tr));
      } else {
        final DateTime date = value.result['BlockEndDate'];
        final DateTime currentDate = await currentTime();

        if (currentDate.isBefore(date)) {
          final difference = date.difference(currentDate).inDays;

          // AlertShow(
          //     context: context,
          //     text1: '${S.of(context).account_blocked} $difference ${S.of(context).days}',
          //     text2: S.of(context).delete_reason,
          //     reason: value.result["BlockReason"] ?? S.of(context).ok,
          //     onConfirm: () {},
          //     splash: true);

          Get.to(() => BlockScreen(
              text1: '${'permanent_block'.tr} $difference ${'days_until'.tr} ${DateFormat('dd/MM/y').format(date)}',
              text2: 'delete_reason'.tr,
              reason: value.result["BlockReason"] ?? 'ok'.tr));
        } else {
          List ipList = value.result['IpAddress'] ?? [];
          List dList = value.result['DeviceId'] ?? [];

          /// UPDATE BLOCK USER ENTRY WHEN DATE IS PASS
          final UserLogin userLogin = UserLogin();
          userLogin.objectId = value.result['objectId'];
          userLogin['IsBlocked'] = false;
          userLogin.blockDays = '0';
          userLogin.blockEndDate = value.result['BlockStartDate'];
          userLogin.hasLoggedIn = true;
          // userLogin.noChats = false;
          // userLogin.noCalls = false;
          // userLogin.noVideocalls = false;
          userLogin.showOnline = true;
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
          StorageService.getBox
              .write('DefaultProfileImg', value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['Imgprofile'].url ?? '');

          /// write gender and total coins for purchase or expenses of coins

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
            Get.off(() => CreateUserProfileScreen());
          } else {
            Get.delete<PairNotificationController>();
            _priceController.getAllPrices(login: value);
            Get.offAll(() => BottomScreen());
          }
        }
      }
    } else {
      /// ALREADY EXITS USER [login]

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
      StorageService.getBox.write('DefaultProfile', value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['objectId'] ?? '');
      StorageService.getBox
          .write('DefaultProfileImg', value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['Imgprofile'].url ?? '');
      StorageService.getBox
          .write('DefaultImgObjectId', value.result['DefaultProfile'] == null ? '' : value.result['DefaultProfile']['DefaultImg']?['objectId'] ?? '');
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
        Get.off(() => CreateUserProfileScreen());
      } else {
        Get.delete<PairNotificationController>();
        _priceController.getAllPrices(login: value);
        Get.offAll(() => BottomScreen());
      }
    }
  }
}
