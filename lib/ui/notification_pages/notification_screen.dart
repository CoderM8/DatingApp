// ignore_for_file: must_be_immutable, invalid_use_of_protected_member
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/post_view.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/PairNotificationController/pair_notification_controller.dart';
import 'package:eypop/Controllers/all_notification_controller/all_notification_controller.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/Controllers/tab_Controller/conversation_controller.dart';
import 'package:eypop/back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/tab_provider/provider_chatmsg.dart';
import 'package:eypop/back4appservice/user_provider/tab_provider/provider_likemsg.dart';
import 'package:eypop/models/new_notification/new_notification_pair.dart';
import 'package:eypop/models/tab_model/chat_message.dart';
import 'package:eypop/models/tab_model/like_message.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/User_profile/user_fullprofile_screen.dart';
import 'package:eypop/ui/notification_pages/calles_screen.dart';
import 'package:eypop/ui/notification_pages/messages_screen.dart';
import 'package:eypop/ui/tab_pages/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

AppSearchController _searchController = Get.put(AppSearchController());

class NotificationScreen extends GetView {
  const NotificationScreen({Key? key}) : super(key: key);

  PairNotificationController get _pairNotificationController => Get.put(PairNotificationController());

  AllNotificationController get _allNotificationController => Get.put(AllNotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).hintColor,
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 80.h,
          title: Styles.regular("DinDon", c: ConstColors.darkGreyColor, ff: "HB", fs: 68.sp),
        ),
        body: Obx(() {
          _pairNotificationController.isLoading.value;
          return ModalProgressHUD(
            inAsyncCall: _pairNotificationController.isLoading.value,
            progressIndicator: Container(
              color: Theme.of(context).hintColor,
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              alignment: Alignment.center,
              child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown),
            ),
            child: AnimatedOpacity(
              opacity: _pairNotificationController.isLoading.value ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 375),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // CHAT
                    ChatPart(
                      localNotification: 'chats'.tr,
                      pairController: _pairNotificationController,
                      allController: _allNotificationController,
                    ),
                    // MESSAGE
                    MessagePart(
                      localNotification: 'messages'.tr,
                      pairController: _pairNotificationController,
                      allController: _allNotificationController,
                    ),
                    // AUDIO CALL
                    CallPart(
                      localNotification: 'calls'.tr,
                      notificationName: "Llamadas",
                      allController: _allNotificationController,
                      pairController: _pairNotificationController,
                    ),
                    // VIDEO CALL
                    VideoCallPart(
                      localNotification: "Video_calls".tr,
                      notificationName: "Videollamada",
                      allController: _allNotificationController,
                      pairController: _pairNotificationController,
                    ),
                    // HEART LIKE
                    HeartLikePart(
                      localNotification: 'heartLike'.tr,
                      notificationName: "Me gustas",
                      allController: _allNotificationController,
                      pairController: _pairNotificationController,
                    ),
                    // VISIT
                    VisitPart(
                      localNotification: 'visits'.tr,
                      notificationName: "Visitas",
                      allController: _allNotificationController,
                      pairController: _pairNotificationController,
                    ),
                    // WINK
                    WinkMessagePart(
                      localNotification: 'winks'.tr,
                      notificationName: "Guiños",
                      allController: _allNotificationController,
                      pairController: _pairNotificationController,
                    ),
                    //LIPLIKE
                    LipLikePart(
                      localNotification: 'lipLike'.tr,
                      notificationName: "Besos",
                      allController: _allNotificationController,
                      pairController: _pairNotificationController,
                    ),
                    // WISHES
                    WishesPart(
                      localNotification: 'TokTok',
                      notificationName: "wishes",
                      allController: _allNotificationController,
                      pairController: _pairNotificationController,
                    ),
                    // CHAT GIFTS
                    GiftPart(
                      localNotification: "Gifts".tr,
                      notificationName: "Regalos",
                      allController: _allNotificationController,
                      pairController: _pairNotificationController,
                    ),
                    // BLOCK
                    BlockPart(
                      localNotification: 'block'.tr,
                      notificationName: "Bloqueados",
                      allController: _allNotificationController,
                      pairController: _pairNotificationController,
                    )
                  ],
                ),
              ),
            ),
          );
        }));
  }
}

// CHAT
class ChatPart extends GetView {
  final String localNotification;
  final PairNotificationController pairController;
  final AllNotificationController allController;

  const ChatPart({required this.localNotification, required this.pairController, required this.allController, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pairController.chatMessageList.value;
      pairController.meBlocked.value;
      if (pairController.chatMessageList.isNotEmpty) {
        return Container(
          height: 123.w,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(top: 5.h),
          padding: EdgeInsets.only(left: 9.w, right: 9.w, top: 6.h, bottom: 9.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Styles.regular(localNotification, style: Theme.of(context).textTheme.bodyMedium),
                  // show when user have unread chats
                  Obx(() {
                    if (allController.notificationSwitch('Chats').value) {
                      return Lottie.asset("assets/jsons/notifications.json", height: 22.w, width: 22.w);
                    } else {
                      return SizedBox(height: 22.w, width: 22.w);
                    }
                  }),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                alignment: Alignment.centerLeft,
                height: 78.w,
                child: ListView.separated(
                  itemCount: pairController.chatMessageList.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(width: 5.w),
                  itemBuilder: (context, index) {
                    /// when my user in ToUser
                    final bool isMe = (pairController.chatMessageList[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                    /// other user block me and me block other user
                    final bool isBlockProfile =
                        (pairController.meBlocked.toString().contains(pairController.chatMessageList[index]['FromProfile']['objectId']) &&
                            pairController.meBlocked.toString().contains(pairController.chatMessageList[index]['ToProfile']['objectId']));

                    /// when FromProfile OR FromUser block
                    final bool isFromUserORProfileBlock = ((pairController.chatMessageList[index]['FromUser']['IsBlocked'] ?? false) ||
                        (pairController.chatMessageList[index]['FromProfile']['IsBlocked'] ?? false));

                    /// when ToProfile OR ToUser block
                    final bool isToUserORProfileBlock = ((pairController.chatMessageList[index]['ToUser']['IsBlocked'] ?? false) ||
                        (pairController.chatMessageList[index]['ToProfile']['IsBlocked'] ?? false));

                    /// when FromProfile OR FromUser delete
                    final bool isFromUserORProfileDelete = ((pairController.chatMessageList[index]['FromUser']['isDeleted'] ?? false) ||
                        (pairController.chatMessageList[index]['FromProfile']['isDeleted'] ?? false));

                    /// when ToProfile OR ToUser delete
                    final bool isToUserORProfileDelete = ((pairController.chatMessageList[index]['ToUser']['isDeleted'] ?? false) ||
                        (pairController.chatMessageList[index]['ToProfile']['isDeleted'] ?? false));
                    return Stack(
                      children: [
                        ImageView(
                          isMe
                              ? pairController.chatMessageList[index]['FromProfile']['Imgprofile'].url
                              : pairController.chatMessageList[index]["ToProfile"]['Imgprofile'].url,
                          height: 78.w,
                          width: 78.w,
                          borderRadius: BorderRadius.circular(20.r),
                          // check last chat message inRead or not --> show border red [isRead] false
                          border: Border.all(
                              color: (pairController.chatMessageList[index]['Chat_Message'] == null ||
                                      pairController.chatMessageList[index]['Chat_Message']['isRead'] ||
                                      !isMe)
                                  ? const Color(0xffC1C1C1)
                                  : ConstColors.redColor,
                              width: 2.w),
                          onTap: () async {
                            StorageService.getBox.write(
                                'msgFromProfileId',
                                isMe
                                    ? pairController.chatMessageList[index]['ToProfile']['objectId']
                                    : pairController.chatMessageList[index]['FromProfile']['objectId']);
                            StorageService.getBox.write(
                                'msgToProfileId',
                                isMe
                                    ? pairController.chatMessageList[index]['FromProfile']['objectId']
                                    : pairController.chatMessageList[index]['ToProfile']['objectId']);

                            StorageService.getBox.write('chattablename', 'Chat_Message');

                            StorageService.getBox.save();

                            /// check FromUser is online [YOU] same vala
                            bool onlineStatus;
                            if ((isMe
                                ? pairController.chatMessageList[index]['FromProfile']['NoChats'] ?? false
                                : pairController.chatMessageList[index]['ToProfile']['NoChats'] ?? false)) {
                              if (isMe ? (isFromUserORProfileDelete || isBlockProfile) : (isToUserORProfileDelete || isBlockProfile)) {
                                onlineStatus = false;
                              } else {
                                onlineStatus = true;
                              }
                            } else {
                              onlineStatus = true; // false
                            }
                            Get.delete<ConversationController>();
                            Get.to(
                              () => ConversationScreen(
                                fromUserDeleted: isMe
                                    ? (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile)
                                    : (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile),
                                toUserDeleted: isMe
                                    ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                                    : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile),
                                toUser: isMe ? pairController.chatMessageList[index]['FromUser'] : pairController.chatMessageList[index]['ToUser'],
                                onlineStatus: onlineStatus,
                                tableName: 'Chat_Message',
                                toProfileName: isMe
                                    ? pairController.chatMessageList[index]['FromProfile']['Name']
                                    : pairController.chatMessageList[index]['ToProfile']['Name'],
                                toProfileImg: isMe
                                    ? pairController.chatMessageList[index]['FromProfile']['Imgprofile'].url
                                    : pairController.chatMessageList[index]['ToProfile']['Imgprofile'].url,
                                fromUserImg: isMe
                                    ? pairController.chatMessageList[index]['ToProfile']['Imgprofile'].url
                                    : pairController.chatMessageList[index]['FromProfile']['Imgprofile'].url,
                                fromProfileId: isMe
                                    ? pairController.chatMessageList[index]['ToProfile']['objectId']
                                    : pairController.chatMessageList[index]['FromProfile']['objectId'],
                                toProfileId: isMe
                                    ? pairController.chatMessageList[index]['FromProfile']['objectId']
                                    : pairController.chatMessageList[index]['ToProfile']['objectId'],
                                toUserGender: isMe
                                    ? pairController.chatMessageList[index]['FromUser']['Gender']
                                    : pairController.chatMessageList[index]['ToUser']['Gender'],
                                toUserId: isMe
                                    ? pairController.chatMessageList[index]['FromUser']['objectId']
                                    : pairController.chatMessageList[index]['ToUser']['objectId'],
                              ),
                            );

                            if (isMe &&
                                pairController.chatMessageList[index]['Chat_Message'] != null &&
                                !pairController.chatMessageList[index]['Chat_Message']['isRead']) {
                              final ChatMessage chatMessage = ChatMessage();
                              chatMessage.objectId = pairController.chatMessageList[index]['Chat_Message']['objectId'];
                              chatMessage.isRead = true;
                              final res = await UserChatMessageProviderApi().update(chatMessage);
                              if (res.success) {
                                pairController.chatMessageList[index]['Chat_Message'] = res.result;
                                final PairNotifications pair = PairNotifications();
                                pair.objectId = pairController.chatMessageList[index]['objectId'];
                                pair['Chat_Message'] = res.result;
                                await PairNotificationProviderApi().update(pair);
                                pairController.chatMessageList.refresh();
                              }
                              if (pairController.chatMessageList.length <= 5) {
                                allController.redFunc(category: 'Chat', fromUser: pairController.chatMessageList[index]['FromUser']['objectId']);
                              }
                            }
                          },
                        ),
                        // when more then 5 data show more icon
                        if (index == 4)
                          InkWell(
                            onTap: () {
                              Get.to(() => MessageScreen(
                                  noTitle: 'no_chat'.tr,
                                  localTitle: localNotification,
                                  type: 'ChatMessage',
                                  title: 'Chat',
                                  tableName: 'Chat_Message'));
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: SvgView("assets/Icons/plus_new.svg", height: 30.w, width: 30.w, fit: BoxFit.cover),
                            ),
                          )
                        else if (isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile))
                          Container(
                            height: 78.w,
                            width: 78.w,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                            child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                          ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

// MESSAGE
class MessagePart extends GetView {
  final String localNotification;
  final PairNotificationController pairController;
  final AllNotificationController allController;

  const MessagePart({required this.pairController, required this.allController, required this.localNotification, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pairController.heartMessageList.value;
      pairController.meBlocked.value;
      if (pairController.heartMessageList.isNotEmpty) {
        return Container(
          height: 123.w,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(top: 5.h),
          padding: EdgeInsets.only(left: 9.w, right: 9.w, top: 6.h, bottom: 9.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Styles.regular(localNotification, style: Theme.of(context).textTheme.bodyMedium),
                  // show when user have unread chats
                  Obx(() {
                    if (allController.notificationSwitch('Mensajes').value) {
                      return Lottie.asset("assets/jsons/notifications.json", height: 22.w, width: 22.w);
                    } else {
                      return SizedBox(height: 22.w, width: 22.w);
                    }
                  }),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                alignment: Alignment.centerLeft,
                height: 78.w,
                child: ListView.separated(
                  itemCount: pairController.heartMessageList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(width: 5.w),
                  itemBuilder: (context, index) {
                    /// when my user in ToUser
                    final bool isMe = (pairController.heartMessageList[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                    /// other user block me and me block other user
                    final bool isBlockProfile =
                        (pairController.meBlocked.toString().contains(pairController.heartMessageList[index]['FromProfile']['objectId']) &&
                            pairController.meBlocked.toString().contains(pairController.heartMessageList[index]['ToProfile']['objectId']));

                    /// when FromProfile OR FromUser block
                    final bool isFromUserORProfileBlock = ((pairController.heartMessageList[index]['FromUser']['IsBlocked'] ?? false) ||
                        (pairController.heartMessageList[index]['FromProfile']['IsBlocked'] ?? false));

                    /// when ToProfile OR ToUser block
                    final bool isToUserORProfileBlock = ((pairController.heartMessageList[index]['ToUser']['IsBlocked'] ?? false) ||
                        (pairController.heartMessageList[index]['ToProfile']['IsBlocked'] ?? false));

                    /// when FromProfile OR FromUser delete
                    final bool isFromUserORProfileDelete = ((pairController.heartMessageList[index]['FromUser']['isDeleted'] ?? false) ||
                        (pairController.heartMessageList[index]['FromProfile']['isDeleted'] ?? false));

                    /// when ToProfile OR ToUser delete
                    final bool isToUserORProfileDelete = ((pairController.heartMessageList[index]['ToUser']['isDeleted'] ?? false) ||
                        (pairController.heartMessageList[index]['ToProfile']['isDeleted'] ?? false));

                    return Stack(
                      children: [
                        InkWell(
                          onTap: () async {
                            StorageService.getBox.write(
                                'msgFromProfileId',
                                isMe
                                    ? pairController.heartMessageList[index]['ToProfile']['objectId']
                                    : pairController.heartMessageList[index]['FromProfile']['objectId']);
                            StorageService.getBox.write(
                                'msgToProfileId',
                                isMe
                                    ? pairController.heartMessageList[index]['FromProfile']['objectId']
                                    : pairController.heartMessageList[index]['ToProfile']['objectId']);

                            StorageService.getBox.write('chattablename', 'Like_Message');

                            StorageService.getBox.save();

                            /// check FromUser is online [YOU] same vala
                            bool onlineStatus;
                            if ((isMe
                                ? pairController.heartMessageList[index]['FromProfile']['NoChats'] ?? false
                                : pairController.heartMessageList[index]['ToProfile']['NoChats'] ?? false)) {
                              if (isMe ? (isFromUserORProfileDelete || isBlockProfile) : (isToUserORProfileDelete || isBlockProfile)) {
                                onlineStatus = false;
                              } else {
                                onlineStatus = true;
                              }
                            } else {
                              onlineStatus = true; // false
                            }
                            Get.delete<ConversationController>();
                            Get.to(
                              () => ConversationScreen(
                                fromUserDeleted: isMe
                                    ? (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile)
                                    : (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile),
                                toUserDeleted: isMe
                                    ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                                    : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile),
                                description: isMe
                                    ? pairController.heartMessageList[index]['FromProfile']['Description']
                                    : pairController.heartMessageList[index]['ToProfile']['Description'],
                                toUser: isMe ? pairController.heartMessageList[index]['FromUser'] : pairController.heartMessageList[index]['ToUser'],
                                onlineStatus: onlineStatus,
                                tableName: 'Like_Message',
                                toProfileName: isMe
                                    ? pairController.heartMessageList[index]['FromProfile']['Name']
                                    : pairController.heartMessageList[index]['ToProfile']['Name'],
                                toProfileImg: isMe
                                    ? pairController.heartMessageList[index]['FromProfile']['Imgprofile'].url
                                    : pairController.heartMessageList[index]['ToProfile']['Imgprofile'].url,
                                fromUserImg: isMe
                                    ? pairController.heartMessageList[index]['ToProfile']['Imgprofile'].url
                                    : pairController.heartMessageList[index]['FromProfile']['Imgprofile'].url,
                                fromProfileId: isMe
                                    ? pairController.heartMessageList[index]['ToProfile']['objectId']
                                    : pairController.heartMessageList[index]['FromProfile']['objectId'],
                                toProfileId: isMe
                                    ? pairController.heartMessageList[index]['FromProfile']['objectId']
                                    : pairController.heartMessageList[index]['ToProfile']['objectId'],
                                toUserGender: isMe
                                    ? pairController.heartMessageList[index]['FromUser']['Gender']
                                    : pairController.heartMessageList[index]['ToUser']['Gender'],
                                toUserId: isMe
                                    ? pairController.heartMessageList[index]['FromUser']['objectId']
                                    : pairController.heartMessageList[index]['ToUser']['objectId'],
                              ),
                            );
                            if (isMe &&
                                pairController.heartMessageList[index]['Like_Message'] != null &&
                                !pairController.heartMessageList[index]['Like_Message']['isRead']) {
                              final LikeMessage likeMessage = LikeMessage();
                              likeMessage.objectId = pairController.heartMessageList[index]['Like_Message']['objectId'];
                              likeMessage.isRead = true;
                              final res = await LikeMsgProviderApi().update(likeMessage);
                              if (res.success) {
                                pairController.heartMessageList[index]['Like_Message'] = res.result;
                                final PairNotifications pair = PairNotifications();
                                pair.objectId = pairController.heartMessageList[index]['objectId'];
                                pair['Like_Message'] = res.result;
                                await PairNotificationProviderApi().update(pair);
                                pairController.heartMessageList.refresh();
                              }
                              if (pairController.heartMessageList.length <= 5) {
                                allController.redFunc(
                                    category: 'Me gustas', fromUser: pairController.heartMessageList[index]['FromUser']['objectId']);
                              }
                            }
                          },
                          child: Stack(
                            children: [
                              ImageView(
                                isMe
                                    ? pairController.heartMessageList[index]['FromProfile']['Imgprofile'].url
                                    : pairController.heartMessageList[index]['ToProfile']['Imgprofile'].url,
                                height: 78.w,
                                width: 78.w,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: const Color(0xffC1C1C1), width: 2.w),
                              ),
                              // check last message inRead or not --> show blur box when isRead[index] = false
                              if (pairController.heartMessageList[index]['Like_Message'] != null &&
                                  !pairController.heartMessageList[index]['Like_Message']['isRead'] &&
                                  isMe)
                                BlurryContainer(
                                  key: UniqueKey(),
                                  blur: 2,
                                  height: 78.w,
                                  width: 78.w,
                                  padding: EdgeInsets.all(18.w),
                                  borderRadius: BorderRadius.circular(19.r),
                                  child: SvgView("assets/Icons/passeye.svg", height: 30.w, width: 30.w, fit: BoxFit.scaleDown),
                                ),
                            ],
                          ),
                        ),
                        // when more then 5 data show more icon
                        if (index == 4)
                          InkWell(
                            onTap: () {
                              Get.to(() => MessageScreen(
                                  noTitle: 'no_message'.tr,
                                  localTitle: localNotification,
                                  type: 'HeartMessage',
                                  title: 'Mensajes',
                                  tableName: 'Like_Message'));
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: SvgView("assets/Icons/plus_new.svg", height: 30.w, width: 30.w, fit: BoxFit.cover),
                            ),
                          )
                        else if (isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile))
                          Container(
                            height: 78.w,
                            width: 78.w,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                            child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                          ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

// AUDIO CALL
class CallPart extends GetView {
  final String notificationName;
  final String localNotification;
  final PairNotificationController pairController;
  final AllNotificationController allController;

  const CallPart(
      {required this.pairController, required this.allController, required this.notificationName, required this.localNotification, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pairController.meBlocked.value;
      pairController.callList.value;
      if (pairController.callList.isNotEmpty) {
        return Container(
          height: 123.w,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(top: 5.h),
          padding: EdgeInsets.only(left: 9.w, right: 9.w, top: 6.h, bottom: 9.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Styles.regular(localNotification, style: Theme.of(context).textTheme.bodyMedium),
                  // show when user have unread calls
                  Obx(() {
                    if (allController.notificationSwitch(notificationName).value) {
                      return Lottie.asset("assets/jsons/notifications.json", height: 22.w, width: 22.w);
                    } else {
                      return SizedBox(height: 22.w, width: 22.w);
                    }
                  }),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                alignment: Alignment.centerLeft,
                height: 78.w,
                child: ListView.separated(
                  itemCount: pairController.callList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(width: 5.w),
                  itemBuilder: (context, index) {
                    /// when my user in ToUser
                    final bool isMe = (pairController.callList[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                    /// other user block me and me block other user
                    final bool isBlockProfile = (pairController.meBlocked.toString().contains(pairController.callList[index]['FromProfile']['objectId']) &&
                        pairController.meBlocked.toString().contains(pairController.callList[index]['ToProfile']['objectId']));

                    /// when FromProfile OR FromUser block
                    final bool isFromUserORProfileBlock =
                        ((pairController.callList[index]['FromUser']['IsBlocked'] ?? false) || (pairController.callList[index]['FromProfile']['IsBlocked'] ?? false));

                    /// when ToProfile OR ToUser block
                    final bool isToUserORProfileBlock =
                        ((pairController.callList[index]['ToUser']['IsBlocked'] ?? false) || (pairController.callList[index]['ToProfile']['IsBlocked'] ?? false));

                    /// when FromProfile OR FromUser delete
                    final bool isFromUserORProfileDelete =
                        ((pairController.callList[index]['FromUser']['isDeleted'] ?? false) || (pairController.callList[index]['FromProfile']['isDeleted'] ?? false));

                    /// when ToProfile OR ToUser delete
                    final bool isToUserORProfileDelete =
                        ((pairController.callList[index]['ToUser']['isDeleted'] ?? false) || (pairController.callList[index]['ToProfile']['isDeleted'] ?? false));
                    return Stack(
                      children: [
                        ImageView(
                          isMe ? pairController.callList[index]['FromProfile']['Imgprofile'].url : pairController.callList[index]['ToProfile']['Imgprofile'].url,
                          height: 78.w,
                          width: 78.w,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xffC1C1C1), width: 2.w),
                          onTap: () {
                            if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted &&
                                !(_searchController.profileData[StorageService.getBox.read('index') ?? 0]['IsBlocked'] ?? false)) {
                              Get.to(() => UserFullProfileScreen(
                                    isDindon: true,
                                    toUserId: (isMe ? pairController.callList[index]['FromUser'] : pairController.callList[index]['ToUser']),
                                    toProfileId: isMe ? pairController.callList[index]['FromProfile']['objectId'] : pairController.callList[index]['ToProfile']['objectId'],
                                    fromProfileId: !isMe ? pairController.callList[index]['FromProfile']['objectId'] : pairController.callList[index]['ToProfile']['objectId'],
                                    fromProfileImg:
                                        !isMe ? pairController.callList[index]['FromProfile']['Imgprofile'].url : pairController.callList[index]['ToProfile']['Imgprofile'].url,
                                  ));
                              if(pairController.callList.length <= 5 && isMe){
                                allController.redFunc(category: 'Llamadas',fromUser: pairController.callList[index]['FromUser']['objectId']);
                              }
                            } else {
                              deleteProfileSnackBar(context);
                            }
                          },
                        ),
                        // when more then 5 data show more icon
                        if (index == 4)
                          InkWell(
                            onTap: () {
                              Get.to(() => CallScreen(newTitle: localNotification, noTitle: 'no_call'.tr, type: 'Call', title: notificationName, showNumber: true));
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: SvgView("assets/Icons/plus_new.svg", height: 30.w, width: 30.w, fit: BoxFit.cover),
                            ),
                          )
                        else if (isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile))
                          Container(
                            height: 78.w,
                            width: 78.w,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                            child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                          ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

// VIDEO CALL
class VideoCallPart extends GetView {
  final String notificationName;
  final String localNotification;
  final PairNotificationController pairController;
  final AllNotificationController allController;

  const VideoCallPart(
      {required this.pairController, required this.allController, required this.notificationName, required this.localNotification, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pairController.meBlocked.value;
      pairController.videoCallList.value;
      if (pairController.videoCallList.isNotEmpty) {
        return Container(
          height: 123.w,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(top: 5.h),
          padding: EdgeInsets.only(left: 9.w, right: 9.w, top: 6.h, bottom: 9.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Styles.regular(localNotification, style: Theme.of(context).textTheme.bodyMedium),
                  // show when user have unread calls
                  Obx(() {
                    if (allController.notificationSwitch(notificationName).value) {
                      return Lottie.asset("assets/jsons/notifications.json", height: 22.w, width: 22.w);
                    } else {
                      return SizedBox(height: 22.w, width: 22.w);
                    }
                  }),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                alignment: Alignment.centerLeft,
                height: 78.w,
                child: ListView.separated(
                  itemCount: pairController.videoCallList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(width: 5.w),
                  itemBuilder: (context, index) {
                    /// when my user in ToUser
                    final bool isMe = (pairController.videoCallList[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                    /// other user block me and me block other user
                    final bool isBlockProfile =
                        (pairController.meBlocked.toString().contains(pairController.videoCallList[index]['FromProfile']['objectId']) &&
                            pairController.meBlocked.toString().contains(pairController.videoCallList[index]['ToProfile']['objectId']));

                    /// when FromProfile OR FromUser block
                    final bool isFromUserORProfileBlock = ((pairController.videoCallList[index]['FromUser']['IsBlocked'] ?? false) ||
                        (pairController.videoCallList[index]['FromProfile']['IsBlocked'] ?? false));

                    /// when ToProfile OR ToUser block
                    final bool isToUserORProfileBlock = ((pairController.videoCallList[index]['ToUser']['IsBlocked'] ?? false) ||
                        (pairController.videoCallList[index]['ToProfile']['IsBlocked'] ?? false));

                    /// when FromProfile OR FromUser delete
                    final bool isFromUserORProfileDelete = ((pairController.videoCallList[index]['FromUser']['isDeleted'] ?? false) ||
                        (pairController.videoCallList[index]['FromProfile']['isDeleted'] ?? false));

                    /// when ToProfile OR ToUser delete
                    final bool isToUserORProfileDelete = ((pairController.videoCallList[index]['ToUser']['isDeleted'] ?? false) ||
                        (pairController.videoCallList[index]['ToProfile']['isDeleted'] ?? false));

                    return Stack(
                      children: [
                        ImageView(
                          isMe
                              ? pairController.videoCallList[index]['FromProfile']['Imgprofile'].url
                              : pairController.videoCallList[index]['ToProfile']['Imgprofile'].url,
                          height: 78.w,
                          width: 78.w,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xffC1C1C1), width: 2.w),
                          onTap: () {
                            if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted &&
                                !(_searchController.profileData[StorageService.getBox.read('index') ?? 0]['IsBlocked'] ?? false)) {
                              Get.to(() => UserFullProfileScreen(isDindon: true,
                                    toUserId:
                                        (isMe ? pairController.videoCallList[index]['FromUser'] : pairController.videoCallList[index]['ToUser']),
                                    toProfileId: isMe
                                        ? pairController.videoCallList[index]['FromProfile']['objectId']
                                        : pairController.videoCallList[index]['ToProfile']['objectId'],
                                    fromProfileId: !isMe
                                        ? pairController.videoCallList[index]['FromProfile']['objectId']
                                        : pairController.videoCallList[index]['ToProfile']['objectId'],
                                    fromProfileImg: !isMe
                                        ? pairController.videoCallList[index]['FromProfile']['Imgprofile'].url
                                        : pairController.videoCallList[index]['ToProfile']['Imgprofile'].url,
                                  ));
                              if (pairController.videoCallList.length <= 5 && isMe) {
                                allController.redFunc(
                                    category: 'Videollamada', fromUser: pairController.videoCallList[index]['FromUser']['objectId']);
                              }
                            } else {
                              deleteProfileSnackBar(context);
                            }
                          },
                        ),
                        // when more then 5 data show more icon
                        if (index == 4)
                          InkWell(
                            onTap: () {
                              Get.to(() => CallScreen(
                                  newTitle: localNotification, noTitle: 'no_call'.tr, type: 'VideoCall', title: notificationName, showNumber: true));
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: SvgView("assets/Icons/plus_new.svg", height: 30.w, width: 30.w, fit: BoxFit.cover),
                            ),
                          )
                        else if (isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile))
                          Container(
                            height: 78.w,
                            width: 78.w,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                            child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                          ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

// HEARTLIKE
class HeartLikePart extends GetView {
  final String notificationName;
  final String localNotification;
  final PairNotificationController pairController;
  final AllNotificationController allController;

  const HeartLikePart(
      {required this.pairController, required this.allController, required this.notificationName, required this.localNotification, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pairController.meBlocked.value;
      pairController.heartLikeList.value;
      if (pairController.heartLikeList.isNotEmpty) {
        return Container(
          height: 123.w,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(top: 5.h),
          padding: EdgeInsets.only(left: 9.w, right: 9.w, top: 6.h, bottom: 9.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Styles.regular(localNotification, style: Theme.of(context).textTheme.bodyMedium),
                  // show when user have unread heartLike
                  Obx(() {
                    if (allController.notificationSwitch(notificationName).value) {
                      return Lottie.asset("assets/jsons/notifications.json", height: 22.w, width: 22.w);
                    } else {
                      return SizedBox(height: 22.w, width: 22.w);
                    }
                  }),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                alignment: Alignment.centerLeft,
                height: 78.w,
                child: ListView.separated(
                  itemCount: pairController.heartLikeList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(width: 5.w),
                  itemBuilder: (context, index) {
                    /// when my user in ToUser
                    final bool isMe = (pairController.heartLikeList[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                    /// other user block me and me block other user
                    final bool isBlockProfile =
                        (pairController.meBlocked.toString().contains(pairController.heartLikeList[index]['FromProfile']['objectId']) &&
                            pairController.meBlocked.toString().contains(pairController.heartLikeList[index]['ToProfile']['objectId']));

                    /// when FromProfile OR FromUser block
                    final bool isFromUserORProfileBlock = ((pairController.heartLikeList[index]['FromUser']['IsBlocked'] ?? false) ||
                        (pairController.heartLikeList[index]['FromProfile']['IsBlocked'] ?? false));

                    /// when ToProfile OR ToUser block
                    final bool isToUserORProfileBlock = ((pairController.heartLikeList[index]['ToUser']['IsBlocked'] ?? false) ||
                        (pairController.heartLikeList[index]['ToProfile']['IsBlocked'] ?? false));

                    /// when FromProfile OR FromUser delete
                    final bool isFromUserORProfileDelete = ((pairController.heartLikeList[index]['FromUser']['isDeleted'] ?? false) ||
                        (pairController.heartLikeList[index]['FromProfile']['isDeleted'] ?? false));

                    /// when ToProfile OR ToUser delete
                    final bool isToUserORProfileDelete = ((pairController.heartLikeList[index]['ToUser']['isDeleted'] ?? false) ||
                        (pairController.heartLikeList[index]['ToProfile']['isDeleted'] ?? false));

                    return Stack(
                      children: [
                        ImageView(
                          isMe
                              ? pairController.heartLikeList[index]['FromProfile']['Imgprofile'].url
                              : pairController.heartLikeList[index]['ToProfile']['Imgprofile'].url,
                          height: 78.w,
                          width: 78.w,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xffC1C1C1), width: 2.w),
                          onTap: () {
                            if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted &&
                                !(_searchController.profileData[StorageService.getBox.read('index') ?? 0]['IsBlocked'] ?? false)) {
                              Get.to(() => UserFullProfileScreen(isDindon: true,
                                    toUserId:
                                        (isMe ? pairController.heartLikeList[index]['FromUser'] : pairController.heartLikeList[index]['ToUser']),
                                    toProfileId: isMe
                                        ? pairController.heartLikeList[index]['FromProfile']['objectId']
                                        : pairController.heartLikeList[index]['ToProfile']['objectId'],
                                    fromProfileId: !isMe
                                        ? pairController.heartLikeList[index]['FromProfile']['objectId']
                                        : pairController.heartLikeList[index]['ToProfile']['objectId'],
                                    fromProfileImg: !isMe
                                        ? pairController.heartLikeList[index]['FromProfile']['Imgprofile'].url
                                        : pairController.heartLikeList[index]['ToProfile']['Imgprofile'].url,
                                  ));
                              if (pairController.heartLikeList.length <= 5 && isMe) {
                                allController.redFunc(category: 'Me gustas', fromUser: pairController.heartLikeList[index]['FromUser']['objectId']);
                              }
                            } else {
                              deleteProfileSnackBar(context);
                            }
                          },
                        ),
                        // when more then 5 data show more icon
                        if (index == 4)
                          InkWell(
                            onTap: () {
                              Get.to(() => CallScreen(
                                  newTitle: localNotification, noTitle: 'no_like'.tr, type: 'HeartLike', title: notificationName, showNumber: false));
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: SvgView("assets/Icons/plus_new.svg", height: 30.w, width: 30.w, fit: BoxFit.cover),
                            ),
                          )
                        else if (isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile))
                          Container(
                            height: 78.w,
                            width: 78.w,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                            child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                          ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

// VISIT
class VisitPart extends GetView {
  final String notificationName;
  final String localNotification;
  final PairNotificationController pairController;
  final AllNotificationController allController;

  const VisitPart(
      {required this.pairController, required this.allController, required this.notificationName, required this.localNotification, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pairController.meBlocked.value;
      pairController.visitList.value;
      if (pairController.visitList.isNotEmpty) {
        return Container(
          height: 123.w,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(top: 5.h),
          padding: EdgeInsets.only(left: 9.w, right: 9.w, top: 6.h, bottom: 9.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Styles.regular(localNotification, style: Theme.of(context).textTheme.bodyMedium),
                  // show when user have unread visit
                  Obx(() {
                    if (allController.notificationSwitch(notificationName).value) {
                      return Lottie.asset("assets/jsons/notifications.json", height: 22.w, width: 22.w);
                    } else {
                      return SizedBox(height: 22.w, width: 22.w);
                    }
                  }),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                alignment: Alignment.centerLeft,
                height: 78.w,
                child: ListView.separated(
                  itemCount: pairController.visitList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(width: 5.w),
                  itemBuilder: (context, index) {
                    /// when my user in ToUser
                    final bool isMe = (pairController.visitList[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                    /// other user block me and me block other user
                    final bool isBlockProfile =
                        (pairController.meBlocked.toString().contains(pairController.visitList[index]['FromProfile']['objectId']) &&
                            pairController.meBlocked.toString().contains(pairController.visitList[index]['ToProfile']['objectId']));

                    /// when FromProfile OR FromUser block
                    final bool isFromUserORProfileBlock = ((pairController.visitList[index]['FromUser']['IsBlocked'] ?? false) ||
                        (pairController.visitList[index]['FromProfile']['IsBlocked'] ?? false));

                    /// when ToProfile OR ToUser block
                    final bool isToUserORProfileBlock = ((pairController.visitList[index]['ToUser']['IsBlocked'] ?? false) ||
                        (pairController.visitList[index]['ToProfile']['IsBlocked'] ?? false));

                    /// when FromProfile OR FromUser delete
                    final bool isFromUserORProfileDelete = ((pairController.visitList[index]['FromUser']['isDeleted'] ?? false) ||
                        (pairController.visitList[index]['FromProfile']['isDeleted'] ?? false));

                    /// when ToProfile OR ToUser delete
                    final bool isToUserORProfileDelete = ((pairController.visitList[index]['ToUser']['isDeleted'] ?? false) ||
                        (pairController.visitList[index]['ToProfile']['isDeleted'] ?? false));

                    return Stack(
                      children: [
                        InkWell(
                          child: ImageView(
                            isMe
                                ? pairController.visitList[index]['FromProfile']['Imgprofile'].url
                                : pairController.visitList[index]['ToProfile']['Imgprofile'].url,
                            height: 78.w,
                            width: 78.w,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: const Color(0xffC1C1C1), width: 2.w),
                            onTap: () {
                              if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted &&
                                  !(_searchController.profileData[StorageService.getBox.read('index') ?? 0]['IsBlocked'] ?? false)) {
                                Get.to(() => UserFullProfileScreen(isDindon: true,
                                      toUserId: (isMe ? pairController.visitList[index]['FromUser'] : pairController.visitList[index]['ToUser']),
                                      toProfileId: isMe
                                          ? pairController.visitList[index]['FromProfile']['objectId']
                                          : pairController.visitList[index]['ToProfile']['objectId'],
                                      fromProfileId: !isMe
                                          ? pairController.visitList[index]['FromProfile']['objectId']
                                          : pairController.visitList[index]['ToProfile']['objectId'],
                                      fromProfileImg: !isMe
                                          ? pairController.visitList[index]['FromProfile']['Imgprofile'].url
                                          : pairController.visitList[index]['ToProfile']['Imgprofile'].url,
                                    ));
                                if (pairController.visitList.length <= 5 && isMe) {
                                  allController.redFunc(category: 'Visitas', fromUser: pairController.visitList[index]['FromUser']['objectId']);
                                }
                              } else {
                                deleteProfileSnackBar(context);
                              }
                            },
                          ),
                        ),
                        // when more then 5 data show more icon
                        if (index == 4)
                          InkWell(
                            onTap: () {
                              Get.to(() => CallScreen(
                                  newTitle: localNotification, noTitle: 'no_visits'.tr, type: 'Visit', title: notificationName, showNumber: false));
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: SvgView("assets/Icons/plus_new.svg", height: 30.w, width: 30.w, fit: BoxFit.cover),
                            ),
                          )
                        else if (isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile))
                          Container(
                            height: 78.w,
                            width: 78.w,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                            child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                          ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

// WINK
class WinkMessagePart extends GetView {
  final String notificationName;
  final String localNotification;
  final PairNotificationController pairController;
  final AllNotificationController allController;

  WinkMessagePart(
      {required this.pairController, required this.allController, required this.notificationName, required this.localNotification, Key? key})
      : super(key: key);
  final PriceController _priceController = Get.put(PriceController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pairController.meBlocked.value;
      pairController.winkList.value;
      if (pairController.winkList.isNotEmpty) {
        return Container(
          height: 123.w,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(top: 5.h),
          padding: EdgeInsets.only(left: 9.w, right: 9.w, top: 6.h, bottom: 9.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Styles.regular(localNotification, style: Theme.of(context).textTheme.bodyMedium),
                  // show when user have unread visit
                  Obx(() {
                    if (allController.notificationSwitch(notificationName).value) {
                      return Lottie.asset("assets/jsons/notifications.json", height: 22.w, width: 22.w);
                    } else {
                      return SizedBox(height: 22.w, width: 22.w);
                    }
                  }),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                alignment: Alignment.centerLeft,
                height: 78.w,
                child: ListView.separated(
                  itemCount: pairController.winkList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(width: 5.w),
                  itemBuilder: (context, index) {
                    /// when my user in ToUser
                    final bool isMe = (pairController.winkList[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                    /// other user block me and me block other user
                    final bool isBlockProfile =
                        (pairController.meBlocked.toString().contains(pairController.winkList[index]['FromProfile']['objectId']) &&
                            pairController.meBlocked.toString().contains(pairController.winkList[index]['ToProfile']['objectId']));

                    /// when FromProfile OR FromUser block
                    final bool isFromUserORProfileBlock = ((pairController.winkList[index]['FromUser']['IsBlocked'] ?? false) ||
                        (pairController.winkList[index]['FromProfile']['IsBlocked'] ?? false));

                    /// when ToProfile OR ToUser block
                    final bool isToUserORProfileBlock = ((pairController.winkList[index]['ToUser']['IsBlocked'] ?? false) ||
                        (pairController.winkList[index]['ToProfile']['IsBlocked'] ?? false));

                    /// when FromProfile OR FromUser delete
                    final bool isFromUserORProfileDelete = ((pairController.winkList[index]['FromUser']['isDeleted'] ?? false) ||
                        (pairController.winkList[index]['FromProfile']['isDeleted'] ?? false));

                    /// when ToProfile OR ToUser delete
                    final bool isToUserORProfileDelete = ((pairController.winkList[index]['ToUser']['isDeleted'] ?? false) ||
                        (pairController.winkList[index]['ToProfile']['isDeleted'] ?? false));

                    return Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted &&
                                !(_searchController.profileData[StorageService.getBox.read('index') ?? 0]['IsBlocked'] ?? false)) {
                              _priceController
                                  .winkReceivedPurchase(pairController.winkList[index], pair: pairController, notification: allController)
                                  .then((isPurchased) {
                                if (isPurchased) {
                                  final element = pairController.winkList[index];
                                  element['IsPurchased'] = isPurchased;
                                  pairController.winkList.removeAt(index);
                                  pairController.winkList.insert(0, element);
                                }
                              });
                            } else {
                              deleteProfileSnackBar(context);
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ImageView(
                                isMe
                                    ? pairController.winkList[index]['FromProfile']['Imgprofile'].url
                                    : pairController.winkList[index]['ToProfile']['Imgprofile'].url,
                                height: 78.w,
                                width: 78.w,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: const Color(0xffC1C1C1), width: 2.w),
                              ),
                              if ((isMe
                                      ? pairController.winkList[index]['FromUser']["Gender"] == 'female'
                                      : pairController.winkList[index]['ToUser']["Gender"] == "female") &&
                                  StorageService.getBox.read('Gender') == 'male' &&
                                  !pairController.winkList[index]['IsPurchased'])
                                BlurryContainer(
                                  blur: 2,
                                  height: 78.w,
                                  width: 78.w,
                                  padding: EdgeInsets.all(18.w),
                                  borderRadius: BorderRadius.circular(19.r),
                                  child: SvgView("assets/Icons/passeye.svg", height: 30.w, width: 30.w, fit: BoxFit.scaleDown),
                                ),
                            ],
                          ),
                        ),
                        // when more then 5 data show more icon
                        if (index == 4)
                          InkWell(
                            onTap: () {
                              Get.to(() => CallScreen(
                                  newTitle: localNotification,
                                  noTitle: 'no_wink'.tr,
                                  type: 'WinkMessage',
                                  title: notificationName,
                                  showNumber: false));
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: SvgView("assets/Icons/plus_new.svg", height: 30.w, width: 30.w, fit: BoxFit.cover),
                            ),
                          )
                        else if (isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile))
                          Container(
                            height: 78.w,
                            width: 78.w,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                            child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                          ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

// LIPLIKE
class LipLikePart extends GetView {
  final String notificationName;
  final String localNotification;

  final PairNotificationController pairController;
  final AllNotificationController allController;

  const LipLikePart(
      {required this.pairController, required this.allController, required this.notificationName, required this.localNotification, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pairController.lipLikeList.value;
      pairController.meBlocked.value;
      if (pairController.lipLikeList.isNotEmpty) {
        return Container(
          height: 123.w,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(top: 5.h),
          padding: EdgeInsets.only(left: 9.w, right: 9.w, top: 6.h, bottom: 9.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Styles.regular(localNotification, style: Theme.of(context).textTheme.bodyMedium),
                  // show when user have unread visit
                  Obx(() {
                    if (allController.notificationSwitch(notificationName).value) {
                      return Lottie.asset("assets/jsons/notifications.json", height: 22.w, width: 22.w);
                    } else {
                      return SizedBox(height: 22.w, width: 22.w);
                    }
                  }),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                alignment: Alignment.centerLeft,
                height: 78.w,
                child: ListView.separated(
                  itemCount: pairController.lipLikeList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(width: 5.w),
                  itemBuilder: (context, index) {
                    /// when my user in ToUser
                    final bool isMe = (pairController.lipLikeList[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                    /// other user block me and me block other user
                    final bool isBlockProfile =
                        (pairController.meBlocked.toString().contains(pairController.lipLikeList[index]['FromProfile']['objectId']) &&
                            pairController.meBlocked.toString().contains(pairController.lipLikeList[index]['ToProfile']['objectId']));

                    /// when FromProfile OR FromUser block
                    final bool isFromUserORProfileBlock = ((pairController.lipLikeList[index]['FromUser']['IsBlocked'] ?? false) ||
                        (pairController.lipLikeList[index]['FromProfile']['IsBlocked'] ?? false));

                    /// when ToProfile OR ToUser block
                    final bool isToUserORProfileBlock = ((pairController.lipLikeList[index]['ToUser']['IsBlocked'] ?? false) ||
                        (pairController.lipLikeList[index]['ToProfile']['IsBlocked'] ?? false));

                    /// when FromProfile OR FromUser delete
                    final bool isFromUserORProfileDelete = ((pairController.lipLikeList[index]['FromUser']['isDeleted'] ?? false) ||
                        (pairController.lipLikeList[index]['FromProfile']['isDeleted'] ?? false));

                    /// when ToProfile OR ToUser delete
                    final bool isToUserORProfileDelete = ((pairController.lipLikeList[index]['ToUser']['isDeleted'] ?? false) ||
                        (pairController.lipLikeList[index]['ToProfile']['isDeleted'] ?? false));

                    return Stack(
                      children: [
                        ImageView(
                          isMe
                              ? pairController.lipLikeList[index]['FromProfile']['Imgprofile'].url
                              : pairController.lipLikeList[index]['ToProfile']['Imgprofile'].url,
                          height: 78.w,
                          width: 78.w,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xffC1C1C1), width: 2.w),
                          onTap: () {
                            if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted &&
                                !(_searchController.profileData[StorageService.getBox.read('index') ?? 0]['IsBlocked'] ?? false)) {
                              Get.to(() => UserFullProfileScreen(isDindon: true,
                                    toUserId: (isMe ? pairController.lipLikeList[index]['FromUser'] : pairController.lipLikeList[index]['ToUser']),
                                    toProfileId: isMe
                                        ? pairController.lipLikeList[index]['FromProfile']['objectId']
                                        : pairController.lipLikeList[index]['ToProfile']['objectId'],
                                    fromProfileId: !isMe
                                        ? pairController.lipLikeList[index]['FromProfile']['objectId']
                                        : pairController.lipLikeList[index]['ToProfile']['objectId'],
                                    fromProfileImg: !isMe
                                        ? pairController.lipLikeList[index]['FromProfile']['Imgprofile'].url
                                        : pairController.lipLikeList[index]['ToProfile']['Imgprofile'].url,
                                  ));
                              if (pairController.lipLikeList.length <= 5 && isMe) {
                                allController.redFunc(category: 'Besos', fromUser: pairController.lipLikeList[index]['FromUser']['objectId']);
                              }
                            } else {
                              deleteProfileSnackBar(context);
                            }
                          },
                        ),
                        // when more then 5 data show more icon
                        if (index == 4)
                          InkWell(
                            onTap: () {
                              Get.to(() => CallScreen(
                                  newTitle: localNotification, noTitle: 'no_kiss'.tr, type: 'LipLike', title: notificationName, showNumber: false));
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: SvgView("assets/Icons/plus_new.svg", height: 30.w, width: 30.w, fit: BoxFit.cover),
                            ),
                          )
                        else if (isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile))
                          Container(
                            height: 78.w,
                            width: 78.w,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                            child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                          ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

// WISH
class WishesPart extends GetView {
  final String notificationName;
  final String localNotification;
  final PairNotificationController pairController;
  final AllNotificationController allController;

  const WishesPart(
      {required this.pairController, required this.allController, required this.notificationName, required this.localNotification, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pairController.meBlocked.value;
      pairController.wishList.value;
      if (pairController.wishList.isNotEmpty) {
        return Container(
          height: 123.w,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(top: 5.h),
          padding: EdgeInsets.only(left: 9.w, right: 9.w, top: 6.h, bottom: 9.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Styles.regular("TokTok", style: Theme.of(context).textTheme.bodyMedium),
                  // show when user have unread visit
                  Obx(() {
                    if (allController.notificationSwitch(notificationName).value) {
                      return Lottie.asset("assets/jsons/notifications.json", height: 22.w, width: 22.w);
                    } else {
                      return SizedBox(height: 22.w, width: 22.w);
                    }
                  }),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                alignment: Alignment.centerLeft,
                height: 78.w,
                child: ListView.separated(
                  itemCount: pairController.wishList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(width: 5.w),
                  itemBuilder: (context, index) {
                    /// when my user in ToUser
                    final bool isMe = (pairController.wishList[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                    /// other user block me and me block other user
                    final bool isBlockProfile =
                        (pairController.meBlocked.toString().contains(pairController.wishList[index]['FromProfile']['objectId']) &&
                            pairController.meBlocked.toString().contains(pairController.wishList[index]['ToProfile']['objectId']));

                    /// when FromProfile OR FromUser block
                    final bool isFromUserORProfileBlock = ((pairController.wishList[index]['FromUser']['IsBlocked'] ?? false) ||
                        (pairController.wishList[index]['FromProfile']['IsBlocked'] ?? false));

                    /// when ToProfile OR ToUser block
                    final bool isToUserORProfileBlock = ((pairController.wishList[index]['ToUser']['IsBlocked'] ?? false) ||
                        (pairController.wishList[index]['ToProfile']['IsBlocked'] ?? false));

                    /// when FromProfile OR FromUser delete
                    final bool isFromUserORProfileDelete = ((pairController.wishList[index]['FromUser']['isDeleted'] ?? false) ||
                        (pairController.wishList[index]['FromProfile']['isDeleted'] ?? false));

                    /// when ToProfile OR ToUser delete
                    final bool isToUserORProfileDelete = ((pairController.wishList[index]['ToUser']['isDeleted'] ?? false) ||
                        (pairController.wishList[index]['ToProfile']['isDeleted'] ?? false));

                    return Stack(
                      children: [
                        ImageView(
                          isMe
                              ? pairController.wishList[index]['FromProfile']['Imgprofile'].url
                              : pairController.wishList[index]['ToProfile']['Imgprofile'].url,
                          height: 78.w,
                          width: 78.w,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xffC1C1C1), width: 2.w),
                        ),
                        // when more then 5 data show more icon
                        if (index == 4)
                          InkWell(
                            onTap: () {
                              Get.to(() => CallScreen(
                                  newTitle: localNotification, noTitle: 'no_TokTok'.tr, type: 'Wishes', title: notificationName, showNumber: false));
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: SvgView("assets/Icons/plus_new.svg", height: 30.w, width: 30.w, fit: BoxFit.cover),
                            ),
                          )
                        else if ((isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile)))
                          Container(
                            height: 78.w,
                            width: 78.w,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                            child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                          )
                        else
                          InkWell(
                            onTap: () {
                              if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted &&
                                  !(_searchController.profileData[StorageService.getBox.read('index') ?? 0]['IsBlocked'] ?? false)) {
                                Get.to(() => UserFullProfileScreen(isDindon: true,
                                      toUserId: (isMe ? pairController.wishList[index]['FromUser'] : pairController.wishList[index]['ToUser']),
                                      toProfileId: isMe
                                          ? pairController.wishList[index]['FromProfile']['objectId']
                                          : pairController.wishList[index]['ToProfile']['objectId'],
                                      fromProfileId: !isMe
                                          ? pairController.wishList[index]['FromProfile']['objectId']
                                          : pairController.wishList[index]['ToProfile']['objectId'],
                                      fromProfileImg: !isMe
                                          ? pairController.wishList[index]['FromProfile']['Imgprofile'].url
                                          : pairController.wishList[index]['ToProfile']['Imgprofile'].url,
                                    ));
                                if (pairController.wishList.length <= 5 && isMe) {
                                  allController.redFunc(category: 'wishes', fromUser: pairController.wishList[index]['FromUser']['objectId']);
                                }
                              } else {
                                deleteProfileSnackBar(context);
                              }
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: Container(
                                height: 55.w,
                                width: 55.w,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(9.w),
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.w)),
                                child: SvgView(pairController.wishList[index]['Wishes']['Lottie_File'].url,
                                    height: 40.w, width: 40.w, fit: BoxFit.scaleDown, network: true, color: Colors.white),
                              ),
                            ),
                          )
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

// CHAT GIFTS
class GiftPart extends GetView {
  final String notificationName;
  final String localNotification;
  final PairNotificationController pairController;
  final AllNotificationController allController;

  const GiftPart(
      {required this.pairController, required this.allController, required this.notificationName, required this.localNotification, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pairController.meBlocked.value;
      pairController.giftList.value;
      if (pairController.giftList.isNotEmpty) {
        return Container(
          height: 123.w,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(top: 5.h),
          padding: EdgeInsets.only(left: 9.w, right: 9.w, top: 6.h, bottom: 9.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Styles.regular(localNotification, style: Theme.of(context).textTheme.bodyMedium),
                  // show when user have unread visit
                  Obx(() {
                    if (allController.notificationSwitch(notificationName).value) {
                      return Lottie.asset("assets/jsons/notifications.json", height: 22.w, width: 22.w);
                    } else {
                      return SizedBox(height: 22.w, width: 22.w);
                    }
                  }),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                alignment: Alignment.centerLeft,
                height: 78.w,
                child: ListView.separated(
                  itemCount: pairController.giftList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(width: 5.w),
                  itemBuilder: (context, index) {
                    /// when my user in ToUser
                    final bool isMe = (pairController.giftList[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                    /// other user block me and me block other user
                    final bool isBlockProfile =
                        (pairController.meBlocked.toString().contains(pairController.giftList[index]['FromProfile']['objectId']) &&
                            pairController.meBlocked.toString().contains(pairController.giftList[index]['ToProfile']['objectId']));

                    /// when FromProfile OR FromUser block
                    final bool isFromUserORProfileBlock = ((pairController.giftList[index]['FromUser']['IsBlocked'] ?? false) ||
                        (pairController.giftList[index]['FromProfile']['IsBlocked'] ?? false));

                    /// when ToProfile OR ToUser block
                    final bool isToUserORProfileBlock = ((pairController.giftList[index]['ToUser']['IsBlocked'] ?? false) ||
                        (pairController.giftList[index]['ToProfile']['IsBlocked'] ?? false));

                    /// when FromProfile OR FromUser delete
                    final bool isFromUserORProfileDelete = ((pairController.giftList[index]['FromUser']['isDeleted'] ?? false) ||
                        (pairController.giftList[index]['FromProfile']['isDeleted'] ?? false));

                    /// when ToProfile OR ToUser delete
                    final bool isToUserORProfileDelete = ((pairController.giftList[index]['ToUser']['isDeleted'] ?? false) ||
                        (pairController.giftList[index]['ToProfile']['isDeleted'] ?? false));
                    return Stack(
                      children: [
                        ImageView(
                          isMe
                              ? pairController.giftList[index]['FromProfile']['Imgprofile'].url
                              : pairController.giftList[index]['ToProfile']['Imgprofile'].url,
                          height: 78.w,
                          width: 78.w,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xffC1C1C1), width: 2.w),
                        ),
                        // when more then 5 data show more icon
                        if (index == 4)
                          InkWell(
                            onTap: () {
                              Get.to(() => MessageScreen(
                                  noTitle: 'no_chatGift'.tr,
                                  localTitle: localNotification,
                                  type: 'ChatGift',
                                  title: 'Chat',
                                  tableName: 'Chat_Message'));
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: SvgView("assets/Icons/plus_new.svg", height: 30.w, width: 30.w, fit: BoxFit.cover),
                            ),
                          )
                        else if ((isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile)))
                          Container(
                            height: 78.w,
                            width: 78.w,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                            child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                          )
                        else
                          InkWell(
                            onTap: () {
                              if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted &&
                                  !(_searchController.profileData[StorageService.getBox.read('index') ?? 0]['IsBlocked'] ?? false)) {
                                Get.to(() => UserFullProfileScreen(isDindon: true,
                                      toUserId: (isMe ? pairController.giftList[index]['FromUser'] : pairController.giftList[index]['ToUser']),
                                      toProfileId: isMe
                                          ? pairController.giftList[index]['FromProfile']['objectId']
                                          : pairController.giftList[index]['ToProfile']['objectId'],
                                      fromProfileId: !isMe
                                          ? pairController.giftList[index]['FromProfile']['objectId']
                                          : pairController.giftList[index]['ToProfile']['objectId'],
                                      fromProfileImg: !isMe
                                          ? pairController.giftList[index]['FromProfile']['Imgprofile'].url
                                          : pairController.giftList[index]['ToProfile']['Imgprofile'].url,
                                    ));
                                if (pairController.giftList.length <= 5 && isMe) {
                                  allController.redFunc(category: 'Regalos', fromUser: pairController.giftList[index]['FromUser']['objectId']);
                                }
                              } else {
                                deleteProfileSnackBar(context);
                              }
                            },
                            child: Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: pairController.giftList[index]['Gifts'] != null
                                  ? Image.network(pairController.giftList[index]['Gifts']['Image'].url, height: 47.w, width: 47.w, fit: BoxFit.cover)
                                  : null,
                            ),
                          )
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

// BLOCK
class BlockPart extends GetView {
  final String notificationName;
  final String localNotification;
  final PairNotificationController pairController;
  final AllNotificationController allController;

  const BlockPart(
      {required this.pairController, required this.allController, required this.notificationName, required this.localNotification, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pairController.meBlocked.value;
      pairController.blockList.value;
      if (pairController.blockList.isNotEmpty) {
        return Container(
          height: 123.w,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(top: 5.h, bottom: 5.h),
          padding: EdgeInsets.only(left: 9.w, right: 9.w, top: 6.h, bottom: 9.h),
          child: Column(
            children: [
              // title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Styles.regular(localNotification, style: Theme.of(context).textTheme.bodyMedium),
                  Obx(() {
                    if (allController.notificationSwitch(notificationName).value) {
                      return Lottie.asset("assets/jsons/notifications.json", height: 25.r, width: 25.r);
                    } else {
                      return SizedBox(height: 22.w, width: 22.w);
                    }
                  })
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                alignment: Alignment.centerLeft,
                height: 78.w,
                child: ListView.separated(
                  itemCount: pairController.blockList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(width: 5.w),
                  itemBuilder: (context, index) {
                    /// when my user in ToUser
                    final bool isMe = (pairController.blockList[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                    /// other user block me and me block other user
                    final bool isBlockProfile =
                        (pairController.meBlocked.toString().contains(pairController.blockList[index]['FromProfile']['objectId']) &&
                            pairController.meBlocked.toString().contains(pairController.blockList[index]['ToProfile']['objectId']));

                    /// when FromProfile OR FromUser block
                    final bool isFromUserORProfileBlock = ((pairController.blockList[index]['FromUser']['IsBlocked'] ?? false) ||
                        (pairController.blockList[index]['FromProfile']['IsBlocked'] ?? false));

                    /// when ToProfile OR ToUser block
                    final bool isToUserORProfileBlock = ((pairController.blockList[index]['ToUser']['IsBlocked'] ?? false) ||
                        (pairController.blockList[index]['ToProfile']['IsBlocked'] ?? false));

                    /// when FromProfile OR FromUser delete
                    final bool isFromUserORProfileDelete = ((pairController.blockList[index]['FromUser']['isDeleted'] ?? false) ||
                        (pairController.blockList[index]['FromProfile']['isDeleted'] ?? false));

                    /// when ToProfile OR ToUser delete
                    final bool isToUserORProfileDelete = ((pairController.blockList[index]['ToUser']['isDeleted'] ?? false) ||
                        (pairController.blockList[index]['ToProfile']['isDeleted'] ?? false));

                    return InkWell(
                      onTap: () {
                        Get.to(() => CallScreen(
                            newTitle: localNotification, noTitle: 'no_locked'.tr, type: 'BlocUser', title: notificationName, showNumber: false));
                      },
                      child: Stack(
                        children: [
                          ImageView(
                            isMe
                                ? pairController.blockList[index]['FromProfile']['Imgprofile'].url
                                : pairController.blockList[index]['ToProfile']['Imgprofile'].url,
                            height: 78.w,
                            width: 78.w,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: const Color(0xffC1C1C1), width: 1.w),
                          ),
                          // when more then 5 data show more icon
                          if (index == 4)
                            InkWell(
                              onTap: () {
                                Get.to(() => CallScreen(
                                    newTitle: localNotification,
                                    noTitle: 'no_locked'.tr,
                                    type: 'BlocUser',
                                    title: notificationName,
                                    showNumber: false));
                              },
                              child: Container(
                                height: 78.w,
                                width: 78.w,
                                padding: EdgeInsets.all(18.w),
                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                                child: SvgView("assets/Icons/plus_new.svg", height: 30.w, width: 30.w, fit: BoxFit.cover),
                              ),
                            )
                          else if (isMe
                              ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                              : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile))
                            // when profile delete and block show lock
                            Container(
                              height: 78.w,
                              width: 78.w,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.60), borderRadius: BorderRadius.circular(19.r)),
                              child: SvgView("assets/Icons/lock.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
