// ignore_for_file: must_be_immutable, invalid_use_of_protected_member

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:csv/csv.dart';
import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/Widgets/bottom_sheet.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/filter_notification.dart';
import 'package:eypop/Constant/Widgets/post_view.dart';
import 'package:eypop/Controllers/all_notification_controller/all_notification_controller.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/user_provider/delete_conversation_api.dart';
import 'package:eypop/back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/tab_provider/provider_chat_gifts.dart';
import 'package:eypop/back4appservice/user_provider/tab_provider/provider_chatmsg.dart';
import 'package:eypop/back4appservice/user_provider/tab_provider/provider_likemsg.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/gettimeago/get_time_ago.dart';
import 'package:eypop/models/delete_table.dart';
import 'package:eypop/models/new_notification/new_notification_pair.dart';
import 'package:eypop/models/tab_model/chat_message.dart';
import 'package:eypop/models/tab_model/like_message.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/ui/settings/download_screen.dart';
import 'package:eypop/ui/store_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Controllers/PairNotificationController/pair_notification_controller.dart';
import '../../back4appservice/base/api_response.dart';
import '../../models/user_login/user_login.dart';
import '../../service/local_storage.dart';
import '../tab_pages/conversation_screen.dart';
import 'my_message_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({required this.title, required this.noTitle, required this.tableName, required this.type, required this.localTitle, Key? key})
      : super(key: key);
  final String localTitle;
  final String type;
  final String title;
  final String noTitle;
  final String tableName;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final PriceController _priceController = Get.put(PriceController());

  final UserController _userController = Get.put(UserController());

  final PairNotificationController _pairNotificationController = Get.put(PairNotificationController());
  final AllNotificationController _allNotificationController = Get.put(AllNotificationController());
  final RefreshController _refreshController = RefreshController();
  final RxList finalItems = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool refreshCounter = false.obs;
  final RxInt loadTime = 0.obs;
  final RxString filters = 'all'.obs;
  final Rx<ProfilePage> profilePage = ProfilePage().obs;
  final LiveQuery messageLiveQuery = LiveQuery(autoSendSessionId: true, debug: false);
  Subscription<ParseObject>? messageSubscription;

  void _onRefresh() async {
    isLoading.value = true;
    _allNotificationController.redFunc(category: widget.title);
    loadTime.value = 0;
    finalItems.clear();
    await _onLoading();
    isLoading.value = false;
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    if (loadTime.value >= historyLimit) {
      _refreshController.loadComplete();
      return;
    }
    ApiResponse? data;

    if (filters.value == 'profileWise' && profilePage.value.objectId != null) {
      data = await _pairNotificationController.getFilteredData(widget.type, loadTime.value, profilePage.value.objectId);
    } else if (filters.value == 'filter1') {
      data = await _pairNotificationController.getOutGoingData(type: widget.type, page: loadTime.value, limit: 20);
    } else if (filters.value == 'filter2') {
      data = await _pairNotificationController.getInComingData(type: widget.type, page: loadTime.value);
    } else {
      data = await _pairNotificationController.getFutureData(type: widget.type, page: loadTime.value, limit: 10);
    }
    if (data != null) {
      finalItems.addAll(data.results ?? []);
      loadTime.value += 10;
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
      data = null;
    }
  }

  @override
  void initState() {
    messageUnReadCountList.clear();
    _allNotificationController.redFunc(category: widget.title);
    isLoading.value = true;
    _onLoading().whenComplete(() {
      isLoading.value = false;
    });
    startMessageLiveQuery();

    super.initState();
  }

  void startMessageLiveQuery() async {
    try {
      final QueryBuilder<PairNotifications> queryChatData1 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('FromUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('Type', widget.type);

      final QueryBuilder<PairNotifications> queryChatData2 = QueryBuilder<PairNotifications>(PairNotifications())
        ..whereEqualTo('ToUser', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..whereEqualTo('Type', widget.type);

      final PairNotifications pairNotifications = PairNotifications();
      final QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(pairNotifications, [queryChatData1, queryChatData2])
        ..whereNotContainedIn('DeletedUsers', [
          {"__type": "Pointer", "className": "User_login", "objectId": StorageService.getBox.read('ObjectId')}
        ])
        ..orderByDescending('updatedAt');

      messageSubscription = await messageLiveQuery.client.subscribe(mainQuery);
      messageSubscription!.on(LiveQueryEvent.create, (ParseObject value) async {
        if (kDebugMode) {
          print('*** CREATE MESSAGE LIVE QUERY ***: $value');
        }
        insertToList(value);
      });
      messageSubscription!.on(LiveQueryEvent.update, (ParseObject value) async {
        final int ind = finalItems.indexWhere((element) => element['objectId'] == value.objectId);
        if (kDebugMode) {
          print('*** UPDATE MESSAGE LIVE QUERY ***: index: $ind $value');
        }
        if (ind.isNegative) {
          if (value['DeletedUsers'] == null || !value['DeletedUsers'].toString().contains(StorageService.getBox.read('ObjectId'))) {
            insertToList(value);
          }
        } else {
          final object = finalItems[ind];
          if (object['Message'] != value['Message'] || object['IsPurchased'] != value['IsPurchased'] || object['ChatType'] != value['ChatType']) {
            object['Message'] = value['Message'];
            object['IsPurchased'] = value['IsPurchased'];
            object['ChatType'] = value['ChatType'];
            if (value['Like_Message'] != null) {
              final res = await LikeMsgProviderApi().getById(value['Like_Message']['objectId']);
              object['Like_Message'] = res.result;
            } else if (value['Chat_Message'] != null) {
              final res = await UserChatMessageProviderApi().getById(value['Chat_Message']['objectId']);
              object['Chat_Message'] = res.result;
            }
            if (value['Gifts'] != null) {
              final res = await UserChatGiftsProviderApi().getById(value['Gifts']['objectId']);
              object['Gifts'] = res.result;
            }
            finalItems.removeAt(ind);

            /// fix show duplicate message on liveQuery
            if (filters.value == 'profileWise' && profilePage.value.objectId == object['ToProfile']['objectId']) {
              finalItems.insert(0, object);
            } else if (filters.value == 'all') {
              finalItems.insert(0, object);
            }

            ApiResponse? count = widget.tableName == 'Chat_Message'
                ? await UserChatMessageProviderApi().messageCount(object['FromProfile']['objectId'], object['ToProfile']['objectId'])
                : await LikeMsgProviderApi().messageCount(object['FromProfile']['objectId'], object['ToProfile']['objectId']);
            if (count != null) {
              updateMessageCount(
                messageUnReadCountList.value,
                object["FromProfile"]["objectId"],
                object["ToProfile"]["objectId"],
                count.results!.length,
              );
            }

            // Consolidating 'profileWise' and 'all' conditions into one [fix show duplicate message on liveQuery]
            if ((filters.value == 'profileWise' && profilePage.value.objectId == value['ToProfile']['objectId']) || filters.value == 'all') {
              // Check for Like_Message or Chat_Message from the current user
              if ((finalItems[0]['Like_Message'] != null &&
                      finalItems[0]['Like_Message']['FromUser']['objectId'].toString().contains(StorageService.getBox.read('ObjectId').toString())) ||
                  (finalItems[0]['Chat_Message'] != null &&
                      finalItems[0]['Chat_Message']['FromUser']['objectId'].toString().contains(StorageService.getBox.read('ObjectId').toString()))) {
                // Remove the message count from the unread count list
                removeMessageCount(messageUnReadCountList.value, finalItems[0]['FromProfile']['objectId'], finalItems[0]['ToProfile']['objectId']);
              }
            }
            finalItems.refresh();
            refreshCounter.value = !refreshCounter.value;
          }
        }
      });
    } catch (error, trace) {
      if (kDebugMode) {
        print("trace ::::: $trace");
        print("error ::::: $error");
      }
    }
  }

  void updateMessageCount(List<Map<String, dynamic>> messageUnReadCountList, String fromProfileID, String toProfileID, int newCount) {
    // Find the map where both FromProfileID and ToProfileID match
    Map<String, dynamic>? item = messageUnReadCountList.firstWhere(
      (element) => element['FromProfileID'] == fromProfileID && element['ToProfileID'] == toProfileID,
      orElse: () => {}, // Handle if no match is found
    );

    if (item.isNotEmpty) {
      // Update the Count if the item is found
      item['Count'] = newCount;
      print('Updated item: $item');
    } else {
      print('No matching profile IDs found.');
    }
  }

  void removeMessageCount(List<Map<String, dynamic>> messageUnReadCountList, String fromProfileID, String toProfileID) {
    // Remove the map where both FromProfileID and ToProfileID match
    messageUnReadCountList.removeWhere(
      (element) => element['FromProfileID'] == fromProfileID && element['ToProfileID'] == toProfileID,
    );
    print('Updated list after removal: $messageUnReadCountList');
  }

  void cancelMessageLiveQuery() async {
    if (messageSubscription != null) {
      messageLiveQuery.client.unSubscribe(messageSubscription!);
    }
  }

  void insertToList(value) async {
    final List<ApiResponse> list = await Future.wait([
      UserLoginProviderApi().getById(value['FromUser']['objectId']),
      UserLoginProviderApi().getById(value['ToUser']['objectId']),
      UserProfileProviderApi().getById(value['ToProfile']['objectId']),
      UserProfileProviderApi().getById(value['FromProfile']['objectId']),
      if (widget.type == 'HeartMessage' && value['Like_Message'] != null)
        LikeMsgProviderApi().getById(value['Like_Message']['objectId'])
      else if (widget.type == 'ChatMessage' && value['Chat_Message'] != null)
        UserChatMessageProviderApi().getById(value['Chat_Message']['objectId']),
    ]);

    value['FromUser'] = list[0].result;
    value['ToUser'] = list[1].result;
    value['ToProfile'] = list[2].result;
    value['FromProfile'] = list[3].result;
    if (list.length == 4) {
      widget.type == 'HeartMessage' ? value['Like_Message'] : value['Chat_Message'] = list[4].result;
    }

    /// fix show duplicate message on liveQuery
    if (filters.value == 'profileWise' && profilePage.value.objectId == value['ToProfile']['objectId']) {
      finalItems.insert(0, value);
    } else if (filters.value == 'all') {
      finalItems.insert(0, value);
    }
  }

  @override
  void dispose() {
    cancelMessageLiveQuery();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (pop) {
        if (!pop) {
          _priceController.update();
          _priceController.refresh();
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.3,
          centerTitle: true,
          toolbarHeight: 80.h,
          title: Styles.regular(widget.localTitle, c: ConstColors.darkGreyColor, ff: "HB", fs: 45.sp),
          leading: Back(
            svg: "assets/Icons/close.svg",
            color: ConstColors.darkGreyColor,
            height: 25.w,
            width: 25.w,
            onTap: () {
              _priceController.update();
              _priceController.refresh();
              Get.back();
            },
            padding: EdgeInsets.only(bottom: 2.h),
          ),
          actions: [
            // profile wise chat history
            InkWell(
                onTap: () async {
                  await HapticFeedback.vibrate();
                  if (widget.type == 'ChatGift') {
                    Navigator.push(
                      Get.context!,
                      CustomPopupRoute(
                        child: AllFilters(
                          title: 'Regalos',
                          filter: filters.value,
                          onTap: (event) {
                            if (!filters.contains(event)) {
                              filters.value = event;
                              _onRefresh();
                            }
                          },
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                        Get.context!,
                        CustomPopupRoute(
                          child: MyProfileMessageScreen(
                            tableName: widget.tableName,
                            onTap: (event, profile) {
                              if (event.contains('all')) {
                                filters.value = event;
                                profilePage.value = ProfilePage();
                                _onRefresh();
                              } else {
                                filters.value = event;
                                profilePage.value = profile;
                                _onRefresh();
                              }
                            },
                          ),
                        ));
                  }
                },
                child: widget.type == 'ChatGift'
                    ? Container(
                        alignment: Alignment.topRight,
                        height: 60.h,
                        width: 60.w,
                        child: SvgView('assets/Icons/option.svg',
                            color: ConstColors.darkGreyColor, padding: EdgeInsets.only(top: 25.h), width: 32.w, fit: BoxFit.scaleDown),
                      )
                    : Obx(() {
                        if (profilePage.value.objectId != null) {
                          return ImageView(profilePage.value.imgProfile.url.toString(),
                              height: 45.w, width: 45.w, circle: true, alignment: Alignment.topCenter);
                        } else {
                          return SvgView("assets/Icons/profile.svg", height: 32.w, width: 32.w, fit: BoxFit.scaleDown);
                        }
                      })),
            SizedBox(width: 20.w)
          ],
        ),
        body: SmartRefresher(
          key: ValueKey(_refreshController),
          enablePullDown: true,
          enablePullUp: true,
          header: CustomHeader(
              refreshStyle: RefreshStyle.Behind,
              builder: (context, mode) {
                return const SizedBox.shrink();
              }),
          footer: Obx(() {
            loadTime.value;
            return CustomFooter(
              height: loadTime.value >= historyLimit ? MediaQuery.sizeOf(context).width / 1.5 : 60.h,
              builder: (context2, LoadStatus? mode) {
                Widget body = const SizedBox.shrink(key: ValueKey(0));
                if (loadTime.value >= historyLimit) {
                  body = Padding(
                    key: const ValueKey(1),
                    padding: EdgeInsets.only(left: 30.w, right: 30.w, top: 25.h, bottom: 40.h),
                    child: Column(
                      children: [
                        Styles.regular("${'We_show_you_the_last'.tr} $historyLimit ${widget.title}",
                            fs: 16.sp, ff: "HB", c: Theme.of(context).primaryColor.withOpacity(0.7), lns: 2, al: TextAlign.center),
                        SizedBox(height: 12.h),
                        SvgView('assets/Icons/zip_download.svg', color: ConstColors.themeColor, height: 44.h, width: 40.w, fit: BoxFit.cover),
                        SizedBox(height: 12.h),
                        Styles.regular("${'Download_your_entire_history_of'.tr} ${widget.title}",
                            fs: 16.sp, c: ConstColors.themeColor, lns: 2, al: TextAlign.center),
                        Styles.regular('It_will_cost'.tr.replaceAll('xxx', historyStars.toString()),
                            fs: 16.sp, c: ConstColors.closeColor, lns: 2, al: TextAlign.center),
                        SizedBox(height: 23.h),
                        GradientButton(
                          title: 'Download'.tr,
                          onTap: _downloadInter,
                        ),
                      ],
                    ),
                  );
                } else {
                  if (mode == LoadStatus.loading) {
                    body = Lottie.asset('assets/jsons/load_more.json', height: 50.w, width: 70.w, fit: BoxFit.cover, key: const ValueKey(2));
                  } else if (mode == LoadStatus.noMore) {
                    body = Padding(
                      key: const ValueKey(3),
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      child: Styles.regular('No_More_Load'.tr,
                          fs: 16.sp, ff: "HB", c: Theme.of(context).primaryColor.withOpacity(0.7), lns: 2, al: TextAlign.center),
                    );
                  }
                }
                return Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 275),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: body,
                  ),
                );
              },
            );
          }),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: Obx(() {
            if (isLoading.value) {
              return SizedBox(
                key: UniqueKey(),
                height: MediaQuery.of(context).size.height / 1.2,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown),
                ),
              );
            }
            if (finalItems.isEmpty) {
              return SizedBox(
                key: UniqueKey(),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Styles.regular(widget.noTitle, c: Theme.of(context).primaryColor),
                ),
              );
            }
            return SingleChildScrollView(
              key: UniqueKey(),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
                itemCount: finalItems.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1, mainAxisSpacing: 16.h, crossAxisSpacing: 16.w),
                itemBuilder: (c, index) {
                  /// when my user in ToUser
                  final bool isMe = (finalItems[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                  /// other user block me and me block other user
                  final bool blockByMe = (_pairNotificationController.meBlocked.toString().contains(finalItems[index]['FromProfile']['objectId']) &&
                      _pairNotificationController.meBlocked.toString().contains(finalItems[index]['ToProfile']['objectId'])); // update block

                  /// when FromProfile OR FromUser block
                  final bool isFromUserORProfileBlock =
                      ((finalItems[index]['FromUser']['IsBlocked'] ?? false) || (finalItems[index]['FromProfile']['IsBlocked'] ?? false));

                  /// when ToProfile OR ToUser block
                  final bool isToUserORProfileBlock =
                      ((finalItems[index]['ToUser']['IsBlocked'] ?? false) || (finalItems[index]['ToProfile']['IsBlocked'] ?? false));

                  /// when FromProfile OR FromUser delete
                  final bool isFromUserORProfileDelete =
                      ((finalItems[index]['FromUser']['isDeleted'] ?? false) || (finalItems[index]['FromProfile']['isDeleted'] ?? false));

                  /// when ToProfile OR ToUser delete
                  final bool isToUserORProfileDelete =
                      ((finalItems[index]['ToUser']['isDeleted'] ?? false) || (finalItems[index]['ToProfile']['isDeleted'] ?? false));

                  // /// show eye Icon
                  //  final RxBool showEyeIcon = false.obs;

                  /// check FromUser is online [YOU] same vala
                  bool onlineStatus;
                  if ((isMe ? finalItems[index]['FromProfile']['NoChats'] ?? false : finalItems[index]['ToProfile']['NoChats'] ?? false)) {
                    if (isMe ? (isFromUserORProfileDelete || blockByMe) : (isToUserORProfileDelete || blockByMe)) {
                      onlineStatus = false;
                    } else {
                      onlineStatus = true;
                    }
                  } else {
                    onlineStatus = true; // false
                  }

                  String blockFromUser = '';

                  // WHEN I'M BLOCK SOMEONE AND SOMEONE BLOCK ME
                  if (blockByMe) {
                    blockFromUser = 'Profile_Blocked'.tr;
                  } else {
                    // DELETE USER / PROFILE
                    if (isFromUserORProfileDelete) {
                      blockFromUser = 'Profile_Deleted'.tr;
                    } else {
                      // BLOCK USER / PROFILE
                      blockFromUser = 'Profile_Blocked'.tr;
                    }
                  }
                  return InkWell(
                    onLongPress: () {
                      deleteItemSheet(context, onTap: () async {
                        isLoading.value = true;
                        Get.back();
                        DeleteConversationApi()
                            .getSpeceficId(
                                fromId: isMe ? finalItems[index]['ToProfile']['objectId'] : finalItems[index]['FromProfile']['objectId'],
                                toId: isMe ? finalItems[index]['FromProfile']['objectId'] : finalItems[index]['ToProfile']['objectId'],
                                type: widget.title)
                            .then((value) {
                          if (value != null) {
                            final DeleteConnection deleteConnection = DeleteConnection();
                            deleteConnection.objectId = value.result['objectId'];
                            DeleteConversationApi().update(deleteConnection).whenComplete(() {
                              DeleteConversationApi().getByUserId(StorageService.getBox.read('ObjectId'), widget.title).then((value) {
                                _userController.update();
                              });
                            });
                          } else {
                            final DeleteConnection deleteConnection = DeleteConnection();
                            deleteConnection.toUser = UserLogin()
                              ..objectId = isMe ? finalItems[index]['FromUser']['objectId'] : finalItems[index]['ToUser']['objectId'];
                            deleteConnection.type = widget.title;
                            deleteConnection.fromUser = UserLogin()..objectId = StorageService.getBox.read('ObjectId');
                            deleteConnection.toProfile = ProfilePage()
                              ..objectId = isMe ? finalItems[index]['FromProfile']['objectId'] : finalItems[index]['ToProfile']['objectId'];
                            deleteConnection.fromProfile = ProfilePage()
                              ..objectId = isMe ? finalItems[index]['ToProfile']['objectId'] : finalItems[index]['FromProfile']['objectId'];
                            DeleteConversationApi().add(deleteConnection).whenComplete(() {
                              DeleteConversationApi().getByUserId(StorageService.getBox.read('ObjectId'), widget.title).then((value) {
                                _userController.update();
                              });
                            });
                          }
                          removeMessageCount(
                              messageUnReadCountList.value, finalItems[index]['FromProfile']['objectId'], finalItems[index]['ToProfile']['objectId']);
                        });
                        _pairNotificationController.setMarkAsRead(
                            widget.title, finalItems[index]['FromProfile']['objectId'], finalItems[index]['ToProfile']['objectId']);
                        await PairNotificationProviderApi()
                            .getByProfile(finalItems[index]['FromProfile']['objectId'], finalItems[index]['ToProfile']['objectId'], widget.type)
                            .then((value) {
                          final PairNotifications pairNotifications = PairNotifications();
                          if (value != null) {
                            if (value.result['DeletedUsers'] != null && value.result['DeletedUsers'].isNotEmpty) {
                              pairNotifications.objectId = finalItems[index]['objectId'];
                              pairNotifications.deletedUsers = [
                                UserLogin()..objectId = StorageService.getBox.read('ObjectId'),
                                UserLogin()..objectId = finalItems[index]['ToUser']['objectId']
                              ];
                              PairNotificationProviderApi().update(pairNotifications);
                            } else {
                              pairNotifications.objectId = finalItems[index]['objectId'];
                              pairNotifications.deletedUsers = [UserLogin()..objectId = StorageService.getBox.read('ObjectId')];
                              PairNotificationProviderApi().update(pairNotifications);
                            }
                          }
                          finalItems.removeAt(index);
                          gradientSnackBar(context, title: 'removed'.tr, image: "assets/Icons/trash.svg");
                        });
                        isLoading.value = false;
                      });
                    },
                    // navigate when any one is not block / delete
                    onTap: ((isMe
                                ? (isFromUserORProfileDelete || isFromUserORProfileBlock || blockByMe)
                                : (isToUserORProfileDelete || isToUserORProfileBlock || blockByMe)) ||
                            (isMe ? (isToUserORProfileDelete || isToUserORProfileBlock) : (isFromUserORProfileDelete || isFromUserORProfileBlock)))
                        ? null
                        : () async {
                            StorageService.getBox.write(
                                'msgFromProfileId', isMe ? finalItems[index]['ToProfile']['objectId'] : finalItems[index]['FromProfile']['objectId']);
                            StorageService.getBox.write(
                                'msgToProfileId', isMe ? finalItems[index]['FromProfile']['objectId'] : finalItems[index]['ToProfile']['objectId']);

                            if (widget.title == 'Mensajes') {
                              StorageService.getBox.write('chattablename', 'Like_Message');
                            } else {
                              StorageService.getBox.write('chattablename', 'Chat_Message');
                            }
                            StorageService.getBox.save();

                            Get.to(() => ConversationScreen(
                                      fromUserDeleted: isMe
                                          ? (isToUserORProfileDelete || isToUserORProfileBlock || blockByMe)
                                          : (isFromUserORProfileDelete || isFromUserORProfileBlock || blockByMe),
                                      toUserDeleted: isMe
                                          ? (isFromUserORProfileDelete || isFromUserORProfileBlock || blockByMe)
                                          : (isToUserORProfileDelete || isToUserORProfileBlock || blockByMe),
                                      description: widget.title == 'Mensajes'
                                          ? isMe
                                              ? finalItems[index]['FromProfile']['Description']
                                              : finalItems[index]['ToProfile']['Description']
                                          : null,
                                      toUser: isMe ? finalItems[index]['FromUser'] : finalItems[index]['ToUser'],
                                      onlineStatus: onlineStatus,
                                      tableName: widget.title == 'Mensajes' ? 'Like_Message' : 'Chat_Message',
                                      toProfileName: isMe ? finalItems[index]['FromProfile']['Name'] : finalItems[index]['ToProfile']['Name'],
                                      toProfileImg: isMe
                                          ? finalItems[index]['FromProfile']['Imgprofile'].url
                                          : finalItems[index]['ToProfile']['Imgprofile'].url,
                                      fromUserImg: isMe
                                          ? finalItems[index]['ToProfile']['Imgprofile'].url
                                          : finalItems[index]['FromProfile']['Imgprofile'].url,
                                      fromProfileId: isMe ? finalItems[index]['ToProfile']['objectId'] : finalItems[index]['FromProfile']['objectId'],
                                      toProfileId: isMe ? finalItems[index]['FromProfile']['objectId'] : finalItems[index]['ToProfile']['objectId'],
                                      toUserGender: isMe ? finalItems[index]['FromUser']['Gender'] : finalItems[index]['ToUser']['Gender'],
                                      toUserId: isMe ? finalItems[index]['FromUser']['objectId'] : finalItems[index]['ToUser']['objectId'],
                                    ))!
                                .whenComplete(() {
                              removeMessageCount(messageUnReadCountList.value, finalItems[index]['FromProfile']['objectId'],
                                  finalItems[index]['ToProfile']['objectId']);
                              refreshCounter.value = !refreshCounter.value;
                            });
                            if (isMe &&
                                widget.type == "ChatMessage" &&
                                finalItems[index]['Chat_Message'] != null &&
                                !finalItems[index]['Chat_Message']['isRead']) {
                              final ChatMessage chatMessage = ChatMessage();
                              chatMessage.objectId = finalItems[index]['Chat_Message']['objectId'];
                              chatMessage.isRead = true;
                              final res = await UserChatMessageProviderApi().update(chatMessage);
                              if (res.success) {
                                finalItems[index]['Chat_Message'] = res.result;
                                final PairNotifications pair = PairNotifications();
                                pair.objectId = finalItems[index]['objectId'];
                                pair['Chat_Message'] = res.result;
                                await PairNotificationProviderApi().update(pair);
                                refreshCounter.value = !refreshCounter.value;
                                finalItems.refresh();
                              }
                            }
                            if (isMe &&
                                widget.type == "HeartMessage" &&
                                finalItems[index]['Like_Message'] != null &&
                                !finalItems[index]['Like_Message']['isRead']) {
                              final LikeMessage likeMessage = LikeMessage();
                              likeMessage.objectId = finalItems[index]['Like_Message']['objectId'];
                              likeMessage.isRead = true;
                              final res = await LikeMsgProviderApi().update(likeMessage);
                              if (res.success) {
                                finalItems[index]['Like_Message'] = res.result;
                                final PairNotifications pair = PairNotifications();
                                pair.objectId = finalItems[index]['objectId'];
                                pair['Like_Message'] = res.result;
                                await PairNotificationProviderApi().update(pair);
                                refreshCounter.value = !refreshCounter.value;
                                finalItems.refresh();
                              }
                            }
                          },
                    child: Stack(
                      children: [
                        Container(
                          height: MediaQuery.sizeOf(context).height,
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  isMe ? finalItems[index]['FromProfile']['Imgprofile'].url : finalItems[index]['ToProfile']['Imgprofile'].url),
                            ),
                          ),
                          child: Container(
                            height: MediaQuery.sizeOf(context).height,
                            width: MediaQuery.sizeOf(context).width,
                            padding: EdgeInsets.only(top: 8.h, right: 11.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xff003B61).withOpacity(0.8),
                                  const Color(0xff003B61).withOpacity(0.5),
                                  const Color(0xff003B61).withOpacity(0.4),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: const [0.0, 0.3, 0.4, 0.9],
                              ),
                            ),
                          ),
                        ),
                        if (isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || blockByMe)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || blockByMe))
                          Container(
                            height: MediaQuery.sizeOf(context).height,
                            width: MediaQuery.sizeOf(context).width,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 30.h),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.66), borderRadius: BorderRadius.circular(20.r)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgView("assets/Icons/ProfileDelete.svg", height: 46.w, width: 46.w, fit: BoxFit.scaleDown),
                                SizedBox(height: 12.5.h),
                                Styles.regular(blockFromUser, fs: 16.sp, c: ConstColors.white)
                              ],
                            ),
                          )
                        else ...[
                          // opposite user is not Delete or Block --> [Name], [LastMessage] and [LastMessageTime]
                          Positioned(
                            left: 16.w,
                            right: 16.w,
                            bottom: 9.h,
                            child: SizedBox(
                              width: 186.w,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Styles.regular(
                                      isMe
                                          ? finalItems[index]['FromProfile']['Name'].toString().capitalizeFirst.toString()
                                          : finalItems[index]['ToProfile']['Name'].toString().capitalizeFirst.toString(),
                                      fs: 16.sp,
                                      lns: 1,
                                      al: TextAlign.start,
                                      c: ConstColors.white),
                                  Styles.regular(
                                      GetTimeAgo.parse(DateTime.parse(finalItems[index]['updatedAt'].toString()),
                                          locale: StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode,
                                          pattern: "dd-MM-yyyy hh:mm aa"),
                                      fs: 12.sp,
                                      lns: 1,
                                      al: TextAlign.start,
                                      c: ConstColors.white),
                                  // Last ChatMessage
                                  if (widget.type == "ChatMessage") ...[
                                    if ((finalItems[index]["ChatType"] ?? 'Text').toString().contains('Text'))
                                      Styles.regular(finalItems[index]['Message'].toString(),
                                          fs: 12.sp, lns: 1, al: TextAlign.start, c: ConstColors.white, ff: "HB")
                                    else if (finalItems[index]["ChatType"].toString().contains('Video'))
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SvgView('assets/Icons/videoPost.svg', height: 10.w, width: 10.w, fit: BoxFit.cover, color: Colors.white),
                                          SizedBox(width: 5.w),
                                          Styles.regular('video'.tr, fs: 10.sp, lns: 1, al: TextAlign.start, c: ConstColors.white, ff: "HB")
                                        ],
                                      )
                                    else if (finalItems[index]["ChatType"].toString().contains('Gift'))
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SvgView('assets/Icons/gift.svg', height: 10.w, width: 10.w, fit: BoxFit.cover),
                                          SizedBox(width: 5.w),
                                          Styles.regular(
                                              finalItems[index]["Gifts"] != null &&
                                                      finalItems[index]["Gifts"]
                                                              [StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode] !=
                                                          null
                                                  ? finalItems[index]["Gifts"]
                                                      [StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode]
                                                  : 'gift'.tr,
                                              fs: 10.sp,
                                              lns: 1,
                                              al: TextAlign.start,
                                              c: ConstColors.white,
                                              ff: "HB")
                                        ],
                                      )
                                    else if (finalItems[index]["ChatType"].toString().contains('Image'))
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SvgView('assets/Icons/imagePost.svg', height: 10.w, width: 10.w, fit: BoxFit.cover, color: Colors.white),
                                          SizedBox(width: 5.w),
                                          Styles.regular('photo'.tr, fs: 10.sp, lns: 1, al: TextAlign.start, c: ConstColors.white, ff: "HB")
                                        ],
                                      ),
                                  ] else if (widget.type == "HeartMessage") ...[
                                    // Last HeartMessage --> check my user is male of message is purchase or not
                                    if (StorageService.getBox.read('Gender') == 'male' && !finalItems[index]["IsPurchased"])
                                      Styles.regular('view_message'.tr, fs: 12.sp, lns: 1, al: TextAlign.start, c: ConstColors.white, ff: "HB")
                                    else
                                      Styles.regular(finalItems[index]['Message'].toString(),
                                          fs: 12.sp, lns: 1, al: TextAlign.start, c: ConstColors.white, ff: "HB")
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // opposite user come from [HeartMessage] --> it should always be shown to the receiver, not to the sender
                          Obx(() {
                            refreshCounter.value;
                            if (/* showEyeIcon.value*/ StorageService.getBox.read('Gender') == 'male' &&
                                !finalItems[index]["IsPurchased"] &&
                                widget.type == "HeartMessage") {
                              return Center(
                                child: InkWell(
                                  // check if my user is delete / block onTap null
                                  onTap: (isMe
                                          ? (isToUserORProfileDelete || isToUserORProfileBlock)
                                          : (isFromUserORProfileDelete || isFromUserORProfileBlock))
                                      ? null
                                      : () async {
                                          StorageService.getBox.write('msgFromProfileId',
                                              isMe ? finalItems[index]['ToProfile']['objectId'] : finalItems[index]['FromProfile']['objectId']);
                                          StorageService.getBox.write('msgToProfileId',
                                              isMe ? finalItems[index]['FromProfile']['objectId'] : finalItems[index]['ToProfile']['objectId']);

                                          if (widget.title == 'Mensajes') {
                                            StorageService.getBox.write('chattablename', 'Like_Message');
                                          } else {
                                            StorageService.getBox.write('chattablename', 'Chat_Message');
                                          }
                                          StorageService.getBox.save();

                                          Get.to(() => ConversationScreen(
                                                    fromUserDeleted: isMe
                                                        ? (isToUserORProfileDelete || isToUserORProfileBlock || blockByMe)
                                                        : (isFromUserORProfileDelete || isFromUserORProfileBlock || blockByMe),
                                                    toUserDeleted: isMe
                                                        ? (isFromUserORProfileDelete || isFromUserORProfileBlock || blockByMe)
                                                        : (isToUserORProfileDelete || isToUserORProfileBlock || blockByMe),
                                                    description: widget.title == 'Mensajes'
                                                        ? isMe
                                                            ? finalItems[index]['FromProfile']['Description']
                                                            : finalItems[index]['ToProfile']['Description']
                                                        : null,
                                                    toUser: isMe ? finalItems[index]['FromUser'] : finalItems[index]['ToUser'],
                                                    onlineStatus: onlineStatus,
                                                    tableName: widget.title == 'Mensajes' ? 'Like_Message' : 'Chat_Message',
                                                    toProfileName:
                                                        isMe ? finalItems[index]['FromProfile']['Name'] : finalItems[index]['ToProfile']['Name'],
                                                    toProfileImg: isMe
                                                        ? finalItems[index]['FromProfile']['Imgprofile'].url
                                                        : finalItems[index]['ToProfile']['Imgprofile'].url,
                                                    fromUserImg: isMe
                                                        ? finalItems[index]['ToProfile']['Imgprofile'].url
                                                        : finalItems[index]['FromProfile']['Imgprofile'].url,
                                                    fromProfileId: isMe
                                                        ? finalItems[index]['ToProfile']['objectId']
                                                        : finalItems[index]['FromProfile']['objectId'],
                                                    toProfileId: isMe
                                                        ? finalItems[index]['FromProfile']['objectId']
                                                        : finalItems[index]['ToProfile']['objectId'],
                                                    toUserGender:
                                                        isMe ? finalItems[index]['FromUser']['Gender'] : finalItems[index]['ToUser']['Gender'],
                                                    toUserId:
                                                        isMe ? finalItems[index]['FromUser']['objectId'] : finalItems[index]['ToUser']['objectId'],
                                                  ))!
                                              .whenComplete(() {
                                            removeMessageCount(messageUnReadCountList.value, finalItems[index]['FromProfile']['objectId'],
                                                finalItems[index]['ToProfile']['objectId']);
                                            refreshCounter.value = !refreshCounter.value;
                                          });

                                          if (isMe &&
                                              widget.type == "ChatMessage" &&
                                              finalItems[index]['Chat_Message'] != null &&
                                              !finalItems[index]['Chat_Message']['isRead']) {
                                            final ChatMessage chatMessage = ChatMessage();
                                            chatMessage.objectId = finalItems[index]['Chat_Message']['objectId'];
                                            chatMessage.isRead = true;
                                            final res = await UserChatMessageProviderApi().update(chatMessage);
                                            if (res.success) {
                                              finalItems[index]['Chat_Message'] = res.result;
                                              final PairNotifications pair = PairNotifications();
                                              pair.objectId = finalItems[index]['objectId'];
                                              pair['Chat_Message'] = res.result;
                                              await PairNotificationProviderApi().update(pair);
                                              refreshCounter.value = !refreshCounter.value;
                                              finalItems.refresh();
                                            }
                                          }
                                          if (isMe &&
                                              widget.type == "HeartMessage" &&
                                              finalItems[index]['Like_Message'] != null &&
                                              !(finalItems[index]['Like_Message']['isRead'] ?? true)) {
                                            final LikeMessage likeMessage = LikeMessage();
                                            likeMessage.objectId = finalItems[index]['Like_Message']['objectId'];
                                            likeMessage.isRead = true;
                                            final res = await LikeMsgProviderApi().update(likeMessage);
                                            if (res.success) {
                                              finalItems[index]['Like_Message'] = res.result;
                                              final PairNotifications pair = PairNotifications();
                                              pair.objectId = finalItems[index]['objectId'];
                                              pair['Like_Message'] = res.result;
                                              await PairNotificationProviderApi().update(pair);
                                              refreshCounter.value = !refreshCounter.value;
                                              finalItems.refresh();
                                            }
                                          }
                                        },
                                  child: Container(
                                    height: 64.w,
                                    width: 64.w,
                                    padding: EdgeInsets.all(16.w),
                                    decoration: const BoxDecoration(color: Color(0xffF16C6B), shape: BoxShape.circle),
                                    child: SvgView("assets/Icons/passeye.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          })
                        ],

                        // User 2 when isMe = [true] check ToUser / ToProfile --> my user small image code
                        Positioned(
                          top: 8.h,
                          right: 11.w,
                          left: 11.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!(isMe
                                  ? (isFromUserORProfileDelete || isFromUserORProfileBlock || blockByMe)
                                  : (isToUserORProfileDelete || isToUserORProfileBlock || blockByMe)))
                                Obx(() {
                                  refreshCounter.value;
                                  messageUnReadCountList.value;
                                  List<Map<String, dynamic>> count = messageUnReadCountList.value
                                      .where((element) =>
                                          element['ToProfileID'] == finalItems[index]['ToProfile']['objectId'] &&
                                          element["FromProfileID"] == finalItems[index]['FromProfile']['objectId'])
                                      .toList();
                                  if (count.isNotEmpty &&
                                      messageUnReadCountList.value.isNotEmpty &&
                                      messageUnReadCountList.value
                                          .any((element) => element['FromProfileID'] == finalItems[index]['FromProfile']['objectId']) &&
                                      messageUnReadCountList.value
                                          .any((element) => element['ToProfileID'] == finalItems[index]['ToProfile']['objectId']) &&
                                      count[0]["Count"] != 0) {
                                    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) { showEyeIcon.value = true;});

                                    return Container(
                                      height: 32.h,
                                      width: 40.w,
                                      alignment: Alignment.center,
                                      decoration:
                                          BoxDecoration(color: ConstColors.redColor, borderRadius: BorderRadius.all(Radius.elliptical(40.w, 32.h))),
                                      child: Styles.regular(count[0]["Count"] > 99 ? '+99' : count[0]["Count"].toString(),
                                          c: ConstColors.white, al: TextAlign.center, fs: 18.sp),
                                    );
                                  } else {
                                    return FutureBuilder<ApiResponse?>(
                                        future: widget.tableName == 'Chat_Message'
                                            ? UserChatMessageProviderApi().messageCount(
                                                finalItems[index]['FromProfile']['objectId'], finalItems[index]['ToProfile']['objectId'])
                                            : LikeMsgProviderApi().messageCount(
                                                finalItems[index]['FromProfile']['objectId'], finalItems[index]['ToProfile']['objectId']),
                                        builder: (context, snapLen) {
                                          if (snapLen.hasData && snapLen.data != null && snapLen.data!.results != null) {
                                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                              // showEyeIcon.value = true;
                                              List<Map<String, dynamic>> data = messageUnReadCountList.value;
                                              if (data.any((element) => element['FromProfileID'] == finalItems[index]['FromProfile']['objectId']) &&
                                                  data.any((element) => element['ToProfileID'] == finalItems[index]['ToProfile']['objectId'])) {
                                              } else {
                                                messageUnReadCountList.add({
                                                  "FromProfileID": finalItems[index]['FromProfile']['objectId'],
                                                  "ToProfileID": finalItems[index]['ToProfile']['objectId'],
                                                  "Count": snapLen.data!.results?.length
                                                });
                                              }
                                            });
                                            return Container(
                                              height: 32.h,
                                              width: 40.w,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: ConstColors.redColor, borderRadius: BorderRadius.all(Radius.elliptical(40.w, 32.h))),
                                              child: Styles.regular(
                                                  (snapLen.data!.results?.length ?? 0) > 99 ? '+99' : snapLen.data!.results!.length.toString(),
                                                  c: ConstColors.white,
                                                  al: TextAlign.center,
                                                  fs: 18.sp),
                                            );
                                          } else {
                                            // WidgetsBinding.instance.addPostFrameCallback((timeStamp) { showEyeIcon.value = false;});
                                            return const SizedBox.shrink();
                                          }
                                        });
                                  }
                                }),
                              const Spacer(),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  ImageView(
                                    isMe ? finalItems[index]['ToProfile']['Imgprofile'].url : finalItems[index]['FromProfile']['Imgprofile'].url,
                                    height: 54.w,
                                    width: 54.w,
                                    circle: true,
                                    alignment: Alignment.topCenter,
                                    border: Border.all(color: Colors.white, width: 3.w),
                                    // show when false not delete not block
                                    onTap: (isMe
                                            ? (isToUserORProfileDelete || isToUserORProfileBlock)
                                            : (isFromUserORProfileDelete || isFromUserORProfileBlock))
                                        ? null
                                        : () {
                                            bottomProfile(
                                              context: context,
                                              countryCode: isMe
                                                  ? finalItems[index]['ToProfile']['CountryCode'].toLowerCase()
                                                  : finalItems[index]['FromProfile']['CountryCode'].toLowerCase(),
                                              profileImage: isMe
                                                  ? finalItems[index]['ToProfile']['Imgprofile'].url
                                                  : finalItems[index]['FromProfile']['Imgprofile'].url,
                                              name: isMe ? finalItems[index]['ToProfile']['Name'] : finalItems[index]['FromProfile']['Name'],
                                              location:
                                                  isMe ? finalItems[index]['ToProfile']['Location'] : finalItems[index]['FromProfile']['Location'],
                                              description: isMe
                                                  ? finalItems[index]['ToProfile']['Description']
                                                  : finalItems[index]['FromProfile']['Description'],
                                              languageList:
                                                  isMe ? finalItems[index]['ToProfile']['Language'] : finalItems[index]['FromProfile']['Language'],
                                            );
                                          },
                                  ),

                                  /// my user Delete or Block show when true
                                  if (isMe
                                      ? (isToUserORProfileDelete || isToUserORProfileBlock)
                                      : (isFromUserORProfileDelete || isFromUserORProfileBlock))
                                    Container(
                                      height: 55.w,
                                      width: 55.w,
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.66), shape: BoxShape.circle),
                                      child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // when user send Gift in chat [ChatGift]

                        if (!(isMe
                            ? (isFromUserORProfileDelete || isFromUserORProfileBlock || blockByMe)
                            : (isToUserORProfileDelete || isToUserORProfileBlock || blockByMe)))
                          if (finalItems[index]['Gifts'] != null && widget.type == "ChatGift")
                            Positioned(
                              bottom: 8.h,
                              right: 0.w,
                              child: Image.network(finalItems[index]['Gifts']['Image'].url, height: 107.w, width: 107.w, fit: BoxFit.cover),
                            )
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _downloadInter() async {
    if (_priceController.userTotalCoin.value >= historyStars) {
      isDownloading.value = true;
      bool cancel = false;
      showAlertDownloadDialog(
        context,
        down: Lottie.asset('assets/jsons/download.json', width: MediaQuery.sizeOf(context).width, fit: BoxFit.scaleDown),
        onTap: () {
          Get.to(() => const DownloadScreen());
        },
        onCancel: () {
          Get.back();
          cancel = true;
          isDownloading.value = false;
        },
      );
      await _pairNotificationController.getInteractionData(type: widget.type).then((value) async {
        if (value != null) {
          List<List<dynamic>> rows = [];
          List<String> row = [];
          row.add("No.");
          row.add("Date:");
          row.add("From:");
          row.add("To:");
          row.add("Message:");
          rows.add(row);
          for (int i = 0; i < value.results!.length; i++) {
            final ele = value.results![i];
            final bool isMe = (ele['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));
            List<dynamic> row = [];
            row.add(i + 1);
            row.add(ele["createdAt"]);
            if (isMe) {
              // when other have send me [Received]
              row.add(ele['FromProfile']['Name'].toString().capitalizeFirst.toString());
              row.add(ele['ToProfile']['Name'].toString().capitalizeFirst.toString());
              if (widget.type == 'ChatMessage') {
                if ((ele['ChatType'] ?? 'Text').toString().contains('Text')) {
                  row.add(ele['Message']);
                } else if (ele['ChatType'].toString().contains('Image')) {
                  row.add('${'photo'.tr} ${'Received'.tr}');
                } else if (ele['ChatType'].toString().contains('Video')) {
                  row.add('${'video'.tr} ${'Received'.tr}');
                } else if (ele['ChatType'].toString().contains('Gift')) {
                  row.add('${'Gifts'.tr} ${'Received'.tr}');
                } else {
                  row.add('Received'.tr);
                }
              } else if (widget.type == 'ChatGift') {
                row.add('Received'.tr);
              } else if (widget.type == 'HeartMessage') {
                if (ele['FromUser']["Gender"] == "female" && StorageService.getBox.read('Gender') == 'male' && !ele['IsPurchased']) {
                  row.add('Received'.tr);
                } else {
                  row.add(ele['Message']);
                }
              } else {
                rows.clear();
                row.clear();
              }
            } else {
              // when i have send
              row.add(ele['FromProfile']['Name'].toString().capitalizeFirst.toString());
              row.add(ele['ToProfile']['Name'].toString().capitalizeFirst.toString());
              if (widget.type == 'ChatMessage') {
                if ((ele['ChatType'] ?? 'Text').toString().contains('Text')) {
                  row.add(ele['Message']);
                } else if (ele['ChatType'].toString().contains('Image')) {
                  row.add('${'photo'.tr} ${'Sent'.tr}');
                } else if (ele['ChatType'].toString().contains('Video')) {
                  row.add('${'video'.tr} ${'Sent'.tr}');
                } else if (ele['ChatType'].toString().contains('Gift')) {
                  row.add('${'Gifts'.tr} ${'Sent'.tr}');
                } else {
                  row.add('Sent'.tr);
                }
              } else if (widget.type == 'ChatGift') {
                row.add('Sent'.tr);
              } else if (widget.type == 'HeartMessage') {
                row.add(ele['Message']);
              } else {
                rows.clear();
                row.clear();
              }
            }
            rows.add(row);
          }
          if (rows.isNotEmpty) {
            if (kDebugMode) {
              print('Hello download start downloading');
            }
            final String csv = const ListToCsvConverter().convert(rows);
            final Directory? dir = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
            final String csvFilePath = '${dir!.path}/${widget.type}.csv';
            final File csvFile = File(csvFilePath);
            await csvFile.writeAsString(csv);
            final Archive archive = Archive();
            archive.addFile(ArchiveFile('${widget.type}.csv', csv.length, csv.codeUnits));
            final List<int>? zipData = ZipEncoder().encode(archive);
            final String zipFilePath = '${dir.path}/${widget.type}.zip';
            final File zipFile = File(zipFilePath);
            await zipFile.writeAsBytes(zipData!); // Share the ZIP file
            if (cancel) {
              if (kDebugMode) {
                print('Hello download cancel');
              }
              csvFile.delete();
              zipFile.delete();
            } else {
              // DownloadCSV
              final ParseCloudFunction function = ParseCloudFunction('DownloadCSV');
              final Map<String, dynamic> params = <String, dynamic>{
                'userId': StorageService.getBox.read('ObjectId'),
                'profileId': StorageService.getBox.read('DefaultProfile'),
                'type': widget.type,
                'file': base64Encode(zipFile.readAsBytesSync())
              };
              await function.execute(parameters: params).then((parseResponse) {
                if (kDebugMode) {
                  print("DownloadCSV save status [${parseResponse.statusCode}] ${parseResponse.result}");
                }
                isDownloading.value = false;
                if (parseResponse.success) {
                  if (parseResponse.result['success']) {
                    isDownloading.value = false;
                  } else if (parseResponse.result['message'] == 'User has no coins') {
                    if (StorageService.getBox.read('Gender') == 'female') {
                      gradientSnackBar(context,
                          title: 'More_Stars'.tr.replaceAll('xxx', historyStars.toString()),
                          image: 'assets/Icons/coin.svg',
                          color1: ConstColors.darkRedBlackColor,
                          color2: ConstColors.redColor);
                    } else {
                      Get.to(() => StoreScreen());
                    }
                    csvFile.delete();
                    zipFile.delete();
                  }
                }
              });
            }
          }
        } else {
          cancel = true;
          Get.back();
          isDownloading.value = false;
          gradientSnackBar(context,
              title: 'Something_went_wrong'.tr,
              image: 'assets/Icons/download_outline.svg',
              color1: ConstColors.darkRedBlackColor,
              color2: ConstColors.redColor);
        }
      });
    } else {
      if (StorageService.getBox.read('Gender') == 'female') {
        gradientSnackBar(context,
            title: 'More_Stars'.tr.replaceAll('xxx', historyStars.toString()),
            image: 'assets/Icons/coin.svg',
            color1: ConstColors.darkRedBlackColor,
            color2: ConstColors.redColor);
      } else {
        Get.to(() => StoreScreen());
      }
    }
  }
}
