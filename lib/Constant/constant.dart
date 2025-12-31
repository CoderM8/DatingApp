// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/post_view.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/models/radioButtonModel.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/splash_screen_first.dart';
import 'package:eypop/ui/store_screen.dart';
import 'package:eypop/ui/token_screen.dart';
import 'package:eypop/ui/wishes_pages/create_wish_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_device_id/flutter_device_id.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

const String keyApplicationName = 'eypop';
const String keyParseApplicationId = 'YUwjJIdCFCiE1spXhebX2VmbtF9EJR1NUI7WQZ6k';
const String keyParseClientKey = 'meu6pxIUqhlQ5iLLJuc490kAFI7Uz5ok5gk2qp1c';
const String keyParseServerUrl = 'https://eypopv13.b4a.io'; /*'https://parseapi.back4app.com'*/

const String keyParseMasterKey = 'g4bmcYaA9WYGE9LN0BfLkpMF8S0mxV3ig0ajXY2A';

const bool keyDebug = false;
int newAppVersion = 0;
int localVersion = 0;

enum PaymentType {
  /// Receive by Western Union, in the EU and America
  WesternUnion,

  /// IBAN transfer only in EU banks
  Iban,

  /// SWIFT international transfer all countries
  Swift,

  /// Receive it immediately by BIZUM only in Spain
  Bizun,

  /// Receive it to your PayPal account in all countries
  Paypal,
}

class ConstColors {
  static Color backgroundColor = const Color(0xfff8fafd);
  static Color white = const Color(0xffFFFFFF);
  static Color black = const Color(0xff000000);
  static Color themeColor = const Color(0xff0076C1);
  static Color subThemeColor = const Color(0xff89C4C2);
  static Color oldThemeColor = const Color(0xff1DCDC7);
  static Color titleColor = const Color(0xff286493);
  static Color subtitle = const Color(0xffBABABA);
  static Color border = const Color(0xff8E8E8E);
  static Color bottomBorder = const Color(0xff707070);
  static Color grey = const Color(0xffC7C7C7);
  static Color shimmerGray = const Color(0xffB5C7D4);
  static Color alertColor = const Color(0xffa25d5d);
  static Color redColor = const Color(0xffFF0000);
  static Color lightRedColor = const Color(0xffE69791);
  static Color darkRedColor = const Color(0xffD91F07);
  static Color darkRedBlackColor = const Color(0xff6F0000);
  static Color closeColor = const Color(0xffB2B2B2);
  static Color greyButtonColor = const Color(0xffB1B1B1);
  static Color darkGreenColor = const Color(0xff01720A);
  static Color lightGreenColor = const Color(0xff00DD00);
  static Color priceGreenColor = const Color(0xff59AF50);
  static Color blueColor = const Color(0xff000AFF);
  static Color purpleColor = const Color(0xffEB00EB);
  static Color darkBlueColor = const Color(0xff000576);
  static Color orangeColor = const Color(0xffFF9300);
  static Color pinkColor = const Color(0xffFF009D);
  static Color lightPurpleColor = const Color(0xffB07CE3);
  static Color offlineColor = const Color(0xffB5B5B5);
  static Color dividerColor = const Color(0xffD4D8DE);
  static Color purpleMediumColor = const Color(0xff8D00C1);
  static Color maroonColor = const Color(0xffB90000);
  static Color darkGreyColor = const Color(0xff6589A0);
  static Color deepBlueColor = const Color(0xff1600BE);
}

/// Report Reason
List<RadioModel> reportData = [
  RadioModel(false, 'assets/Icons/user_error.svg', 'fake_profile'.tr),
  RadioModel(false, 'assets/Icons/marijuana_sativa.svg', 'inappropriate_content'.tr),
  RadioModel(false, 'assets/Icons/moneydollar.svg', 'spam_scam'.tr),
  RadioModel(false, 'assets/Icons/hate.svg', 'gender_hate'.tr),
  RadioModel(false, 'assets/Icons/profilelogout.svg', 'behavior_outside_eypop'.tr),
  RadioModel(false, 'assets/Icons/18plus.svg', 'under_age'.tr),
  RadioModel(false, 'assets/Icons/forbidden.svg', 'illegal_content_eu'.tr),
  RadioModel(false, 'assets/Icons/pencil.svg', 'other_reasons'.tr),
];

///new key
const String agoraAppId = '41f0d404848f42cb807c57fe0fd7743b';

final RxMap con = {}.obs;
final RxString userLoginType = ''.obs;
final RxString userEmail = ''.obs;
final Rx<Duration> remainingTime = const Duration().obs;
final Rx<DateTime> startTime = DateTime.now().obs;
final Rx<DateTime> endTime = DateTime.now().obs;
final RxBool userProfileRefresh = false.obs;
final RxBool bottomRefresh = false.obs;
final RxString accountType = ''.obs;

/// status change
final RxBool hasLoggedIn = false.obs;
final RxBool noCalls = false.obs;
final RxBool noVideocalls = false.obs;
final RxBool noChats = false.obs;
final RxBool nonVisibleInteractionsOptions = false.obs;

final RxBool influencerCall = false.obs;
final RxBool influencerVideocall = false.obs;

/// get Default Profile
final RxBool noCallsProfile = true.obs;
final RxBool noVideocallsProfile = true.obs;
final RxBool noChatsProfile = false.obs;

/// inAppNotification
final RxString toChatUser = ''.obs; // toUserId store for inAppNotification
final RxString toMessageUser = ''.obs; // toMessageId store for inAppNotification

/// get pricePlans
List pricePlans = [];
List priceFlashSale = [];

// message read count list
RxList<Map<String, dynamic>> messageUnReadCountList = <Map<String, dynamic>>[
  {"FromProfileID": "", "ToProfileID": "", "Count": 0}
].obs;

Widget divider() {
  return Container(color: ConstColors.dividerColor, height: 0.3.h);
}

void showSnackBar(context, {required String content, bool ok = false}) {
  gradientSnackBar(context,
      title: content,
      image: ok ? "assets/Icons/ok.svg" : "assets/Icons/cross.svg",
      color1: ok ? ConstColors.darkGreenColor : ConstColors.darkRedColor,
      color2: ok ? ConstColors.lightGreenColor : ConstColors.redColor);
}

void gradientSnackBar(context, {required String title, Color? color1, Color? color2, required String image}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Container(
        height: 71.h,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            gradient: LinearGradient(
                colors: [color1 ?? ConstColors.darkGreenColor, color2 ?? ConstColors.lightGreenColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 1.0])),
        child: Row(
          children: [
            SvgView(image, width: 35.w, height: 25.h, color: ConstColors.white),
            SizedBox(width: 15.w),
            Expanded(child: Styles.regular(title, c: Colors.white, fs: 18.sp, lns: 2)),
          ],
        ),
      ),
      elevation: 0,
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: MediaQuery.of(context).padding.bottom + 10.h),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

void deleteProfileSnackBar(context) {
  gradientSnackBar(context,
      title: 'your_active_profile_is_deleted'.tr, image: "assets/Icons/trash.svg", color1: ConstColors.darkRedColor, color2: ConstColors.redColor);
}

Widget preCached(key) {
  return Obx(() {
    if (isDarkMode.value) {
      return SvgPicture.asset('assets/Icons/dark_precach.svg', fit: BoxFit.fitHeight, key: key);
    } else {
      return SvgPicture.asset('assets/Icons/light_precach.svg', fit: BoxFit.fitHeight, key: key);
    }
  });
}

Widget preCachedFullScreen(key) {
  return Obx(() {
    if (isDarkMode.value) {
      return SvgPicture.asset('assets/Icons/long_precach_dark.svg', fit: BoxFit.fitHeight, key: key);
    } else {
      return SvgPicture.asset('assets/Icons/long_precach_light.svg', fit: BoxFit.fitHeight, key: key);
    }
  });
}

Widget preCachedSquare() {
  return Obx(() {
    if (isDarkMode.value) {
      return SvgPicture.asset('assets/Icons/dark_precach_square.svg', fit: BoxFit.fitHeight);
    } else {
      return SvgPicture.asset('assets/Icons/light_precach_square.svg', fit: BoxFit.fitHeight);
    }
  });
}

Widget preCachedImage(key) {
  return Obx(() {
    if (isDarkMode.value) {
      return SvgPicture.asset('assets/Icons/dark_precach.svg', fit: BoxFit.cover, key: key);
    } else {
      return SvgPicture.asset('assets/Icons/light_precach.svg', fit: BoxFit.cover, key: key);
    }
  });
}

File renameFile({required File file, required String name, required String extension}) {
  final lastSeparator = file.path.lastIndexOf(Platform.pathSeparator);
  final newPath = "${file.path.substring(0, lastSeparator + 1)}$name.$extension";
  return file.renameSync(newPath);
}

Future getDefaultProfile() async {
  if (StorageService.getBox.read('DefaultProfile') != null) {
    await UserProfileProviderApi().getByObjectId(StorageService.getBox.read('DefaultProfile')).then((value){
        if(value.result != null){
          noCallsProfile.value = (value.result['NoCalls'] ?? true);
          noVideocallsProfile.value = (value.result['NoVideocalls'] ?? true);
          noChatsProfile.value = (value.result['NoChats'] ?? false);
        }
      });
  }
}

/// make online user_login (updateLastOnline) ParseCloudFunction
Future<void> updateLastOnline() async {
  if (StorageService.getBox.read('ObjectId') != null) {
    final Map<String, dynamic> params = <String, dynamic>{'userId': StorageService.getBox.read('ObjectId')};
    final ParseCloudFunction getCurrentTime = ParseCloudFunction('updateLastOnline');
    await getCurrentTime.execute(parameters: params);
  }
}

/// make online default user_profile and this default profile all user_wish (updateLastOnlineProfile) ParseCloudFunction
Future<void> updateLastOnlineProfile() async {
  if (StorageService.getBox.read('DefaultProfile') != null) {
    final Map<String, dynamic> params = <String, dynamic>{'profileId': StorageService.getBox.read('DefaultProfile')};
    final ParseCloudFunction getCurrentTime = ParseCloudFunction('updateLastOnlineProfile');
    await getCurrentTime.execute(parameters: params);
  }
}

/// make online user_login (onlineUser) ParseCloudFunction
Future<void> onlineUser() async {
  Future.delayed(const Duration(seconds: 1));
  if (StorageService.getBox.read('ObjectId') != null) {
    final Map<String, dynamic> params = <String, dynamic>{
      'userId': StorageService.getBox.read('ObjectId'),
      'local': StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode,
    };
    final ParseCloudFunction getCurrentTime = ParseCloudFunction('onlineUser');
    final ParseResponse pr = await getCurrentTime.execute(parameters: params);
    if (kDebugMode) {
      print('Hello response online ${pr.result}');
    }
  }
}

/// make offline user_login (offlineUser) ParseCloudFunction
Future<void> offlineUser() async {
  Future.delayed(const Duration(seconds: 1));
  if (StorageService.getBox.read('ObjectId') != null) {
    final Map<String, dynamic> params = <String, dynamic>{
      'userId': StorageService.getBox.read('ObjectId'),
      'local': StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode,
    };
    final ParseCloudFunction getCurrentTime = ParseCloudFunction('offlineUser');
    final ParseResponse pr = await getCurrentTime.execute(parameters: params);
    if (kDebugMode) {
      print('Hello response offline ${pr.result}');
    }
  }
}

// /// make online default profile
// Future<void> onlineProfile() async {
//   Future.delayed(const Duration(seconds: 1));
//   if (StorageService.getBox.read('DefaultProfile') != null) {
//     final Map<String, dynamic> params = <String, dynamic>{'profileId': StorageService.getBox.read('DefaultProfile')};
//     final ParseCloudFunction getCurrentTime = ParseCloudFunction('onlineProfile');
//     final ParseResponse pr = await getCurrentTime.execute(parameters: params);
//     if (kDebugMode) {
//       print('Hello response online profile ${pr.result}');
//     }
//   }
// }
//
// /// make offline default profile
// Future<void> offlineProfile() async {
//   Future.delayed(const Duration(seconds: 1));
//   if (StorageService.getBox.read('DefaultProfile') != null) {
//     final Map<String, dynamic> params = <String, dynamic>{'profileId': StorageService.getBox.read('DefaultProfile')};
//     final ParseCloudFunction getCurrentTime = ParseCloudFunction('offlineProfile');
//     final ParseResponse pr = await getCurrentTime.execute(parameters: params);
//     if (kDebugMode) {
//       print('Hello response offline profile ${pr.result}');
//     }
//   }
// }

Future<void> initInstallation(String userId) async {
  final String? token = await setupToken();
  final ParseInstallation currentInstallation = await ParseInstallation.currentInstallation();
  if (currentInstallation.objectId == null) {
    await currentInstallation.subscribeToChannel('push');
    currentInstallation.deviceToken = token;
    currentInstallation.set('UserId', userId);
    final ParseResponse res = await currentInstallation.save();
    print("ParseInstallation case 1 create: [${res.success}] ${res.result}");
  } else if (userId != currentInstallation['UserId']) {
    currentInstallation.set('UserId', userId);
    final ParseResponse res = await currentInstallation.save();
    print("ParseInstallation case 2 update: [${res.success}] ${res.result}");
  } else {
    print("ParseInstallation case 3 default: $currentInstallation");
  }
}

extension StringValidators on String {
  bool get containsUppercase => contains(RegExp(r'[A-Z]'));

  bool get containsLowercase => contains(RegExp(r'[a-z]'));
}

Future<bool> userReview() async {
  try {
    final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('User_Review'))
      ..whereEqualTo('User', UserLogin()..objectId = StorageService.getBox.read('ObjectId'));

    final res = getApiResponse<ParseObject>(await query.query());
    return res.results == null;
  } catch (e) {
    return true;
  }
}

Future<String?> setupToken() async {
  final String? token = Platform.isAndroid
      ? await FirebaseMessaging.instance.getToken()
      : (await FlutterCallkitIncoming.getDevicePushTokenVoIP()).toString().toUpperCase();
  if (StorageService.getBox.read('ObjectId') != null) {
    final ApiResponse apiResponse = await UserLoginProviderApi().getById(StorageService.getBox.read('ObjectId'));
    if (apiResponse.result['deviceTokenCall'] != null) {
      if (!apiResponse.result['deviceTokenCall'].toString().contains(token!)) {
        UserLogin userLogin = UserLogin();
        userLogin.objectId = StorageService.getBox.read('ObjectId');
        userLogin['deviceTokenCall'] = [token, ...apiResponse.result['deviceTokenCall']];
        UserLoginProviderApi().update(userLogin);
      }
    } else {
      UserLogin userLogin = UserLogin();
      userLogin.objectId = StorageService.getBox.read('ObjectId');
      userLogin['deviceTokenCall'] = [token];
      UserLoginProviderApi().update(userLogin);
    }
  }
  // String? ios = await FirebaseMessaging.instance.getToken();
  // print('Hello token firebase ios ------- $ios');
  if (kDebugMode) {
    print('Hello token $token');
  }
  return token;
}

Future<DateTime> currentTime() async {
  try {
    final ParseCloudFunction getCurrentTime = ParseCloudFunction('getCurrentDateTime');
    final ParseResponse parseResponse = await getCurrentTime.execute();
    return DateTime.parse(parseResponse.result).toUtc();
  } catch (e) {
    return DateTime.now().toUtc();
  }
}

class WishBox extends StatelessWidget {
  final String svg;
  final String title;
  final bool isDone;
  final VoidCallback? onTap;

  const WishBox({Key? key, required this.svg, required this.title, required this.isDone, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.ease,
        child: Container(
          height: 30.h,
          padding: EdgeInsets.only(right: 10.w, left: 10.w),
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            color: ConstColors.black.withOpacity(0.50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgView(svg, network: true, height: 15.h, width: 20.w, color: ConstColors.redColor),
              SizedBox(width: 7.w),
              Styles.regular(title, c: ConstColors.white, ff: 'HR', fs: 14.sp, ov: TextOverflow.ellipsis),
              if (isDone) Container(margin: EdgeInsets.only(left: 10.w), width: 18.h, child: SvgPicture.asset('assets/Icons/magic_star.svg'))
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationBody extends StatelessWidget {
  final String alert;
  final String notificationAlert;
  final String name;
  final String image;
  final double minHeight;

  const NotificationBody(
      {Key? key, required this.alert, required this.notificationAlert, required this.name, required this.image, this.minHeight = 0.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minHeight = math.min(this.minHeight, MediaQuery.of(context).size.height);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 12, blurRadius: 16)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ConstColors.themeColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(width: 1.4, color: ConstColors.themeColor.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 10.r, right: 10.r, top: 5.r, bottom: 5.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(30.w), child: Image.network(image, height: 60.w, width: 60.w, fit: BoxFit.cover)),
                          Positioned(
                            bottom: 0.0,
                            right: 0.0,
                            child: Container(
                                height: 17.h, width: 17.h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: Colors.green)),
                          )
                        ],
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                        width: 210.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Styles.regular(name, ov: TextOverflow.ellipsis, c: Colors.white, fs: 24.sp, ff: 'HM'),
                            Styles.regular(alert, ov: TextOverflow.ellipsis, c: Colors.white, fs: 16.sp, ff: "HR"),
                          ],
                        ),
                      ),
                      SizedBox(width: 20.w),
                      SvgView(notification(notificationAlert), fit: BoxFit.cover, width: 40.w),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String notificationText(alert, context) {
  switch (alert) {
    case 'send you liplike':
      {
        return 'send_you_liplike'.tr;
      }
    case 'send you heartlike':
      {
        return 'send_you_heartlike'.tr;
      }
    case 'send you a Wink':
      {
        return 'send_you_a_Wink'.tr;
      }
    case 'send you Heart Message':
      {
        return 'send_you_Heart_Message'.tr;
      }
    case 'send you Chat Message':
      {
        return 'send_you_Chat_Message'.tr;
      }
    case 'Calling you':
      {
        return 'calling_you'.tr;
      }
    case 'Visit Your profile':
      {
        return 'Visit_Your_profile'.tr;
      }
    case 'full fill your toktok':
      {
        return 'full_fill_your_toktok'.tr;
      }
    case 'send you Gift':
      {
        return "Send_You_Gift".tr;
      }
    default:
      {
        return 'assets/Icons/tresure.svg';
      }
  }
}

String notification(alert) {
  switch (alert) {
    case 'send you liplike':
      {
        return 'assets/Icons/lipLike.svg';
      }
    case 'send you heartlike':
      {
        return 'assets/Icons/heartNoti.svg';
      }
    case 'send you a Wink':
      {
        return 'assets/Icons/wink.svg';
      }
    case 'send you Heart Message':
      {
        return 'assets/Icons/heartMessage.svg';
      }
    case 'send you Chat Message':
      {
        return 'assets/Icons/chat.svg';
      }
    case 'Calling you':
      {
        return 'assets/Icons/call.svg';
      }
    case 'Visit Your profile':
      {
        return 'assets/Icons/visit.svg';
      }
    case 'full fill your toktok':
      {
        return 'assets/Icons/wishNotification.svg';
      }
    case 'send you Gift':
      {
        return 'assets/Icons/gift.svg';
      }
    default:
      {
        return 'assets/Icons/tresure.svg';
      }
  }
}

const MethodChannel receiver = MethodChannel('Receiver');

Map receiveNotification = {};

Future<dynamic> getIOSInstallation() async {
  return await receiver.invokeMethod('DeviceMethod');
}

Future<void> initInstallationParseToken() async {
  if (Platform.isAndroid) {
    if (StorageService.getBox.read('ObjectId') != null) {
      initInstallation(StorageService.getBox.read('ObjectId'));
    } else {
      initInstallation("noUserMain");
    }
  } else {
    if (StorageService.getBox.read('ObjectId') != null) {
      setupToken();
    }
  }

  try {
    Map valueMap = {};
    if (Platform.isAndroid) {
      final result = await receiver.invokeMethod('ReceiverMethod');
      print('Hello ReceiverMethod Data Android ******* $result');
      if (result != null) {
        valueMap = json.decode(result);
      }
    } else {
      final result = await receiver.invokeMethod('ReceiverMethod', {"UserObjectId": StorageService.getBox.read('ObjectId') ?? ''});
      print('Hello ReceiverMethod Data IOS ******* $result');
      valueMap = result;
    }
    if (valueMap.isNotEmpty) {
      receiveNotification = valueMap;
    }
    print('👍 Hello receiveNotification Notification Result 👍✅ ***** $receiveNotification');
  } catch (e, t) {
    print('❌ Hello Native Code Notification Error ❌ ***** $e');
    print('❌ Hello Native Code Notification Trace ❌ ***** $t');
  }
}

// Future<void> getBackgroundDataIos() async {
//   try {
//     Map valueMap = {};
//     if (Platform.isAndroid) {
//       final result = await receiver.invokeMethod('ReceiverMethod');
//       if (result != null) {
//         valueMap = json.decode(result);
//       }
//     } else {
//       final result = await receiver.invokeMethod('ReceiverMethod', {"UserObjectId": StorageService.getBox.read('ObjectId') ?? ''});
//       valueMap = result;
//     }
//     if (kDebugMode) {
//       print('Hello Native Code Notification Result: $valueMap');
//     }
//     if (valueMap.isNotEmpty) {
//       receiveNotification = valueMap;
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print('Hello Native Code Notification Error: $e');
//     }
//   }
// }

String priceLocal(value) {
  return NumberFormat.compact(locale: StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode).format(value);
}

/// show Dialog index (muro) & (toktok)
final RxList<int> indexMuroList = <int>[].obs;
final RxList<int> indexTokTokList = <int>[].obs;

/// Ads Internal Link Open Screen
adsOpenScreen(String link) {
  switch (link) {
    case 'purchase':
      Get.to(() => StoreScreen());
      break;
    case 'toktok':
      Get.to(() => const CreateWishScreen());
      break;
    case 'withdrawal':
      Get.to(() => TokenView());
      break;
    default:
      showSnackBar(Get.context, content: 'invalid_link'.tr);
  }
}

Future adsDialog(ParseObject ads, int index, String service) async {
  return showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SizedBox(
          height: 730.h,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InkWell(
                onTap: () async {
                  if (ads['InternalLink'].toString().isNotEmpty) {
                    adsOpenScreen(ads['InternalLink'].toString());
                  } else if (ads['ExternalLink'].toString().isNotEmpty) {
                    final url = Uri.parse(ads['ExternalLink'].toString());
                    await launchUrl(url);
                  }
                },
                child: ImageView(
                  ads['Image'].url,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(40.r),
                  placeholder: preCached(UniqueKey()),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 23.h, left: 10.w, right: 22.w),
                child: SvgView(
                  "assets/Icons/cancelbutton.svg",
                  height: 45.w,
                  width: 45.w,
                  onTap: () {
                    if (service == 'muro') {
                      indexMuroList.add(index);
                    } else {
                      indexTokTokList.add(index);
                    }
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget pricesTile({required String svg, required String title, required String subTitle}) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.r),
    decoration: BoxDecoration(
        color: Colors.transparent, borderRadius: BorderRadius.circular(16.r), border: Border.all(width: 1.w, color: ConstColors.border)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgView(svg, color: Theme.of(Get.context!).primaryColor),
        SizedBox(height: 6.5.h),
        Styles.regular(title, fs: 18.sp, c: Theme.of(Get.context!).primaryColor),
        SizedBox(height: 2.h),
        Styles.regular(subTitle, fs: 18.sp, c: Theme.of(Get.context!).primaryColor, al: TextAlign.center),
      ],
    ),
  );
}

class IP {
  static Future<String?> get ip async {
    try {
      final response = await http.get(Uri.parse(ipApiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['myip'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<String?> get deviceId async {
    try {
      return await FlutterDeviceId().getDeviceId();
    } catch (e) {
      return null;
    }
  }

  static Future<All> get all async {
    final id = await ip;
    final id2 = await deviceId;
    debugPrint('HELLO DEVICE INFO $id : $id2');
    return All(ip: id, deviceId: id2);
  }
}

class All {
  String? ip;
  String? deviceId;

  All({this.ip, this.deviceId});
}

class ThumbUrl {
  static Future<String?> file(String url) async {
    final String? file = await VideoThumbnail.thumbnailFile(video: url, imageFormat: ImageFormat.JPEG, maxHeight: 0, maxWidth: 0, quality: 100);
    return file;
  }

  static Future<ParseFile> network(String url) async {
    final Uint8List? list = await VideoThumbnail.thumbnailData(video: url, imageFormat: ImageFormat.JPEG, maxHeight: 0, maxWidth: 0, quality: 100);
    final tempDir = await getTemporaryDirectory();
    final File file = await File('${tempDir.path}/thumb.png').create();
    file.writeAsBytesSync(list!);
    return ParseFile(file);
  }

  /// CONVERT URL TO FILE
  static Future<File> getFileFromUrl(String url) async {
    final responseData = await http.get(Uri.parse(url));
    final Uint8List uin8list = responseData.bodyBytes;
    final tempDir = await getTemporaryDirectory();
    final File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(uin8list);
    return file;
  }
}

/// New coin system from cloud
Future<dynamic> parseCloudInteraction(
    {required fromUserId,
    required toUserId,
    required toProfileId,
    required fromProfileId,
    required type,
    String? message,
    String? tempUniqueId,
    String? time,
    bool isPairUpdate = false,
    String? objectId,
    ParseObject? giftObject,
    String? chatType,
    Map<String, dynamic>? postMap,
    int callPrice = 0,
    postId}) async {
  final ParseCloudFunction function = ParseCloudFunction(type);
  final Map<String, dynamic> params = <String, dynamic>{
    'toUserId': toUserId,
    'fromUserId': fromUserId,
    'toProfileId': toProfileId,
    'fromProfileId': fromProfileId,
    'tempUniqueId': tempUniqueId ?? '',
    'message': message ?? '',
    'time': time ?? '',
    'isPairUpdate': isPairUpdate,
    'objectId': objectId ?? '',
    'postId': postId ?? '',
    'callPrice': callPrice,
    'chatType': chatType ?? "",
    'postMap': postMap ?? {},
    'giftObjectId': giftObject != null ? giftObject.objectId : "",
  };
  final ParseResponse parseResponse = await function.execute(parameters: params);
  print("💎 Hello interaction cloud function: $type code:[${parseResponse.statusCode}] result: ${parseResponse.result}");

  if (parseResponse.statusCode == 200) {
    return parseResponse.result;
  }
  return {"success": false, "message": parseResponse.statusCode};
}

Color boxColor(DateTime userDate) {
  // DateTime dateTime = await currentTime();
  final DateTime dateTime = DateTime.now();
  if (dateTime.difference(userDate).inHours <= startNumber) {
    return const Color(0xff27B262).withOpacity(0.78);
  } else if (dateTime.difference(userDate).inHours > startNumber && dateTime.difference(userDate).inHours < endNumber) {
    return const Color(0xff9fc5e8).withOpacity(0.84);
  } else {
    return Colors.transparent;
  }
}

RecentModel roundColor(DateTime? userDate, context, gender) {
  // DateTime dateTime = await currentTime();
  final DateTime dateTime = DateTime.now();
  userDate ??= dateTime;
  if (gender == 'female') {
    if (dateTime.difference(userDate).inHours <= 2) {
      return RecentModel(const Color(0xff00d997), 'online_now'.tr);
    } else if (dateTime.difference(userDate).inHours > 2 && dateTime.difference(userDate).inHours < recentlyActivatedNumber) {
      return RecentModel(const Color(0xffb8d900), 'recently_active_female'.tr);
    } else {
      return RecentModel(const Color(0xff3c44fb), 'active_a_few_days_ago_female'.tr);
    }
  } else {
    if (dateTime.difference(userDate).inHours <= 2) {
      return RecentModel(const Color(0xff00d997), 'online_now'.tr);
    } else if (dateTime.difference(userDate).inHours > 2 && dateTime.difference(userDate).inHours < recentlyActivatedNumber) {
      return RecentModel(const Color(0xffb8d900), 'recently_active_male'.tr);
    } else {
      return RecentModel(const Color(0xff3c44fb), 'active_a_few_days_ago_male'.tr);
    }
  }
}

String boxText(DateTime userDate, context, gender) {
  final DateTime dateTime = DateTime.now();
  if (gender == 'female') {
    if (dateTime.difference(userDate).inHours <= startNumber) {
      return 'recently_added_female'.tr;
    } else if (dateTime.difference(userDate).inHours > startNumber && dateTime.difference(userDate).inHours < endNumber) {
      return 'new_female_user'.tr;
    } else {
      return '';
    }
  } else {
    if (dateTime.difference(userDate).inHours <= startNumber) {
      return 'recently_added_male'.tr;
    } else if (dateTime.difference(userDate).inHours > startNumber && dateTime.difference(userDate).inHours < endNumber) {
      return 'new_male_user'.tr;
    } else {
      return '';
    }
  }
}

class RecentModel {
  const RecentModel(this.color, this.title);

  final Color color;
  final String title;
}
