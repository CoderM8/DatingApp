import 'dart:io';
import 'package:card_swiper/card_swiper.dart';
import 'package:eypop/Constant/Widgets/bottom_sheet.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/PairNotificationController/pair_notification_controller.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/purchase_nudeimage_api.dart';
import 'package:eypop/back4appservice/purchase_nudevideo_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/models/verticaltab_model/blockuser.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:vocsy_esys_flutter_share/vocsy_esys_flutter_share.dart';

import '../../back4appservice/user_provider/all_notifications/all_notifications.dart';
import '../../back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import '../../back4appservice/user_provider/users/provider_profileuser_api.dart';
import '../../back4appservice/user_provider/vertical_tab/provider_blockuser.dart';
import '../../back4appservice/user_provider/wishes/wish_provider_api.dart';
import '../../models/all_notifications/all_notifications.dart';
import '../../models/new_notification/new_notification_pair.dart';
import '../../models/user_login/user_login.dart';
import '../../models/user_login/user_profile.dart';
import '../../service/local_storage.dart';
import '../search_controller.dart';

final PriceController _priceController = Get.put(PriceController());
final UserController _userController = Get.put(UserController());
final AppSearchController _searchController = Get.put(AppSearchController());

class RefreshController extends GetxController {}

class WishSwiperController extends GetxController with GetTickerProviderStateMixin {
  final SwiperController swiperController = SwiperController();
  PairNotificationController pairController = Get.put(PairNotificationController());
  List<String> wishSwiperObjectIdList = <String>[];
  List<String> wishSwiperProfileIdList = <String>[];
  String local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
  AnimationController? controller;
  final RxList<ParseObject> wishSwiperList = <ParseObject>[].obs;
  final RxInt wishSwiperIndex = 0.obs;
  final RxBool isGlobalSearch = true.obs;
  final RxBool isSharing = false.obs;
  final RxInt loadPage = 0.obs;
  final RxBool isSwiperLoading = false.obs;
  final RxList wishIds = [].obs;
  final RxList myWishes = [].obs;
  List fillWishes = [];
  final RxBool isLoading = false.obs;
  final RxBool isWishSending = false.obs;
  final RxBool isWishRemove = false.obs;
  final RxList<bool> purchaseNude = <bool>[].obs;

  @override
  void onInit() {
    initController();
    super.onInit();
  }

  void initController() async {
    controller = AnimationController(vsync: this);

    controller!.addStatusListener((val) {
      if (val == AnimationStatus.completed) {
        Get.back();
      }
    });
  }

  @override
  void onClose() {
    controller!.dispose();
    super.onClose();
  }

  static const String prefixLink = 'https://eypop.page.link';

  Future<Uri> createDynamicLink(profileid, senderid, path, wishId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: prefixLink,
      link: Uri.parse("$prefixLink/$path?profileid=$profileid&senderid=$senderid&wishId=$wishId"),
      androidParameters: const AndroidParameters(packageName: 'com.actuajeriko.eypop'),
      iosParameters: const IOSParameters(appStoreId: "1628570550", bundleId: 'com.actuajeriko.eypop'),
    );
    final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters, shortLinkType: ShortDynamicLinkType.short);

    return dynamicLink.shortUrl;
  }

  Future<void> share(imageUrl, userName, description, profileId, senderId, wishId) async {
    isSharing.value = true;
    try {
      Uint8List? list;
      List request = [];
      if (imageUrl != 'EMPTY') {
        request = await Future.wait([HttpClient().getUrl(Uri.parse(imageUrl)), createDynamicLink(profileId, senderId, 'Wish', wishId)]);
        HttpClientResponse response = await request[0].close();
        list = await consolidateHttpClientResponseBytes(response);
      }
      await VocsyShare.file('EYPOP', 'eypop.jpg', list!, 'image/jpg', text: '$userName\n$description \n${request[1]}');
      isSharing.value = false;
    } catch (e) {
      isSharing.value = false;
      if (kDebugMode) {
        print('Hello share error $e');
      }
    }
  }

  Future<void> getMyWishes() async {
    myWishes.clear();
    final ApiResponse? apiResponse = await PairNotificationProviderApi().getUsersAllWish();
    if (apiResponse != null) {
      for (ParseObject element in apiResponse.results ?? []) {
        myWishes.add(element);
      }
    }
  }

  Future<bool> getSwiperData() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('Hello Wish Loading Start.... Page: $loadPage');
    }
    List<String> ids = [];
    await UserLoginProviderApi().blockId(StorageService.getBox.read('DefaultProfile') ?? '').then((blockResponse) {
      if (blockResponse != null) {
        for (final element in blockResponse.results ?? []) {
          if (!ids.contains(element['ToProfile']['objectId'])) {
            ids.add(element['ToProfile']['objectId']);
          }
        }
      }
    });

    if (wishSwiperList.isEmpty && loadPage.value > 30) {
      wishIds.clear();
      StorageService.wishBox.clear();
    }

    for (var element in wishIds) {
      if (element['selfProfileId'] == StorageService.getBox.read('DefaultProfile')) {
        if (isGlobalSearch.value) {
          if (!ids.contains(element['id'])) {
            ids.add(element['id']);
          }
        }
      }
    }
    for (var element in pairController.meBlockedUserProfile) {
      if (!ids.contains(element)) {
        ids.add(element);
      }
    }
    final Set<String> uniqueId = ids.toSet(); // make list sort as unique remove repeat id
    ids = uniqueId.toList();
    final ApiResponse? apiRes = await WishesApi().getWishesForSwiper(loadPage.value, ids,!isGlobalSearch.value);
    if (apiRes != null) {
      try {
        final List results = apiRes.results ?? [];
        results.shuffle();
        for (final ParseObject wishModel in results) {
          await addWishPostData(wishModel);
          if(!seenWishIds.contains(wishModel['objectId'])){
              seenWishIds.add(wishModel['objectId']);
          }
        }
        // if (kDebugMode) {
          print('Hello Wish Loading Finish Total WishPost: ${wishSwiperList.length}');
        // }
      } catch (e) {
        if (kDebugMode) {
          print('Hello Wish getSwiperData ERROR $e');
        }
        getSwiperData();
      }
    } else {
      isSwiperLoading.value = false;
      isLoading.value = false;
      if (!isGlobalSearch.value) {
        return true;
      }
      return false;
    }

    loadPage.value += 10;
    isSwiperLoading.value = false;
    isLoading.value = false;
    return true;
  }

  Future<void> addWishPostData(ParseObject wishModel) async {
    if (!wishSwiperObjectIdList.contains(wishModel.objectId!) /*&& !wishSwiperProfileIdList.contains(wishModel['Profile']['objectId'])*/) {
      if (wishModel['Wish_List'].length == 3) {

        //DateTime lastOnline = wishModel['User']['lastOnline'] ?? DateTime.now();

        final bool isWishAdd = (wishModel['Profile']['isDeleted'] ?? false) == false &&
            (wishModel['Profile']['IsBlocked'] ?? false) == false &&
            (wishModel['User']['isDeleted'] ?? false) == false &&
            (wishModel['User']['IsBlocked'] ?? false) == false;
        if (isWishAdd) {
          wishSwiperList.add(wishModel);
          wishSwiperObjectIdList.add(wishModel.objectId!);
          // wishSwiperProfileIdList.add(wishModel['Profile']['objectId']);
          if (wishModel['Type'] == 'Image') {
            ApiResponse? response =
                await PurchaseNudeImageProviderApi().getById(wishModel['Profile']['objectId'], StorageService.getBox.read('DefaultProfile'));
            if (response != null) {
              if (wishModel['Img_Post'] != null && response.results!.contains(wishModel['Img_Post']['objectId'])) {
                purchaseNude.add(false);
              } else {
                purchaseNude.add(true);
              }
            } else {
              purchaseNude.add(true);
            }
          } else {
            ApiResponse? response =
                await PurchaseNudeVideoProviderApi().getById(wishModel['Profile']['objectId'], StorageService.getBox.read('DefaultProfile'));
            if (response != null) {
              if (wishModel['Video_Post'] != null && response.results!.contains(wishModel['Video_Post']['objectId'])) {
                purchaseNude.add(false);
              } else {
                purchaseNude.add(true);
              }
            } else {
              purchaseNude.add(true);
            }
          }
        }
      }
    }
  }

  void fullFillWish(toUserGender, toProfile, toUser, wishId) async {
    Get.back();
    isWishSending.value = true;
    if (controller == null || controller!.isDismissed || controller!.isCompleted) {
      initController();
    }
    controller!.reset();
    await _priceController.coinService('Wishes', toUserGender, toProfile, toUser, wishId: wishId, catValue: 0).then((value) {
      if (value != null) {
        myWishes.add(value.result);
        fillWishes.add(value.result);
      }
    });
    isWishSending.value = false;
    update();
  }

  void reportBlock(context, {required String toProfileId}) {
    showBottomSheetBlockReport(context, blockOnTap: () async {
      /// block
      _userController.blockloading.value = true;
      BlockUser block = BlockUser();
      block.emailuser = "Block User";
      await UserProfileProviderApi().getById(toProfileId).then((value) async {
        block.toUser = UserLogin()..objectId = value.result['User']['objectId'];

        block.type = "BLOCK";
        block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');

        block.toProfile = ProfilePage()..objectId = toProfileId;

        block.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
        await BlockUSerProviderApi().add(block);
        await PairNotificationProviderApi().getByProfile(StorageService.getBox.read('DefaultProfile'), toProfileId, 'BlocUser').then((val) async {
          PairNotifications pairNotifications = PairNotifications();
          if (val == null) {
            pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
            pairNotifications.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
            pairNotifications.users = [ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'), ProfilePage()..objectId = toProfileId];
            pairNotifications.message = '';
            pairNotifications.notificationType = 'BlocUser';
            pairNotifications.isPurchased = true;
            pairNotifications.isRead = true;
            pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
            pairNotifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];

            await PairNotificationProviderApi().add(pairNotifications);
          } else {
            pairNotifications.objectId = val.result['objectId'];
            pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
            pairNotifications.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
            pairNotifications.users = [ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'), ProfilePage()..objectId = toProfileId];
            pairNotifications.message = '';
            pairNotifications.notificationType = 'BlocUser';
            pairNotifications.isPurchased = true;
            pairNotifications.isRead = true;
            pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
            pairNotifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];
            pairNotifications.deletedUsers = [];
            await PairNotificationProviderApi().update(pairNotifications);
          }
        });
        Notifications notifications = Notifications();
        notifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];
        notifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
        notifications.toProfile = ProfilePage()..objectId = toProfileId;
        notifications.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
        notifications.notificationType = 'BlocUser';
        notifications.isRead = true;
        NotificationsProviderApi().add(notifications);
      });
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
      _searchController.seenKeys.clear();
      pictureX.swiperIndex.value = 0;
      _searchController.page.value = 0;
      wishSwiperList.clear();
      seenWishIds.clear();
      searchRadiusKm.value = 10;
      purchaseNude.clear();
      indexMuroList.clear();
      indexTokTokList.clear();
      wishSwiperObjectIdList.clear();
      wishSwiperProfileIdList.clear();
      // myWishes.clear();
      wishSwiperIndex.value = 0;
      loadPage.value = 0;
      _searchController.update();
      Get.back();
    }, informOnTap: (reason, moreReason) {
      /// just inform
      BlockUser block = BlockUser();
      block.emailuser = reason;
      block['Reason'] = 'Just to Inform';
      block['Description'] = moreReason;
      block.type = "REPORT";
      UserProfileProviderApi().getById(toProfileId).then((value) async {
        block.toUser = UserLogin()..objectId = value.result['User']['objectId'];
        block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
        block.toProfile = ProfilePage()..objectId = toProfileId;
        block.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
        BlockUSerProviderApi().add(block);
      });
      for (var element in reportData) {
        element.isSelected = false;
      }
      Get.back();
      Get.back();
      Get.back();
    }, bothOnTap: (reason, moreReason) async {
      /// report and block
      _userController.blockloading.value = true;
      Get.back();
      Get.back();
      Get.back();
      BlockUser block = BlockUser();

      /// BLOCK ENTRY
      block.emailuser = reason;
      block['Reason'] = "REPORT AND BLOCK";
      block['Description'] = moreReason;
      Get.back();
      await UserProfileProviderApi().getById(toProfileId).then((value) async {
        block.toUser = UserLogin()..objectId = value.result['User']['objectId'];

        block.type = "BLOCK";
        block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');

        block.toProfile = ProfilePage()..objectId = toProfileId;

        block.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
        await BlockUSerProviderApi().add(block);
        await PairNotificationProviderApi().getByProfile(StorageService.getBox.read('DefaultProfile'), toProfileId, 'BlocUser').then((val) async {
          PairNotifications pairNotifications = PairNotifications();
          if (val == null) {
            pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
            pairNotifications.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
            pairNotifications.users = [ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'), ProfilePage()..objectId = toProfileId];
            pairNotifications.message = '';
            pairNotifications.notificationType = 'BlocUser';
            pairNotifications.isPurchased = true;
            pairNotifications.isRead = true;
            pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
            pairNotifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];

            await PairNotificationProviderApi().add(pairNotifications);
          } else {
            pairNotifications.objectId = val.result['objectId'];
            pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
            pairNotifications.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
            pairNotifications.users = [ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile'), ProfilePage()..objectId = toProfileId];
            pairNotifications.message = '';
            pairNotifications.notificationType = 'BlocUser';
            pairNotifications.isPurchased = true;
            pairNotifications.isRead = true;
            pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
            pairNotifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];
            pairNotifications.deletedUsers = [];
            await PairNotificationProviderApi().update(pairNotifications);
          }
        });
        Notifications notifications = Notifications();
        notifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];
        notifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
        notifications.toProfile = ProfilePage()..objectId = toProfileId;
        notifications.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
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
      UserProfileProviderApi().getById(toProfileId).then((value) async {
        report.toUser = UserLogin()..objectId = value.result['User']['objectId'];
        report.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
        report.toProfile = ProfilePage()..objectId = toProfileId;
        report.fromProfile = ProfilePage()..objectId = StorageService.getBox.read('DefaultProfile');
        BlockUSerProviderApi().add(report);
      });
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
      _searchController.seenKeys.clear();
      pictureX.swiperIndex.value = 0;
      _searchController.page.value = 0;
      wishSwiperList.clear();
      seenWishIds.clear();
      searchRadiusKm.value = 10;
      purchaseNude.clear();
      indexMuroList.clear();
      indexTokTokList.clear();
      wishSwiperObjectIdList.clear();
      wishSwiperProfileIdList.clear();
      // myWishes.clear();
      wishSwiperIndex.value = 0;
      loadPage.value = 0;
      _searchController.update();
    });
  }
}
