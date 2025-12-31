// ignore_for_file: must_be_immutable, invalid_use_of_protected_member

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/all_notification_controller/all_notification_controller.dart';

import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/tab_provider/provider_chatmsg.dart';
import 'package:eypop/models/new_notification/new_notification_pair.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../Constant/Widgets/alert_widget.dart';
import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Controllers/PairNotificationController/pair_notification_controller.dart';
import '../../Controllers/user_controller.dart';
import '../../back4appservice/base/api_response.dart';
import '../../back4appservice/user_provider/delete_conversation_api.dart';
import '../../back4appservice/user_provider/tab_provider/provider_likemsg.dart';

import '../../models/delete_table.dart';
import '../../models/user_login/user_login.dart';
import '../../service/local_storage.dart';
import '../splash_screen_first.dart';
import '../tab_pages/conversation_screen.dart';

class FilterMessageScreen extends StatefulWidget {
  const FilterMessageScreen(
      {required this.svg,
      required this.title,
      required this.noTitle,
      required this.tableName,
      required this.futureTitle,
      required this.localTitle,
      required this.profileId,
      Key? key})
      : super(key: key);
  final String svg;
  final String localTitle;
  final String futureTitle;
  final String title;
  final String noTitle;
  final String tableName;
  final String profileId;

  @override
  State<FilterMessageScreen> createState() => _FilterMessageScreenState();
}

class _FilterMessageScreenState extends State<FilterMessageScreen> {
  final PriceController _priceController = Get.put(PriceController());

  final UserController _userController = Get.put(UserController());

  final RxInt totalMsgCount = 0.obs;

  final PairNotificationController _pairNotificationController = Get.put(PairNotificationController());
  final AllNotificationController _allNotificationController = Get.put(AllNotificationController());
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final RxBool isLoading = false.obs;

  void _onRefresh() async {
    _allNotificationController.redFunc(category: widget.title);
    isLoading.value = true;
    loadTime = 0;
    totalMsgCount.value = 0;
    if (finalItems.isNotEmpty) {
      finalItems.clear();
    }
    final ApiResponse? value = await _pairNotificationController.getFilteredData(widget.futureTitle, loadTime, widget.profileId);
    for (var element in value!.results!) {
      if (element['DeletedUsers'] != null && element['DeletedUsers'].toString().contains(StorageService.getBox.read('ObjectId'))) {
      } else {
        finalItems.add(element);
      }
    }
    _refreshController.refreshCompleted();
    Future.delayed(const Duration(seconds: 1), () {
      isNeedLoad.value = false;
    });
    isLoading.value = false;
  }

  final RxList finalItems = [].obs;
  final RxList items = [].obs;
  final RxBool refreshCounter = false.obs;
  final RxBool isNeedLoad = false.obs;
  int loadTime = 0;

  Future<void> _onLoading() async {
    final ApiResponse? data = await _pairNotificationController.getFilteredData(widget.futureTitle, loadTime, widget.profileId);
    final ApiResponse? count = await _pairNotificationController.getCount(widget.futureTitle, widget.profileId);
    totalMsgCount.value = count!.results!.length;
    if (data != null) {
      for (var element in data.results!) {
        if (element['DeletedUsers'] != null && element['DeletedUsers'].toString().contains(StorageService.getBox.read('ObjectId'))) {
        } else {
          finalItems.add(element);
        }
      }
    }
    _refreshController.loadComplete();
    Future.delayed(const Duration(seconds: 1), () {
      isNeedLoad.value = false;
    });
    loadTime += 20;
  }

  @override
  void initState() {
    isLoading.value = true;
    _allNotificationController.redFunc(category: widget.title);
    _onLoading().whenComplete(() {
      isLoading.value = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final RxInt count = 0.obs;
    return PopScope(
      canPop: false,
      onPopInvoked: (pop) {
        if (!pop) {
          _priceController.update();
          Get.back();
        }
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            shadowColor: ConstColors.white,
            elevation: 0.3,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: ConstColors.themeColor,
            leadingWidth: 100.w,
            leading: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      _priceController.update();
                      Get.back();
                    }),
                SvgView(widget.svg, height: 33.w, width: 33.w)
              ],
            ),
            title: Align(alignment: Alignment(-1.2.w, 0), child: Styles.regular(widget.localTitle)),
            actions: [
              Obx(() {
                if (totalMsgCount.value != 0) {
                  return Align(
                    child: Container(
                      padding: EdgeInsets.only(left: 12.w, right: 12.w),
                      height: 29.h,
                      decoration: BoxDecoration(color: ConstColors.redColor, borderRadius: const BorderRadius.all(Radius.elliptical(90, 50))),
                      child: Center(child: Styles.regular(totalMsgCount.value.toString(), c: ConstColors.white)),
                    ),
                  );
                } else {
                  return const SizedBox(height: 0.0);
                }
              }),
              SizedBox(width: 20.w)
            ],
          ),
          body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: Obx(() {
              return CustomHeader(
                height: isNeedLoad.value ? 0.0 : 150.0.h,
                refreshStyle: RefreshStyle.Behind,
                builder: (context, mode) {
                  Widget? body;
                  if (!isNeedLoad.value) {
                    if (mode == RefreshStatus.canRefresh) {
                      body = SizedBox(height: 20.h, child: Lottie.asset('assets/jsons/down-loading.json'));
                    }

                    if (mode == RefreshStatus.refreshing) {
                      body = SizedBox(height: 20.h, child: Lottie.asset('assets/jsons/down-loading.json'));
                    }
                    if (mode == RefreshStatus.completed) {}
                  }
                  if (body == null) {
                    return const SizedBox(height: 0.0, width: 0.0);
                  } else {
                    return Center(child: body);
                  }
                },
              );
            }),
            footer: CustomFooter(
              height: 20.0,
              builder: (context, LoadStatus? mode) {
                Widget body = const SizedBox.shrink();
                if (mode == LoadStatus.loading) {
                  body = const CupertinoActivityIndicator();
                }
                return SizedBox(height: 20, child: Center(child: body));
              },
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: SingleChildScrollView(
              child: Obx(() {
                finalItems.value;
                if (finalItems.isNotEmpty) {
                  return SizedBox(
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: finalItems.length,
                      itemBuilder: (context, index) {
                        /// when my user in ToUser
                        final bool isMe = (finalItems[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

                        /// other user block me and me block other user
                        final bool isBlockProfile = (_pairNotificationController.meBlocked.toString().contains(finalItems[index]['FromProfile']['objectId']) &&
                            _pairNotificationController.meBlocked.toString().contains(finalItems[index]['ToProfile']['objectId'])); // update block

                        /// when FromProfile OR FromUser block
                        final bool isFromUserORProfileBlock = ((finalItems[index]['FromUser']['IsBlocked'] ?? false) || (finalItems[index]['FromProfile']['IsBlocked'] ?? false));

                        /// when ToProfile OR ToUser block
                        final bool isToUserORProfileBlock = ((finalItems[index]['ToUser']['IsBlocked'] ?? false) || (finalItems[index]['ToProfile']['IsBlocked'] ?? false));

                        /// when FromProfile OR FromUser delete
                        final bool isFromUserORProfileDelete = ((finalItems[index]['FromUser']['isDeleted'] ?? false) || (finalItems[index]['FromProfile']['isDeleted'] ?? false));

                        /// when ToProfile OR ToUser delete
                        final bool isToUserORProfileDelete = ((finalItems[index]['ToUser']['isDeleted'] ?? false) || (finalItems[index]['ToProfile']['isDeleted'] ?? false));

                        /// check FromUser is online [YOU] same vala
                        bool onlineStatus;
                        if ((isMe ? finalItems[index]['FromProfile']['NoChats'] ?? false : finalItems[index]['ToProfile']['NoChats'] ?? false)) {
                          if (isMe ? (isFromUserORProfileDelete || isBlockProfile) : (isToUserORProfileDelete || isBlockProfile)) {
                            onlineStatus = false;
                          } else {
                            onlineStatus = true;
                          }
                        } else {
                          onlineStatus = true; // false
                        }
                        final RxBool singleRefCounter = false.obs;
                        return Slidable(
                          key: ValueKey(index),
                          endActionPane: ActionPane(
                            extentRatio: .25,
                            motion: const ScrollMotion(),
                            children: [
                              CustomSlidableAction(
                                backgroundColor: ConstColors.themeColor,
                                onPressed: (context) {
                                  AlertShow(
                                      svg: "assets/Icons/delete.svg",
                                      alert: "${'remove'.tr} ${widget.localTitle.toUpperCase()}!",
                                      confirmText: 'remove'.tr.replaceAll('¡', ''),
                                      text1: "",
                                      text2: "${'want_to_delete_this'.tr} ${widget.localTitle.toUpperCase()}?",
                                      onConfirm: () async {
                                        DeleteConversationApi()
                                            .getSpeceficId(
                                                fromId: finalItems[index]['FromProfile']['objectId'], toId: finalItems[index]['ToProfile']['objectId'], type: widget.title)
                                            .then((value) {
                                          if (value != null) {
                                            DeleteConnection deleteConnection = DeleteConnection();
                                            deleteConnection.objectId = value.result['objectId'];
                                            DeleteConversationApi().update(deleteConnection).whenComplete(() {
                                              DeleteConversationApi().getByUserId(StorageService.getBox.read('ObjectId'), widget.title).then((value) {
                                                _userController.update();
                                              });
                                            });
                                          } else {
                                            DeleteConnection deleteConnection = DeleteConnection();
                                            deleteConnection.toUser = UserLogin()..objectId = finalItems[index]['ToUser']['objectId'];
                                            deleteConnection.type = widget.title;
                                            deleteConnection.fromUser = UserLogin()..objectId = finalItems[index]['FromUser']['objectId'];
                                            deleteConnection.toProfile = ProfilePage()..objectId = finalItems[index]['ToProfile']['objectId'];
                                            deleteConnection.fromProfile = ProfilePage()..objectId = finalItems[index]['FromProfile']['objectId'];
                                            DeleteConversationApi().add(deleteConnection).whenComplete(() {
                                              DeleteConversationApi().getByUserId(StorageService.getBox.read('ObjectId'), widget.title).then((value) {
                                                _userController.update();
                                              });
                                            });
                                          }
                                        });
                                        _pairNotificationController.setMarkAsRead(
                                            widget.title, finalItems[index]['FromProfile']['objectId'], finalItems[index]['ToProfile']['objectId']);
                                        await PairNotificationProviderApi()
                                            .getByProfile(finalItems[index]['FromProfile']['objectId'], finalItems[index]['ToProfile']['objectId'], widget.futureTitle)
                                            .then((value) {
                                          PairNotifications pairNotifications = PairNotifications();
                                          if (value == null) {
                                          } else {
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

                                          isNeedLoad.value = true;
                                          finalItems.removeAt(index);
                                        });
                                      },
                                      context: context);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/Icons/delete.svg",
                                      height: 31.w,
                                      width: 24.w,
                                      fit: BoxFit.scaleDown,
                                    ),
                                    SizedBox(
                                      height: 14.w,
                                    ),
                                    Styles.regular('remove'.tr.replaceAll('¡', ''), c: ConstColors.white, fs: 14.sp, al: TextAlign.center)
                                  ],
                                ),
                              ),
                            ],
                          ),
                          startActionPane: ActionPane(
                            extentRatio: .25,
                            motion: const ScrollMotion(),
                            children: [
                              CustomSlidableAction(
                                backgroundColor: ConstColors.themeColor,
                                onPressed: (context) {
                                  AlertShow(
                                      svg: "assets/Icons/delete.svg",
                                      alert: "${'remove'.tr} ${widget.localTitle.toUpperCase()}!",
                                      confirmText: 'remove'.tr.replaceAll('¡', ''),
                                      text1: "",
                                      text2: "${'want_to_delete_this'.tr} ${widget.localTitle.toUpperCase()}?",
                                      onConfirm: () async {
                                        DeleteConversationApi()
                                            .getSpeceficId(
                                                fromId: finalItems[index]['FromProfile']['objectId'], toId: finalItems[index]['ToProfile']['objectId'], type: widget.title)
                                            .then((value) {
                                          if (value != null) {
                                            DeleteConnection deleteConnection = DeleteConnection();
                                            deleteConnection.objectId = value.result['objectId'];
                                            DeleteConversationApi().update(deleteConnection).whenComplete(() {
                                              DeleteConversationApi().getByUserId(StorageService.getBox.read('ObjectId'), widget.title).then((value) {
                                                _userController.update();
                                              });
                                            });
                                          } else {
                                            DeleteConnection deleteConnection = DeleteConnection();
                                            deleteConnection.toUser = UserLogin()..objectId = finalItems[index]['ToUser']['objectId'];
                                            deleteConnection.type = widget.title;
                                            deleteConnection.fromUser = UserLogin()..objectId = finalItems[index]['FromUser']['objectId'];
                                            deleteConnection.toProfile = ProfilePage()..objectId = finalItems[index]['ToProfile']['objectId'];
                                            deleteConnection.fromProfile = ProfilePage()..objectId = finalItems[index]['FromProfile']['objectId'];
                                            DeleteConversationApi().add(deleteConnection).whenComplete(() {
                                              DeleteConversationApi().getByUserId(StorageService.getBox.read('ObjectId'), widget.title).then((value) {
                                                _userController.update();
                                              });
                                            });
                                          }
                                        });
                                        _pairNotificationController.setMarkAsRead(
                                            widget.title, finalItems[index]['FromProfile']['objectId'], finalItems[index]['ToProfile']['objectId']);
                                        await PairNotificationProviderApi()
                                            .getByProfile(finalItems[index]['FromProfile']['objectId'], finalItems[index]['ToProfile']['objectId'], widget.futureTitle)
                                            .then((value) {
                                          PairNotifications pairNotifications = PairNotifications();
                                          if (value == null) {
                                          } else {
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

                                          isNeedLoad.value = true;
                                          finalItems.removeAt(index);
                                        });
                                      },
                                      context: context);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/Icons/delete.svg",
                                      height: 31.w,
                                      width: 24.w,
                                      fit: BoxFit.scaleDown,
                                    ),
                                    SizedBox(
                                      height: 14.w,
                                    ),
                                    Styles.regular('remove'.tr.replaceAll('¡', ''), c: ConstColors.white, fs: 14.sp, al: TextAlign.center)
                                  ],
                                ),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: EdgeInsets.only(left: 20.w),
                            height: 81.h,
                            child: GestureDetector(
                              onTap: () {
                                StorageService.getBox.write('msgFromProfileId', isMe ? finalItems[index]['ToProfile']['objectId'] : finalItems[index]['FromProfile']['objectId']);
                                StorageService.getBox.write('msgToProfileId', isMe ? finalItems[index]['FromProfile']['objectId'] : finalItems[index]['ToProfile']['objectId']);

                                if (widget.title == 'Mensajes') {
                                  StorageService.getBox.write('chattablename', 'Like_Message');
                                } else {
                                  StorageService.getBox.write('chattablename', 'Chat_Message');
                                }
                                StorageService.getBox.save();
                                Get.to(
                                  () => ConversationScreen(
                                    fromUserDeleted: isMe
                                        ? (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile)
                                        : (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile),
                                    toUserDeleted: isMe
                                        ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                                        : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile),
                                    description: widget.title == 'Mensajes'
                                        ? isMe
                                            ? finalItems[index]['FromProfile']['Description']
                                            : finalItems[index]['ToProfile']['Description']
                                        : null,
                                    toUser: isMe ? finalItems[index]['FromUser'] : finalItems[index]['ToUser'],
                                    onlineStatus: onlineStatus,
                                    tableName: widget.title == 'Mensajes' ? 'Like_Message' : 'Chat_Message',
                                    toProfileName: isMe ? finalItems[index]['FromProfile']['Name'] : finalItems[index]['ToProfile']['Name'],
                                    toProfileImg: isMe ? finalItems[index]['FromProfile']['Imgprofile'].url : finalItems[index]['ToProfile']['Imgprofile'].url,
                                    fromUserImg: isMe ? finalItems[index]['ToProfile']['Imgprofile'].url : finalItems[index]['FromProfile']['Imgprofile'].url,
                                    fromProfileId: isMe ? finalItems[index]['ToProfile']['objectId'] : finalItems[index]['FromProfile']['objectId'],
                                    toProfileId: isMe ? finalItems[index]['FromProfile']['objectId'] : finalItems[index]['ToProfile']['objectId'],
                                    toUserGender: isMe ? finalItems[index]['FromUser']['Gender'] : finalItems[index]['ToUser']['Gender'],
                                    toUserId: isMe ? finalItems[index]['FromUser']['objectId'] : finalItems[index]['ToUser']['objectId'],
                                  ),
                                )!
                                    .then((value) {
                                  if (value != null) {
                                    isNeedLoad.value = true;
                                    finalItems[index]['Message'] = value;
                                    finalItems[index]["IsPurchased"] = true;
                                    finalItems[index]['updatedAt'] = DateTime.now();
                                    final element = finalItems[index];
                                    finalItems.removeAt(index);
                                    finalItems.insert(0, element);
                                    refreshCounter.value = !refreshCounter.value;
                                  }
                                  singleRefCounter.value = !singleRefCounter.value;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 80.w,
                                    child: Center(
                                      child: SizedBox(
                                        height: 60.h,
                                        width: 60.h,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(60.r),
                                          child: Stack(
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: isMe ? finalItems[index]['FromProfile']['Imgprofile'].url : finalItems[index]['ToProfile']['Imgprofile'].url,
                                                memCacheHeight: 200,
                                                height: MediaQuery.of(context).size.height,
                                                width: MediaQuery.of(context).size.width,
                                                fit: BoxFit.cover,
                                                fadeInDuration: const Duration(milliseconds: 100),
                                                placeholderFadeInDuration: const Duration(milliseconds: 100),
                                                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                              ),
                                              if (isMe
                                                  ? (isFromUserORProfileDelete || isFromUserORProfileBlock || isBlockProfile)
                                                  : (isToUserORProfileDelete || isToUserORProfileBlock || isBlockProfile))
                                                Container(
                                                  padding: EdgeInsets.all(15.h),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.6),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    "assets/Icons/ProfileDelete.svg",
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 9.h),
                                          child: Row(
                                            children: [
                                              if (widget.futureTitle != 'HeartMessage') ...[
                                                Container(
                                                  height: 11.h,
                                                  width: 11.h,
                                                  decoration: BoxDecoration(shape: BoxShape.circle, color: onlineStatus == true ? Colors.green : const Color(0xffB3C1DB)),
                                                ),
                                                SizedBox(width: 6.w),
                                              ],
                                              SizedBox(
                                                width: 200.w,
                                                child: Styles.regular(
                                                    isMe
                                                        ? finalItems[index]['FromProfile']['Name'].toString().capitalizeFirst.toString()
                                                        : finalItems[index]['ToProfile']['Name'].toString().capitalizeFirst.toString(),
                                                    c: Theme.of(context).primaryColor,
                                                    ff: 'RB',
                                                    ov: TextOverflow.ellipsis,
                                                    fw: FontWeight.bold,
                                                    fs: 20.sp),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        SizedBox(
                                          width: 222.w,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: StorageService.getBox.read('Gender') == 'male' && !finalItems[index]["IsPurchased"]
                                                    ? Styles.regular('view_message'.tr, ov: TextOverflow.ellipsis, c: ConstColors.themeColor, ff: 'RB', fs: 18.sp)
                                                    : Styles.regular(finalItems[index]['Message'], ov: TextOverflow.ellipsis, c: Theme.of(context).primaryColor, ff: 'RR', fs: 18.sp),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 9.h, right: 20.w, bottom: 9.h),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Styles.regular(
                                            getDateAndDay(
                                              context,
                                              datetime: DateTime.parse(finalItems[index]['updatedAt'].toString()),
                                            ).toString(),
                                            c: ConstColors.subtitle,
                                            ff: 'RR',
                                            fs: 14.sp),
                                        Obx(() {
                                          refreshCounter.value;
                                          singleRefCounter.value;
                                          return FutureBuilder<ApiResponse?>(
                                              future: widget.tableName == 'Chat_Message'
                                                  ? UserChatMessageProviderApi()
                                                      .messageCount(finalItems[index]['FromProfile']['objectId'], finalItems[index]['ToProfile']['objectId'])
                                                  : LikeMsgProviderApi().messageCount(finalItems[index]['FromProfile']['objectId'], finalItems[index]['ToProfile']['objectId']),
                                              builder: (context, snapLen) {
                                                if (snapLen.data != null) {
                                                  return Container(
                                                    padding: EdgeInsets.only(left: 12.w, right: 12.w),
                                                    height: 30.h,
                                                    decoration: BoxDecoration(color: ConstColors.themeColor, borderRadius: BorderRadius.circular(20.r)),
                                                    child: Center(child: Styles.regular(snapLen.data!.results!.length.toString(), c: ConstColors.white)),
                                                  );
                                                } else {
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    count.value = 0;
                                                  });
                                                  return const SizedBox(height: 0.0, width: 0.0);
                                                }
                                              });
                                        }),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(height: 1.h, color: isDarkMode.value ? const Color(0xffEBECEE).withOpacity(0.2) : const Color(0xffEBECEE));
                      },
                    ),
                  );
                } else {
                  if (isLoading.value) {
                    return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: CircularProgressIndicator(
                          color: ConstColors.themeColor,
                        )));
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Styles.regular(widget.noTitle, c: Theme.of(context).primaryColor),
                      ),
                    );
                  }
                }
              }),
            ),
          )),
    );
  }
}

getDateAndDay(context, {datetime}) {
  String dateFormatter(DateTime date) {
    dynamic dayData =
        '{ "1" : "${'monday'.tr}", "2" : "${'tuesday'.tr}", "3" : "${'wednesday'.tr}", "4" : "${'thursday'.tr}", "5" : "${'friday'.tr}", "6" : "${'saturday'.tr}", "7" : "${'sunday'.tr}" }';

    return json.decode(dayData)['${date.weekday}'];
  }

  final elapsed = DateTime.now().millisecondsSinceEpoch - datetime.millisecondsSinceEpoch;

  final num seconds = elapsed / 1000;
  final num minutes = seconds / 60;
  final num hours = minutes / 60;
  final num days = hours / 24;

  if (hours < 24) {
    final String formattedDate = DateFormat('hh:mm').format(datetime);
    return formattedDate;
  } else if (hours < 48) {
    return 'yesterday'.tr;
  } else if (days < 7) {
    final String formattedDate = dateFormatter(datetime);
    return formattedDate;
  } else {
   final String formattedDate = DateFormat('dd/MM/yyyy').format(datetime);
    return formattedDate;
  }
}
