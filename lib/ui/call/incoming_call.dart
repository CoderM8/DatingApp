// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/call_controller/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../back4appservice/user_provider/users/provider_user_api.dart';
import '../../models/user_login/user_login.dart';
import '../../service/local_storage.dart';
import 'call_page.dart';

class Incoming extends StatefulWidget {
  final ParseObject callInfo;
  final bool visitType;
  final String callId;
  final String name;
  final String name2;
  final String location;
  final String location2;
  final String toImg;
  final String fromImg;
  final String toGender;

  const Incoming(
      {Key? key,
      required this.callInfo,
      required this.callId,
      required this.name,
      required this.name2,
      required this.location,
      required this.location2,
      this.visitType = false,
      required this.fromImg,
      required this.toGender,
      required this.toImg})
      : super(key: key);

  @override
  State<Incoming> createState() => _IncomingState();
}

class _IncomingState extends State<Incoming> with TickerProviderStateMixin {
  bool isPickup = false;
  final CallController callController = Get.put(CallController());
  AudioPlayer? playerEndCall;

  @override
  void initState() {
    callController.selfCut.value = false;
    playerEndCall = AudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    if (playerEndCall != null) {
      playerEndCall!.dispose();
      playerEndCall = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Obx(() {
              parseCall.value;
              if (parseCall.value.objectId != null) {
                if (parseCall.value['ChannelName']!.contains(StorageService.getBox.read('ObjectId'))) {
                  if (parseCall.value['IsCallEnd'] != null) {
                    if (parseCall.value['IsCallEnd'] == true && parseCall.value['Accepted'] == false) {
                      final UserLogin userLogin = UserLogin();
                      userLogin.objectId = parseCall.value['ToUser']['objectId'];
                      userLogin.local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
                      UserLoginProviderApi().update(userLogin);

                      isPickup = false;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (widget.visitType == true) {
                          exit(0);
                        } else {
                          Get.back();
                        }
                      });
                    }

                    if (parseCall.value['IsCallEnd'] == true && parseCall.value['Accepted'] == true) {
                      final UserLogin userLogin = UserLogin();
                      userLogin.objectId = parseCall.value['ToUser']['objectId'];
                      userLogin.local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
                      UserLoginProviderApi().update(userLogin);

                      isPickup = false;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (widget.visitType == true) {
                          exit(0);
                        } else {
                          Get.back();
                        }
                      });
                    }
                  }

                  if (parseCall.value['Accepted'] == false && parseCall.value['IsCallEnd'] == false) {
                    return Center(
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.fromImg,
                            useOldImageOnUrlChange: true,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [const Icon(Icons.error, color: Colors.black, size: 30), Styles.regular("Unable to load", c: Colors.black)],
                            ),
                          ),
                          GradientWidget(
                            colors: [ConstColors.black.withOpacity(0.5), ConstColors.black.withOpacity(0.5), const Color(0xFF072DFF).withOpacity(0.7)],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 120.w,
                                  width: 120.w,
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2.5, color: ConstColors.themeColor)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(60.w),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.fromImg,
                                      useOldImageOnUrlChange: true,
                                      height: 45.w,
                                      width: 45.w,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [const Icon(Icons.error, color: Colors.black, size: 30), Styles.regular("Unable to load", c: Colors.black)],
                                      ), //   fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Styles.regular(widget.name, c: Colors.white),
                                SizedBox(height: 8.h),
                                Styles.regular(widget.location, c: Colors.white),
                                SizedBox(height: 5.h),
                                RotatedBox(quarterTurns: 0, child: Lottie.asset("assets/flecha.json", height: 160.w, width: 160.w)),
                                SizedBox(height: 15.h),
                                Container(
                                  height: 120.w,
                                  width: 120.w,
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2.5, color: ConstColors.themeColor)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(60.w),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.toImg,
                                      useOldImageOnUrlChange: true,
                                      height: 45.w,
                                      width: 45.w,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [const Icon(Icons.error, color: Colors.black, size: 30), Styles.regular("Unable to load", c: Colors.black)],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Styles.regular(widget.name2, c: Colors.white),
                                SizedBox(height: 8.h),
                                Styles.regular(widget.location2, c: Colors.white),
                                SizedBox(height: 30.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                        onTap: () async {
                                          await callController.permissionMic();
                                          isPickup = true;
                                          final DateTime dateTime = await currentTime();
                                          final ParseObject callObject = ParseObject('Calls')
                                            ..objectId = widget.callInfo['objectId']
                                            ..set('startTime', dateTime)
                                            ..set('Accepted', isPickup)
                                            ..set('Log', {
                                              "CallId": widget.callInfo['objectId'],
                                              "Event": 'Manually Accept by user',
                                              "Users": "senderId: ${widget.callInfo['FromUser']['objectId']} UserId: ${widget.callInfo['ToUser']['objectId']}",
                                              "State": "Incoming/acceptButton/click/241",
                                            });
                                          await callObject.save();
                                        },
                                        child: Lottie.asset("assets/phone.json", height: 120.w, width: 120.w)),
                                    GestureDetector(
                                      onTap: () async {
                                        isPickup = false;
                                        await playerEndCall!.play(AssetSource('audio/call_end.mp3'),volume: 1);
                                        final DateTime dateTime = await currentTime();
                                        final ParseObject callObject = ParseObject('Calls')
                                          ..objectId = widget.callInfo['objectId']
                                          ..set('endTime', dateTime)
                                          ..set('startTime', dateTime)
                                          ..set('IsCallEnd', true)
                                          ..set('Log', {
                                            "CallId": widget.callInfo['objectId'],
                                            "Event": 'EndCall',
                                            "Users": "senderId: ${widget.callInfo['FromUser']['objectId']} UserId: ${widget.callInfo['ToUser']['objectId']}",
                                            "State": "IncomingCall/user cut after dial/260",
                                          });
                                        await callObject.save();
                                        if (playerEndCall != null) {
                                          playerEndCall!.dispose();
                                          playerEndCall = null;
                                        }
                                      },
                                      child: Container(
                                        height: 72.w,
                                        width: 72.w,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                        child: Icon(Icons.call, color: Colors.white, size: 42.w),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 15.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (parseCall.value['Accepted'] == true && parseCall.value['IsCallEnd'] == false) {
                    return CallPage(
                      uid: 2,
                      callId: widget.callInfo['objectId'],
                      name: widget.name,
                      name2: widget.name2,
                      img: widget.fromImg,
                      img2: widget.toImg,
                      location: widget.location,
                      location2: widget.location2,
                      toUserGender: widget.toGender,
                      toUserId: parseCall.value['FromUser']['objectId'],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                } else {
                  return const SizedBox.shrink();
                }
              } else {
                return const SizedBox.shrink();
              }
            }),
          ),
        ));
  }
}
