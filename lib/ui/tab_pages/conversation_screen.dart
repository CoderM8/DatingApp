// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable, deprecated_member_use, invalid_use_of_protected_member

import 'dart:convert';
import 'dart:io';

import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/Widgets/bottom_sheet.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/post_view.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/Picture_Controller/profile_pic_controller.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/Controllers/tab_Controller/conversation_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/repositories/Calls/call_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/all_notifications/all_notifications.dart';
import 'package:eypop/back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/vertical_tab/provider_blockuser.dart';
import 'package:eypop/models/all_notifications/all_notifications.dart';
import 'package:eypop/models/call/calls.dart';
import 'package:eypop/models/new_notification/new_notification_pair.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/verticaltab_model/blockuser.dart';
import 'package:eypop/service/calling.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/User_profile/user_fullprofile_screen.dart';
import 'package:eypop/ui/bottom_screen.dart';
import 'package:eypop/ui/call/dial_waiting_page.dart';
import 'package:eypop/ui/store_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class ConversationScreen extends GetView {
  ConversationScreen({
    required this.fromUserDeleted,
    required this.fromProfileId,
    required this.fromUserImg,
    required this.toUserDeleted,
    required this.toUser,
    required this.toProfileName,
    required this.toProfileImg,
    required this.toProfileId,
    required this.toUserGender,
    required this.toUserId,
    required this.tableName,
    this.personal = false,
    this.description,
    this.onlineStatus = true,
    this.visitType = false,
    Key? key,
  }) : super(key: key);

  final String toProfileName, toProfileImg, toProfileId, toUserGender, toUserId, fromProfileId, fromUserImg, tableName;
  final bool toUserDeleted, fromUserDeleted, visitType, personal;
  late bool onlineStatus;
  final ParseObject toUser;
  final String? description;

  static PictureController get pictureX => Get.put(PictureController());

  // static ConversationController get _conController => Get.put(ConversationController());
  final ConversationController _conController = Get.put(ConversationController());

  static PriceController get _priceController => Get.put(PriceController());

  static AppSearchController get _searchController => Get.put(AppSearchController());

  @override
  Widget build(BuildContext context) {
    _conController.isUpdate.listen((val){
      /// chat
      if(_conController.isNoChat.value == false && _conController.isHasLoggedIn.value == true){
        _conController.onlineStatus.value = true;
        print('hello onlineStatus **** True');
      }else{
        _conController.onlineStatus.value = false;
        print('hello onlineStatus **** False');
      }

      /// call
      if(_conController.isNoCall.value == false && _conController.isHasLoggedIn.value == true){
        _conController.isCallEnable.value = true;
        print('hello isCallEnable **** True');
      }else{
        _conController.isCallEnable.value = false;
        print('hello isCallEnable **** False');
      }

      /// video call
      if(_conController.isNoVideocall.value == false && _conController.isHasLoggedIn.value == true){
        _conController.isVideocallEnable.value = true;
        print('hello isVideocallEnable **** True');
      }else{
        _conController.isVideocallEnable.value = false;
        print('hello isVideocallEnable **** False');
      }
    });

    if (tableName == 'Chat_Message') {
      toChatUser.value = toUserId;
    } else if (tableName == 'Like_Message') {
      toMessageUser.value = toUserId;
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (canPop) async {
        if (!canPop) {
          await _willPopCallback(context);
        }
      },
      child: Scaffold(
        appBar: _appBar(context),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                _conController.isTyping.value;
                if (_conController.isChatLoading.value) {
                  return SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                    child: Center(child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown)),
                  );
                }
                if (_priceController.isGiftSending.value) {
                  return SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                    child: Center(child: Lottie.asset('assets/jsons/chat_gift.json')),
                  );
                }
                // sort key date wise
                final List<DateTime> dateSectionsKeys = _conController.messageList.keys.toList()
                  ..sort((a, b) => b.compareTo(a)); // Sort sections in descending order
                return Column(
                  children: [
                    if (_conController.isLoadMore.value) Lottie.asset('assets/jsons/load_more.json', width: 60.w, height: 60.w, fit: BoxFit.cover),
                    if (_conController.isLimit200.value)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 11.w),
                        child: Styles.regular("ChatLimit_text".tr.replaceAll('xxx', chatLimit.toString()),
                            c: ConstColors.redColor, fs: 16.sp, al: TextAlign.center),
                      ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: ListView.builder(
                          reverse: true,
                          controller: _conController.scrollController,
                          padding: EdgeInsets.only(top: 10.h, bottom: 10.h, right: 10.w, left: 10.w),
                          itemCount: dateSectionsKeys.length,
                          itemBuilder: (context, index) {
                            final dateSection = dateSectionsKeys[index];
                            final List<Widget> messagesForDate = _conController.messageList[dateSection] ?? [];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (messagesForDate.isNotEmpty)
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                      child:
                                          Styles.regular(getWhen(date: dateSection), c: ConstColors.darkGreyColor, fs: 14.sp, al: TextAlign.center),
                                    ),
                                  ),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: messagesForDate.length,
                                  itemBuilder: (c, messageIndex) {
                                    return messagesForDate[messageIndex];
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    _progress(),
                  ],
                );
              }),
            ),
            _chatInput(context),
          ],
        ),
        bottomNavigationBar: tableName == "Chat_Message" ? _bottomMenu(context) : null,
      ),
    );
  }

  Future<void> _willPopCallback(context) async {
    _priceController.chat.clear();
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 600));

    if (visitType) {
      Get.offAll(() => BottomScreen());
    } else {
      if (description != null) {
        if (_conController.chatList.isNotEmpty && _conController.chatList.last['isPurchased'] == true) {
          Get.back(result: _conController.chatList.last["Message"]);
          Get.delete<ConversationController>();
        } else {
          Get.back();
          Get.delete<ConversationController>();
        }
      } else {
        if (_conController.newChatAdded.value < _conController.chatList.length) {
          Get.back(result: _conController.chatList.last["Message"]);
          Get.delete<ConversationController>();
        } else {
          Get.back();
          Get.delete<ConversationController>();
        }
      }
    }
  }

  AppBar _appBar(context) {
    return AppBar(
      leading: Back(
        onTap: () async {
          _priceController.chat.clear();
          FocusScope.of(context).unfocus();
          await Future.delayed(const Duration(milliseconds: 600));
          if (visitType) {
            Get.offAll(() => BottomScreen());
          } else {
            if (description != null) {
              if (_conController.chatList.isNotEmpty && _conController.chatList.last['isPurchased'] == true) {
                Get.back(result: _conController.chatList.last["Message"]);
                Get.delete<ConversationController>();
              } else {
                Get.back();
                Get.delete<ConversationController>();
              }
            } else {
              if (_conController.newChatAdded.value < _conController.chatList.length) {
                Get.back(result: _conController.chatList.last["Message"]);
                Get.delete<ConversationController>();
              } else {
                Get.back();
                Get.delete<ConversationController>();
              }
            }
          }
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Transform(
              transform: Matrix4.translationValues(-11, 0, 0),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 30.w),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  // my profile open
                                  List myProfile = [];
                                  for (var e in _searchController.profileData) {
                                    if (e.objectId == fromProfileId) {
                                      myProfile.add(e);
                                    }
                                  }
                                  if (myProfile.isNotEmpty) {
                                    bottomProfile(
                                      context: context,
                                      countryCode: myProfile[0]['CountryCode'].toLowerCase(),
                                      profileImage: myProfile[0]['Imgprofile'].url,
                                      name: myProfile[0]['Name'],
                                      location: myProfile[0]['Location'],
                                      description: myProfile[0]['Description'],
                                      languageList: myProfile[0]['Language'],
                                    );
                                  }
                                },
                                child: ImageView(fromUserImg, height: 40.w, width: 40.w, circle: true, alignment: Alignment.topCenter)),
                            // check when my user is delete
                            if (fromUserDeleted)
                              Container(
                                height: 40.w,
                                width: 40.w,
                                padding: EdgeInsets.all(10.h),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.6)),
                                child: SvgView("assets/Icons/ProfileDelete.svg", height: 30.w, width: 30.w, fit: BoxFit.scaleDown),
                              ),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: toUserDeleted || fromUserDeleted
                                ? () {
                                    if (kDebugMode) {
                                      print('Visit profile onTap disable');
                                    }
                                  }
                                : () {
                                    if (personal) {
                                      Get.back();
                                    } else {
                                      FocusManager.instance.primaryFocus!.unfocus();
                                      if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted &&
                                          !(_searchController.profileData[StorageService.getBox.read('index') ?? 0]['IsBlocked'] ?? false)) {
                                        Get.to(() => UserFullProfileScreen(
                                                personal: tableName == 'Chat_Message',
                                                toProfileId: toProfileId,
                                                toUserId: toUser,
                                                fromProfileId: fromProfileId))!
                                            .whenComplete(() {
                                          _conController.showRate.value = false;
                                        });
                                      } else {
                                        deleteProfileSnackBar(context);
                                      }
                                    }
                                  },
                            child: ImageView(
                              toProfileImg,
                              height: 42.w,
                              width: 42.w,
                              circle: true,
                              border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.w),
                            ),
                          ),
                          // check when opposite user is delete
                          if (toUserDeleted)
                            Container(
                              height: 42.w,
                              width: 42.w,
                              padding: EdgeInsets.all(10.h),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.6)),
                              child: SvgView("assets/Icons/ProfileDelete.svg", height: 30.w, width: 30.w, fit: BoxFit.scaleDown),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Stack(
                  //   clipBehavior: Clip.none,
                  //   children: [
                  //     GestureDetector(
                  //       onTap: () {
                  //         // my profile open
                  //         List myProfile = [];
                  //         for (var e in _searchController.profileData) {
                  //           if (e.objectId == fromProfileId) {
                  //             myProfile.add(e);
                  //           }
                  //         }
                  //         if (myProfile.isNotEmpty) {
                  //           bottomProfile(
                  //             context: context,
                  //             countryCode: myProfile[0]['CountryCode'].toLowerCase(),
                  //             profileImage: myProfile[0]['Imgprofile'].url,
                  //             name: myProfile[0]['Name'],
                  //             location: myProfile[0]['Location'],
                  //             description: myProfile[0]['Description'],
                  //             languageList: myProfile[0]['Language'],
                  //           );
                  //         }
                  //       },
                  //       child: Stack(
                  //         alignment: Alignment.center,
                  //         children: [
                  //           ImageView(fromUserImg, height: 40.w, width: 40.w, circle: true),
                  //           // check when my user is delete
                  //           if (fromUserDeleted)
                  //             Container(
                  //               height: 40.w,
                  //               width: 40.w,
                  //               padding: EdgeInsets.all(10.h),
                  //               decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.6)),
                  //               child: SvgView("assets/Icons/ProfileDelete.svg", height: 30.w, width: 30.w, fit: BoxFit.scaleDown),
                  //             ),
                  //         ],
                  //       ),
                  //     ),
                  //     Positioned(
                  //       top: 0,
                  //       right: -30.w,
                  //       child: GestureDetector(
                  //         onTap: toUserDeleted || fromUserDeleted
                  //             ? () {
                  //                 if (kDebugMode) {
                  //                   print('Visit profile onTap disable');
                  //                 }
                  //               }
                  //             : () {
                  //                 if (personal) {
                  //                   Get.back();
                  //                 } else {
                  //                   FocusManager.instance.primaryFocus!.unfocus();
                  //                   if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted &&
                  //                       !(_searchController.profileData[StorageService.getBox.read('index') ?? 0]['IsBlocked'] ?? false)) {
                  //                     Get.to(() => UserFullProfileScreen(
                  //                             personal: tableName == 'Chat_Message',
                  //                             toProfileId: toProfileId,
                  //                             toUserId: toUser,
                  //                             fromProfileId: fromProfileId))!
                  //                         .whenComplete(() {
                  //                       _conController.showRate.value = false;
                  //                     });
                  //                   } else {
                  //                     deleteProfileSnackBar(context);
                  //                   }
                  //                 }
                  //               },
                  //         child:
                  //         Stack(
                  //           alignment: Alignment.center,
                  //           children: [
                  //             ImageView(
                  //               toProfileImg,
                  //               height: 42.w,
                  //               width: 42.w,
                  //               circle: true,
                  //               border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.w),
                  //             ),
                  //             // check when opposite user is delete
                  //             if (toUserDeleted)
                  //               Container(
                  //                 height: 42.w,
                  //                 width: 42.w,
                  //                 padding: EdgeInsets.all(10.h),
                  //                 decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.6)),
                  //                 child: SvgView("assets/Icons/ProfileDelete.svg", height: 30.w, width: 30.w, fit: BoxFit.scaleDown),
                  //               ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(width: 15.w),
                  Obx(() {
                    _conController.isUpdate.value;
                    _conController.onlineStatus.value;
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Styles.regular(toProfileName, fs: 18.sp, c: ConstColors.themeColor),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 275),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: _conController.userStatus(userIsDeleted: toUserDeleted, description: description, onlineStatus: _conController.onlineStatus.value),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          if (tableName == 'Chat_Message') ...[
            Obx(() {
              _conController.isUpdate.value;
              _conController.isCallBusy.value;
              final bool enable = (_conController.isCallEnable.value && !toUserDeleted && !fromUserDeleted);
              return InkWell(
                onTap: enable
                    ? () {
                        showBottomSheetAudioVideoCall(
                          context,
                          title: 'call'.tr,
                          callTitle: "make_call".tr,
                          isOnline: (_conController.isOnline != null && _conController.isOnline!.value),
                          description: 'call_description'.tr,
                          askPermissionOnTap: () {
                            Get.back();
                            _priceController.chat.text = 'I_can_call_you_now'.tr;
                          },
                          callOnTap: () async {
                            Get.back();
                            await checkUserPermission();
                            final PermissionStatus status = await Permission.microphone.status;
                            if (status.isGranted) {
                              if (_priceController.isPurchase.value == false) {
                                _priceController.isPurchase.value = true;
                                if (StorageService.getBox.read('Gender') == 'female') {
                                  final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                                  final String fromUserId = StorageService.getBox.read('ObjectId');
                                  final String toUserId = toUser['objectId'];
                                  final String channelName = '${fromUserId}_$toUserId';
                                  final PairNotifications pairNotifications = PairNotifications();
                                  pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
                                  pairNotifications.fromProfile = ProfilePage()..objectId = fromProfileId;
                                  pairNotifications.users = [ProfilePage()..objectId = fromProfileId, ProfilePage()..objectId = toProfileId];
                                  pairNotifications.message = '';
                                  pairNotifications.notificationType = 'Call';
                                  pairNotifications.isPurchased = true;
                                  pairNotifications.isRead = true;
                                  pairNotifications.fromUser = UserLogin()..objectId = fromUserId;
                                  pairNotifications.toUser = UserLogin()..objectId = toUserId;
                                  final ApiResponse apiResponse = await PairNotificationProviderApi().add(pairNotifications);

                                  if (_conController.isCallBusy.value) {
                                    Get.to(() => DialWaitingPage(
                                            img: toProfileImg, name: toProfileName, pairNotificationsId: apiResponse.result['objectId']))!
                                        .whenComplete(() {
                                      _priceController.isPurchase.value = false;
                                    });
                                  } else {
                                    final CallModel callModel = CallModel();
                                    callModel.reason = 'OffLine';
                                    callModel.fromUserId = ProfilePage()..objectId = fromProfileId;
                                    callModel.fromUser = UserLogin()..objectId = fromUserId;
                                    callModel.toUserID = ProfilePage()..objectId = toProfileId;
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

                                    if (toUser['CallNotification']) {
                                      CallService.makeCall(
                                          userId: toUser['objectId'],
                                          type: "Calling you",
                                          fromProfileId: fromProfileId,
                                          callId: save.result['objectId'],
                                          isVoiceCall: true);
                                    }
                                  }

                                  final Notifications notifications = Notifications();
                                  notifications.toUser = UserLogin()..objectId = toUserId;
                                  notifications.fromUser = UserLogin()..objectId = fromUserId;
                                  notifications.toProfile = ProfilePage()..objectId = toProfileId;
                                  notifications.fromProfile = ProfilePage()..objectId = fromProfileId;
                                  notifications.notificationType = 'Call';
                                  notifications.isRead = false;

                                  NotificationsProviderApi().add(notifications);
                                } else {
                                  if (_priceController.userTotalCoin.value >= _priceController.callPrice.value) {
                                    final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                                    final String fromUserId = StorageService.getBox.read('ObjectId');
                                    final String toUserId = toUser['objectId'];
                                    final String channelName = '${fromUserId}_$toUserId';

                                    final PairNotifications pairNotifications = PairNotifications();

                                    pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
                                    pairNotifications.fromProfile = ProfilePage()..objectId = fromProfileId;
                                    pairNotifications.users = [ProfilePage()..objectId = fromProfileId, ProfilePage()..objectId = toProfileId];
                                    pairNotifications.message = '';
                                    pairNotifications.notificationType = 'Call';
                                    pairNotifications.isPurchased = true;
                                    pairNotifications.isRead = true;
                                    pairNotifications.fromUser = UserLogin()..objectId = fromUserId;
                                    pairNotifications.toUser = UserLogin()..objectId = toUserId;
                                    final ApiResponse apiResponse = await PairNotificationProviderApi().add(pairNotifications);
                                    if (_conController.isCallBusy.value) {
                                      Get.to(() => DialWaitingPage(
                                              img: toProfileImg, name: toProfileName, pairNotificationsId: apiResponse.result['objectId']))!
                                          .whenComplete(() {
                                        _priceController.isPurchase.value = false;
                                      });
                                    } else {
                                      final CallModel callModel = CallModel();
                                      callModel.reason = 'OffLine';
                                      callModel.fromUserId = ProfilePage()..objectId = fromProfileId;
                                      callModel.fromUser = UserLogin()..objectId = fromUserId;
                                      callModel.toUserID = ProfilePage()..objectId = toProfileId;
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

                                      if (toUser['CallNotification']) {
                                        CallService.makeCall(
                                            userId: toUser['objectId'],
                                            type: "Calling you",
                                            fromProfileId: fromProfileId,
                                            callId: save.result['objectId'],
                                            isVoiceCall: true);
                                      }
                                    }
                                    final Notifications notifications = Notifications();
                                    notifications.toUser = UserLogin()..objectId = toUserId;
                                    notifications.fromUser = UserLogin()..objectId = fromUserId;
                                    notifications.toProfile = ProfilePage()..objectId = toProfileId;
                                    notifications.fromProfile = ProfilePage()..objectId = fromProfileId;
                                    notifications.notificationType = 'Call';
                                    notifications.isRead = false;

                                    NotificationsProviderApi().add(notifications);
                                  } else {
                                    _priceController.isPurchase.value = false;
                                    Get.to(() => StoreScreen());
                                  }
                                }
                              }
                            }
                          },
                        );
                      }
                    : () {
                        if (kDebugMode) {
                          print('Call onTap disable');
                        }
                      },
                child: SvgView('assets/Icons/call.svg',
                    key: ValueKey<bool>(enable), height: 24.w, width: 24.w, color: enable ? ConstColors.themeColor : ConstColors.offlineColor),
              );
            }),
            SizedBox(width: 17.w),
            Obx(() {
              _conController.isUpdate.value;
              _conController.isCallBusy.value;
              final bool enable = (_conController.isVideocallEnable.value && !toUserDeleted && !fromUserDeleted);
              return InkWell(
                onTap: enable
                    ? () {
                        showBottomSheetAudioVideoCall(
                          context,
                          title: 'videocall'.tr,
                          callTitle: 'make_videocall'.tr,
                          description: 'videocall_description'.tr,
                          isOnline: (_conController.isOnline != null && _conController.isOnline!.value),
                          askPermissionOnTap: () {
                            Get.back();
                            _priceController.chat.text = 'I_can_call_you_now'.tr;
                          },
                          callOnTap: () async {
                            await checkUserPermission(video: true);
                            final PermissionStatus microphone = await Permission.microphone.status;
                            final PermissionStatus camera = await Permission.camera.status;
                            if (microphone.isGranted && camera.isGranted) {
                              if (_priceController.isPurchase.value == false) {
                                _priceController.isPurchase.value = true;
                                if (StorageService.getBox.read('Gender') == 'female') {
                                  final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                                  final String fromUserId = StorageService.getBox.read('ObjectId');
                                  final String toUserId = toUser['objectId'];
                                  final String channelName = '${fromUserId}_$toUserId';

                                  final PairNotifications pairNotifications = PairNotifications();

                                  pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
                                  pairNotifications.fromProfile = ProfilePage()..objectId = fromProfileId;
                                  pairNotifications.users = [ProfilePage()..objectId = fromProfileId, ProfilePage()..objectId = toProfileId];
                                  pairNotifications.message = '';
                                  pairNotifications.notificationType = 'VideoCall';
                                  pairNotifications.isPurchased = true;
                                  pairNotifications.isRead = true;
                                  pairNotifications.fromUser = UserLogin()..objectId = fromUserId;
                                  pairNotifications.toUser = UserLogin()..objectId = toUserId;

                                  final ApiResponse apiResponse = await PairNotificationProviderApi().add(pairNotifications);
                                  if (_conController.isCallBusy.value) {
                                    Get.to(() => DialWaitingPage(
                                            img: toProfileImg, name: toProfileName, pairNotificationsId: apiResponse.result['objectId']))!
                                        .whenComplete(() {
                                      _priceController.isPurchase.value = false;
                                    });
                                  } else {
                                    final CallModel callModel = CallModel();
                                    callModel.reason = 'OffLine';
                                    callModel.fromUserId = ProfilePage()..objectId = fromProfileId;
                                    callModel.fromUser = UserLogin()..objectId = fromUserId;
                                    callModel.toUserID = ProfilePage()..objectId = toProfileId;
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
                                    if (toUser['CallNotification']) {
                                      CallService.makeCall(
                                          userId: toUser['objectId'],
                                          fromProfileId: fromProfileId,
                                          type: "Calling you",
                                          callId: save.result['objectId'],
                                          isVoiceCall: false);
                                    }
                                  }

                                  final Notifications notifications = Notifications();
                                  notifications.toUser = UserLogin()..objectId = toUserId;
                                  notifications.fromUser = UserLogin()..objectId = fromUserId;
                                  notifications.toProfile = ProfilePage()..objectId = toProfileId;
                                  notifications.fromProfile = ProfilePage()..objectId = fromProfileId;
                                  notifications.notificationType = 'VideoCall';
                                  notifications.isRead = false;

                                  NotificationsProviderApi().add(notifications);
                                  // }
                                } else {
                                  if (_priceController.userTotalCoin.value >= _priceController.videoCallPrice.value) {
                                    final UserCallProviderApi userCallProviderApi = UserCallProviderApi();
                                    final String fromUserId = StorageService.getBox.read('ObjectId');
                                    final String toUserId = toUser['objectId'];
                                    final String channelName = '${fromUserId}_$toUserId';
                                    final PairNotifications pairNotifications = PairNotifications();

                                    pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
                                    pairNotifications.fromProfile = ProfilePage()..objectId = fromProfileId;
                                    pairNotifications.users = [ProfilePage()..objectId = fromProfileId, ProfilePage()..objectId = toProfileId];
                                    pairNotifications.message = '';
                                    pairNotifications.notificationType = 'VideoCall';
                                    pairNotifications.isPurchased = true;
                                    pairNotifications.isRead = true;
                                    pairNotifications.fromUser = UserLogin()..objectId = fromUserId;
                                    pairNotifications.toUser = UserLogin()..objectId = toUserId;

                                    final ApiResponse apiResponse = await PairNotificationProviderApi().add(pairNotifications);
                                    if (_conController.isCallBusy.value) {
                                      Get.to(() => DialWaitingPage(
                                              img: toProfileImg, pairNotificationsId: apiResponse.result['objectId'], name: toProfileName))!
                                          .whenComplete(() {
                                        _priceController.isPurchase.value = false;
                                      });
                                    } else {
                                      final CallModel callModel = CallModel();
                                      callModel.reason = 'OffLine';
                                      callModel.fromUserId = ProfilePage()..objectId = fromProfileId;
                                      callModel.fromUser = UserLogin()..objectId = fromUserId;
                                      callModel.toUserID = ProfilePage()..objectId = toProfileId;
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
                                      if (toUser['CallNotification']) {
                                        CallService.makeCall(
                                            userId: toUser['objectId'],
                                            fromProfileId: fromProfileId,
                                            type: "Calling you",
                                            callId: save.result['objectId'],
                                            isVoiceCall: false);
                                      }
                                    }

                                    final Notifications notifications = Notifications();
                                    notifications.toUser = UserLogin()..objectId = toUserId;
                                    notifications.fromUser = UserLogin()..objectId = fromUserId;
                                    notifications.toProfile = ProfilePage()..objectId = toProfileId;
                                    notifications.fromProfile = ProfilePage()..objectId = fromProfileId;
                                    notifications.notificationType = 'VideoCall';
                                    notifications.isRead = false;

                                    NotificationsProviderApi().add(notifications);
                                  } else {
                                    _priceController.isPurchase.value = false;
                                    Get.to(() => StoreScreen());
                                  }
                                }
                              }
                            }
                          },
                        );
                      }
                    : () {
                        if (kDebugMode) {
                          print('Video Call onTap disable');
                        }
                      },
                child: SvgView('assets/Icons/video_camera.svg',
                    key: ValueKey<bool>(enable), width: 24.w, color: enable ? ConstColors.themeColor : ConstColors.offlineColor),
              );
            }),
          ] else ...[
            Obx(() {
              pictureX.chatTranslate.value;
              return RoundButton(
                key: ValueKey<bool>(pictureX.chatTranslate.value),
                svg: pictureX.chatTranslate.value ? 'assets/Icons/chatTranslate.svg' : 'assets/Icons/chatTranslate_off.svg',
                onTap: () {
                  pictureX.chatTranslate.value = !pictureX.chatTranslate.value;
                },
              );
            }),
            SizedBox(width: 13.w),
            RoundButton(
              key: const ValueKey(1),
              svg: 'assets/Icons/report.svg',
              onTap: () {
                _blockPanel(context);
              },
            ),
          ]
        ],
      ),
    );
  }

  Widget _chatInput(context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.only(bottom: 10.h, left: 10.w, right: 10.w, top: 8.h),
        child: Theme(
          data: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                  cursorColor: ConstColors.themeColor, selectionColor: ConstColors.themeColor, selectionHandleColor: ConstColors.redColor)),
          child: TextFormField(
            maxLength: 250,
            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
            controller: _priceController.chat,
            minLines: 1,
            maxLines: 2,
            onChanged: _conController.sendTypingNotification,
            cursorColor: ConstColors.themeColor,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              counterStyle: TextStyle(color: Colors.grey, fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
              hintText: 'Write_a_message'.tr,
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              isDense: true,
              semanticCounterText: tableName == "Chat_Message" ? "" : null,
              counterText: tableName == "Chat_Message" ? "" : null,
              hintStyle: TextStyle(color: Colors.grey, fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
              suffixIcon: Obx(() {
                 _conController.isUpdate.value;
                _conController.onlineStatus.value;
                _conController.clicked.value;
                return InkWell(
                  onTap: (_conController.clicked.value || description == null && !_conController.onlineStatus.value) || toUserDeleted || fromUserDeleted
                      ? () {
                          if (kDebugMode) {
                            print('Hello chat text click disable');
                          }
                        }
                      : () async {
                          // _conController.clicked.value = true;
                          if (_priceController.chat.text.trim().isNotEmpty) {
                            await _conController
                                .save(
                                    toProfile: toProfileId,
                                    fromProfileId: fromProfileId,
                                    toUser: toUserId,
                                    gender: toUserGender,
                                    tableName: tableName,
                                    chatType: 'Text')
                                .whenComplete(() {
                              _conController.clicked.value = false;
                            });
                          }
                          _conController.clicked.value = false;
                        },
                  child: Container(
                    padding: EdgeInsets.only(top: 12.r, bottom: 12.r, right: 12.r, left: 20.r),
                    child: SvgView("assets/Icons/send.svg",
                        color: (description == null && !_conController.onlineStatus.value) || toUserDeleted || fromUserDeleted ? Colors.grey : ConstColors.themeColor),
                  ),
                );
              }),
              enabledBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide(color: const Color(0xffEAEBEF), width: 1.w)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide(color: const Color(0xffEAEBEF), width: 1.w)),
              disabledBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide(color: const Color(0xffEAEBEF), width: 1.w)),
              errorBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide(color: const Color(0xffEAEBEF), width: 1.w)),
              focusedBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide(color: const Color(0xffEAEBEF), width: 1.w)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomMenu(context) {
    return Obx(() {
      _conController.isUpdate.value;
      _conController.onlineStatus.value;
      final bool enable = (toUserDeleted || fromUserDeleted || !_conController.onlineStatus.value);
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10.h, left: 10.w, right: 10.w, top: 8.h),
        child: Row(
          children: [
            // CHAT GIFT
            RoundButton(
              key: const ValueKey(0),
              svg: 'assets/Icons/gift.svg',
              enable: !enable,
              onTap: _priceController.isGiftSending.value || _conController.giftsList.isEmpty
                  ? null
                  : () {
                      FocusManager.instance.primaryFocus!.unfocus();
                      chatGiftSheet(
                        context,
                        giftsList: _conController.giftsList,
                        onTap: (giftObject) async {
                          // handle click event for sending gift to user
                          await _conController.save(
                            toProfile: toProfileId,
                            fromProfileId: fromProfileId,
                            toUser: toUserId,
                            gender: toUserGender,
                            tableName: tableName,
                            giftObject: giftObject,
                            chatType: "Gift",
                          );
                        },
                      );
                    },
            ),
            SizedBox(width: 13.w),
            // UPLOAD VIDEO IN CHAT
            RoundButton(
              key: const ValueKey(1),
              svg: 'assets/Icons/videoPost.svg',
              enable: !enable,
              onTap: _conController.isUploading.value
                  ? null
                  : () async {
                      FocusManager.instance.primaryFocus!.unfocus();
                      await _conController.uploadPosts(isVideo: true).then((file) async {
                        if (file != null) {
                          // CHECK VIDEO SIZE [40MB] MAX LIMIT
                          if (file.lengthSync() < videoLimit) {
                            await ThumbUrl.file(file.path).then((value) async {
                              if (value != null) {
                                _conController.isUploading.value = true;
                                final image = File(value).readAsBytesSync();
                                final decodedImage = await decodeImageFromList(image);
                                final bool isLandscape = decodedImage.width > decodedImage.height;
                                _conController.postPath.addAll({'Type': 'Video', 'Image': value, "IsLandscape": isLandscape});
                                await _conController.save(
                                  toProfile: toProfileId,
                                  fromProfileId: fromProfileId,
                                  toUser: toUserId,
                                  gender: toUserGender,
                                  tableName: tableName,
                                  postMap: {'image': base64Encode(image), 'video': base64Encode(file.readAsBytesSync()), 'isLandscape': isLandscape},
                                  chatType: "Video",
                                );
                              }
                            });
                          } else {
                            gradientSnackBar(context,
                                image: 'assets/Icons/videoPost.svg',
                                title: 'upload_video_less_40mb',
                                color1: ConstColors.darkRedBlackColor,
                                color2: ConstColors.redColor);
                          }
                        }
                      });
                    },
            ),
            SizedBox(width: 13.w),
            // UPLOAD IMAGE IN CHAT
            RoundButton(
              key: const ValueKey(2),
              enable: !enable,
              svg: 'assets/Icons/imagePost.svg',
              onTap: _conController.isUploading.value
                  ? null
                  : () async {
                      FocusManager.instance.primaryFocus!.unfocus();
                      await _conController.uploadPosts().then((value) async {
                        if (value != null) {
                          if (value.lengthSync() < imageLimit) {
                            _conController.isUploading.value = true;
                            final image = value.readAsBytesSync();
                            final decodedImage = await decodeImageFromList(image);
                            final bool isLandscape = decodedImage.width > decodedImage.height;
                            _conController.postPath.addAll({'Type': 'Image', 'Image': value.path, "IsLandscape": isLandscape});
                            await _conController.save(
                              toProfile: toProfileId,
                              fromProfileId: fromProfileId,
                              toUser: toUserId,
                              gender: toUserGender,
                              tableName: tableName,
                              postMap: {'image': base64Encode(image), 'isLandscape': isLandscape},
                              chatType: "Image",
                            );
                          } else {
                            gradientSnackBar(context,
                                image: 'assets/Icons/imagePost.svg',
                                title: 'upload_image_less_20mb'.tr,
                                color1: ConstColors.darkRedBlackColor,
                                color2: ConstColors.redColor);
                          }
                        }
                      });
                    },
            ),
            SizedBox(width: 13.w),
            // TRANSLATE CHAT MESSAGE
            Obx(() {
              pictureX.chatTranslate.value;
              return RoundButton(
                key: ValueKey<bool>(pictureX.chatTranslate.value),
                svg: pictureX.chatTranslate.value ? 'assets/Icons/chatTranslate.svg' : 'assets/Icons/chatTranslate_off.svg',
                onTap: () {
                  FocusManager.instance.primaryFocus!.unfocus();
                  pictureX.chatTranslate.value = !pictureX.chatTranslate.value;
                },
              );
            }),
            SizedBox(width: 13.w),
            // REPORT OR BLOCK USER
            RoundButton(
              key: const ValueKey(4),
              svg: 'assets/Icons/report.svg',
              onTap: () {
                FocusManager.instance.primaryFocus!.unfocus();
                _blockPanel(context);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _progress() {
    return Column(
      children: [
        // when we send video, image show loading
        if (_conController.isUploading.value && _conController.postPath.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Builder(builder: (context) {
              final bool isLandscape = _conController.postPath['IsLandscape'] ?? false;
              return Container(
                alignment: Alignment.center,
                height: isLandscape ? 175.h : 250.w,
                width: isLandscape ? 250.w : 175.w,
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  border: Border.all(color: ConstColors.themeColor, width: 2.w),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(3.r)),
                  color: const Color(0xFF767676),
                  image: _conController.postPath['Image'] != null
                      ? DecorationImage(image: FileImage(File(_conController.postPath['Image'])), fit: BoxFit.cover)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Lottie.asset('assets/jsons/top-loading.json', width: 65.w, height: 65.w, fit: BoxFit.cover),
                    const Spacer(),
                    if (_conController.postPath['Type'].toString().contains('Video'))
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.w, bottom: 10.h),
                          child: SvgView('assets/Icons/video_outline.svg', height: 15.w, width: 15.w, fit: BoxFit.cover, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        // when opposite user typing
        if (_conController.isTyping.value)
          Align(
            alignment: Alignment.topLeft,
            child: Transform(
              transform: Matrix4.translationValues(-16, 0, 0),
              child: Lottie.asset('assets/jsons/chat-jumping.json', height: 70.h, fit: BoxFit.cover, alignment: Alignment.topLeft),
            ),
          ),
      ],
    );
  }

  Future<void> _blockPanel(context) async {
    final UserController userController = Get.find<UserController>();
    showBottomSheetBlockReport(
      context,
      informOnTap: (String reason, String moreReason) async {
        /// Report Add To Database
        userController.blockloading.value = true;
        final BlockUser block = BlockUser();
        block.emailuser = reason;
        block['Reason'] = 'Just to Inform';
        block['Description'] = moreReason;
        block.type = "REPORT";
        block.toUser = UserLogin()..objectId = toUserId;
        block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
        block.toProfile = ProfilePage()..objectId = toProfileId;
        block.fromProfile = ProfilePage()..objectId = fromProfileId;
        await BlockUSerProviderApi().add(block);
        userController.blockloading.value = false;
        Get.back();
      },
      bothOnTap: (String reason, String moreReason) async {
        userController.blockloading.value = true;

        /// BLOCK ENTRY
        final BlockUser block = BlockUser();
        block.emailuser = reason;
        block['Reason'] = 'REPORT AND BLOCK';
        block['Description'] = moreReason;
        block.toUser = UserLogin()..objectId = toUserId;
        block.type = "BLOCK";
        block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
        block.toProfile = ProfilePage()..objectId = toProfileId;
        block.fromProfile = ProfilePage()..objectId = fromProfileId;
        BlockUSerProviderApi().add(block);
        await PairNotificationProviderApi().getByProfile(fromProfileId, toProfileId, 'BlocUser').then((val) async {
          final PairNotifications pairNotifications = PairNotifications();
          if (val == null) {
            pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
            pairNotifications.fromProfile = ProfilePage()..objectId = fromProfileId;
            pairNotifications.users = [ProfilePage()..objectId = fromProfileId, ProfilePage()..objectId = toProfileId];
            pairNotifications.message = '';
            pairNotifications.notificationType = 'BlocUser';
            pairNotifications.isPurchased = true;
            pairNotifications.isRead = true;
            pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
            pairNotifications.toUser = UserLogin()..objectId = toUserId;
            PairNotificationProviderApi().add(pairNotifications);
          } else {
            pairNotifications.objectId = val.result['objectId'];
            pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
            pairNotifications.fromProfile = ProfilePage()..objectId = fromProfileId;
            pairNotifications.users = [ProfilePage()..objectId = fromProfileId, ProfilePage()..objectId = toProfileId];
            pairNotifications.message = '';
            pairNotifications.notificationType = 'BlocUser';
            pairNotifications.isPurchased = true;
            pairNotifications.isRead = true;
            pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
            pairNotifications.toUser = UserLogin()..objectId = toUserId;
            pairNotifications.deletedUsers = [];
            PairNotificationProviderApi().update(pairNotifications);
          }
        });

        /// REPORT ENTRY
        final BlockUser report = BlockUser();
        report.emailuser = reason;
        report['Reason'] = 'Just to Inform';
        report['Description'] = moreReason;
        report.type = "REPORT";
        report.toUser = UserLogin()..objectId = toUserId;
        report.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
        report.toProfile = ProfilePage()..objectId = toProfileId;
        report.fromProfile = ProfilePage()..objectId = fromProfileId;
        await BlockUSerProviderApi().add(report);

        userController.blockloading.value = false;
        _searchController.load.value = false;
        _searchController.likeList.clear();
        _searchController.imagePostCount.clear();
        _searchController.wallPostCount.clear();
        _searchController.wallVideoPostCount.clear();
        _searchController.videoPostCount.clear();
        pictureX.swiperIndex.value = 0;
        _searchController.finalPost.clear();
        _searchController.tempGetWallProfileId.clear();
        _searchController.parseObjectList.clear();
        _searchController.showNudeImage.clear();
        indexMuroList.clear();
        _searchController.seenKeys.clear();
        _searchController.page.value = 0;
        pictureX.swiperIndex.value = 0;
        _searchController.update();
        Get.back();
      },
      blockOnTap: () async {
        userController.blockloading.value = true;
        final BlockUser block = BlockUser();
        block.emailuser = "Block User";
        block.toUser = UserLogin()..objectId = toUserId;
        block.type = "BLOCK";
        block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
        block.toProfile = ProfilePage()..objectId = toProfileId;
        block.fromProfile = ProfilePage()..objectId = fromProfileId;
        BlockUSerProviderApi().add(block);
        await PairNotificationProviderApi().getByProfile(fromProfileId, toProfileId, 'BlocUser').then((val) async {
          final PairNotifications pairNotifications = PairNotifications();
          if (val == null) {
            pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
            pairNotifications.fromProfile = ProfilePage()..objectId = fromProfileId;
            pairNotifications.users = [ProfilePage()..objectId = fromProfileId, ProfilePage()..objectId = toProfileId];
            pairNotifications.message = '';
            pairNotifications.notificationType = 'BlocUser';
            pairNotifications.isPurchased = true;
            pairNotifications.isRead = true;
            pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
            pairNotifications.toUser = UserLogin()..objectId = toUserId;
            PairNotificationProviderApi().add(pairNotifications);
          } else {
            pairNotifications.objectId = val.result['objectId'];
            pairNotifications.toProfile = ProfilePage()..objectId = toProfileId;
            pairNotifications.fromProfile = ProfilePage()..objectId = fromProfileId;
            pairNotifications.users = [ProfilePage()..objectId = fromProfileId, ProfilePage()..objectId = toProfileId];
            pairNotifications.message = '';
            pairNotifications.notificationType = 'BlocUser';
            pairNotifications.isPurchased = true;
            pairNotifications.isRead = true;
            pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
            pairNotifications.toUser = UserLogin()..objectId = toUserId;
            pairNotifications.deletedUsers = [];
            PairNotificationProviderApi().update(pairNotifications);
          }
        });
        userController.blockloading.value = false;
        _searchController.load.value = false;
        _searchController.likeList.clear();
        _searchController.imagePostCount.clear();
        _searchController.wallPostCount.clear();
        _searchController.wallVideoPostCount.clear();
        _searchController.videoPostCount.clear();
        pictureX.swiperIndex.value = 0;
        _searchController.finalPost.clear();
        _searchController.tempGetWallProfileId.clear();
        _searchController.parseObjectList.clear();
        _searchController.showNudeImage.clear();
        indexMuroList.clear();
        _searchController.seenKeys.clear();
        _searchController.page.value = 0;
        pictureX.swiperIndex.value = 0;
        _searchController.update();
        Get.back();
      },
    );

    // showModalBottomSheet<void>(
    //   backgroundColor: Colors.transparent,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30.r), topRight: Radius.circular(30.r))),
    //   context: context,
    //   builder: (BuildContext con) {
    //     return Container(
    //         height: 356.h,
    //         decoration: BoxDecoration(color: bottomColor(), borderRadius: BorderRadius.only(topLeft: Radius.circular(10.r), topRight: Radius.circular(10.r))),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Padding(
    //               padding: EdgeInsets.only(top: 20.h, bottom: 20.0.h),
    //               child: Row(
    //                 children: [
    //                   Expanded(
    //                     child: Padding(
    //                       padding: EdgeInsets.only(left: 53.0.w),
    //                       child: Styles.regular('Select_an_option'.tr, fs: 20.sp, c: Theme.of(context).primaryColor, al: TextAlign.center),
    //                     ),
    //                   ),
    //                   GestureDetector(
    //                     onTap: () {
    //                       Get.back();
    //                     },
    //                     child: Padding(
    //                         padding: EdgeInsets.only(right: 18.0.w),
    //                         child: Icon(
    //                           Icons.close,
    //                           color: Theme.of(context).primaryColor,
    //                           size: 21.w,
    //                         )),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             Divider(color: const Color(0xFFE5E5E5), height: 1.0.w),
    //             GestureDetector(
    //               onTap: () {
    //                 Get.back();
    //                 showDialog<String>(
    //                   context: context,
    //                   builder: (BuildContext context) => StatefulBuilder(
    //                     builder: (context, setState) {
    //                       return AlertDialog(
    //                         backgroundColor: bottomColor(),
    //                         actionsAlignment: MainAxisAlignment.center,
    //                         contentPadding: EdgeInsets.only(top: 16.h, bottom: 20.h),
    //                         elevation: 0.0,
    //                         content: SizedBox(
    //                           width: 367.w,
    //                           height: pictureX.reportText == 'other'.tr ? 406.w : 355.w,
    //                           child: Column(
    //                             mainAxisSize: MainAxisSize.min,
    //                             children: [
    //                               Row(
    //                                 crossAxisAlignment: CrossAxisAlignment.center,
    //                                 children: [
    //                                   Padding(
    //                                     padding: EdgeInsets.only(left: 21.w),
    //                                     child: SvgView("assets/Icons/reportIcon.svg", height: 35.w, width: 26.w, color: ConstColors.themeColor),
    //                                   ),
    //                                   Expanded(
    //                                     child: Padding(
    //                                       padding: EdgeInsets.only(right: 35.w),
    //                                       child: Styles.regular('report'.tr, c: Theme.of(context).primaryColor, al: TextAlign.center, fw: FontWeight.bold, fs: 20.sp),
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                               SizedBox(
    //                                 height: 15.h,
    //                               ),
    //                               const Divider(
    //                                 thickness: 1.0,
    //                                 color: Color(0xFFECECEC),
    //                               ),
    //                               SizedBox(
    //                                 height: 25.h,
    //                               ),
    //                               ListView.builder(
    //                                 shrinkWrap: true,
    //                                 itemCount: pictureX.sampleData.length,
    //                                 itemBuilder: (BuildContext context, int index) {
    //                                   return GestureDetector(
    //                                     onTap: () {
    //                                       setState(() {
    //                                         for (var element in pictureX.sampleData) {
    //                                           element.isSelected = false;
    //                                         }
    //                                         pictureX.sampleData[index].isSelected = true;
    //                                         pictureX.reportText = pictureX.sampleData[index].text;
    //                                       });
    //                                     },
    //                                     child: RadioItem(pictureX.sampleData[index]),
    //                                   );
    //                                 },
    //                               ),
    //                               if (pictureX.reportText == 'other'.tr)
    //                                 TextFieldModel(
    //                                     color: Colors.black,
    //                                     controllers: pictureX.reportTextController,
    //                                     onChanged: (value) {
    //                                       pictureX.reportText = value;
    //                                     },
    //                                     hint: 'write_the_reason'.tr,
    //                                     width: 345.w),
    //                               SizedBox(height: 15.h),
    //                               const Divider(thickness: 1.0, color: Color(0xFFECECEC)),
    //                               SizedBox(height: 15.h),
    //                               Row(
    //                                 mainAxisAlignment: MainAxisAlignment.center,
    //                                 children: [
    //                                   GestureDetector(
    //                                     onTap: () {
    //                                       Get.back();
    //                                     },
    //                                     child: Container(
    //                                         height: 42.w,
    //                                         width: 115.w,
    //                                         decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10.r)),
    //                                         alignment: Alignment.center,
    //                                         child: Styles.regular('Cancel'.tr, fs: 16.sp, c: Colors.white)),
    //                                   ),
    //                                   SizedBox(
    //                                     width: 8.w,
    //                                   ),
    //                                   GestureDetector(
    //                                     /// Report Add To Database
    //                                     onTap: () async {
    //                                       userController.blockloading.value = true;
    //                                       BlockUser block = BlockUser();
    //                                       block.emailuser = pictureX.reportText;
    //                                       block.type = "REPORT";
    //
    //                                       UserProfileProviderApi().getById(otherDefaultProfileId!).then((value) async {
    //                                         block.toUser = UserLogin()..objectId = value.result['User']['objectId'];
    //
    //                                         block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
    //
    //                                         block.toProfile = ProfilePage()..objectId = otherDefaultProfileId;
    //
    //                                         block.fromProfile = ProfilePage()..objectId = fromProfileId;
    //                                         await BlockUSerProviderApi().add(block);
    //                                       });
    //
    //                                       pictureX.block.clear();
    //                                       for (var element in pictureX.sampleData) {
    //                                         element.isSelected = false;
    //                                       }
    //                                       pictureX.reportText = '';
    //                                       userController.blockloading.value = false;
    //                                       pictureX.reportTextController.clear();
    //                                       Get.back();
    //                                     },
    //
    //                                     child: Container(
    //                                         height: 42.w,
    //                                         width: 115.w,
    //                                         decoration: BoxDecoration(color: ConstColors.themeColor, borderRadius: BorderRadius.circular(10.r)),
    //                                         alignment: Alignment.center,
    //                                         child: Styles.regular('report'.tr, fs: 16.sp, c: Colors.white)),
    //                                   ),
    //                                 ],
    //                               )
    //                             ],
    //                           ),
    //                         ),
    //                       );
    //                     },
    //                   ),
    //                 );
    //               },
    //               child: Container(
    //                 width: 397.w,
    //                 height: 52.w,
    //                 margin: EdgeInsets.only(bottom: 15.0.h, top: 25.0.h),
    //                 alignment: Alignment.center,
    //                 decoration: BoxDecoration(
    //                   color: ConstColors.themeColor,
    //                   borderRadius: BorderRadius.circular(10.0.r),
    //                 ),
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     Styles.regular('report'.tr, c: Colors.white, fs: 20.sp, al: TextAlign.center),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             GestureDetector(
    //               onTap: () {
    //                 Get.back();
    //                 showDialog(
    //                     context: context,
    //                     builder: (BuildContext context) {
    //                       return AlertDialog(
    //                         backgroundColor: bottomColor(),
    //                         contentPadding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 21.h),
    //                         content: Column(
    //                           mainAxisSize: MainAxisSize.min,
    //                           children: [
    //                             Row(
    //                               children: [
    //                                 Expanded(child: Styles.regular('are_you_sure'.tr, c: Theme.of(context).primaryColor, al: TextAlign.center, fs: 22.sp, fw: FontWeight.bold)),
    //                               ],
    //                             ),
    //                             SizedBox(
    //                               height: 24.h,
    //                             ),
    //                             Row(
    //                               mainAxisAlignment: MainAxisAlignment.center,
    //                               children: [Styles.regular('this_profile_will_be_blocked'.tr, c: Theme.of(context).primaryColor, fs: 20.sp)],
    //                             ),
    //                             SizedBox(
    //                               height: 29.h,
    //                             ),
    //                             Row(
    //                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                               children: [
    //                                 GestureDetector(
    //                                   onTap: () {
    //                                     Get.back();
    //                                   },
    //                                   child: Container(
    //                                     height: 42.h,
    //                                     width: 115.w,
    //                                     alignment: Alignment.center,
    //                                     decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10.0)),
    //                                     child: Styles.regular('Cancel'.tr, c: Colors.white, fs: 16.sp),
    //                                   ),
    //                                 ),
    //                                 SizedBox(width: 8.w),
    //                                 GestureDetector(
    //                                   onTap: () async {
    //                                     userController.blockloading.value = true;
    //                                     BlockUser block = BlockUser();
    //                                     block.emailuser = "Block User";
    //                                     Get.back();
    //                                     await UserProfileProviderApi().getById(otherDefaultProfileId!).then((value) async {
    //                                       block.toUser = UserLogin()..objectId = value.result['User']['objectId'];
    //                                       block.type = "BLOCK";
    //                                       block.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
    //                                       block.toProfile = ProfilePage()..objectId = otherDefaultProfileId;
    //                                       block.fromProfile = ProfilePage()..objectId = fromProfileId;
    //                                       BlockUSerProviderApi().add(block);
    //                                       await PairNotificationProviderApi().getByProfile(fromProfileId, otherDefaultProfileId, 'BlocUser').then((val) async {
    //                                         PairNotifications pairNotifications = PairNotifications();
    //                                         if (val == null) {
    //                                           pairNotifications.toProfile = ProfilePage()..objectId = otherDefaultProfileId;
    //                                           pairNotifications.fromProfile = ProfilePage()..objectId = fromProfileId;
    //                                           pairNotifications.users = [ProfilePage()..objectId = fromProfileId, ProfilePage()..objectId = otherDefaultProfileId];
    //                                           pairNotifications.message = '';
    //                                           pairNotifications.notificationType = 'BlocUser';
    //                                           pairNotifications.isPurchased = true;
    //                                           pairNotifications.isRead = true;
    //                                           pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
    //                                           pairNotifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];
    //                                           PairNotificationProviderApi().add(pairNotifications);
    //                                         } else {
    //                                           pairNotifications.objectId = val.result['objectId'];
    //                                           pairNotifications.toProfile = ProfilePage()..objectId = otherDefaultProfileId;
    //                                           pairNotifications.fromProfile = ProfilePage()..objectId = fromProfileId;
    //                                           pairNotifications.users = [ProfilePage()..objectId = fromProfileId, ProfilePage()..objectId = otherDefaultProfileId];
    //                                           pairNotifications.message = '';
    //                                           pairNotifications.notificationType = 'BlocUser';
    //                                           pairNotifications.isPurchased = true;
    //                                           pairNotifications.isRead = true;
    //                                           pairNotifications.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
    //                                           pairNotifications.toUser = UserLogin()..objectId = value.result['User']['objectId'];
    //                                           pairNotifications.deletedUsers = [];
    //                                           PairNotificationProviderApi().update(pairNotifications);
    //                                         }
    //                                       });
    //                                     });
    //                                     pictureX.block.clear();
    //                                     userController.blockloading.value = false;
    //                                     searchController.load.value = false;
    //                                     searchController.likeList.clear();
    //                                     searchController.imagePostCount.clear();
    //                                     searchController.videoPostCount.clear();
    //                                     pictureX.swiperIndex.value = 0;
    //                                     searchController.finalPost.clear();
    //                                     searchController.seenKeys.clear();
    //                                     searchController.page.value = 0;
    //                                     pictureX.swiperIndex.value = 0;
    //                                     searchController.update();
    //                                     Get.back();
    //                                   },
    //                                   child: Container(
    //                                     height: 42.h,
    //                                     width: 115.w,
    //                                     alignment: Alignment.center,
    //                                     decoration: BoxDecoration(color: ConstColors.themeColor, borderRadius: BorderRadius.circular(10.0)),
    //                                     child: Styles.regular('blocker'.tr, c: Colors.white, fs: 16.sp),
    //                                   ),
    //                                 )
    //                               ],
    //                             )
    //                           ],
    //                         ),
    //                       );
    //                     });
    //               },
    //               child: Container(
    //                 width: 397.w,
    //                 height: 52.w,
    //                 margin: EdgeInsets.only(bottom: 15.0.h),
    //                 alignment: Alignment.center,
    //                 decoration: BoxDecoration(
    //                   color: ConstColors.themeColor,
    //                   borderRadius: BorderRadius.circular(10.0.r),
    //                 ),
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     Styles.regular('blocker'.tr, c: Colors.white, fs: 20.sp, al: TextAlign.center),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             GestureDetector(
    //               onTap: () {
    //                 Get.back();
    //               },
    //               child: Container(
    //                 width: 397.w,
    //                 height: 52.w,
    //                 alignment: Alignment.center,
    //                 decoration: BoxDecoration(
    //                   color: Colors.grey,
    //                   borderRadius: BorderRadius.circular(10.0.r),
    //                 ),
    //                 child: Styles.regular('Cancel'.tr, fs: 15, c: Colors.white),
    //               ),
    //             ),
    //           ],
    //         ));
    //   },
    // );
  }
}
