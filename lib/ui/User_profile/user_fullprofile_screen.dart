import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/Widgets/bottom_sheet.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/post_view.dart';
import 'package:eypop/Controllers/PairNotificationController/pair_notification_controller.dart' as pair;
import 'package:eypop/Controllers/notification_controller.dart';
import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/purchase_nudeimage_api.dart';
import 'package:eypop/back4appservice/purchase_nudevideo_api.dart';
import 'package:eypop/service/calling.dart';
import 'package:eypop/ui/User_profile/picture_screen.dart';
import 'package:eypop/ui/User_profile/showpicture_screen.dart';
import 'package:eypop/ui/User_profile/showvideo_screen.dart';
import 'package:eypop/ui/store_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Controllers/Picture_Controller/profile_pic_controller.dart';
import '../../Controllers/price_controller.dart';
import '../../Controllers/tab_Controller/conversation_controller.dart';
import '../../Controllers/tab_Controller/usertabbar_controller.dart';
import '../../Controllers/translate_controler.dart';
import '../../Controllers/user_controller.dart';
import '../../back4appservice/repositories/Calls/call_provider_api.dart';
import '../../back4appservice/repositories/users/provider_post_video_api.dart';
import '../../back4appservice/user_provider/all_notifications/all_notifications.dart';
import '../../back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import '../../back4appservice/user_provider/users/provider_post_api.dart';
import '../../back4appservice/user_provider/users/provider_profileuser_api.dart';
import '../../back4appservice/user_provider/vertical_tab/provider_blockuser.dart';
import '../../models/all_notifications/all_notifications.dart';
import '../../models/call/calls.dart';
import '../../models/new_notification/new_notification_pair.dart';
import '../../models/user_login/user_login.dart';
import '../../models/user_login/user_profile.dart';
import '../../models/verticaltab_model/blockuser.dart';
import '../../service/local_storage.dart';
import '../bottom_screen.dart';
import '../call/dial_waiting_page.dart';
import '../tab_pages/conversation_screen.dart';

class UserFullProfileScreen extends StatefulWidget {
  const UserFullProfileScreen({
    Key? key,
    required this.toProfileId,
    required this.fromProfileId,
    required this.toUserId,
    this.fromProfileImg,
    this.personal = false,
    this.isNotification = false,
    this.isDindon = false,
    this.visitType = false,
  }) : super(key: key);

  final String fromProfileId, toProfileId;
  final String? fromProfileImg;
  final bool isNotification, visitType, personal;
  final ParseObject toUserId;
  final bool isDindon;

  @override
  State<UserFullProfileScreen> createState() => _UserFullProfileScreenState();
}

class _UserFullProfileScreenState extends State<UserFullProfileScreen> with SingleTickerProviderStateMixin {
  final UserTabController _tabX = Get.put(UserTabController());

  final UserController _userController = Get.put(UserController());

  final PriceController _priceController = Get.put(PriceController());

  final TranslateController _translateController = Get.put(TranslateController());

  final AppSearchController _searchController = Get.put(AppSearchController());

  final pair.PairNotificationController _pairNotificationController = Get.put(pair.PairNotificationController());

  final PictureController pictureX = Get.put(PictureController());

  String name = '';

  String localeFlag = SchedulerBinding.instance.platformDispatcher.locale.countryCode!.toLowerCase();
  TabController? tabController;
  ScrollController? scrollController;

  final Rx<ParseObject> userProfile = ParseObject('').obs;
  final RxBool isLoading = false.obs;
  final RxBool isShowConnectCallButton = false.obs;

  scrollListener() {}

  @override
  void initState() {
    visitsData();
    getUserProfile();
    scrollController = ScrollController();
    scrollController!.addListener(scrollListener);
    tabController = TabController(length: 2, vsync: this);
    tabController!.index = 0;
    tabController!.addListener(_smoothScrollToTop);
    super.initState();
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  Future<void> getUserProfile() async {
    isLoading.value = true;
    await UserProfileProviderApi().getById(widget.toProfileId).then((value) {
      if (value.result != null) {
        userProfile.value = value.result;
      } else {
        if (value.results != null) {
          userProfile.value = value.results![0];
        }
      }
    });
    isLoading.value = false;
  }

  _smoothScrollToTop() {
    scrollController!.animateTo(0, duration: const Duration(microseconds: 300), curve: Curves.ease);
    _tabX.selectedIndex.value = tabController!.index;
  }

  Future<void> visitsData() async {
    final value = await parseCloudInteraction(
      fromUserId: StorageService.getBox.read('ObjectId'),
      fromProfileId: StorageService.getBox.read('DefaultProfile'),
      toUserId: widget.toUserId.objectId,
      toProfileId: widget.toProfileId,
      type: 'sendVisits',
    );
    if (value['success'] == true) {
      if (widget.toUserId['VisitNotification']) {
        NotificationController().parseCloudNotification(widget.toUserId['objectId'], 'Visit Your profile', widget.toProfileId, widget.fromProfileId);
      }
    }
  }

  _willPopCallback(canPop) async {
    if (!canPop) {
      if (widget.visitType == true) {
        Get.offAll(() => BottomScreen());
      } else {
        if (widget.isNotification) {
          Get.back();
        }
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: _willPopCallback,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Styles.regular('eypop', ff: "HR", fs: 35.sp, c: ConstColors.themeColor),
          elevation: 0.3,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: Back(
            svg: 'assets/Icons/close.svg',
            color: ConstColors.themeColor,
            height: 28.w,
            width: 28.w,
            padding: EdgeInsets.only(top: 10.h),
            onTap: () {
              if (widget.visitType == true) {
                Get.offAll(() => BottomScreen());
              } else {
                Get.back();
                if (widget.isNotification) {
                  Get.back();
                }
              }
            },
          ),
          actions: [
            Row(
              children: [
                Obx(() {
                  _translateController.translate.value;
                  return GestureDetector(
                    onTap: () {
                      _translateController.translate.value = !_translateController.translate.value;
                    },
                    child: SvgView(
                      _translateController.translate.value ? 'assets/Icons/chatTranslate.svg' : 'assets/Icons/chatTranslate_off.svg',
                      fit: BoxFit.scaleDown,
                      height: 29.w,
                      width: 29.w,
                      key: ValueKey<bool>(_translateController.translate.value),
                    ),
                  );
                }),
                SizedBox(width: 17.w),
                GestureDetector(
                  onTap: () {
                    showBottomSheetBlockReport(context, blockOnTap: () async {
                      /// block
                      _userController.blockloading.value = true;
                      BlockUser block = BlockUser();
                      block.emailuser = "Block User";
                      block.toUser = UserLogin()..objectId = widget.toUserId['objectId'];

                      block.type = "BLOCK";
                      block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');

                      block.toProfile = ProfilePage()..objectId = widget.toProfileId;

                      block.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                      await BlockUSerProviderApi().add(block);
                      await PairNotificationProviderApi().getByProfile(widget.fromProfileId, widget.toProfileId, 'BlocUser').then((val) async {
                        PairNotifications pairNotifications = PairNotifications();
                        if (val == null) {
                          pairNotifications.toProfile = ProfilePage()..objectId = widget.toProfileId;
                          pairNotifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                          pairNotifications.users = [ProfilePage()..objectId = widget.fromProfileId, ProfilePage()..objectId = widget.toProfileId];
                          pairNotifications.message = '';
                          pairNotifications.notificationType = 'BlocUser';
                          pairNotifications.isPurchased = true;
                          pairNotifications.isRead = true;
                          pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                          pairNotifications.toUser = UserLogin()..objectId = widget.toUserId['objectId'];

                          await PairNotificationProviderApi().add(pairNotifications);
                        } else {
                          pairNotifications.objectId = val.result['objectId'];
                          pairNotifications.toProfile = ProfilePage()..objectId = widget.toProfileId;
                          pairNotifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                          pairNotifications.users = [ProfilePage()..objectId = widget.fromProfileId, ProfilePage()..objectId = widget.toProfileId];
                          pairNotifications.message = '';
                          pairNotifications.notificationType = 'BlocUser';
                          pairNotifications.isPurchased = true;
                          pairNotifications.isRead = true;
                          pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                          pairNotifications.toUser = UserLogin()..objectId = widget.toUserId['objectId'];
                          pairNotifications.deletedUsers = [];
                          await PairNotificationProviderApi().update(pairNotifications);
                        }
                      });
                      Notifications notifications = Notifications();
                      notifications.toUser = UserLogin()..objectId = widget.toUserId['objectId'];
                      notifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                      notifications.toProfile = ProfilePage()..objectId = widget.toProfileId;
                      notifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                      notifications.notificationType = 'BlocUser';
                      notifications.isRead = true;

                      NotificationsProviderApi().add(notifications);

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
                      indexMuroList.clear();
                      _searchController.seenKeys.clear();
                      pictureX.swiperIndex.value = 0;
                      _searchController.page.value = 0;
                      _searchController.update();
                      Get.back();
                      Get.back();
                    }, informOnTap: (reason, moreReason) async {
                      /// just inform
                      _userController.blockloading.value = true;
                      final BlockUser block = BlockUser();

                      block.emailuser = reason;
                      block['Reason'] = 'Just to Inform';
                      block['Description'] = moreReason;
                      block.type = "REPORT";

                      block.toUser = UserLogin()..objectId = widget.toUserId['objectId'];

                      block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');

                      block.toProfile = ProfilePage()..objectId = widget.toProfileId;

                      block.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                      await BlockUSerProviderApi().add(block);

                      for (var element in reportData) {
                        element.isSelected = false;
                      }
                      _userController.blockloading.value = false;
                      Get.back();
                      Get.back();
                      Get.back();
                    }, bothOnTap: (reason, moreReason) async {
                      /// report and block
                      _userController.blockloading.value = true;

                      Get.back();
                      Get.back();
                      Get.back();
                      Get.back();
                      BlockUser block = BlockUser();

                      /// BLOCK ENTRY
                      block.emailuser = "Block User";
                      block.toUser = UserLogin()..objectId = widget.toUserId['objectId'];

                      block.emailuser = reason;
                      block['Reason'] = 'REPORT AND BLOCK';
                      block['Description'] = moreReason;
                      block.type = "BLOCK";
                      block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');

                      block.toProfile = ProfilePage()..objectId = widget.toProfileId;

                      block.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                      await BlockUSerProviderApi().add(block);
                      await PairNotificationProviderApi().getByProfile(widget.fromProfileId, widget.toProfileId, 'BlocUser').then((val) async {
                        final PairNotifications pairNotifications = PairNotifications();
                        if (val == null) {
                          pairNotifications.toProfile = ProfilePage()..objectId = widget.toProfileId;
                          pairNotifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                          pairNotifications.users = [ProfilePage()..objectId = widget.fromProfileId, ProfilePage()..objectId = widget.toProfileId];
                          pairNotifications.message = '';
                          pairNotifications.notificationType = 'BlocUser';
                          pairNotifications.isPurchased = true;
                          pairNotifications.isRead = true;
                          pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                          pairNotifications.toUser = UserLogin()..objectId = widget.toUserId['objectId'];

                          await PairNotificationProviderApi().add(pairNotifications);
                        } else {
                          pairNotifications.objectId = val.result['objectId'];
                          pairNotifications.toProfile = ProfilePage()..objectId = widget.toProfileId;
                          pairNotifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                          pairNotifications.users = [ProfilePage()..objectId = widget.fromProfileId, ProfilePage()..objectId = widget.toProfileId];
                          pairNotifications.message = '';
                          pairNotifications.notificationType = 'BlocUser';
                          pairNotifications.isPurchased = true;
                          pairNotifications.isRead = true;
                          pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                          pairNotifications.toUser = UserLogin()..objectId = widget.toUserId['objectId'];
                          pairNotifications.deletedUsers = [];
                          await PairNotificationProviderApi().update(pairNotifications);
                        }
                      });
                      Notifications notifications = Notifications();
                      notifications.toUser = UserLogin()..objectId = widget.toUserId['objectId'];
                      notifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                      notifications.toProfile = ProfilePage()..objectId = widget.toProfileId;
                      notifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                      notifications.notificationType = 'BlocUser';
                      notifications.isRead = true;

                      NotificationsProviderApi().add(notifications);

                      /// Report ENTRY
                      final BlockUser report = BlockUser();
                      report.emailuser = reason;
                      report['Reason'] = 'Just to Inform';
                      report['Description'] = moreReason;
                      report.type = "REPORT";
                      report.toUser = UserLogin()..objectId = widget.toUserId['objectId'];
                      report.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                      report.toProfile = ProfilePage()..objectId = widget.toProfileId;
                      report.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                      await BlockUSerProviderApi().add(report);

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
                      indexMuroList.clear();
                      _searchController.seenKeys.clear();
                      pictureX.swiperIndex.value = 0;
                      _searchController.page.value = 0;
                      _searchController.update();
                    });
                  },
                  child: const SvgView('assets/Icons/report.svg'),
                ),
                SizedBox(width: 17.w),
              ],
            )
          ],
        ),
        bottomNavigationBar: Obx(() {
          if (userProfile.value.objectId == null) {
            return const SizedBox.shrink(key: ValueKey(0));
          }
          return Container(
            key: const ValueKey(1),
            height: 118.h,
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h, bottom: 10.h),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r)), color: ConstColors.themeColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // CHAT
                Options(
                  onTap: (isBusy, online) {
                    if (widget.personal) {
                      Get.back();
                    } else {
                      bool onlineStatus;
                      // DateTime lastOnlineTime = snapshot.data!.results![0]['User'].get<DateTime>('lastOnline');

                      // print('hello HasLoggedIn ----*** ${userProfile.value['User']['HasLoggedIn']}');
                      // print('hello NoChats ----*** ${userProfile.value['NoChats']}');

                      if ((userProfile.value['NoChats'] ?? false) == false && (userProfile.value['User']['HasLoggedIn'] ?? true == true)) {
                        onlineStatus = true;
                        print('online status True ======');
                      } else {
                        onlineStatus = false;
                        print('online status False ======');
                      }
                      StorageService.getBox.write('chattablename', 'Chat_Message');

                      StorageService.getBox
                          .write('msgFromProfileId', widget.isDindon ? StorageService.getBox.read('DefaultProfile') : widget.fromProfileId);
                      StorageService.getBox.write('msgToProfileId', widget.toProfileId);

                      StorageService.getBox.save();

                      Get.delete<ConversationController>();

                      /// other user block me and me block other user
                      final bool isBlockProfile = (_pairNotificationController.meBlocked
                              .toString()
                              .contains(widget.isDindon ? StorageService.getBox.read('DefaultProfile') : widget.fromProfileId) &&
                          _pairNotificationController.meBlocked.toString().contains(widget.toProfileId)); // update block

                      Get.to(
                        () => ConversationScreen(
                          fromUserDeleted: false,
                          toUserDeleted:
                              ((userProfile.value['isDeleted'] ?? false) || (userProfile.value['User']['isDeleted'] ?? false) || isBlockProfile),
                          personal: true,
                          toUser: userProfile.value['User'],
                          onlineStatus: onlineStatus,
                          tableName: 'Chat_Message',
                          fromUserImg: widget.isDindon
                              ? StorageService.getBox.read('DefaultProfileImg')
                              : widget.fromProfileImg ?? StorageService.getBox.read('DefaultProfileImg'),
                          toProfileName: userProfile.value['Name'].toString(),
                          toProfileImg: userProfile.value['Imgprofile'].url.toString(),
                          fromProfileId: widget.isDindon ? StorageService.getBox.read('DefaultProfile') : widget.fromProfileId,
                          toProfileId: widget.toProfileId,
                          toUserGender: userProfile.value['User']['Gender'],
                          toUserId: userProfile.value['User']['objectId'],
                        ),
                      );
                    }
                  },
                  svg: 'assets/Icons/chat.svg',
                  enable: true,
                  online: ((userProfile.value['NoChats'] ?? false == false) && (userProfile.value['User']['HasLoggedIn'] ?? true == true)),
                  title: 'chat',
                  userId: userProfile.value["User"]['objectId'],
                  profileId: userProfile.value['objectId'],
                ),
                // AUDIO CALL
                Options(
                  onTap: (isBusy, isOnline) async {
                    showBottomSheetAudioVideoCall(
                      context,
                      title: 'call'.tr,
                      callTitle: "make_call".tr,
                      isOnline: isOnline,
                      description: 'call_description'.tr,
                      askPermissionOnTap: () {
                        if (widget.personal) {
                          Get.back();
                          Get.back();
                          _priceController.chat.text = 'I_can_call_you_now'.tr;
                        } else {
                          Get.back();
                          bool onlineStatus;
                          if ((userProfile.value['NoChats'] ?? false) == false && (userProfile.value['User']['HasLoggedIn'] ?? true == true)) {
                            onlineStatus = true;
                            print('online status True ======');
                          } else {
                            onlineStatus = false;
                            print('online status False ======');
                          }
                          // if (userProfile.value['NoChats'] ?? false) {
                          //   onlineStatus = false;
                          // } else {
                          //   onlineStatus = true;
                          // }
                          StorageService.getBox.write('chattablename', 'Chat_Message');
                          StorageService.getBox.write('msgFromProfileId', widget.fromProfileId);
                          StorageService.getBox.write('msgToProfileId', widget.toProfileId);
                          StorageService.getBox.save();

                          // DateTime lastOnlineTime = snapshot.data!.results![0]['User'].get<DateTime>('lastOnline');

                          Get.delete<ConversationController>();

                          /// other user block me and me block other user
                          final bool isBlockProfile = (_pairNotificationController.meBlocked.toString().contains(widget.fromProfileId) &&
                              _pairNotificationController.meBlocked.toString().contains(widget.toProfileId)); // update block
                          _priceController.chat.text = 'I_can_call_you_now'.tr;
                          Get.to(
                            () => ConversationScreen(
                              fromUserDeleted: false,
                              toUserDeleted:
                                  ((userProfile.value['isDeleted'] ?? false) || (userProfile.value['User']['isDeleted'] ?? false) || isBlockProfile),
                              personal: true,
                              toUser: userProfile.value['User'],
                              onlineStatus: onlineStatus,
                              tableName: 'Chat_Message',
                              fromUserImg: widget.fromProfileImg ?? StorageService.getBox.read('DefaultProfileImg'),
                              toProfileName: userProfile.value['Name'].toString(),
                              toProfileImg: userProfile.value['Imgprofile'].url.toString(),
                              fromProfileId: widget.fromProfileId,
                              toProfileId: widget.toProfileId,
                              toUserGender: userProfile.value['User']['Gender'],
                              toUserId: userProfile.value['User']['objectId'],
                            ),
                          );
                        }
                      },
                      callOnTap: () async {
                        Get.back();
                        await checkUserPermission();
                        final PermissionStatus status = await Permission.microphone.status;
                        if (status.isGranted) {
                          isShowConnectCallButton.value = true;
                          if (_priceController.isPurchase.value == false) {
                            _priceController.isPurchase.value = true;
                            if (StorageService.getBox.read('Gender') == 'female') {
                              final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                              final String fromUserId = StorageService.getBox.read('ObjectId');
                              final String toUserId = userProfile.value['User']['objectId'];
                              final String channelName = '${fromUserId}_$toUserId';
                              final PairNotifications pairNotifications = PairNotifications();
                              pairNotifications.toProfile = ProfilePage()..objectId = userProfile.value['objectId'];
                              pairNotifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                              pairNotifications.users = [
                                ProfilePage()..objectId = widget.fromProfileId,
                                ProfilePage()..objectId = userProfile.value['objectId']
                              ];
                              pairNotifications.message = '';
                              pairNotifications.notificationType = 'Call';
                              pairNotifications.isPurchased = true;
                              pairNotifications.isRead = true;
                              pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                              pairNotifications.toUser = UserLogin()..objectId = toUserId;
                              final ApiResponse apiResponse = await PairNotificationProviderApi().add(pairNotifications);

                              if (isBusy) {
                                isShowConnectCallButton.value = false;
                                Get.to(() => DialWaitingPage(
                                        img: userProfile.value['Imgprofile'].url,
                                        name: userProfile.value['Name'],
                                        pairNotificationsId: apiResponse.result['objectId']))!
                                    .whenComplete(() {
                                  _priceController.isPurchase.value = false;
                                });
                              } else {
                                final CallModel callModel = CallModel();
                                callModel.reason = 'OffLine';
                                callModel.fromUserId = ProfilePage()..objectId = widget.fromProfileId;
                                callModel.fromUser = UserLogin()..objectId = fromUserId;
                                callModel.toUserID = ProfilePage()..objectId = userProfile.value['objectId'];
                                callModel.toUser = UserLogin()..objectId = toUserId;
                                callModel.accepted = false;
                                callModel.duration = '00:00:00';
                                callModel.status = 0;
                                callModel.isVoice = true;
                                callModel.channelName = channelName;
                                callModel.isCallEnd = false;
                                callModel.callerType = 'Sender';
                                callModel.pairNotification = PairNotifications()..objectId = apiResponse.result['objectId'];
                                final save = await userCallProviderApi.add(callModel);

                                pairNotifications.objectId = apiResponse.result['objectId'];
                                pairNotifications["call"] = CallModel()..objectId = save.result['objectId'];
                                await PairNotificationProviderApi().update(pairNotifications);
                                isShowConnectCallButton.value = false;
                                if (userProfile.value['User']['CallNotification']) {
                                  CallService.makeCall(
                                    userId: userProfile.value['User']['objectId'],
                                    type: "Calling you",
                                    fromProfileId: widget.fromProfileId,
                                    callId: save.result['objectId'],
                                    isVoiceCall: true,
                                  );
                                }
                              }

                              final Notifications notifications = Notifications();
                              notifications.toUser = UserLogin()..objectId = toUserId;
                              notifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                              notifications.toProfile = ProfilePage()..objectId = userProfile.value['objectId'];
                              notifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                              notifications.notificationType = 'Call';
                              notifications.isRead = false;

                              NotificationsProviderApi().add(notifications);
                            } else {
                              if (_priceController.userTotalCoin.value >= _priceController.callPrice.value) {
                                final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                                final String fromUserId = StorageService.getBox.read('ObjectId');
                                final String toUserId = userProfile.value['User']['objectId'];
                                final String channelName = '${fromUserId}_$toUserId';

                                final PairNotifications pairNotifications = PairNotifications();

                                pairNotifications.toProfile = ProfilePage()..objectId = userProfile.value['objectId'];
                                pairNotifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                                pairNotifications.users = [
                                  ProfilePage()..objectId = widget.fromProfileId,
                                  ProfilePage()..objectId = userProfile.value['objectId']
                                ];
                                pairNotifications.message = '';
                                pairNotifications.notificationType = 'Call';
                                pairNotifications.isPurchased = true;
                                pairNotifications.isRead = true;
                                pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                                pairNotifications.toUser = UserLogin()..objectId = toUserId;
                                final ApiResponse apiResponse = await PairNotificationProviderApi().add(pairNotifications);
                                if (isBusy) {
                                  isShowConnectCallButton.value = false;
                                  Get.to(() => DialWaitingPage(
                                          img: userProfile.value['Imgprofile'].url,
                                          name: userProfile.value['Name'],
                                          pairNotificationsId: apiResponse.result['objectId']))!
                                      .whenComplete(() {
                                    _priceController.isPurchase.value = false;
                                  });
                                } else {
                                  final CallModel callModel = CallModel();
                                  callModel.reason = 'OffLine';
                                  callModel.fromUserId = ProfilePage()..objectId = widget.fromProfileId;
                                  callModel.fromUser = UserLogin()..objectId = fromUserId;
                                  callModel.toUserID = ProfilePage()..objectId = userProfile.value['objectId'];
                                  callModel.toUser = UserLogin()..objectId = toUserId;
                                  callModel.accepted = false;
                                  callModel.duration = '00:00:00';
                                  callModel.isVoice = true;
                                  callModel.status = 0;
                                  callModel.channelName = channelName;
                                  callModel.isCallEnd = false;
                                  callModel.callerType = 'Sender';
                                  callModel.pairNotification = PairNotifications()..objectId = apiResponse.result['objectId'];
                                  final save = await userCallProviderApi.add(callModel);
                                  pairNotifications.objectId = apiResponse.result['objectId'];
                                  pairNotifications["call"] = CallModel()..objectId = save.result['objectId'];
                                  await PairNotificationProviderApi().update(pairNotifications);
                                  isShowConnectCallButton.value = false;
                                  if (userProfile.value['User']['CallNotification']) {
                                    CallService.makeCall(
                                      userId: userProfile.value['User']['objectId'],
                                      type: "Calling you",
                                      fromProfileId: widget.fromProfileId,
                                      callId: save.result['objectId'],
                                      isVoiceCall: true,
                                    );
                                  }
                                }
                                final Notifications notifications = Notifications();
                                notifications.toUser = UserLogin()..objectId = toUserId;
                                notifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                                notifications.toProfile = ProfilePage()..objectId = userProfile.value['objectId'];
                                notifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                                notifications.notificationType = 'Call';
                                notifications.isRead = false;

                                NotificationsProviderApi().add(notifications);
                              } else {
                                _priceController.isPurchase.value = false;
                                isShowConnectCallButton.value = false;

                                Get.to(() => StoreScreen());
                              }
                            }
                          }
                        }
                      },
                    );
                  },
                  svg: 'assets/Icons/call.svg',
                  enable: true,
                  online: ((userProfile.value['NoCalls'] ?? false) == false && (userProfile.value['User']['HasLoggedIn'] ?? true == true)),
                  title: 'call',
                  userId: userProfile.value["User"]['objectId'],
                  profileId: userProfile.value['objectId'],
                ),
                // VIDEO CALL
                Options(
                  onTap: (isBusy, isOnline) async {
                    showBottomSheetAudioVideoCall(
                      context,
                      title: 'videocall'.tr,
                      callTitle: "make_videocall".tr,
                      isOnline: isOnline,
                      description: 'videocall_description'.tr,
                      askPermissionOnTap: () {
                        if (widget.personal) {
                          Get.back();
                          Get.back();
                          _priceController.chat.text = 'I_can_call_you_now'.tr;
                        } else {
                          Get.back();
                          bool onlineStatus;

                          if ((userProfile.value['NoChats'] ?? false) == false && (userProfile.value['User']['HasLoggedIn'] ?? true == true)) {
                            onlineStatus = true;
                            print('online status True ======');
                          } else {
                            onlineStatus = false;
                            print('online status False ======');
                          }

                          // if (userProfile.value['NoChats'] ?? false) {
                          //   onlineStatus = false;
                          // } else {
                          //   onlineStatus = true;
                          // }
                          StorageService.getBox.write('chattablename', 'Chat_Message');
                          StorageService.getBox.write('msgFromProfileId', widget.fromProfileId);
                          StorageService.getBox.write('msgToProfileId', widget.toProfileId);
                          StorageService.getBox.save();

                          // DateTime lastOnlineTime = snapshot.data!.results![0]['User'].get<DateTime>('lastOnline');

                          Get.delete<ConversationController>();

                          /// other user block me and me block other user
                          final bool isBlockProfile = (_pairNotificationController.meBlocked.toString().contains(widget.fromProfileId) &&
                              _pairNotificationController.meBlocked.toString().contains(widget.toProfileId)); // update block
                          _priceController.chat.text = 'I_can_call_you_now'.tr;
                          Get.to(
                            () => ConversationScreen(
                              fromUserDeleted: false,
                              toUserDeleted:
                                  ((userProfile.value['isDeleted'] ?? false) || (userProfile.value['User']['isDeleted'] ?? false) || isBlockProfile),
                              personal: true,
                              toUser: userProfile.value['User'],
                              onlineStatus: onlineStatus,
                              tableName: 'Chat_Message',
                              fromUserImg: widget.fromProfileImg ?? StorageService.getBox.read('DefaultProfileImg'),
                              toProfileName: userProfile.value['Name'].toString(),
                              toProfileImg: userProfile.value['Imgprofile'].url.toString(),
                              fromProfileId: widget.fromProfileId,
                              toProfileId: widget.toProfileId,
                              toUserGender: userProfile.value['User']['Gender'],
                              toUserId: userProfile.value['User']['objectId'],
                            ),
                          );
                        }
                      },
                      callOnTap: () async {
                        Get.back();
                        await checkUserPermission(video: true);
                        final PermissionStatus microphone = await Permission.microphone.status;
                        final PermissionStatus camera = await Permission.camera.status;
                        if (microphone.isGranted && camera.isGranted) {
                          if (_priceController.isPurchase.value == false) {
                            isShowConnectCallButton.value = true;
                            _priceController.isPurchase.value = true;
                            if (StorageService.getBox.read('Gender') == 'female') {
                              final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                              final String fromUserId = StorageService.getBox.read('ObjectId');
                              final String toUserId = userProfile.value['User']['objectId'];
                              final String channelName = '${fromUserId}_$toUserId';

                              final PairNotifications pairNotifications = PairNotifications();
                              pairNotifications.toProfile = ProfilePage()..objectId = userProfile.value['objectId'];
                              pairNotifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                              pairNotifications.users = [
                                ProfilePage()..objectId = widget.fromProfileId,
                                ProfilePage()..objectId = userProfile.value['objectId']
                              ];
                              pairNotifications.message = '';
                              pairNotifications.notificationType = 'VideoCall';
                              pairNotifications.isPurchased = true;
                              pairNotifications.isRead = true;
                              pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                              pairNotifications.toUser = UserLogin()..objectId = toUserId;
                              final ApiResponse apiResponse = await PairNotificationProviderApi().add(pairNotifications);

                              if (isBusy) {
                                isShowConnectCallButton.value = false;
                                Get.to(() => DialWaitingPage(
                                          img: userProfile.value['Imgprofile'].url,
                                          name: userProfile.value['Name'],
                                          pairNotificationsId: apiResponse.result['objectId'],
                                        ))!
                                    .whenComplete(() {
                                  _priceController.isPurchase.value = false;
                                });
                              } else {
                                final CallModel callModel = CallModel();
                                callModel.reason = 'OffLine';
                                callModel.fromUserId = ProfilePage()..objectId = widget.fromProfileId;
                                callModel.fromUser = UserLogin()..objectId = fromUserId;
                                callModel.toUserID = ProfilePage()..objectId = userProfile.value['objectId'];
                                callModel.toUser = UserLogin()..objectId = toUserId;
                                callModel.accepted = false;
                                callModel.duration = '00:00:00';
                                callModel.status = 0;
                                callModel.isVoice = false;
                                callModel.channelName = channelName;
                                callModel.isCallEnd = false;
                                callModel.callerType = 'Sender';
                                callModel.pairNotification = PairNotifications()..objectId = apiResponse.result['objectId'];
                                final save = await userCallProviderApi.add(callModel);

                                pairNotifications.objectId = apiResponse.result['objectId'];
                                pairNotifications["call"] = CallModel()..objectId = save.result['objectId'];
                                await PairNotificationProviderApi().update(pairNotifications);
                                isShowConnectCallButton.value = false;
                                if (userProfile.value['User']['CallNotification']) {
                                  CallService.makeCall(
                                    userId: userProfile.value['User']['objectId'],
                                    type: "Calling you",
                                    fromProfileId: widget.fromProfileId,
                                    callId: save.result['objectId'],
                                    isVoiceCall: false,
                                  );
                                }
                              }

                              final Notifications notifications = Notifications();
                              notifications.toUser = UserLogin()..objectId = toUserId;
                              notifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                              notifications.toProfile = ProfilePage()..objectId = userProfile.value['objectId'];
                              notifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                              notifications.notificationType = 'VideoCall';
                              notifications.isRead = false;

                              NotificationsProviderApi().add(notifications);
                            } else {
                              if (_priceController.userTotalCoin.value >= _priceController.videoCallPrice.value) {
                                final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                                final String fromUserId = StorageService.getBox.read('ObjectId');
                                final String toUserId = userProfile.value['User']['objectId'];
                                final String channelName = '${fromUserId}_$toUserId';

                                final PairNotifications pairNotifications = PairNotifications();

                                pairNotifications.toProfile = ProfilePage()..objectId = userProfile.value['objectId'];
                                pairNotifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                                pairNotifications.users = [
                                  ProfilePage()..objectId = widget.fromProfileId,
                                  ProfilePage()..objectId = userProfile.value['objectId']
                                ];
                                pairNotifications.message = '';
                                pairNotifications.notificationType = 'VideoCall';
                                pairNotifications.isPurchased = true;
                                pairNotifications.isRead = true;
                                pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                                pairNotifications.toUser = UserLogin()..objectId = toUserId;
                                final ApiResponse apiResponse = await PairNotificationProviderApi().add(pairNotifications);
                                if (isBusy) {
                                  isShowConnectCallButton.value = false;
                                  Get.to(() => DialWaitingPage(
                                            img: userProfile.value['Imgprofile'].url,
                                            name: userProfile.value['Name'],
                                            pairNotificationsId: apiResponse.result['objectId'],
                                          ))!
                                      .whenComplete(() {
                                    _priceController.isPurchase.value = false;
                                  });
                                } else {
                                  final CallModel callModel = CallModel();
                                  callModel.reason = 'OffLine';
                                  callModel.fromUserId = ProfilePage()..objectId = widget.fromProfileId;
                                  callModel.fromUser = UserLogin()..objectId = fromUserId;
                                  callModel.toUserID = ProfilePage()..objectId = userProfile.value['objectId'];
                                  callModel.toUser = UserLogin()..objectId = toUserId;
                                  callModel.accepted = false;
                                  callModel.duration = '00:00:00';
                                  callModel.isVoice = false;
                                  callModel.status = 0;
                                  callModel.channelName = channelName;
                                  callModel.isCallEnd = false;
                                  callModel.callerType = 'Sender';
                                  callModel.pairNotification = PairNotifications()..objectId = apiResponse.result['objectId'];
                                  final save = await userCallProviderApi.add(callModel);

                                  pairNotifications.objectId = apiResponse.result['objectId'];
                                  pairNotifications["call"] = CallModel()..objectId = save.result['objectId'];
                                  await PairNotificationProviderApi().update(pairNotifications);
                                  isShowConnectCallButton.value = false;
                                  if (userProfile.value['User']['CallNotification']) {
                                    CallService.makeCall(
                                      userId: userProfile.value['User']['objectId'],
                                      type: "Calling you",
                                      fromProfileId: widget.fromProfileId,
                                      callId: save.result['objectId'],
                                      isVoiceCall: false,
                                    );
                                  }
                                }
                                final Notifications notifications = Notifications();
                                notifications.toUser = UserLogin()..objectId = toUserId;
                                notifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                                notifications.toProfile = ProfilePage()..objectId = userProfile.value['objectId'];
                                notifications.fromProfile = ProfilePage()..objectId = widget.fromProfileId;
                                notifications.notificationType = 'VideoCall';
                                notifications.isRead = false;

                                NotificationsProviderApi().add(notifications);
                              } else {
                                isShowConnectCallButton.value = false;
                                _priceController.isPurchase.value = false;
                                Get.to(() => StoreScreen());
                              }
                            }
                          }
                        }
                      },
                    );
                  },
                  svg: 'assets/Icons/video_camera.svg',
                  enable: true,
                  online: ((userProfile.value['NoVideocalls'] ?? false) == false && (userProfile.value['User']['HasLoggedIn'] ?? true == true)),
                  title: 'VideoCall',
                  userId: userProfile.value["User"]['objectId'],
                  profileId: userProfile.value['objectId'],
                ),
                // MESSAGE
                Options(
                  svg: 'assets/Icons/heartMessage.svg',
                  enable: false,
                  onTap: (isBusy, isOnline) {
                    addBottomOption(
                        controller: pictureX.spam,
                        context: context,
                        description: 'sending_messages'.tr,
                        isTextField: true,
                        title: 'send_a_message'.tr,
                        subTitle: 'break_ice_with_kiss'.tr,
                        buttontitle: 'sendmessage'.tr,
                        ontap: () async {
                          if (pictureX.spam.text.removeAllWhitespace.isNotEmpty) {
                            _priceController.coinService('HeartMessage', userProfile.value["User"]['Gender'], userProfile.value['objectId'],
                                userProfile.value.get<ParseObject>('User')!.get<String>('objectId'),
                                fromProfile: widget.isDindon ? StorageService.getBox.read('DefaultProfile') : widget.fromProfileId,
                                catValue: _priceController.heartMessagePrice.value);
                          }
                        },
                        select: false,
                        hint: 'write_your_message_here'.tr,
                        height: 460.h);
                  },
                  title: 'message',
                  userId: userProfile.value["User"]['objectId'],
                  profileId: userProfile.value['objectId'],
                ),
                // WINK MESSAGE
                Options(
                  svg: 'assets/Icons/wink.svg',
                  enable: false,
                  onTap: (isBusy, isOnline) {
                    addBottomOption(
                        dropdownList: pictureX.winkItems,
                        context: context,
                        controller: pictureX.winkMsg,
                        description: 'sending_winks'.tr,
                        title: 'send_a_wink'.tr,
                        subTitle: 'get_her_attention'.tr,
                        buttontitle: 'sendwink'.tr,
                        ontap: () async {
                          if (pictureX.winkMsg.text.isNotEmpty) {
                            _priceController.coinService('WinkMessage', userProfile.value["User"]['Gender'], userProfile.value['objectId'],
                                userProfile.value.get<ParseObject>('User')!.get<String>('objectId'),
                                fromProfile: widget.fromProfileId, catValue: _priceController.winkMessagePrice.value);
                          } else {
                            Get.back();
                          }
                        },
                        select: false,
                        hint: 'click_here'.tr,
                        sufiix: true,
                        height: 460.h);
                  },
                  title: 'wink',
                  userId: userProfile.value["User"]['objectId'],
                  profileId: userProfile.value['objectId'],
                ),
                // LIPLIKE
                Options(
                  svg: 'assets/Icons/lipLike.svg',
                  enable: false,
                  onTap: (isBusy, isOnline) async {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Theme.of(context).dialogBackgroundColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(top: 14.h, left: 20.w, right: 20.w, bottom: MediaQuery.of(context).padding.bottom + 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(height: 3.h, width: 58.w, color: ConstColors.closeColor),
                              SizedBox(height: 12.h),
                              Styles.regular('send_a_kiss'.tr, c: Theme.of(context).primaryColor, ff: 'HB', fs: 18.sp),
                              SizedBox(height: 20.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child:
                                    Styles.regular('sending_kiss_attention'.tr, al: TextAlign.center, c: Theme.of(context).primaryColor, fs: 18.sp),
                              ),
                              Lottie.asset('assets/jsons/liplike.json', height: 150.w, width: 150.w),
                              // only male side show this text
                              if (StorageService.getBox.read('Gender') == 'male')
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  child: Styles.regular('sending_kiss'.tr, al: TextAlign.center, c: ConstColors.bottomBorder, fs: 18.sp),
                                ),
                              SizedBox(height: 26.h),
                              GradientButton(
                                  title: 'sendkiss'.tr,
                                  onTap: () {
                                    if (!pictureX.visible.value) {
                                      Get.back();
                                      _priceController.coinService('LipLike', userProfile.value["User"]['Gender'], userProfile.value['objectId'],
                                          userProfile.value['User']['objectId'],
                                          fromProfile: widget.fromProfileId, catValue: _priceController.lipLikePrice.value);
                                    }
                                  })
                            ],
                          ),
                        );
                      },
                    );
                  },
                  title: 'kiss',
                  userId: userProfile.value["User"]['objectId'],
                  profileId: userProfile.value['objectId'],
                ),
              ],
            ),
          );
        }),
        body: Stack(
          children: [
            Obx(() {
              if (isLoading.value == false) {
                if (userProfile.value.objectId == null) {
                  return const SizedBox.shrink();
                }
                name = userProfile.value['Name'].toString().split(' ').first.capitalizeFirst!;
                if (userProfile.value["CountryCode"].toString().isNotEmpty) {
                  localeFlag = userProfile.value["CountryCode"].toString().toLowerCase();
                }
                return NestedScrollView(
                  key: ValueKey(scrollController),
                  controller: scrollController,
                  headerSliverBuilder: (context, value) {
                    return [
                      SliverToBoxAdapter(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 13.h, left: 20.w, right: 15.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 7.h),
                                      Stack(
                                        children: [
                                          Container(
                                            height: 80.h,
                                            width: 80.h,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: ConstColors.themeColor, width: 2.w),
                                              borderRadius: BorderRadius.circular(80.r),
                                              color: ConstColors.white,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(80.r),
                                              child: CachedNetworkImage(
                                                alignment: Alignment.topCenter,
                                                imageUrl: userProfile.value['Imgprofile'].url,
                                                memCacheHeight: 200,
                                                //this line

                                                fit: BoxFit.cover,
                                                fadeInDuration: const Duration(milliseconds: 100),
                                                placeholderFadeInDuration: const Duration(milliseconds: 100),
                                                placeholder: (context, url) => preCachedSquare(),
                                                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                              ),
                                            ),
                                          ),
                                          if (userProfile.value['img_status'] == false)
                                            Container(
                                              height: 80.h,
                                              width: 80.h,
                                              padding: EdgeInsets.all(15.r),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(80.r),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(80.r),
                                                child: SvgView("assets/Icons/ProfileDelete.svg", height: 70.w, width: 70.w, fit: BoxFit.scaleDown),
                                              ),
                                            ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              height: 22.h,
                                              width: 22.w,
                                              decoration: BoxDecoration(color: ConstColors.white, shape: BoxShape.circle),
                                              child: CircleAvatar(
                                                backgroundImage: AssetImage('assets/flags/$localeFlag.png'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 9.w),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Styles.regular('${userProfile.value['Name'].toString().capitalizeFirst}',
                                                  fs: 18.sp, c: Theme.of(context).primaryColor, ff: 'RB'),
                                              SizedBox(
                                                width: 205.w,
                                                child: Styles.regular(userProfile.value['Location'],
                                                    lns: 2, ov: TextOverflow.ellipsis, fs: 16.sp, c: Theme.of(context).primaryColor, ff: 'RR'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                              alignment: Alignment.center,
                                              height: 26.w,
                                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30.r), color: ConstColors.themeColor.withOpacity(0.90)),
                                              child: Styles.regular(
                                                  "${(_searchController.calculateDistance(_searchController.profileData[StorageService.getBox.read('index') ?? 0].locationGeoPoint.latitude, _searchController.profileData[StorageService.getBox.read('index') ?? 0].locationGeoPoint.longitude, userProfile.value['LocationGeoPoint'].latitude, userProfile.value['LocationGeoPoint'].longitude)).round()} km",
                                                  c: ConstColors.white,
                                                  fs: 18.sp,
                                                  ff: "HR")),
                                          SizedBox(
                                            width: 35.w * userProfile.value['Language'].length,
                                            height: 35.h,
                                            child: ListView.builder(
                                              itemCount: userProfile.value['Language'].length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, ind) {
                                                return Padding(
                                                  padding: EdgeInsets.only(left: 5.w),
                                                  child: CachedNetworkImage(
                                                    imageUrl: userProfile.value['Language'][ind]['Image'].url,
                                                    memCacheHeight: 200,
                                                    width: 26.w,
                                                    //this line
                                                    fadeInDuration: const Duration(milliseconds: 100),
                                                    placeholderFadeInDuration: const Duration(milliseconds: 100),
                                                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 5.h),
                                  Obx(() {
                                    return AnimatedSize(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.ease,
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        SizedBox(height: 7.h),
                                        if (_translateController.translate.value) ...[
                                          FutureBuilder<TranslateLan?>(
                                              future:
                                                  _translateController.translateLang(text: userProfile.value['Description'], targetLanguage: 'es'),
                                              builder: (context, snap) {
                                                if (snap.hasData && snap.connectionState == ConnectionState.done) {
                                                  return Styles.regular(snap.data!.data.translations[0].translatedText,
                                                      key: const ValueKey(0),
                                                      al: TextAlign.start,
                                                      fs: 18.sp,
                                                      c: Theme.of(context).primaryColor,
                                                      ff: 'RR');
                                                } else {
                                                  return Shimmer.fromColors(
                                                      baseColor: ConstColors.subtitle,
                                                      highlightColor: ConstColors.themeColor,
                                                      child: Styles.regular(userProfile.value['Description'],
                                                          key: const ValueKey(3),
                                                          al: TextAlign.start,
                                                          fs: 18.sp,
                                                          c: Theme.of(context).primaryColor,
                                                          ff: 'RR'));
                                                }
                                              }),
                                        ],
                                        if (_translateController.translate.value == false) ...[
                                          Styles.regular(userProfile.value['Description'],
                                              key: const ValueKey(1), al: TextAlign.start, fs: 18.sp, c: Theme.of(context).primaryColor, ff: 'RR'),
                                        ]
                                      ]),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            SizedBox(height: 19.h),
                          ],
                        ),
                      ),
                    ];
                  },
                  body: Column(
                    children: [
                      Obx(
                        () => Container(
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
                            tabAlignment: TabAlignment.center,
                            controller: tabController,
                            indicatorColor: ConstColors.themeColor,
                            labelColor: ConstColors.themeColor,
                            indicator: UnderlineTabIndicator(
                                borderSide: BorderSide(width: 4.0, color: ConstColors.themeColor), insets: EdgeInsets.only(left: 10.w, right: 10.w)),
                            isScrollable: true,
                            tabs: [
                              Tab(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 20.w, left: 20.w),
                                  child: SvgView('assets/Icons/gallery2.svg',
                                      color: _tabX.selectedIndex.value == 0 ? ConstColors.themeColor : ConstColors.themeColor.withOpacity(0.57)),
                                ),
                              ),
                              Tab(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 20.w, right: 20.w),
                                  child: SvgView('assets/Icons/video.svg',
                                      color: _tabX.selectedIndex.value == 1 ? ConstColors.themeColor : ConstColors.themeColor.withOpacity(0.57)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(seconds: 1),
                          child: Obx(() {
                            userProfileRefresh.value;
                            return TabBarView(
                              controller: tabController,
                              children: [
                                FutureBuilder<List<ApiResponse?>>(
                                  future: Future.wait([
                                    PostProviderApi().profilePostQuery(widget.toProfileId),
                                    PurchaseNudeImageProviderApi().getById(widget.toProfileId, StorageService.getBox.read('DefaultProfile')),
                                  ]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(
                                        key: const ValueKey(0),
                                        child: Container(
                                          padding: EdgeInsets.all(10.r),
                                          height: 250.h,
                                          child:
                                              Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown),
                                        ),
                                      );
                                    } else if (snapshot.hasData) {
                                      final snapshotPhoto = snapshot.data![0];
                                      final snapshotPurchase = snapshot.data![1];
                                      if (snapshotPhoto != null) {
                                        if (userProfile.value.objectId != null && userProfile.value['DefaultImg'] != null) {
                                          StorageService.getBox.write('DefaultImg', userProfile.value['DefaultImg']?['objectId'] ?? '');
                                        }
                                        return photos(context,
                                            images: snapshotPhoto.results ?? [], nudeImages: snapshotPurchase?.results ?? [], key: const ValueKey(1));
                                      } else {
                                        return Center(
                                          key: const ValueKey(2),
                                          child: Styles.regular("$name ${'has_no_published_photos'.tr}", c: Theme.of(context).primaryColor),
                                        );
                                      }
                                    } else {
                                      return Center(
                                        key: const ValueKey(2),
                                        child: Styles.regular("$name ${'has_no_published_photos'.tr}", c: Theme.of(context).primaryColor),
                                      );
                                    }
                                  },
                                ),
                                FutureBuilder<List<ApiResponse?>>(
                                  future: Future.wait([
                                    PostVideoProviderApi().profileVideoPostQuery(widget.toProfileId),
                                    PurchaseNudeVideoProviderApi().getById(widget.toProfileId, StorageService.getBox.read('DefaultProfile')),
                                  ]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(
                                        key: const ValueKey(3),
                                        child: Container(
                                            padding: EdgeInsets.all(10.r),
                                            height: 250.h,
                                            child: Lottie.asset('assets/jsons/three-dot-loading.json',
                                                height: 98.w, width: 98.w, fit: BoxFit.scaleDown)),
                                      );
                                    } else if (snapshot.hasData) {
                                      final snapshotVideo = snapshot.data![0];
                                      final snapshotPurchase = snapshot.data![1];
                                      if (snapshotVideo != null) {
                                        return videos(context,
                                            videos: snapshotVideo.results ?? [], nudeVideos: snapshotPurchase?.results ?? [], key: const ValueKey(4));
                                      } else {
                                        return Center(
                                          key: const ValueKey(2),
                                          child: Styles.regular("$name ${'has_no_published_videos'.tr}", c: Theme.of(context).primaryColor),
                                        );
                                      }
                                    } else {
                                      return Center(
                                          key: const ValueKey(5),
                                          child: Styles.regular("$name ${'has_no_published_videos'.tr}", c: Theme.of(context).primaryColor));
                                    }
                                  },
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Shimmer.fromColors(
                baseColor: ConstColors.subtitle,
                highlightColor: ConstColors.themeColor,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 13.h, left: 20.w, right: 15.w),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 7.h),
                              Stack(
                                children: [
                                  Container(
                                    height: 80.h,
                                    width: 80.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: ConstColors.themeColor, width: 2.w),
                                      borderRadius: BorderRadius.circular(80.r),
                                      color: ConstColors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(80.r),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 9.w, top: 10.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        height: 20.w,
                                        width: 160.w,
                                        decoration:
                                            BoxDecoration(borderRadius: BorderRadius.circular(6.r), color: ConstColors.themeColor.withOpacity(0.90)),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        alignment: Alignment.center,
                                        height: 20.w,
                                        width: 210.w,
                                        decoration:
                                            BoxDecoration(borderRadius: BorderRadius.circular(6.r), color: ConstColors.themeColor.withOpacity(0.90)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 26.w,
                                    width: 87.w,
                                    decoration:
                                        BoxDecoration(borderRadius: BorderRadius.circular(6.r), color: ConstColors.themeColor.withOpacity(0.90)),
                                  ),
                                  SizedBox(
                                    width: 70.w,
                                    height: 35.h,
                                    child: ListView.builder(
                                      itemCount: 3,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, ind) {
                                        return Padding(
                                          padding: EdgeInsets.only(left: 5.w),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Column(children: [
                            Container(padding: EdgeInsets.only(top: 7.h), width: 377.w),
                            Container(padding: EdgeInsets.only(top: 7.h), width: 377.w),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 20.w,
                      width: 400.w,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r), color: ConstColors.themeColor.withOpacity(0.90)),
                    ),
                    SizedBox(height: 19.h),
                  ],
                ),
              );
            }),
            Obx(() {
              return Center(
                child: AnimatedContainer(
                  width: _priceController.isPurchase.value && isShowConnectCallButton.value ? 200.0 : 0.0,
                  height: _priceController.isPurchase.value && isShowConnectCallButton.value ? 273.0 : 0.0,
                  alignment: Alignment.center,
                  duration: const Duration(milliseconds: 150),
                  child: AnimatedOpacity(
                    opacity: _priceController.isPurchase.value && isShowConnectCallButton.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                        height: 50.h,
                        width: 200.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: ConstColors.themeColor, borderRadius: BorderRadius.circular(10.r)),
                        child: Styles.regular('Connecting'.tr, c: Theme.of(context).primaryColor, ff: 'HB')),
                  ),
                ),
              );
            }),
            Obx(
              () => Center(
                child: AnimatedContainer(
                  width: pictureX.winkvisible.value ? 200.0 : 0.0,
                  height: pictureX.winkvisible.value ? 273.0 : 0.0,
                  alignment: Alignment.center,
                  duration: const Duration(milliseconds: 150),
                  // curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    opacity: pictureX.winkvisible.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Lottie.asset("assets/jsons/wink.json"),
                  ),
                ),
              ),
            ),
            Obx(
              () => Center(
                child: AnimatedContainer(
                  width: pictureX.messagevisible.value ? 200.0 : 0.0,
                  height: pictureX.messagevisible.value ? 273.0 : 0.0,
                  alignment: Alignment.center,
                  duration: const Duration(milliseconds: 150),
                  // curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    opacity: pictureX.messagevisible.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Lottie.asset("assets/jsons/message.json"),
                  ),
                ),
              ),
            ),
            Obx(() {
              pictureX.visible.value;
              if (pictureX.visible.value) {
                return Positioned(right: -100, bottom: 0, child: Lottie.asset("assets/jsons/kiss.json", height: 400.w, width: 400.w));
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget photos(context, {required List images, required List nudeImages, required Key key}) {
    List<bool> purchase = [];
    try {
      if (StorageService.getBox.read('DefaultImg') != null) {
        dynamic first;
        final int index = images.indexWhere((element) => element['objectId'] == StorageService.getBox.read('DefaultImg'));
        for (var element in images) {
          if (element['objectId'] == StorageService.getBox.read('DefaultImg')) {
            first = element;
          }
        }
        if (!index.isNegative) {
          images.removeAt(index);
          images.insert(0, first);
        }
      }
    } catch (e) {
      debugPrint('Hello video index Error: $e');
    }
    return GridView.builder(
      key: key,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisExtent: 204, crossAxisCount: 3),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: images.length,
      itemBuilder: (context, index) {
        if (nudeImages.toString().contains(images[index]['objectId'])) {
          purchase.add(false);
        } else {
          purchase.add(true);
        }
        return PostView(
          imgStatus: (images[index]['Status'] ?? true),
          img: images[index]['Post'] != null ? images[index]['Post'].url.toString() : "",
          isNude: ((images[index]['IsNude'] ?? false) && purchase[index]),
          onTap: () {
            print('hello data ====== ${StorageService.getBox.read('DefaultImg')}');

            Get.to(() => ShowPictureScreen(
                  imgObjectId: images[index]['objectId'],
                  toUserDefaultProfileId: StorageService.getBox.read('DefaultImg'),
                  visitMode: true,
                  index: index,
                  toProfileId: widget.toProfileId,
                  fromProfileId: widget.fromProfileId,
                ));
          },
        );
      },
    );
  }

  Widget videos(context, {required List videos, required List nudeVideos, required Key key}) {
    List<bool> purchase = [];
    return GridView.builder(
        key: key,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisExtent: 204, crossAxisCount: 3),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          if (nudeVideos.toString().contains(videos[index]['objectId'])) {
            purchase.add(false);
          } else {
            purchase.add(true);
          }
          return PostView(
            imgStatus: (videos[index]['Status'] ?? true),
            img: videos[index]['PostThumbnail'] != null ? videos[index]['PostThumbnail'].url.toString() : "",
            memCacheHeight: 600,
            isNude: ((videos[index]['IsNude'] ?? false) && purchase[index]),
            onTap: () {
              Get.to(() => ShowVideoScreen(
                  userController: _userController,
                  vidObjectId: videos[index]['objectId'],
                  visitMode: true,
                  toProfileId: widget.toProfileId,
                  fromProfileId: widget.fromProfileId,
                  index: index));
            },
          );
        });
  }
}

class Options extends StatefulWidget {
  const Options(
      {Key? key,
      required this.svg,
      required this.enable,
      this.online = false,
      required this.userId,
      required this.profileId,
      required this.onTap,
      required this.title})
      : super(key: key);

  final Function(bool, bool) onTap;
  final String svg;
  final bool enable;
  final bool online;
  final String userId;
  final String profileId;
  final String title;

  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  final LiveQuery liveQuery = LiveQuery(debug: false);
  Subscription<ParseObject>? subscription;

  final LiveQuery liveProfileQuery = LiveQuery(debug: false);
  Subscription<ParseObject>? profileSubscription;

  final RxBool online = false.obs;
  final RxBool isLive = false.obs;
  final RxBool isOnAnotherCall = false.obs;
  final RxBool isHasLoggedIn = false.obs;

  @override
  void initState() {
    online.value = widget.online;
    if (widget.enable) {
      onlineStatusQuery();
    }
    super.initState();
  }

  @override
  void dispose() {
    try {
      if (widget.enable) {
        if (widget.userId.isNotEmpty) {
          liveQuery.client.unSubscribe(subscription!);
        }
        if(widget.profileId.isNotEmpty){
          liveProfileQuery.client.unSubscribe(profileSubscription!);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('error in widget.position $e');
      }
    }

    super.dispose();
  }

  onlineStatusQuery() async {
    // 1.chat  2.call  3.VideoCall (3 options for profile online status)
    try {
      final QueryBuilder<UserLogin> queryData = QueryBuilder<UserLogin>(UserLogin())..whereEqualTo('objectId', widget.userId);
      final QueryBuilder<ProfilePage> queryProfileData = QueryBuilder<ProfilePage>(ProfilePage())
        ..whereEqualTo('objectId', widget.profileId)
        ..includeObject(['User']);

      /// User Login Query
      queryData.query().then((value) {
        isLive.value = (value.result[0]['showOnline'] ?? false);
        if (widget.title == 'call') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            isOnAnotherCall.value = (value.result[0]['IsBusy'] ?? false);
          });
        } else if (widget.title == 'VideoCall') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            isOnAnotherCall.value = (value.result[0]['IsBusy'] ?? false);
          });
        }
      });

      /// User Profile Query
      queryProfileData.query().then((value) {
        if (widget.title == 'chat') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if((value.result[0]['NoChats'] ?? false) == false && (value.result[0]['User']['HasLoggedIn'] ?? true) == true){
              online.value = true;
              print('hello online  True----');
            }else{
              online.value = false;
              print('hello online  False----');

            }
          });
        } else if (widget.title == 'call') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if((value.result[0]['NoCalls'] ?? false) == false && (value.result[0]['User']['HasLoggedIn'] ?? true) == true){
              online.value = true;
            }else{
              online.value = false;
            }
          });
        } else if (widget.title == 'VideoCall') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if((value.result[0]['NoVideocalls'] ?? false) == false && (value.result[0]['User']['HasLoggedIn'] ?? true) == true){
              online.value = true;
            }else{
              online.value = false;
            }
          });
        }
      });

      /// login live query

      subscription = await liveQuery.client.subscribe(queryData);
      subscription!.on(LiveQueryEvent.create, (value) {});
      subscription!.on(LiveQueryEvent.update, (value) {
        isLive.value = (value['showOnline'] ?? false);
        isHasLoggedIn.value = (value['HasLoggedIn'] ?? true);
        if (widget.title == 'call') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            isOnAnotherCall.value = (value['IsBusy'] ?? false);
          });
        } else if (widget.title == 'VideoCall') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            isOnAnotherCall.value = (value['IsBusy'] ?? false);
          });
        }
      });
      subscription!.on(LiveQueryEvent.delete, (value) {});

      /// profile live query

      profileSubscription = await liveProfileQuery.client.subscribe(queryProfileData);
      profileSubscription!.on(LiveQueryEvent.create, (value) {});
      profileSubscription!.on(LiveQueryEvent.update, (value) {
        if (widget.title == 'chat') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if((value['NoChats'] ?? false) == false && isHasLoggedIn.value == true){
              online.value = true;
            }else{
              online.value = false;
            }
          });
        } else if (widget.title == 'call') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if((value['NoCalls'] ?? false) == false && isHasLoggedIn.value == true){
              online.value = true;
            }else{
              online.value = false;
            }
          });
        } else if (widget.title == 'VideoCall') {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if((value['NoVideocalls'] ?? false) == false && isHasLoggedIn.value == true){
              online.value = true;
            }else{
              online.value = false;
            }
          });
        }
      });
      profileSubscription!.on(LiveQueryEvent.delete, (value) {});
    } catch (trace, error) {
      if (kDebugMode) {
        print("trace ::::: $trace");
        print("error ::::: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      online.value;
      isOnAnotherCall.value;
      return GestureDetector(
        onTap: () {
          widget.enable
              ? (online.value)
                  ? isOnAnotherCall.value
                      ? widget.onTap(true, isLive.value)
                      : widget.onTap(false, isLive.value)
                  : null
              : widget.onTap(false, isLive.value);
        },
        child: Container(
          height: 50.h,
          width: 50.h,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(color: ConstColors.white, shape: BoxShape.circle),
          child: SvgView(
            widget.svg,
            fit: BoxFit.scaleDown,
            color: widget.enable
                ? (online.value)
                    ? ConstColors.themeColor
                    : ConstColors.offlineColor
                : ConstColors.themeColor,
          ),
        ),
      );
    });
  }
}
