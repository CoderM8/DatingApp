// ignore_for_file: must_be_immutable
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/post_view.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/PairNotificationController/pair_notification_controller.dart';
import 'package:eypop/Controllers/search_controller.dart';

import 'package:eypop/models/user_login/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';

class MyProfileMessageScreen extends StatelessWidget {
  MyProfileMessageScreen({Key? key, required this.onTap, required this.tableName}) : super(key: key);
  final String tableName;
  final Function(String, ProfilePage) onTap;

  final AppSearchController _searchController = Get.put(AppSearchController());

  final PairNotificationController _pairNotificationController = Get.put(PairNotificationController());

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80.h),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 20.h, top: 20.h, right: 20.w, bottom: 30.h),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(40.r), bottomLeft: Radius.circular(40.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                itemCount: _searchController.profileData.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final RxInt totalMsgCount = 0.obs;
                    if (tableName == 'Chat_Message') {
                      // _pairNotificationController.chatCount(_searchController.profileData[index].objectId!).then((value) {
                      //   if (value != null) {
                      //     totalMsgCount.value = value.results!.length;
                      //   } else {
                      //     totalMsgCount.value = 0;
                      //   }
                      // });
                      List messageCountCheckPairList = [];
                      Future.delayed(
                        Duration.zero,
                        () async {
                          await PairNotificationProviderApi()
                              .messageCountCheckPair(_searchController.profileData[index].objectId!, 'ChatMessage')
                              .then((value) {
                            if (value != null) {
                              messageCountCheckPairList.addAll(value.results!);
                              _pairNotificationController.chatCount(_searchController.profileData[index].objectId!).then((value) async {
                                if (value != null) {
                                  RxList totalCountList = [].obs;
                                  for (var element in value.results!) {
                                    if (messageCountCheckPairList
                                            .any((element1) => element1['FromProfile']['objectId'] == element['FromProfile']['objectId']) &&
                                        messageCountCheckPairList
                                            .any((element1) => element1['ToProfile']['objectId'] == element['ToProfile']['objectId']) &&
                                        (element['FromProfile']['isDeleted'] ?? false) == false &&
                                        (element['FromProfile']['IsBlocked'] ?? false) == false &&
                                        (element['FromUser']['isDeleted'] ?? false) == false &&
                                        (element['FromUser']['IsBlocked'] ?? false) == false &&
                                        !(_pairNotificationController.meBlocked.toString().contains(element['FromProfile']['objectId']) &&
                                            _pairNotificationController.meBlocked.toString().contains(element['ToProfile']['objectId'])) &&
                                        !totalCountList.any((e) => e['FromProfile']['objectId'] == element['FromProfile']['objectId'])) {
                                      totalCountList.add(element);
                                    }
                                  }
                                  // }

                                  totalMsgCount.value = totalCountList.length;
                                } else {
                                  totalMsgCount.value = 0;
                                }
                              });
                            }
                          });
                        },
                      );
                    } else {
                      // _pairNotificationController.getFilteredcount('HeartMessage',_searchController.profileData[index].objectId!).then((value) {
                      //   if (value != null) {
                      //     RxList totalCountList = [].obs;
                      //     for (var element in value.results!) {
                      //       if (element['Like_Message']['isRead'] == false && !(_pairNotificationController.meBlocked.toString().contains(element['FromProfile']['objectId']) &&
                      //           _pairNotificationController.meBlocked.toString().contains(element['ToProfile']['objectId']))) {
                      //       // print('FromProfile ::: ${element['FromProfile']}');
                      //         totalCountList.add(element);
                      //       }else{
                      //
                      //       }
                      List messageCountCheckPairList = [];
                      Future.delayed(
                        Duration.zero,
                        () async {
                          await PairNotificationProviderApi()
                              .messageCountCheckPair(_searchController.profileData[index].objectId!, 'HeartMessage')
                              .then((value) {
                            if (value != null) {
                              messageCountCheckPairList.addAll(value.results!);
                              _pairNotificationController.messageCount(_searchController.profileData[index].objectId!).then((value) async {
                                if (value != null) {
                                  RxList totalCountList = [].obs;
                                  for (var element in value.results!) {
                                    if (messageCountCheckPairList
                                            .any((element1) => element1['FromProfile']['objectId'] == element['FromProfile']['objectId']) &&
                                        messageCountCheckPairList
                                            .any((element1) => element1['ToProfile']['objectId'] == element['ToProfile']['objectId']) &&
                                        (element['FromProfile']['isDeleted'] ?? false) == false &&
                                        (element['FromProfile']['IsBlocked'] ?? false) == false &&
                                        (element['FromUser']['isDeleted'] ?? false) == false &&
                                        (element['FromUser']['IsBlocked'] ?? false) == false &&
                                        !(_pairNotificationController.meBlocked.toString().contains(element['FromProfile']['objectId']) &&
                                            _pairNotificationController.meBlocked.toString().contains(element['ToProfile']['objectId'])) &&
                                        !totalCountList.any((e) => e['FromProfile']['objectId'] == element['FromProfile']['objectId'])) {
                                      totalCountList.add(element);
                                    }
                                  }
                                  // }

                                  totalMsgCount.value = totalCountList.length;
                                } else {
                                  totalMsgCount.value = 0;
                                }
                              });
                            }
                          });
                        },
                      );
                    }

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onTap('profileWise', _searchController.profileData[index]);
                        // Get.to(() => FilterMessageScreen(
                        //         noTitle: noTitle,
                        //         profileId: _searchController.profileData[index].objectId.toString(),
                        //         svg: svg,
                        //         localTitle: localTitle,
                        //         title: title,
                        //         futureTitle: futureTitle,
                        //         tableName: tableName))!
                        //     .then((value) {
                        //   singleRefCounter.value = !singleRefCounter.value;
                        // });
                      },
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ImageView(
                                _searchController.profileData[index].imgProfile.url.toString(),
                                height: 64.w,
                                width: 64.w,
                                circle: true,
                                alignment: Alignment.topCenter,
                                border: Border.all(color: ConstColors.themeColor, width: 3.w),
                              ),
                              if (_searchController.profileData[index].isDeleted == true ||
                                  (_searchController.profileData[index]['IsBlocked'] ?? false) == true)
                                Container(
                                  height: 64.w,
                                  width: 64.w,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.66), shape: BoxShape.circle),
                                  child: SvgView("assets/Icons/ProfileDelete.svg", height: 40.w, width: 40.w, fit: BoxFit.scaleDown),
                                ),
                            ],
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Styles.regular(_searchController.profileData[index].name, fs: 16.sp),
                                Styles.regular(_searchController.profileData[index].locationName, fs: 16.sp, ff: "HL")
                              ],
                            ),
                          ),
                          Obx(() {
                            if (totalMsgCount.value != 0) {
                              return Container(
                                height: 36.w,
                                width: 56.w,
                                decoration:
                                    BoxDecoration(color: ConstColors.maroonColor, borderRadius: BorderRadius.all(Radius.elliptical(56.w, 36.h))),
                                child: Center(child: Styles.regular('${totalMsgCount.value}', c: ConstColors.white, fs: 14.sp)),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          })
                        ],
                      ),
                    );
                  });
                },
              ),
              SizedBox(height: 28.h),
              GradientButton(
                title: 'Show_all_my_profiles'.tr,
                onTap: () {
                  Get.back();
                  onTap('all', ProfilePage());
                },
              ),
              SizedBox(height: 28.h),
            ],
          ),
        ),
      ),
    );
  }
}
