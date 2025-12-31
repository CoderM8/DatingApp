// ignore_for_file: prefer_typing_uninitialized_variables
// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:io';

import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Controllers/toktok_contoller.dart';
import 'package:eypop/Controllers/translate_controler.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/back4appservice/user_provider/wishes/toktok_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/wishes/wish_provider_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/wishes_model/toktok_model.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../Constant/constant.dart';
import '../../back4appservice/base/api_response.dart';

class CreateWishController extends GetxController with GetTickerProviderStateMixin {
  static TokTokController get tokTokController => Get.find<TokTokController>();
  final RxList allWishes = [].obs;
  final RxString wishTimeForDisplay = 'when'.tr.obs;
  final RxString wishTimeForDatabase = ''.obs;
  final RxList<ParseObject> selectedWishes = <ParseObject>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingOTP = false.obs;
  final RxBool isWishCreating = false.obs;
  final RxBool isWhen = false.obs;
  final RxString pickedFile = "".obs;
  final RxString videoThumbFile = "".obs;
  final RxString telephoneNumber = "".obs;
  final RxString whatsappNumber = "".obs;
  final RxString countryCodeTelephone = "".obs;
  final RxString countryCodeWhatsapp = "".obs;

  final Rx<DateTime> phoneNumberDate = DateTime.now().subtract(const Duration(days: 1)).toUtc().obs;

  final RxBool isTelephone = false.obs;
  final RxBool isWhatsapp = false.obs;
  final RxBool isInstagram = false.obs;
  final RxBool isFacebook = false.obs;
  final RxBool isTelegram = false.obs;
  final RxBool isOnlyfans = false.obs;
  final RxBool isSkype = false.obs;
  //final RxBool isVisible = true.obs;

  final TextEditingController instagramId = TextEditingController();
  final TextEditingController facebookId = TextEditingController();
  final TextEditingController telegramId = TextEditingController();
  final TextEditingController onlyfansId = TextEditingController();
  final TextEditingController skypeId = TextEditingController();

  String local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
  List daysList = [
    'Today'.tr,
    'Tonight'.tr,
    'Morning'.tr,
    'Tomorrow_night'.tr,
    'Thursday'.tr,
    'Thursday_night'.tr,
    'On_Friday'.tr,
    'Friday_night'.tr,
    'Saturday'.tr,
    'Saturday_night'.tr,
    'On_Sunday'.tr,
    'Weekend'.tr,
    'Next_week'.tr,
  ];
  String postType = '';

  ParseResponse? apiResponse;
  Timer? timer;
  RxInt start = 60.obs;
  final RxString countryCodeNumber = '+34'.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxString verificationCode = ''.obs;
  final Rx<TextEditingController> telephone = TextEditingController().obs;
  final RxBool isValid = false.obs;
  final RxString otp = ''.obs;

  TokTokModel toktokData = TokTokModel();

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

  @override
  Future<void> onInit() async {
    isLoading.value = true;
    await getCountryCode();
    if (StorageService.getBox.read('DefaultProfile') != null) {
      await getToktokData();
      await getToktokImages();
    }

    getWishesData().then((value) {
      if (value.results != null) {
        allWishes.addAll(value.results ?? []);
      }
      isLoading.value = false;
    });
    super.onInit();
  }

  Future getToktokImages() async {
    tokTokController.seeTokTok.clear();
    if (tokTokController.tokTokTotalImage.isNotEmpty) {
      for (var e in tokTokController.tokTokTotalImage) {
        ApiResponse? data = await WishesApi().getByToktokImage(e['Img_Post']);
        if (data != null) {
          tokTokController.seeTokTok.add({"Data": data.result['Img_Post'], "Type": 'Image'});
        }
      }
    }
    if (tokTokController.tokTokTotalVideo.isNotEmpty) {
      for (var e in tokTokController.tokTokTotalVideo) {
        ApiResponse? data = await WishesApi().getByToktokVideo(e['Video_Post']);
        if (data != null) {
          tokTokController.seeTokTok.add({"Data": data.result['Video_Post'], "Type": 'Video'});
        }
      }
    }
  }

  Future getToktokData() async {
    await TokTokApi().getUserId(StorageService.getBox.read('DefaultProfile')).then((value) async {
      if (value != null) {
        toktokData = value.result;
        tokTokController.tokTokObject = value.result;
        wishTimeForDisplay.value = toktokData.time;
        isWhen.value = true;
        for (ParseObject element in toktokData['Wish_List']) {
          selectedWishes.add(element);
        }
        telephoneNumber.value = toktokData.telephone;
        whatsappNumber.value = toktokData.whatsapp;
        countryCodeTelephone.value = toktokData.telephoneDiaCode;
        countryCodeWhatsapp.value = toktokData.whatsappDiaCode;
        instagramId.text = toktokData.instagram;
        facebookId.text = toktokData.facebook;
        telegramId.text = toktokData.telegram;
        onlyfansId.text = toktokData.onlyfans;
        skypeId.text = toktokData.skype;
        isTelephone.value = toktokData.isTelephoneEnable;
        isWhatsapp.value = toktokData.isWhatsappEnable;
        isInstagram.value = toktokData.isInstagramEnable;
        isFacebook.value = toktokData.isFacebookEnable;
        isTelegram.value = toktokData.isTelegramEnable;
        isOnlyfans.value = toktokData.isOnlyFansEnable;
        isSkype.value = toktokData.isSkypeEnable;
        //isVisible.value = toktokData.isVisible;
        phoneNumberDate.value = toktokData.phoneNumberDate;
      } else {
        if (userLoginType.value == 'phoneNumber') {
          final ApiResponse? checkUser = await UserLoginProviderApi().checkUserById(userEmail.value);
          if (checkUser != null) {
            telephoneNumber.value = checkUser.result['phone_number'];
            whatsappNumber.value = checkUser.result['phone_number'];
            countryCodeTelephone.value = checkUser.result['country_dial_code'];
            countryCodeWhatsapp.value = checkUser.result['country_dial_code'];
            // phoneNumberDate.value = DateTime.now().toUtc();
            // isTelephone.value = false;
            // isWhatsapp.value = true;
          }
        }
      }
    });
  }

  Future<void> getCountryCode() async {
    final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Country'))..whereEqualTo('Status', true);
    apiResponse = await query.query();
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

  Future<bool> verifyOtp(context) async {
    try {
      final value = await _auth.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationCode.value, smsCode: otp.value));
      print("PHONE-NUMBER AUTH  ${value.user}");
      return value.user != null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("PHONE-NUMBER AUTH ERROR ${e.message}");
      }
      final TranslateLan? translateLan = await TranslateController().translateLang(text: e.message.toString(), targetLanguage: 'es');
      final String error = translateLan!.data.translations[0].translatedText;
      final snackBar = SnackBar(content: Styles.regular(error));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }

  Future<ParseResponse> getWishesData() async {
    final QueryBuilder<ParseObject> wishGet = QueryBuilder<ParseObject>(ParseObject('Wishes_List'));
    return await wishGet.query();
  }

  Future<File?> fromGallery(String type, context) async {
    pickedFile.value = "";
    videoThumbFile.value = '';
    try {
      if (type == "video") {
        final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(type: FileType.video, allowCompression: false);
        if (pickerResult != null && pickerResult.paths.isNotEmpty) {
          final newFile = renameFile(file: File(pickerResult.paths[0]!), name: "video", extension: 'mp4');
          if (newFile.lengthSync() > videoLimit) {
            showSnackBar(context, content: 'upload_video_less_40mb'.tr);
            videoThumbFile.value = "";
          } else {
            postType = 'Video';
            pickedFile.value = newFile.path; // for video path
            await ThumbUrl.file(newFile.path).then((value) {
              if (value != null) {
                // for image thumb path
                videoThumbFile.value = value;
              }
            });
          }
        }
      } else {
        postType = 'Image';
        await imagePick().then((value) {
          if (value != null) {
            pickedFile.value = value.path;
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('error in wish file picker $e');
      }
    }

    update();
    return File(pickedFile.value);
  }

  Future<File?> imagePick({source = ImageSource.gallery}) async {
    final pickFile = await ImagePicker().pickImage(source: source);
    if (pickFile == null) {
      return null;
    } else {
      return File(pickFile.path);
    }
  }

  void createTokTok() async {
    isWishCreating.value = true;
    try {
      final TokTokModel toktokModel = TokTokModel();

      toktokModel.user = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
      toktokModel.profile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
      toktokModel.gender = StorageService.getBox.read('Gender');
      toktokModel.time = wishTimeForDisplay.value;
      toktokModel.wishList = selectedWishes;
      //toktokModel.isVisible = isVisible.value;
      toktokModel.telephone = telephoneNumber.value;
      toktokModel.whatsapp = whatsappNumber.value;
      toktokModel.telephoneDiaCode = countryCodeTelephone.value;
      toktokModel.whatsappDiaCode = countryCodeWhatsapp.value;
      toktokModel.instagram = instagramId.value.text;
      toktokModel.facebook = facebookId.text;
      toktokModel.telegram = telegramId.text;
      toktokModel.onlyfans = onlyfansId.text;
      toktokModel.skype = skypeId.text;
      toktokModel.isWhatsappEnable = isWhatsapp.value;
      toktokModel.isTelephoneEnable = isTelephone.value;
      toktokModel.isInstagramEnable = isInstagram.value;
      toktokModel.isFacebookEnable = isFacebook.value;
      toktokModel.isTelegramEnable = isTelegram.value;
      toktokModel.isOnlyFansEnable = isOnlyfans.value;
      toktokModel.isSkypeEnable = isSkype.value;
      toktokModel.phoneNumberDate = phoneNumberDate.value;

      if (toktokData.objectId == null) {
        await TokTokApi().add(toktokModel).then((value) {
          toktokData = value.result;
          tokTokController.tokTokObject = value.result;
          tokTokController.tokTokObjectId.value = tokTokController.tokTokObject['objectId'];
        });
      } else {
        toktokModel.objectId = toktokData.objectId;
        await TokTokApi().update(toktokModel).then((value) {
          toktokData = value.result;
          tokTokController.tokTokObject = value.result;
          tokTokController.tokTokObjectId.value = tokTokController.tokTokObject['objectId'];
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('hello wish error $e');
      }
      isWishCreating.value = false;
    }
    isWishCreating.value = false;
    Get.back();
  }

// void createWish() async {
//   isWishCreating.value = true;
//   try {
//     final WishModel wishModel = WishModel();
//     wishModel.user = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
//     wishModel.profile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
//     wishModel.gender = StorageService.getBox.read('Gender');
//     // 0 means all wish are accepted
//     wishModel.status = 0;
//     wishModel.post = ParseFile(File(pickedFile.value));
//     wishModel.time = wishTimeForDatabase.value;
//     wishModel.wishList = selectedWishes;
//     wishModel.isVisible = true;
//     wishModel.postType = postType;
//     wishModel.isNude = _bottomControllers.isNude.value;
//     if (postType == 'Video') {
//       wishModel.thumbnail = ParseFile(File(videoThumbFile.value));
//     }
//     await WishesApi().add(wishModel);
//   } on Exception catch (e) {
//     if (kDebugMode) {
//       print('hello wish error $e');
//     }
//     isWishCreating.value = false;
//   }
//   isWishCreating.value = false;
//   _p.update();
//   Get.back();
// }
}
