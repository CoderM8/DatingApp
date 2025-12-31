// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/ui/User_profile/squar_crop_screen.dart';
import 'package:eypop/ui/permission_screen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../Constant/constant.dart';
import '../back4appservice/base/api_response.dart';
import '../back4appservice/user_provider/language_api.dart';
import '../back4appservice/user_provider/users/provider_post_api.dart';
import '../back4appservice/user_provider/users/provider_profileuser_api.dart';
import '../back4appservice/user_provider/users/provider_user_api.dart';
import '../models/user_login/user_login.dart';
import '../models/user_login/user_post.dart';
import '../models/user_login/user_profile.dart';
import '../service/local_storage.dart';
import '../ui/bottom_screen.dart';

/// Table: [AppInfo] ColumnName: [IpApi]
String ipApiUrl = '';

/// Table: [AppInfo] ColumnName: [VozipRecordApi]
String vozipRecordApi = '';

/// Table: [AppInfo] ColumnName: [new_profile_start_number]
int startNumber = 74;

/// Table: [AppInfo] ColumnName: [new_profile_end_number]
int endNumber = 240;

/// Table: [AppInfo] ColumnName: [recently_activated_hour]
int recentlyActivatedNumber = 240;

/// Table: [AppInfo] ColumnName: [ReviewTime]
int reviewTime = 5;

/// Table: [AppInfo] ColumnName: [IosCallApi]
final RxString iosCallApiLink = ''.obs;

/// Table: [AppInfo] ColumnName: [EnableDeletePhoto]
final RxBool enableDeletePhoto = false.obs;

/// Table: [AppInfo] ColumnName: [UploadVideoInf]
final RxBool uploadVideoInf = false.obs;

/// Table: [AppInfo] ColumnName: [BlockByIP]
final RxBool blockByIP = true.obs;

/// Table: [AppInfo] ColumnName: [ChatLimit]
int chatLimit = 200;

/// Table: [AppInfo] ColumnName: [HistoryLimit]
int historyLimit = 100;

/// Table: [AppInfo] ColumnName: [HistoryStars]
int historyStars = 20;

/// Table: [AppInfo] ColumnName: [TokTokImageLimit]
int tokTokImageLimit = 3;

/// Table: [AppInfo] ColumnName: [TokTokVideoLimit]
int tokTokVideoLimit = 5;

/// Table: [AppInfo] ColumnName: [TokTokDeactiveDays]
int tokTokDeactiveDays = 30;

/// Table: [AppInfo] ColumnName: [AccountJson]
Map accountJson = {};

List blockIpAddress = [];
List blockDeviceId = [];
// change video upload limit in app
int videoLimit = 41900000; // VIDEO SIZE [40MB]
int imageLimit = 20900000; // IMAGE SIZE [20MB]

class UserController extends GetxController with WidgetsBindingObserver {
  final AppSearchController _searchController = Get.put(AppSearchController());
  final cropKeySpec = GlobalKey<CropState>();
  final UserProfileProviderApi userprofileProvider = UserProfileProviderApi();
  final UserLoginProviderApi userLoginProvidergApi = UserLoginProviderApi();
  final PostProviderApi postProviderApi = PostProviderApi();

  final GlobalKey<FormState> createProfileForm = GlobalKey<FormState>();
  final GlobalKey<FormState> editProfileForm = GlobalKey<FormState>();

  final RxBool male = false.obs;
  final RxBool female = false.obs;
  final RxBool isProfile = false.obs;
  final RxBool isProcessI = false.obs;
  final RxString contactNumber = ''.obs;
  final RxString privacyPolicy = ''.obs;
  final RxString cookiePolicy = ''.obs;
  final RxString contractDark = ''.obs;
  final RxString contractLight = ''.obs;
  final RxString termsCondition = ''.obs;
  final RxString contract = ''.obs;
  final RxString skypeId = ''.obs;
  final RxString telegramId = ''.obs;
  final RxString email = ''.obs;
  final RxString minimumWithdrawn = '0'.obs;
  final RxString singleStarPrice = '0'.obs;
  final RxInt womanMaxProfile = 0.obs;
  final RxInt manMaxProfile = 0.obs;
  final RxInt defaultGiftCoin = 0.obs;

  final RxString finaldate = ''.obs;
  final RxString countryCode = ''.obs;
  final RxString countryCodeNumber = '+34'.obs;
  final RxString country = ''.obs;
  final RxDouble locationLatitude = 0.0.obs;
  final RxDouble locationLongitude = 0.0.obs;
  final RxBool isProcess = false.obs;
  final RxBool isProcess2 = false.obs;
  final RxBool searchLocation = false.obs;

  final TextEditingController newName = TextEditingController();
  final TextEditingController newDescription = TextEditingController();
  final TextEditingController query = TextEditingController();
  final Rx<TextEditingController> searchLanguageTextController = TextEditingController().obs;
  TextEditingController nameEdit = TextEditingController();
  TextEditingController descriptionEdit = TextEditingController();
  final TextEditingController newQuery = TextEditingController();
  final RxBool blockloading = false.obs;
  final RxString locationName = ''.obs;
  final RxString address = ''.obs;
  final RxBool isNameEdit = false.obs;
  final RxBool isDescriptionEdit = false.obs;
  final RxDouble km = 1000.0.obs;
  final RxList selectedLanguages = [].obs;
  final RxString imageProfile = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSelect = false.obs;
  final RxBool isDateSelect = false.obs;
  final RxBool isNewName = false.obs;
  final RxBool isNewDescription = false.obs;
  DateTime? selectedDate;

  String location = '';

  List<String> newLangList = [];
  List<Map<String, String>> langList = [];
  RxList getAllLanguage = [].obs;
  RxList searchLanguage = [].obs;

  final ImagePicker _picker = ImagePicker();
  XFile? selectedImage;

  Timer? timer;
  PendingDynamicLinkData? initialLink;

  /// update user last online every 1 minute when in app
  void startTimer() {
    timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      updateLastOnline();
      updateLastOnlineProfile();
    });
  }

  void stopTimer() async {
    if (timer != null) {
      timer!.cancel();
    }
  }

  // // make online user
  // Future<void> onlineUser() async {
  //   Future.delayed(const Duration(seconds: 1));
  //   if (StorageService.getBox.read('ObjectId') != null) {
  //     final Map<String, dynamic> params = <String, dynamic>{
  //       'userId': StorageService.getBox.read('ObjectId'),
  //       'local': StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode,
  //     };
  //     final ParseCloudFunction getCurrentTime = ParseCloudFunction('onlineUser');
  //     final ParseResponse pr = await getCurrentTime.execute(parameters: params);
  //     if (kDebugMode) {
  //       print('Hello response online ${pr.result}');
  //     }
  //   }
  // }
  //
  // // make offline user
  // Future<void> offlineUser() async {
  //   Future.delayed(const Duration(seconds: 1));
  //   if (StorageService.getBox.read('ObjectId') != null) {
  //     final Map<String, dynamic> params = <String, dynamic>{
  //       'userId': StorageService.getBox.read('ObjectId'),
  //       'local': StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode,
  //     };
  //     final ParseCloudFunction getCurrentTime = ParseCloudFunction('offlineUser');
  //     final ParseResponse pr = await getCurrentTime.execute(parameters: params);
  //     if (kDebugMode) {
  //       print('Hello response offline ${pr.result}');
  //     }
  //   }
  // }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (kDebugMode) {
      print("App AppLifecycleState is ${state.name}");
    }
    if (state == AppLifecycleState.resumed) {
      await onlineUser();
      await updateLastOnlineProfile();
    } else {
      await offlineUser();
      await updateLastOnlineProfile();
    }
  }

  Future<void> imgFromGallery() async {
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50).then((value) {
      isSelect.value = true;
      if (value != null) {
        selectedImage = value;
        Get.to(() => SquareCropScreen(file: File(value.path)))!.then((value) {
          isLoading.value = false;
          isSelect.value = true;
        });
      }
      isSelect.value = false;
    });
  }

  Future<void> countryCodeFinder() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      Get.to(() => const PermissionScreen());
    } else {
      getCurrentPosition().then((value) async {
        final List<Placemark> placemarks = await placemarkFromCoordinates(value.latitude, value.longitude);
        final Placemark place = placemarks[0];
        countryCode.value = place.isoCountryCode!;
        country.value = place.country!;
        final response = await rootBundle.loadString('assets/all_country_phones.json');
        final data = await json.decode(response);
        for (var i = 0; i < data.length; i++) {
          if (data[i]['code'] == countryCode.value) {
            countryCodeNumber.value = data[i]['dial_code'];
          }
        }
      });
    }
    update();
  }

  Future<Position> getCurrentPosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  void getGlobalData() async {
    final ApiResponse lang = await LanguageProviderApi().getAll();
    langList.clear();
    for (var element in lang.results ?? []) {
      langList.add({'ObjectId': element['objectId'], 'title': element['title'], 'image': element['Image'].url});
    }
  }

  @override
  Future<void> onInit() async {
    FirebaseDynamicLinks.instance.getInitialLink().then((value) {
      initialLink = value;
    });
    getGlobalData();
    final QueryBuilder<ParseObject> queryInfo = QueryBuilder<ParseObject>(ParseObject('AppInfo'));
    final ParseResponse apiResponse = await queryInfo.query();
    email.value = apiResponse.results![0]['Email'];
    contactNumber.value = apiResponse.results![0]['ContactNumber'];
    skypeId.value = apiResponse.results![0]['Skype'] ?? '';
    telegramId.value = apiResponse.results![0]['Telegram'] ?? '';
    privacyPolicy.value = apiResponse.results![0]['PrivecyPolicy'];
    cookiePolicy.value = apiResponse.results![0]['CookiePolicy'];
    contractDark.value = apiResponse.results![0]['Contract_dark'];
    contractLight.value = apiResponse.results![0]['Contract_light'];
    termsCondition.value = apiResponse.results![0]['TermsCondition'];
    contract.value = apiResponse.results![0]['Contract'];
    minimumWithdrawn.value = (apiResponse.results![0]['Minimun_withdrawn'] ?? '0').toString();
    singleStarPrice.value = (apiResponse.results![0]['single_star_price'] ?? '0').toString();
    manMaxProfile.value = apiResponse.results![0]['MenMaxProfile'];
    womanMaxProfile.value = apiResponse.results![0]['WomenMaxProfile'];
    defaultGiftCoin.value = apiResponse.results![0]['DefaultGiftCoin'];
    iosCallApiLink.value = apiResponse.results![0]['IosCallApi'];

    ipApiUrl = apiResponse.results![0]['IpApi'];
    // start audio call recoding api by antonio ---> ['VozipRecordApi']
    vozipRecordApi = apiResponse.results![0]['VozipRecordApi'];
    endNumber = apiResponse.results![0]['new_profile_end_number'];
    startNumber = apiResponse.results![0]['new_profile_start_number'];
    recentlyActivatedNumber = apiResponse.results![0]['recently_activated_hour'];

    // SHOW DIALOG EVERY [ReviewTime] MINUTE TO USER GIVE REVIEW
    reviewTime = apiResponse.results![0]['ReviewTime'] ?? 5;

    // FAKE USER CAN DELETE OWN POST WHEN [EnableDeletePhoto] true
    enableDeletePhoto.value = apiResponse.results![0]['EnableDeletePhoto'] ?? false;

    // FAKE USER CAN'T UPLOAD VIDEO WHEN [UploadVideoInf] false
    uploadVideoInf.value = apiResponse.results![0]['UploadVideoInf'] ?? false;

    // USER BLOCKED WHEN CREATE MORE THEN ONE ACCOUNT WHEN [BlockByIP] TRUE
    blockByIP.value = apiResponse.results![0]['BlockByIP'] ?? true;

    // We have show TokTok deactivate days
    tokTokDeactiveDays = (apiResponse.results![0]['TokTokDeactiveDays'] ?? 30);

    // We have shown you the last ['ChatLimit'] messages from Chat and HeartMessage
    chatLimit = (apiResponse.results![0]['ChatLimit'] ?? 200);
    // In all the DinDon lists we will only show the last ['HistoryLimit'] records
    historyLimit = (apiResponse.results![0]['HistoryLimit'] ?? 100);
    // user will be able to download their DinDon history of each thing for ['HistoryStars'] stars
    historyStars = (apiResponse.results![0]['HistoryStars'] ?? 20);
    // You will only be able to display ['TokTokImageLimit'] photos on the TikTok screen
    tokTokImageLimit = (apiResponse.results![0]['TokTokImageLimit'] ?? 3);
    // You will only be able to display ['TokTokVideoLimit'] videos on the TikTok screen
    tokTokVideoLimit = (apiResponse.results![0]['TokTokVideoLimit'] ?? 5);
    // Your client ID and client secret obtained from Google Cloud Console ['AccountJson']
    // create new [https://console.firebase.google.com/project/eypop-c3e1d/settings/serviceaccounts/adminsdk] ---> [Generate new private key] ---> ['AccountJson']
    accountJson = apiResponse.results![0]['AccountJson'] ?? {};
    newAppVersion = int.parse(Platform.isAndroid ? apiResponse.results![0]['NewVersionAndroid'] : apiResponse.results![0]['NewVersionIos']);
    getAllBlockIp();

    isProcess2.value = false;
    isProcess.value = false;

    newName.text = '';
    newDescription.text = '';
    locationName.value = '';
    newLangList.clear();

    WidgetsBinding.instance.addObserver(this);

    print('User DefaultProfile ******** ${StorageService.getBox.read('DefaultProfile')}');
    startTimer();
    super.onInit();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  ///GET BLOCK USER IP BY ADMIN
  Future<void> getAllBlockIp() async {
    blockIpAddress.clear();
    blockDeviceId.clear();
    final QueryBuilder<ParseObject> queryIpBlock = QueryBuilder<ParseObject>(ParseObject('BlockIpAddress'));
    final count = await queryIpBlock.count();
    queryIpBlock.setLimit(count.count);
    final ParseResponse apiResponse = await queryIpBlock.query();
    for (final ele in apiResponse.results ?? []) {
      blockIpAddress.addAll(ele['IpAddress'] ?? []);
      blockDeviceId.addAll(ele['DeviceId'] ?? []);
    }
    final Set uniqueIPAddresses = blockIpAddress.toSet();
    final Set uniqueDeviceId = blockDeviceId.toSet();
    blockIpAddress = uniqueIPAddresses.toList();
    blockDeviceId = uniqueDeviceId.toList();
  }

  Future<void> editProfile({required UserLogin loginUserModal, required ProfilePage userProfile}) async {
    try {
      isProcess2.value = true;
      if (editProfileForm.currentState!.validate()) {
        final ProfilePage userprofileModel = ProfilePage();
        final UserLogin userLogin = UserLogin();
        userprofileModel.language = selectedLanguages;
        userprofileModel.name = nameEdit.text;
        userprofileModel.description = descriptionEdit.text;
        if (imageProfile.value.isNotEmpty) {
          final File file = renameFile(file: File(imageProfile.value), name: "image", extension: 'jpg');
          final ParseFile parseFile = ParseFile(file);
          userprofileModel.imgProfile = parseFile;
          final ApiResponse? checkPost = await postProviderApi.getById(userProfile['DefaultImg']?['objectId'] ?? '');
          if (checkPost != null) {
            final UserPost userPost = UserPost();
            userPost.objectId = userProfile['DefaultImg']['objectId'];
            userPost.imgPost = parseFile;
            userPost.type = "FREE";
            userPost.status = true;
            final ApiResponse imageResponse = await postProviderApi.update(userPost);
            userprofileModel.defaultImgUrl = imageResponse.result['Post'].url;
          } else {
            final UserPost userPost = UserPost();
            userPost.imgPost = parseFile;
            userPost.type = "FREE";
            userPost.status = true;
            userPost.accountType = loginUserModal['AccountType'];
            userPost.userId = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
            userPost.profileId = ProfilePage()..objectId = userProfile['objectId'];
            final ApiResponse imageResponse = await postProviderApi.add(userPost);
            userprofileModel.defaultImgUrl = imageResponse.result['Post'].url;
            userprofileModel.defaultImg = UserPost()..objectId = imageResponse.result['objectId'];
            StorageService.getBox.write('DefaultImgObjectId', imageResponse.result['objectId']);
          }
        }
        userprofileModel.userId = UserLogin()..objectId = loginUserModal.objectId;
        userprofileModel.objectId = StorageService.getBox.read('DefaultProfile');
        if (countryCode.value.isNotEmpty) {
          userprofileModel.countryCode = countryCode.value;
        }
        if (locationLatitude.value != 0.0 && locationLongitude.value != 0.0) {
          userprofileModel.locationGeoPoint = ParseGeoPoint(latitude: locationLatitude.value, longitude: locationLongitude.value);
        }
        userprofileModel.locationRadius = km.value.toString();
        userprofileModel.locationName = locationName.value;
        userprofileModel.reachProfile = '0-0';

        userLogin.objectId = StorageService.getBox.read('ObjectId');
        userLogin.locationName = locationName.value;
        if (locationLatitude.value != 0.0 && locationLongitude.value != 0.0) {
          userLogin.locationGeoPoint = ParseGeoPoint(latitude: locationLatitude.value, longitude: locationLongitude.value);
        }
        userLogin.locationRadius = km.value.toString();
        userprofileModel.imgStatus = true;
        await userLoginProvidergApi.update(userLogin);
        await userprofileProvider.update(userprofileModel);
        isProcess2.value = false;
        await _searchController.getProfileData();
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
        update();
        query.clear();
        _searchController.update();
        Get.back();
      }
    } catch (e) {
      imageProfile.value = '';
      isProcess2.value = false;
    }
  }

  Future<void> validateAndSave({bool? isNewUser}) async {
    try {
      final FormState? form = createProfileForm.currentState;
      if (form!.validate()) {
        final ProfilePage userprofile = ProfilePage();
        userprofile.name = newName.text;
        userprofile.description = newDescription.text;
        File? fileImage;
        if (imageProfile.value.isNotEmpty) {
          fileImage = renameFile(file: File(imageProfile.value), name: "image", extension: 'jpg');
        } else {
          Future<File> getImageFileFromAssets(String path) async => File('${(await getTemporaryDirectory()).path}/$path');
          fileImage = await getImageFileFromAssets('assets/images/profile.jpg');
        }
        userprofile.imgProfile = ParseFile(fileImage);

        final ApiResponse apiResponse = await UserLoginProviderApi().getById(StorageService.getBox.read('ObjectId'));
        userprofile.language = selectedLanguages;
        userprofile.locationName = location;
        userprofile.latitude = locationLatitude.toString();
        userprofile.longitude = locationLongitude.toString();
        userprofile.locationRadius = km.value.toString();
        userprofile.locationGeoPoint = ParseGeoPoint(latitude: locationLatitude.value, longitude: locationLongitude.value);
        userprofile.userId = UserLogin()..objectId = StorageService.getBox.read('ObjectId');

        userprofile.countryCode = countryCode.value;
        userprofile.isBlocked = false;
        userprofile.isDeleted = false;
        userprofile.accountType = apiResponse.result['AccountType'];
        userprofile.gender = StorageService.getBox.read('Gender');
        userprofile.reachProfile = '0-0';
        userprofile.noChats = false;
        userprofile.noVideocalls = false;
        userprofile.noCalls = false;
        userprofile.autoDisconnectionChats = false;
        userprofile.autoDisconnectionVideoCalls = false;
        userprofile.autoDisconnectionCalls = false;
        userprofile.demo = 'Testing';

        final ApiResponse profile = await userprofileProvider.add(userprofile);
        final UserPost userPost = UserPost();

        userPost.imgPost = ParseFile(fileImage);
        userPost.isNude = false;
        userPost.status = true;
        userPost.type = "FREE";
        userPost.userId = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
        userPost.profileId = ProfilePage()..objectId = profile.result['objectId'];
        userPost.accountType = apiResponse.result['AccountType'];

        await postProviderApi.add(userPost).then((value) {
          final ProfilePage userProfile = ProfilePage();
          userProfile.objectId = profile.result['objectId'];
          userProfile.defaultImg = UserPost()..objectId = value.result['objectId'];
          userProfile.defaultImgUrl = value.result["Post"].url;
          userprofileProvider.update(userProfile);
        });

        newName.clear();
        newDescription.clear();
        locationName.value = '';
        newLangList.clear();

        final ApiResponse id = await userLoginProvidergApi.getById(StorageService.getBox.read("ObjectId"));

        if (id.result['DefaultProfile'] == null) {
          final UserLogin userLogin2 = UserLogin();
          userLogin2.objectId = StorageService.getBox.read("ObjectId");

          userLogin2.defaultProfileId = profile.result;
          userLogin2.locationGeoPoint = ParseGeoPoint(latitude: locationLatitude.value, longitude: locationLongitude.value);
          userLogin2.locationRadius = km.value.toString();

          userLogin2.locationName = locationName.value;

          StorageService.getBox.write('DefaultProfile', userLogin2.defaultProfileId.objectId ?? '');
          StorageService.getBox.write('DefaultImgObjectId',
              userLogin2.defaultProfileId['DefaultImg'] == null ? '' : userLogin2.defaultProfileId['DefaultImg']?['objectId'] ?? '');
          StorageService.getBox.write('DefaultProfileImg', profile.result['Imgprofile'].url);
          userLoginProvidergApi.update(userLogin2);
        }

        selectedImage = null;

        /// cloud function (email & notification) (CreateContactBrevo) (template 1,3)
        final ParseCloudFunction function = ParseCloudFunction('CreateContactBrevo');
        final Map<String, dynamic> params = <String, dynamic>{
          'EmailId': apiResponse.result['Email'],
          'First_Name': userprofile.name,
          'Gender': apiResponse.result['Gender'],
          'UserId': StorageService.getBox.read('ObjectId'),
          'isNewUser': isNewUser
        };
        await function.execute(parameters: params);

        if (id.result['DefaultProfile'] == null) {
          Get.offAll(() => BottomScreen());
        } else {
          await _searchController.getProfileData();
          update();
          Get.back();
        }
        isProcess.value = false;
      }
    } catch (e, t) {
      isProcess.value = false;
      if (kDebugMode) {
        print("Try Data validateAndSave Error $e $t");
      }
    }
  }

  void clear() {
    Get.back();
    selectedImage = null;
    isProcess2.value = false;
    isProcess.value = false;
  }

  @override
  void onClose() {
    isProcess2.value = false;
    isProcess.value = false;
    WidgetsBinding.instance.removeObserver(this);
    stopTimer();
    super.onClose();
  }
}
