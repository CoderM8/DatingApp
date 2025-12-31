// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/call_controller/agora_call_controller.dart';
import 'package:eypop/Controllers/call_controller/call_controller.dart';
import 'package:eypop/models/call/calls.dart';
import 'package:eypop/service/calling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../back4appservice/user_provider/users/provider_user_api.dart';
import '../../models/user_login/user_login.dart';
import '../../service/local_storage.dart';
import 'video_call_page.dart';

class IncomingVideoCall extends StatefulWidget {
  final ParseObject callInfo;
  final bool visitType;
  final String callId;
  final String name;
  final String toImg;
  final String fromImg;
  final String toGender;

  const IncomingVideoCall(
      {Key? key, required this.callInfo, required this.callId, required this.name, this.visitType = false, required this.fromImg, required this.toGender, required this.toImg})
      : super(key: key);

  @override
  State<IncomingVideoCall> createState() => _IncomingVideoCallState();
}

class _IncomingVideoCallState extends State<IncomingVideoCall> with TickerProviderStateMixin {
  bool isPickUp = false;
  final CallController callController = Get.put(CallController());
  final AgoraVideoCallController ac = Get.put(AgoraVideoCallController());
  AudioPlayer? playerEndCall;

  @override
  void initState() {
    super.initState();
    // AGORA RTC INIT PASS [2] WHEN RECEIVED INCOMING CALL EVERY TIME
    ac.agoraInitialize(callId: widget.callId, uid: 2, isVoiceCall: false);
    playerEndCall = AudioPlayer();
    callController.selfCut.value = false;
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
        canPop: true,
        child: Scaffold(
          body: GradientWidget(
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

                      isPickUp = false;

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

                      isPickUp = false;
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
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          SizedBox(height: 72.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Obx(() {
                              onUserJoin.value;
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                child: (ac.rtcEngine != null && onUserJoin.value)
                                    ? InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: ac.onSwitchCamera,
                                        child: SizedBox(
                                          height: 183.h,
                                          width: 127.h,
                                          child: ClipRRect(
                                            key: const ValueKey(1),
                                            borderRadius: BorderRadius.circular(10.r),
                                            child: AgoraVideoView(controller: VideoViewController(rtcEngine: ac.rtcEngine!, canvas: const VideoCanvas(uid: 0))),
                                          ),
                                        ),
                                      )
                                    : ClipRRect(
                                        key: const ValueKey(2),
                                        borderRadius: BorderRadius.circular(10.r),
                                        child: CachedNetworkImage(
                                          imageUrl: widget.toImg,
                                          useOldImageOnUrlChange: true,
                                          height: 183.h,
                                          width: 127.h,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => ClipRRect(borderRadius: BorderRadius.circular(10.r), child: preCachedImage(UniqueKey())),
                                          errorWidget: (context, url, error) =>
                                              ClipRRect(borderRadius: BorderRadius.circular(10.r), child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover)),
                                        ),
                                      ),
                              );
                            }),
                          ),
                          SizedBox(height: 53.h),
                          ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: widget.fromImg,
                              useOldImageOnUrlChange: true,
                              height: 120.w,
                              width: 120.w,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => ClipOval(child: preCachedImage(UniqueKey())),
                              errorWidget: (context, url, error) => ClipOval(child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover)),
                            ),
                          ),
                          SizedBox(height: 11.h),
                          Styles.regular(widget.name, c: Theme.of(context).primaryColor, ff: "RR", fs: 18.sp),
                          SizedBox(height: 30.h),
                          Lottie.asset("assets/flecha.json", height: 160.w, width: 160.w),
                          SizedBox(height: 57.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // CALL ACCEPT
                              SvgView(
                                'assets/Icons/call_accept.svg',
                                height: 72.w,
                                width: 72.w,
                                fit: BoxFit.cover,
                                onTap: () async {
                                  await callController.permissionMic();
                                  await callController.permissionCamera();
                                  isPickUp = true;
                                  final DateTime dateTime = await currentTime();
                                  final ParseObject callObject = ParseObject('Calls')
                                    ..objectId = widget.callInfo['objectId']
                                    ..set('startTime', dateTime)
                                    ..set('Accepted', isPickUp)
                                    ..set('Log', {
                                      "CallId": widget.callInfo['objectId'],
                                      "Event": 'Manually Accept by user',
                                      "Type": '1/VideoCall',
                                      "Users": "senderId: ${widget.callInfo['FromUser']['objectId']} UserId: ${widget.callInfo['ToUser']['objectId']}",
                                      "State": "lib/ui/video_call/incoming_video_call.dart/acceptButton/click/241",
                                    });
                                  await callObject.save();
                                },
                              ),
                              // CALL END
                              SvgView(
                                'assets/Icons/call_end.svg',
                                height: 84.w,
                                width: 84.w,
                                fit: BoxFit.cover,
                                onTap: () async {
                                  await playerEndCall!.play(AssetSource('audio/call_end.mp3'), volume: 1);
                                  final DateTime dateTime = await currentTime();
                                  final CallModel callModel = CallModel()
                                    ..objectId = parseCall.value['objectId']
                                    ..set('startTime', dateTime)
                                    ..set('endTime', dateTime)
                                    ..set('IsCallEnd', true)
                                    ..set('Log', {
                                      "CallId": parseCall.value['objectId'],
                                      "Event": 'EndCall',
                                      "Type": '1/VideoCall',
                                      "Users": "senderId: ${parseCall.value['FromUser']['objectId']} UserId: ${parseCall.value['ToUser']['objectId']}",
                                      "State": "lib/ui/video_call/incoming_video_call.dart/cutCall/userCut/234",
                                    });
                                  await callModel.save();
                                  await ac.agoraLeave();
                                  CallService.makeCall(
                                    userId: parseCall.value['ToUser']['objectId'],
                                    type: "Cut",
                                    fromProfileId: parseCall.value['FromProfile']['objectId'],
                                    callId: parseCall.value['objectId'],
                                    isVoiceCall: false,
                                  );
                                  if (playerEndCall != null) {
                                    playerEndCall!.dispose();
                                    playerEndCall = null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else if (parseCall.value['Accepted'] == true && parseCall.value['IsCallEnd'] == false) {
                    return VideoCallPage(
                      uid: 2,
                      callId: widget.callInfo['objectId'],
                      img: widget.fromImg,
                      img2: widget.toImg,
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
