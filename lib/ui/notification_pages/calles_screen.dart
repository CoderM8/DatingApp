// ignore_for_file: must_be_immutable, null_check_always_fails, invalid_use_of_protected_member

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:csv/csv.dart';
import 'package:eypop/Constant/Widgets/alert_widget.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/post_view.dart';
import 'package:eypop/Controllers/search_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/user_provider/delete_conversation_api.dart';
import 'package:eypop/back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/vertical_tab/provider_blockuser.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/verticaltab_model/blockuser.dart';
import 'package:eypop/ui/bottom_screen.dart';
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

import '../../Constant/Widgets/bottom_sheet.dart';
import '../../Constant/Widgets/filter_notification.dart';
import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Controllers/PairNotificationController/pair_notification_controller.dart';
import '../../Controllers/all_notification_controller/all_notification_controller.dart';
import '../../Controllers/price_controller.dart';
import '../../back4appservice/repositories/Calls/call_provider_api.dart';
import '../../gettimeago/get_time_ago.dart';
import '../../models/delete_table.dart';
import '../../models/new_notification/new_notification_pair.dart';
import '../../models/user_login/user_profile.dart';
import '../../service/local_storage.dart';
import '../User_profile/user_fullprofile_screen.dart';

class CallScreen extends StatefulWidget {
  const CallScreen(
      {this.visitType = false,
      required this.showNumber,
      required this.type,
      required this.title,
      required this.noTitle,
      required this.newTitle,
      Key? key})
      : super(key: key);
  final String title;
  final String noTitle;
  final String newTitle;
  final String type;
  final bool showNumber;
  final bool visitType;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final PriceController _priceController = Get.put(PriceController());
  final PairNotificationController _pairNotificationController = Get.put(PairNotificationController());
  final AllNotificationController _allNotificationController = Get.put(AllNotificationController());

  final AppSearchController _searchController = Get.put(AppSearchController());
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final RxBool isLoading = false.obs;
  final RxBool isDeleteLoading = false.obs;
  final RxList finalItems = [].obs;
  final RxInt loadTime = 0.obs;
  final RxString filters = 'all'.obs;

  Future<void> _onRefresh() async {
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
    if (filters.value == 'filter1') {
      print('------ Hello OutGoing Data Filter1 ------');
      await _pairNotificationController.getOutGoingData(type: widget.type, page: loadTime.value, limit: 20).then((value) async {
        if (widget.type == 'VideoCall' || widget.type == 'Call') {
          if (value != null) {
            for (var element in value.results!) {
              if (element['call'] == null) {
                /// print('hello objectid --- ${ele['objectId']}');
                final data22 = await UserCallProviderApi().getCallByPointer(element['objectId'], widget.type == 'Call');
                if (data22 != null) {
                  if (data22.result['Accepted'] == true &&
                      data22.result['IsCallEnd'] == true &&
                      data22.result['FromUser']['objectId'].toString().contains(StorageService.getBox.read('ObjectId'))) {
                    element['call'] = data22.result;
                    finalItems.add(element);
                  }
                }
              } else {
                if (element['call']['Accepted'] == true &&
                    element['call']['IsCallEnd'] == true &&
                    element['call']['FromUser']['objectId'].toString().contains(StorageService.getBox.read('ObjectId'))) {
                  finalItems.add(element);
                }
              }
            }
          }
        } else {
          data = value;
        }
      });
    } else if (filters.value == 'filter2') {
      print('------ Hello InComing Data Filter2 ------');
      await _pairNotificationController.getInComingData(type: widget.type, page: loadTime.value).then((value) async {
        if (widget.type == 'VideoCall' || widget.type == 'Call') {
          if (value != null) {
            for (var element in value.results!) {
              if (element['call'] == null) {
                /// print('hello objectid --- ${ele['objectId']}');
                final data22 = await UserCallProviderApi().getCallByPointer(element['objectId'], widget.type == 'Call');
                if (data22 != null) {
                  if (data22.result['Accepted'] == true &&
                      data22.result['IsCallEnd'] == true &&
                      !(data22.result['FromUser']['objectId'].toString().contains(StorageService.getBox.read('ObjectId')))) {
                    element['call'] = data22.result;
                    finalItems.add(element);
                  }
                }
              } else {
                if (element['call']['Accepted'] == true &&
                    element['call']['IsCallEnd'] == true &&
                    !(element['call']['FromUser']['objectId'].toString().contains(StorageService.getBox.read('ObjectId')))) {
                  finalItems.add(element);
                }
              }
            }
          }
        } else {
          data = value;
        }
      });
    } else if (filters.value == 'filter3') {
      // missed - not Lost received
      print('------ Hello MissedReceive Data Filter3 ------');
      await _pairNotificationController.getMissedCallData(type: widget.type, page: loadTime.value).then((value) async {
        if (value != null) {
          for (final element in value.results ?? []) {
            if (element['call']["Accepted"] == false && element['call']["IsCallEnd"] == true) {
              finalItems.add(element);
            }
          }
        }
      });
    } else if (filters.value == 'filter4') {
      // busy and not responding
      print('------ Hello BusyCall Data Filter4 ------');
      await _pairNotificationController.getBusyCallData(type: widget.type, page: loadTime.value).then((value) async {
        if (value != null) {
          for (final element in value.results ?? []) {
            if (element['call'] != null) {
              if (element['call']["Accepted"] == false && element['call']["IsCallEnd"] == true) {
                finalItems.add(element);
              }
            }else{
              finalItems.add(element);
            }
          }
        }
      });
    } else {
      if (widget.type == 'BlocUser') {
        print('------ Hello Blockuser Data ------');
        data = await _pairNotificationController.getOutGoingData(type: 'BlocUser', page: loadTime.value, limit: 20);
      } else {
        print('------ Hello All Data ------');
        data = await _pairNotificationController.getFutureData(type: widget.type, page: loadTime.value, limit: 20);
      }
    }
    if (data != null) {
      finalItems.addAll(data?.results ?? []);
      loadTime.value += 20;
      _refreshController.loadComplete();
    } else {
      await Future.delayed(const Duration(seconds: 2));
      _refreshController.loadNoData();
      data = null;
    }
  }

  @override
  void initState() {
    _allNotificationController.redFunc(category: widget.title);
    isLoading.value = true;
    _onLoading().whenComplete(() {
      isLoading.value = false;
    });
    super.initState();
  }

  _willPopCallback(bool didPop) async {
    if (!didPop) {
      if (widget.visitType) {
        Get.offAll(() => BottomScreen());
      } else {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _willPopCallback,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.3,
          centerTitle: true,
          toolbarHeight: 80.h,
          title: Styles.regular(widget.newTitle, c: ConstColors.darkGreyColor, ff: "HB", fs: 38.sp),
          leading: Back(
            svg: "assets/Icons/close.svg",
            color: ConstColors.darkGreyColor,
            height: 25.w,
            width: 25.w,
            onTap: () {
              if (widget.visitType) {
                Get.offAll(() => BottomScreen());
              } else {
                Get.back();
              }
            },
            padding: EdgeInsets.only(bottom: 2.h),
          ),
          actions: [
            if (widget.type != 'BlocUser')
              InkWell(
                onTap: () async {
                  await HapticFeedback.vibrate();
                  Navigator.push(
                    context,
                    CustomPopupRoute(
                        child: AllFilters(
                      title: widget.title,
                      filter: filters.value,
                      onTap: (event) {
                        if (!filters.contains(event)) {
                          filters.value = event;
                          _onRefresh();
                        }
                      },
                    )),
                  );
                },
                child: Container(
                  alignment: Alignment.topRight,
                  height: 60.h,
                  width: 60.w,
                  child: SvgView(
                    'assets/Icons/option.svg',
                    color: ConstColors.darkGreyColor,
                    padding: EdgeInsets.only(top: 25.h, right: 20.w),
                    width: 32.w,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            SmartRefresher(
              key: ValueKey(_refreshController),
              enablePullDown: true,
              enablePullUp: true,
              header: CustomHeader(
                refreshStyle: RefreshStyle.Behind,
                builder: (context, mode) {
                  return const SizedBox.shrink();
                },
              ),
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
                            Styles.regular("${'We_show_you_the_last'.tr} $historyLimit ${widget.newTitle}",
                                fs: 16.sp, ff: "HB", c: Theme.of(context).primaryColor.withOpacity(0.7), lns: 2, al: TextAlign.center),
                            SizedBox(height: 12.h),
                            SvgView('assets/Icons/zip_download.svg', color: ConstColors.themeColor, height: 44.h, width: 40.w, fit: BoxFit.cover),
                            SizedBox(height: 12.h),
                            Styles.regular("${'Download_your_entire_history_of'.tr} ${widget.newTitle}",
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
              child: SingleChildScrollView(
                child: Obx(() {
                  if (isLoading.value) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.2,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown),
                      ),
                    );
                  }
                  if (finalItems.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Styles.regular(widget.noTitle, c: Theme.of(context).primaryColor),
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: finalItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 1, mainAxisSpacing: 16.h, crossAxisSpacing: 16.w),
                    itemBuilder: (c, index) {
                      /// other user block me and me block other user
                      final bool blockByMe =
                          (_pairNotificationController.meBlocked.toString().contains(finalItems[index]['FromProfile']['objectId']) &&
                              _pairNotificationController.meBlocked.toString().contains(finalItems[index]['ToProfile']['objectId'])); // update block

                      /// when my user in ToUser
                      final bool isMe = (finalItems[index]['ToUser']['objectId'] == StorageService.getBox.read('ObjectId'));

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

                      String blockFromUser = '';

                      //print('hello object id ----- ${finalItems[index]['objectId']}');
                      //print('hello fromuser id ----- ${finalItems[index]['FromUser']['objectId']}');
                      //print('hello touser id ----- ${finalItems[index]['ToUser']['objectId']}');

                      /// FOR BLOCK SECTION IF USER COME FROM OWN BLOCK SECTION
                      if ((widget.type == 'BlocUser' && blockByMe)) {
                        blockFromUser = 'Profile_Blocked'.tr;
                      } else {
                        /// FOR OTHER SECTION DELETE USER
                        if (isFromUserORProfileDelete) {
                          blockFromUser = 'Profile_Deleted'.tr;
                        } else {
                          /// FOR OTHER SECTION BLOCK USER
                          blockFromUser = 'Profile_Blocked'.tr;
                        }
                      }
                      return InkWell(
                        onLongPress: () {
                          // change delete button text when title = Bloqueados
                          deleteItemSheet(context, title: widget.type == 'BlocUser' ? 'unlock'.tr : 'Delete'.tr, onTap: () async {
                            isDeleteLoading.value = true;
                            Get.back();
                            if (widget.type == 'BlocUser') {
                              String objectId = '';
                              await BlockUSerProviderApi().getByUserId(StorageService.getBox.read('ObjectId')).then((value) {
                                if (value != null) {
                                  for (var element in value.results!) {
                                    if (element.toString().contains(finalItems[index]['ToUser']['objectId'])) {
                                      objectId = element['objectId'];
                                    }
                                  }
                                }
                              });
                              final BlockUser blockUser = BlockUser();
                              blockUser.objectId = objectId;
                              BlockUSerProviderApi().remove(blockUser).whenComplete(() {
                                _priceController.update();
                              });
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
                                gradientSnackBar(context, title: 'Unlocked'.tr, image: "assets/Icons/lock.svg");
                              });
                            } else {
                              await DeleteConversationApi()
                                  .getSpeceficId(
                                      fromId: finalItems[index]['FromProfile']['objectId'],
                                      toId: finalItems[index]['ToProfile']['objectId'],
                                      type: widget.title)
                                  .then((value) {
                                if (value != null) {
                                  DeleteConnection deleteConnection = DeleteConnection();
                                  deleteConnection.objectId = value.result['objectId'];
                                  DeleteConversationApi().update(deleteConnection).whenComplete(() {
                                    DeleteConversationApi().getByUserId(StorageService.getBox.read('ObjectId'), widget.title);
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
                                      _priceController.update();
                                    });
                                  });
                                }
                              });
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
                            }
                            isDeleteLoading.value = false;
                          });
                        },
                        // navigate when any one is not block / delete
                        onTap: ((isMe
                                    ? (isFromUserORProfileDelete || isFromUserORProfileBlock || blockByMe)
                                    : (isToUserORProfileDelete || isToUserORProfileBlock || blockByMe)) ||
                                (isMe
                                    ? (isToUserORProfileDelete || isToUserORProfileBlock)
                                    : (isFromUserORProfileDelete || isFromUserORProfileBlock)))
                            ? () {
                                if (kDebugMode) {
                                  print('Hello call screen onTap null');
                                }
                              }
                            : () {
                                // check current profile isDelete or not
                                if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted) {
                                  Get.to(() => UserFullProfileScreen(
                                        toUserId: (isMe ? finalItems[index]['FromUser'] : finalItems[index]['ToUser']),
                                        toProfileId: isMe ? finalItems[index]['FromProfile']['objectId'] : finalItems[index]['ToProfile']['objectId'],
                                        fromProfileId:
                                            !isMe ? finalItems[index]['FromProfile']['objectId'] : finalItems[index]['ToProfile']['objectId'],
                                        fromProfileImg: !isMe
                                            ? finalItems[index]['FromProfile']['Imgprofile'].url
                                            : finalItems[index]['ToProfile']['Imgprofile'].url,
                                      ));
                                } else {
                                  deleteProfileSnackBar(context);
                                }
                              },
                        child: Stack(
                          children: [
                            Container(
                              key: UniqueKey(),
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
                            // opposite user is Delete or Block / block by me
                            if (isMe
                                ? (isFromUserORProfileDelete || isFromUserORProfileBlock || blockByMe)
                                : (isToUserORProfileDelete || isToUserORProfileBlock || blockByMe))
                              Container(
                                key: UniqueKey(),
                                height: MediaQuery.sizeOf(context).height,
                                width: MediaQuery.sizeOf(context).width,
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 30.h),
                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.66), borderRadius: BorderRadius.circular(20.r)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgView(widget.type == "BlocUser" ? "assets/Icons/lock.svg" : "assets/Icons/ProfileDelete.svg",
                                        height: 46.w, width: 46.w, fit: BoxFit.scaleDown),
                                    SizedBox(height: 12.5.h),
                                    Styles.regular(blockFromUser, fs: 16.sp, c: ConstColors.white)
                                  ],
                                ),
                              )
                            else ...[
                              // opposite user is not Delete or Block --> [Name], [LastMessage] and [LastMessageTime]
                              Positioned(
                                key: UniqueKey(),
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
                                      // widget.futureTitle == "WinkMessage" ---> show winkMessage
                                      if (widget.type == "WinkMessage")
                                        Styles.regular(finalItems[index]['Message'].toString(),
                                            fs: 12.sp, lns: 1, al: TextAlign.start, c: ConstColors.white, ff: "HB")
                                    ],
                                  ),
                                ),
                              ),
                              // opposite user come from [WinkMessage] ---> check LastMessage is not purchase and male
                              // Guiños purchase button
                              if (widget.type == "WinkMessage" &&
                                  (isMe ? finalItems[index]['FromUser']["Gender"] == 'female' : finalItems[index]['ToUser']["Gender"] == "female") &&
                                  StorageService.getBox.read('Gender') == 'male' &&
                                  !finalItems[index]['IsPurchased'])
                                Center(
                                  key: UniqueKey(),
                                  child: InkWell(
                                    // check if my user is delete / block onTap null
                                    onTap: (isMe
                                            ? (isToUserORProfileDelete || isToUserORProfileBlock)
                                            : (isFromUserORProfileDelete || isFromUserORProfileBlock))
                                        ? () {
                                            if (kDebugMode) {
                                              print('Hello call screen WinkMessage purchase onTap null');
                                            }
                                          }
                                        : () {
                                            // check current profile idDelete or not
                                            if (!_searchController.profileData[StorageService.getBox.read('index') ?? 0].isDeleted) {
                                              _priceController
                                                  .winkReceivedPurchase(finalItems[index],
                                                      pair: _pairNotificationController, notification: _allNotificationController)
                                                  .then((isPurchased) {
                                                if (isPurchased) {
                                                  final element = finalItems[index];
                                                  element['IsPurchased'] = isPurchased;
                                                  finalItems.removeAt(index);
                                                  finalItems.insert(0, element);
                                                }
                                              });
                                            } else {
                                              deleteProfileSnackBar(context);
                                            }
                                          },
                                    child: BlurryContainer(
                                      blur: 6,
                                      height: MediaQuery.sizeOf(context).height,
                                      width: MediaQuery.sizeOf(context).width,
                                      borderRadius: BorderRadius.circular(20.r),
                                      child: SvgView("assets/Icons/passeye.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                                    ),
                                  ),
                                ),
                            ],
                            // User 2 when isMe = [true] check ToUser / ToProfile --> my user small image code
                            Positioned(
                                top: 8.h,
                                right: 11.w,
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ImageView(
                                          isMe
                                              ? finalItems[index]['ToProfile']['Imgprofile'].url
                                              : finalItems[index]['FromProfile']['Imgprofile'].url,
                                          height: 54.w,
                                          width: 54.w,
                                          circle: true,alignment: Alignment.topCenter,
                                          border: Border.all(color: Colors.white, width: 3.w),
                                          // show when false not delete not block
                                          onTap: (isMe
                                                  ? (isToUserORProfileDelete || isToUserORProfileBlock)
                                                  : (isFromUserORProfileDelete || isFromUserORProfileBlock))
                                              ? () {
                                                  if (kDebugMode) {
                                                    print('Hello call screen my user onTap null');
                                                  }
                                                }
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
                                                    location: isMe
                                                        ? finalItems[index]['ToProfile']['Location']
                                                        : finalItems[index]['FromProfile']['Location'],
                                                    description: isMe
                                                        ? finalItems[index]['ToProfile']['Description']
                                                        : finalItems[index]['FromProfile']['Description'],
                                                    languageList: isMe
                                                        ? finalItems[index]['ToProfile']['Language']
                                                        : finalItems[index]['FromProfile']['Language'],
                                                  );
                                                },
                                        ),
                                        // my user Delete or Block show when true
                                        if (isMe
                                            ? (isToUserORProfileDelete || isToUserORProfileBlock)
                                            : (isFromUserORProfileDelete || isFromUserORProfileBlock))
                                          Container(
                                            key: UniqueKey(),
                                            height: 55.w,
                                            width: 55.w,
                                            padding: EdgeInsets.all(16.w),
                                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.66), shape: BoxShape.circle),
                                            child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    // show when opposite user not delete / block / block by me
                                    if (!(isMe
                                        ? (isFromUserORProfileDelete || isFromUserORProfileBlock || blockByMe)
                                        : (isToUserORProfileDelete || isToUserORProfileBlock || blockByMe))) ...[
                                      // type = Call / VideoCall icon, [CallDuration] and [MissedCall]
                                      /// outgoing (green up arrow)
                                      /// incoming (green down arrow)
                                      /// miss receive (black)
                                      /// bust not respond (red)
                                      if (widget.showNumber) ...[
                                        // if (finalItems[index]['call'] == null) ...[
                                        //   FutureBuilder<ApiResponse?>(
                                        //     future: UserCallProviderApi().getCallByPointer(finalItems[index]['objectId'], widget.type == 'Call'),
                                        //     builder: (context, snapshot) {
                                        //       if (snapshot.data == null || finalItems[index]['busy'] == true) {
                                        //         return CallButton(
                                        //           key: UniqueKey(),
                                        //           color: ConstColors.maroonColor,
                                        //           svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                        //         );
                                        //       } else {
                                        //         if (snapshot.data!.result['Accepted'] == true && snapshot.data!.result['IsCallEnd'] == true) {
                                        //           final bool isOutGoing =
                                        //               finalItems[index]['FromUser']['objectId'].toString().contains(StorageService.getBox.read('ObjectId'));
                                        //           return Column(
                                        //             key: UniqueKey(),
                                        //             children: [
                                        //               CallButton(
                                        //                 color: ConstColors.darkGreenColor,
                                        //                 svg: isOutGoing
                                        //                     ? widget.type == 'Call'
                                        //                         ? "assets/Icons/outGoAudioCall.svg"
                                        //                         : "assets/Icons/outGoVideoCall.svg"
                                        //                     : widget.type == 'Call'
                                        //                         ? "assets/Icons/inAudioCall.svg"
                                        //                         : "assets/Icons/inVideoCall.svg",
                                        //               ),
                                        //               SizedBox(height: 5.h),
                                        //               Styles.regular(removeLeadingZeros(snapshot.data!.result['CallDuration']),
                                        //                   fs: 15.sp, lns: 1, ff: "HB", c: ConstColors.white),
                                        //             ],
                                        //           );
                                        //         } else {
                                        //           return CallButton(
                                        //             key: UniqueKey(),
                                        //             color: ConstColors.black,
                                        //             svg: widget.type == 'Call' ? "assets/Icons/missAudioCall.svg" : "assets/Icons/missVideoCall.svg",
                                        //           );
                                        //         }
                                        //       }
                                        //     },
                                        //   ),
                                        // ] else ...[
                                        //   if(finalItems[index]['busy'] == true)...[
                                        //     CallButton(
                                        //       key: UniqueKey(),
                                        //       color: ConstColors.maroonColor,
                                        //       svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                        //     )
                                        //   ]
                                        //  else if (finalItems[index]['call']['Accepted'] == true && finalItems[index]['call']['IsCallEnd'] == true)
                                        //     Builder(builder: (context) {
                                        //       final bool isOutGoing = finalItems[index]['FromProfile']['objectId']
                                        //           .toString()
                                        //           .contains(StorageService.getBox.read('DefaultProfile'));
                                        //       return Column(
                                        //         key: UniqueKey(),
                                        //         children: [
                                        //           CallButton(
                                        //             color: ConstColors.darkGreenColor,
                                        //             svg: isOutGoing
                                        //                 ? widget.type == 'Call'
                                        //                     ? "assets/Icons/outGoAudioCall.svg"
                                        //                     : "assets/Icons/outGoVideoCall.svg"
                                        //                 : widget.type == 'Call'
                                        //                     ? "assets/Icons/inAudioCall.svg"
                                        //                     : "assets/Icons/inVideoCall.svg",
                                        //           ),
                                        //           SizedBox(height: 5.h),
                                        //           Styles.regular(removeLeadingZeros(finalItems[index]['call']['CallDuration']),
                                        //               fs: 15.sp, lns: 1, ff: "HB", c: ConstColors.white),
                                        //         ],
                                        //       );
                                        //     })
                                        //   else if(!(finalItems[index]['call']['Accepted'] == true && finalItems[index]['call']['IsCallEnd'] == true))
                                        //     CallButton(
                                        //       key: UniqueKey(),
                                        //       color: ConstColors.black,
                                        //       svg: widget.type == 'Call' ? "assets/Icons/missAudioCall.svg" : "assets/Icons/missVideoCall.svg",
                                        //     )
                                        //   else CallButton(
                                        //         key: UniqueKey(),
                                        //         color: ConstColors.maroonColor,
                                        //         svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                        //       )
                                        // ],

                                        /// filter wise
                                        if (filters.value == 'filter1') ...[
                                          Column(
                                            key: UniqueKey(),
                                            children: [
                                              CallButton(
                                                color: ConstColors.darkGreenColor,
                                                svg: widget.type == 'Call' ? "assets/Icons/outGoAudioCall.svg" : "assets/Icons/outGoVideoCall.svg",
                                              ),
                                              SizedBox(height: 5.h),
                                              Styles.regular(removeLeadingZeros(finalItems[index]['call']['CallDuration']),
                                                  fs: 15.sp, lns: 1, ff: "HB", c: ConstColors.white),
                                            ],
                                          ),
                                        ] else if (filters.value == 'filter2') ...[
                                          Column(
                                            key: UniqueKey(),
                                            children: [
                                              CallButton(
                                                color: ConstColors.darkGreenColor,
                                                svg: widget.type == 'Call' ? "assets/Icons/inAudioCall.svg" : "assets/Icons/inVideoCall.svg",
                                              ),
                                              SizedBox(height: 5.h),
                                              Styles.regular(removeLeadingZeros(finalItems[index]['call']['CallDuration']),
                                                  fs: 15.sp, lns: 1, ff: "HB", c: ConstColors.white),
                                            ],
                                          ),
                                        ] else if (filters.value == 'filter3') ...[
                                          CallButton(
                                            key: UniqueKey(),
                                            color: ConstColors.black,
                                            svg: widget.type == 'Call' ? "assets/Icons/missAudioCall.svg" : "assets/Icons/missVideoCall.svg",
                                          ),
                                        ] else if (filters.value == 'filter4') ...[
                                          CallButton(
                                            key: UniqueKey(),
                                            color: ConstColors.maroonColor,
                                            svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                          ),
                                        ] else ...[
                                          if (finalItems[index]['call'] == null) ...[
                                            FutureBuilder<ApiResponse?>(
                                              future: UserCallProviderApi().getCallByPointer(finalItems[index]['objectId'], widget.type == 'Call'),
                                              builder: (context, snapshot) {
                                                if (snapshot.data != null && snapshot.connectionState == ConnectionState.done) {
                                                  if (snapshot.data!.result['Accepted'] == true && snapshot.data!.result['IsCallEnd'] == true) {
                                                    final bool isOutGoing = snapshot.data!.result['FromProfile']['objectId']
                                                        .toString()
                                                        .contains(StorageService.getBox.read('DefaultProfile'));
                                                    print('------ Hello Filter1 & Filter2 ------ $isOutGoing');
                                                    return Column(
                                                      key: UniqueKey(),
                                                      children: [
                                                        CallButton(
                                                          color: ConstColors.darkGreenColor,
                                                          svg: isOutGoing
                                                              ? widget.type == 'Call'
                                                                  ? "assets/Icons/outGoAudioCall.svg"
                                                                  : "assets/Icons/outGoVideoCall.svg"
                                                              : widget.type == 'Call'
                                                                  ? "assets/Icons/inAudioCall.svg"
                                                                  : "assets/Icons/inVideoCall.svg",
                                                        ),
                                                        SizedBox(height: 5.h),
                                                        Styles.regular(
                                                          removeLeadingZeros(snapshot.data!.result['CallDuration']),
                                                          fs: 15.sp,
                                                          lns: 1,
                                                          ff: "HB",
                                                          c: ConstColors.white,
                                                        ),
                                                      ],
                                                    );
                                                  } else if (snapshot.data!.result['Accepted'] == false &&
                                                      snapshot.data!.result['IsCallEnd'] == true) {
                                                    print('------ Hello Filter3 Missed ------ ');
                                                    return CallButton(
                                                      key: UniqueKey(),
                                                      color: ConstColors.black,
                                                      svg:
                                                          widget.type == 'Call' ? "assets/Icons/missAudioCall.svg" : "assets/Icons/missVideoCall.svg",
                                                    );
                                                  } else if (finalItems[index]['busy'] == true) {
                                                    print('------ Hello Filter4 Busy ------');
                                                    return CallButton(
                                                      key: UniqueKey(),
                                                      color: ConstColors.maroonColor,
                                                      svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                                    );
                                                  } else {
                                                    print('------ Hello Filter Else ------');
                                                    return CallButton(
                                                      key: UniqueKey(),
                                                      color: ConstColors.maroonColor,
                                                      svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                                    );
                                                  }
                                                }
                                                return CallButton(
                                                  key: UniqueKey(),
                                                  color: ConstColors.maroonColor,
                                                  svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                                );
                                                //Container(height: 25.w, width: 25.w, color: Colors.yellow);
                                              },
                                            )
                                          ] else ...[
                                            if (finalItems[index]['call']['Accepted'] == true && finalItems[index]['call']['IsCallEnd'] == true) ...[
                                              Builder(builder: (context) {
                                                final bool isOutGoing = finalItems[index]['FromProfile']['objectId']
                                                    .toString()
                                                    .contains(StorageService.getBox.read('DefaultProfile'));
                                                print('****** Hello Filter1 & Filter2 ****** $isOutGoing');
                                                return Column(
                                                  key: UniqueKey(),
                                                  children: [
                                                    CallButton(
                                                      color: ConstColors.darkGreenColor,
                                                      svg: isOutGoing
                                                          ? widget.type == 'Call'
                                                              ? "assets/Icons/outGoAudioCall.svg"
                                                              : "assets/Icons/outGoVideoCall.svg"
                                                          : widget.type == 'Call'
                                                              ? "assets/Icons/inAudioCall.svg"
                                                              : "assets/Icons/inVideoCall.svg",
                                                    ),
                                                    SizedBox(height: 5.h),
                                                    Styles.regular(removeLeadingZeros(finalItems[index]['call']['CallDuration']),
                                                        fs: 15.sp, lns: 1, ff: "HB", c: ConstColors.white),
                                                  ],
                                                );
                                              })
                                            ] else if (finalItems[index]['call']['Accepted'] == false &&
                                                finalItems[index]['call']['IsCallEnd'] == true)
                                              CallButton(
                                                key: UniqueKey(),
                                                color: ConstColors.black,
                                                svg: widget.type == 'Call' ? "assets/Icons/missAudioCall.svg" : "assets/Icons/missVideoCall.svg",
                                              )
                                            else if (finalItems[index]['busy'] == true)
                                              CallButton(
                                                key: UniqueKey(),
                                                color: ConstColors.maroonColor,
                                                svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                              )
                                            else ...[
                                              CallButton(
                                                key: UniqueKey(),
                                                color: ConstColors.maroonColor,
                                                svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                              )
                                            ]
                                          ]
                                        ],
                                      ],

                                      /// my code

                                      //   if (finalItems[index]['call'] == null) ...[
                                      //     FutureBuilder<ApiResponse?>(
                                      //       future: UserCallProviderApi().getCallByPointer(finalItems[index]['objectId'], widget.type == 'Call'),
                                      //       builder: (context, snapshot) {
                                      //         if (snapshot.data != null && snapshot.connectionState == ConnectionState.done) {
                                      //           if (filters.value == 'filter1' || filters.value == 'filter2') {
                                      //             if (snapshot.data!.result['Accepted'] == true && snapshot.data!.result['IsCallEnd'] == true) {
                                      //               final bool isOutGoing = finalItems[index]['FromUser']['objectId']
                                      //                   .toString()
                                      //                   .contains(StorageService.getBox.read('ObjectId'));
                                      //               print('------ Hello Filter1 & Filter2 ------ $isOutGoing');
                                      //               return Column(
                                      //                 key: UniqueKey(),
                                      //                 children: [
                                      //                   CallButton(
                                      //                     color: ConstColors.darkGreenColor,
                                      //                     svg: isOutGoing
                                      //                         ? widget.type == 'Call'
                                      //                             ? "assets/Icons/outGoAudioCall.svg"
                                      //                             : "assets/Icons/outGoVideoCall.svg"
                                      //                         : widget.type == 'Call'
                                      //                             ? "assets/Icons/inAudioCall.svg"
                                      //                             : "assets/Icons/inVideoCall.svg",
                                      //                   ),
                                      //                   SizedBox(height: 5.h),
                                      //                   Styles.regular(
                                      //                     removeLeadingZeros(snapshot.data!.result['CallDuration']),
                                      //                     fs: 15.sp,
                                      //                     lns: 1,
                                      //                     ff: "HB",
                                      //                     c: ConstColors.white,
                                      //                   ),
                                      //                 ],
                                      //               );
                                      //             }
                                      //           } else if (filters.value == 'filter3' &&
                                      //               !(snapshot.data!.result['Accepted'] == true && snapshot.data!.result['IsCallEnd'] == true)) {
                                      //             print('------ Hello Filter3 Missed AAA ------ $index');
                                      //             return CallButton(
                                      //               key: UniqueKey(),
                                      //               color: ConstColors.black,
                                      //               svg: widget.type == 'Call' ? "assets/Icons/missAudioCall.svg" : "assets/Icons/missVideoCall.svg",
                                      //             );
                                      //           } else if (filters.value == 'filter4' && finalItems[index]['busy'] == true) {
                                      //             print('------ Hello Filter4 Busy ------');
                                      //             return CallButton(
                                      //               key: UniqueKey(),
                                      //               color: ConstColors.maroonColor,
                                      //               svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                      //             );
                                      //           } else {
                                      //             print('------ Hello All Data with API ------ ${filters.value}');
                                      //
                                      //             /// Handle All Data
                                      //             if (finalItems[index]['busy'] == true) {
                                      //               print('------ Hello Filter4 Busy All Data ------');
                                      //               return CallButton(
                                      //                 key: UniqueKey(),
                                      //                 color: ConstColors.maroonColor,
                                      //                 svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                      //               );
                                      //             } else {
                                      //               if (snapshot.data!.result['Accepted'] == true && snapshot.data!.result['IsCallEnd'] == true) {
                                      //                 final bool isOutGoing = finalItems[index]['FromUser']['objectId']
                                      //                     .toString()
                                      //                     .contains(StorageService.getBox.read('ObjectId'));
                                      //                 print('------ Hello Filter1 & Filter2 All Data ------ $isOutGoing');
                                      //                 return Column(
                                      //                   key: UniqueKey(),
                                      //                   children: [
                                      //                     CallButton(
                                      //                       color: ConstColors.darkGreenColor,
                                      //                       svg: isOutGoing
                                      //                           ? widget.type == 'Call'
                                      //                               ? "assets/Icons/outGoAudioCall.svg"
                                      //                               : "assets/Icons/outGoVideoCall.svg"
                                      //                           : widget.type == 'Call'
                                      //                               ? "assets/Icons/inAudioCall.svg"
                                      //                               : "assets/Icons/inVideoCall.svg",
                                      //                     ),
                                      //                     SizedBox(height: 5.h),
                                      //                     Styles.regular(
                                      //                       removeLeadingZeros(snapshot.data!.result['CallDuration']),
                                      //                       fs: 15.sp,
                                      //                       lns: 1,
                                      //                       ff: "HB",
                                      //                       c: ConstColors.white,
                                      //                     ),
                                      //                   ],
                                      //                 );
                                      //               } else {
                                      //                 print('------ Hello Filter3 Missed ------');
                                      //                 return CallButton(
                                      //                   key: UniqueKey(),
                                      //                   color: ConstColors.black,
                                      //                   svg: widget.type == 'Call' ? "assets/Icons/missAudioCall.svg" : "assets/Icons/missVideoCall.svg",
                                      //                 );
                                      //               }
                                      //             }
                                      //           }
                                      //         }
                                      //         return Container(height: 25.w, width: 25.w, color: Colors.yellow);
                                      //       },
                                      //     )
                                      //   ] else ...[
                                      //     if (filters.value == 'filter1' || filters.value == 'filter2') ...[
                                      //       if (finalItems[index]['call']['Accepted'] == true && finalItems[index]['call']['IsCallEnd'] == true)
                                      //         Builder(builder: (context) {
                                      //           final bool isOutGoing = finalItems[index]['FromProfile']['objectId']
                                      //               .toString()
                                      //               .contains(StorageService.getBox.read('DefaultProfile'));
                                      //           print('****** Hello Filter1 & Filter2 ****** $isOutGoing');
                                      //           return Column(
                                      //             key: UniqueKey(),
                                      //             children: [
                                      //               CallButton(
                                      //                 color: ConstColors.darkGreenColor,
                                      //                 svg: isOutGoing
                                      //                     ? widget.type == 'Call'
                                      //                         ? "assets/Icons/outGoAudioCall.svg"
                                      //                         : "assets/Icons/outGoVideoCall.svg"
                                      //                     : widget.type == 'Call'
                                      //                         ? "assets/Icons/inAudioCall.svg"
                                      //                         : "assets/Icons/inVideoCall.svg",
                                      //               ),
                                      //               SizedBox(height: 5.h),
                                      //               Styles.regular(removeLeadingZeros(finalItems[index]['call']['CallDuration']),
                                      //                   fs: 15.sp, lns: 1, ff: "HB", c: ConstColors.white),
                                      //             ],
                                      //           );
                                      //         })
                                      //       else
                                      //         Builder(builder: (context) {
                                      //           print('****** Hello Filter1 & Filter2 ****** ${finalItems[index]['call']['Accepted'] == true && finalItems[index]['call']['IsCallEnd'] == true}');
                                      //           return Container(height: 25.w, width: 25.w, color: Colors.red);
                                      //         })
                                      //
                                      //
                                      //
                                      //      // else  Container(height: 25.w, width: 25.w, color: Colors.red)
                                      //     ] else if (filters.value == 'filter3' &&
                                      //         !(finalItems[index]['call']['Accepted'] == true && finalItems[index]['call']['IsCallEnd'] == true))
                                      //       CallButton(
                                      //         key: UniqueKey(),
                                      //         color: ConstColors.black,
                                      //         svg: widget.type == 'Call' ? "assets/Icons/missAudioCall.svg" : "assets/Icons/missVideoCall.svg",
                                      //       )
                                      //     else if (filters.value == 'filter4' && finalItems[index]['busy'] == true)
                                      //       CallButton(
                                      //         key: UniqueKey(),
                                      //         color: ConstColors.maroonColor,
                                      //         svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                      //       )
                                      //     else ...[
                                      //       if (finalItems[index]['busy'] == true) ...[
                                      //         CallButton(
                                      //           key: UniqueKey(),
                                      //           color: ConstColors.maroonColor,
                                      //           svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
                                      //         )
                                      //       ] else if (finalItems[index]['call']['Accepted'] == true && finalItems[index]['call']['IsCallEnd'] == true) ...[
                                      //         Builder(builder: (context) {
                                      //           final bool isOutGoing = finalItems[index]['FromProfile']['objectId']
                                      //               .toString()
                                      //               .contains(StorageService.getBox.read('DefaultProfile'));
                                      //           print('****** Hello Filter1 & Filter2 All Data ****** $isOutGoing');
                                      //           return Column(
                                      //             key: UniqueKey(),
                                      //             children: [
                                      //               CallButton(
                                      //                 color: ConstColors.darkGreenColor,
                                      //                 svg: isOutGoing
                                      //                     ? widget.type == 'Call'
                                      //                         ? "assets/Icons/outGoAudioCall.svg"
                                      //                         : "assets/Icons/outGoVideoCall.svg"
                                      //                     : widget.type == 'Call'
                                      //                         ? "assets/Icons/inAudioCall.svg"
                                      //                         : "assets/Icons/inVideoCall.svg",
                                      //               ),
                                      //               SizedBox(height: 5.h),
                                      //               Styles.regular(removeLeadingZeros(finalItems[index]['call']['CallDuration']),
                                      //                   fs: 15.sp, lns: 1, ff: "HB", c: ConstColors.white),
                                      //             ],
                                      //           );
                                      //         })
                                      //       ] else
                                      //         CallButton(
                                      //           key: UniqueKey(),
                                      //           color: ConstColors.black,
                                      //           svg: widget.type == 'Call' ? "assets/Icons/missAudioCall.svg" : "assets/Icons/missVideoCall.svg",
                                      //         )
                                      //     ]
                                      //   ]
                                      // ],
                                      // widget.futureTitle == Wishes show svg
                                      if (widget.type == 'Wishes' && finalItems[index]['Wishes']['Lottie_File'] != null)
                                        Container(
                                          key: UniqueKey(),
                                          height: 55.w,
                                          width: 55.w,
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(9.w),
                                          decoration: BoxDecoration(
                                              color: ConstColors.darkBlueColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 3.w)),
                                          child: SvgView(finalItems[index]['Wishes']['Lottie_File'].url,
                                              height: 40.w, width: 40.w, fit: BoxFit.scaleDown, network: true, color: Colors.white),
                                        ),
                                    ],
                                  ],
                                )),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
            Obx(() {
              if (isDeleteLoading.value) {
                return Container(
                  color: ConstColors.black.withOpacity(0.5),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadInter() async {
    if (_priceController.userTotalCoin.value >= historyStars) {
      bool cancel = false;
      isDownloading.value = true;
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
              if (widget.showNumber) {
                // widget.futureTitle == 'Call'
                // widget.futureTitle == 'VideoCall'
              } else if (widget.type == 'HeartLike') {
                row.add('i_like_you'.tr);
              } else if (widget.type == 'Visit') {
                row.add('I_have_been_visited'.tr);
              } else if (widget.type == 'WinkMessage') {
                // check if my user ifs male and i'm not purchase wink
                if (ele['FromUser']["Gender"] == "female" && StorageService.getBox.read('Gender') == 'male' && !ele['IsPurchased']) {
                  row.add('I_have_been_winked'.tr);
                } else {
                  row.add(ele['Message']);
                }
              } else if (widget.type == 'LipLike') {
                row.add('I_have_been_kissed'.tr);
              } else if (widget.type == 'Wishes') {
                row.add('Received'.tr);
              } else if (widget.type == 'BlocUser') {
              } else {
                rows.clear();
                row.clear();
              }
            } else {
              // when i have send
              row.add(ele['FromProfile']['Name'].toString().capitalizeFirst.toString());
              row.add(ele['ToProfile']['Name'].toString().capitalizeFirst.toString());
              if (widget.showNumber) {
                // widget.futureTitle == 'Call'
                // widget.futureTitle == 'VideoCall'
              } else if (widget.type == 'HeartLike') {
                row.add('I_like'.tr);
              } else if (widget.type == 'Visit') {
                row.add('I_have_visited'.tr);
              } else if (widget.type == 'WinkMessage') {
                row.add(ele['Message']);
              } else if (widget.type == 'LipLike') {
                row.add('I_have_kissed'.tr);
              } else if (widget.type == 'Wishes') {
                row.add('Sent'.tr);
              } else if (widget.type == 'BlocUser') {
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
              csvFile.delete();
              zipFile.delete();
              if (kDebugMode) {
                print('Hello download cancel');
              }
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

class CallButton extends StatelessWidget {
  const CallButton({Key? key, required this.svg, required this.color}) : super(key: key);
  final String svg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.w,
      width: 55.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3.w)),
      child: SvgView(svg, height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
    );
  }
}

String removeLeadingZeros(String input) {
  if (input.startsWith('00')) {
    return input.replaceFirst('00:', '');
  }
  return input;
}

// if (finalItems[index]['call'] == null) ...[
// FutureBuilder<ApiResponse?>(
// future: UserCallProviderApi().getCallByPointer(finalItems[index]['objectId'], widget.type == 'Call'),
// builder: (context, snapshot) {
// if (snapshot.data == null || finalItems[index]['busy'] == true) {
// return CallButton(
// key: UniqueKey(),
// color: ConstColors.black,
// svg: widget.type == 'Call' ? "assets/Icons/missAudioCall.svg" : "assets/Icons/missVideoCall.svg",
// );
// } else {
// if (snapshot.data!.result['Accepted'] == true && snapshot.data!.result['IsCallEnd'] == true) {
// final bool isOutGoing =
// finalItems[index]['FromUser']['objectId'].toString().contains(StorageService.getBox.read('ObjectId'));
// return Column(
// key: UniqueKey(),
// children: [
// CallButton(
// color: ConstColors.darkGreenColor,
// svg: isOutGoing
// ? widget.type == 'Call'
// ? "assets/Icons/outGoAudioCall.svg"
//     : "assets/Icons/outGoVideoCall.svg"
//     : widget.type == 'Call'
// ? "assets/Icons/inAudioCall.svg"
//     : "assets/Icons/inVideoCall.svg",
// ),
// SizedBox(height: 5.h),
// Styles.regular(removeLeadingZeros(snapshot.data!.result['CallDuration']),
// fs: 15.sp, lns: 1, ff: "HB", c: ConstColors.white),
// ],
// );
// } else {
// return CallButton(
// key: UniqueKey(),
// color: ConstColors.maroonColor,
// svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
// );
// }
// }
// },
// ),
// ] else ...[
// if (finalItems[index]['call']['Accepted'] == true && finalItems[index]['call']['IsCallEnd'] == true)
// Builder(builder: (context) {
// final bool isOutGoing = finalItems[index]['FromProfile']['objectId']
//     .toString()
//     .contains(StorageService.getBox.read('DefaultProfile'));
// return Column(
// key: UniqueKey(),
// children: [
// CallButton(
// color: ConstColors.darkGreenColor,
// svg: isOutGoing
// ? widget.type == 'Call'
// ? "assets/Icons/outGoAudioCall.svg"
//     : "assets/Icons/outGoVideoCall.svg"
//     : widget.type == 'Call'
// ? "assets/Icons/inAudioCall.svg"
//     : "assets/Icons/inVideoCall.svg",
// ),
// SizedBox(height: 5.h),
// Styles.regular(removeLeadingZeros(finalItems[index]['call']['CallDuration']),
// fs: 15.sp, lns: 1, ff: "HB", c: ConstColors.white),
// ],
// );
// })
// else if (finalItems[index]['busy'] == true) ...[
// CallButton(
// key: UniqueKey(),
// color: ConstColors.black,
// svg: widget.type == 'Call' ? "assets/Icons/missAudioCall.svg" : "assets/Icons/missVideoCall.svg",
// )
// ] else
// CallButton(
// key: UniqueKey(),
// color: ConstColors.maroonColor,
// svg: widget.type == 'Call' ? "assets/Icons/endAudioCall.svg" : "assets/Icons/endVideoCall.svg",
// )
// ]
