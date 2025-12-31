// ignore_for_file: use_key_in_widget_constructors

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Controllers/call_controller/agora_call_controller.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/service/calling.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../Constant/constant.dart';
import '../../Controllers/call_controller/call_controller.dart';
import '../../back4appservice/user_provider/users/provider_user_api.dart';
import '../../models/call/calls.dart';
import '../../models/user_login/user_login.dart';
import '../../service/local_storage.dart';
import 'video_call_page.dart';

class VideoDialCall extends StatefulWidget {
  final String callId;
  final String img;
  final String name;
  final String name2;
  final String img2;
  final String toGender;

  const VideoDialCall({required this.callId, required this.img, required this.name, required this.name2, required this.img2, required this.toGender});

  @override
  State<VideoDialCall> createState() => _VideoDialCallState();
}

class _VideoDialCallState extends State<VideoDialCall> with SingleTickerProviderStateMixin {
  final AgoraVideoCallController ac = Get.put(AgoraVideoCallController());
  final PriceController _priceController = Get.put(PriceController());
  late AnimationController animationController;
  AudioPlayer? player;
  AudioPlayer? playerEndCall;

  @override
  void dispose() {
    if (player != null) {
      player!.dispose();
      player = null;
    }
    animationController.dispose();
    super.dispose();
  }

  void agoraRingtone() async {
    player = AudioPlayer();
    playerEndCall = AudioPlayer();
    await player!.play(AssetSource('audio/waiting_ring.mp3'));
    player!.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void initState() {
    agoraRingtone();
    // AGORA RTC INIT PASS [1] WHEN YOU DIAL CALL EVERY TIME
    ac.agoraInitialize(callId: widget.callId, uid: 1, isVoiceCall: false);
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 30))
      ..forward().whenComplete(() async {
        if (player != null) {
          player!.dispose();
          player = null;
        }
        await playerEndCall!.play(AssetSource('audio/call_end.mp3'),volume: 1);
        final DateTime dateTime = await currentTime();
        final callModel = CallModel()
          ..objectId = parseCall.value['objectId']
          ..set('endTime', dateTime)
          ..set('IsCallEnd', true)
          ..set('Log', {
            "CallId": parseCall.value['objectId'],
            "Event": 'EndCall',
            "Type": '1/VideoCall',
            "Users": "senderId: ${parseCall.value['FromUser']['objectId']} UserId: ${parseCall.value['ToUser']['objectId']}",
            "State": "lib/ui/video_call/video_dial_page.dart/initState/AutoCut 30 second/99",
          });
        await callModel.save();
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
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: GradientWidget(
          child: Obx(() {
            parseCall.value;
            if (parseCall.value.objectId != null) {
              if (parseCall.value['ChannelName'].contains(StorageService.getBox.read('ObjectId'))) {
                if (parseCall.value['IsCallEnd'] != null) {
                  if (parseCall.value['IsCallEnd'] == true && parseCall.value['Accepted'] == false) {
                    if (player != null) {
                      player!.dispose();
                      player = null;
                    }
                    final UserLogin userLogin = UserLogin();
                    userLogin.objectId = parseCall.value['FromUser']['objectId'];

                    ///userLogin.userisbusy = false;
                    userLogin.local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
                    UserLoginProviderApi().update(userLogin);

                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      // add your code here.
                      _priceController.isPurchase.value = false;
                      _priceController.isShowConnectCallButton.value = false;
                      Get.back();
                    });
                  }

                  if (parseCall.value['IsCallEnd'] == true && parseCall.value['Accepted'] == true) {
                    if (player != null) {
                      player!.dispose();
                      player = null;
                    }
                    final UserLogin userLogin = UserLogin();
                    userLogin.objectId = parseCall.value['FromUser']['objectId'];

                    userLogin.local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
                    UserLoginProviderApi().update(userLogin);

                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      // add your code here.
                      _priceController.isPurchase.value = false;
                      _priceController.isShowConnectCallButton.value = false;
                      Get.back();
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
                                          imageUrl: widget.img2,
                                          useOldImageOnUrlChange: true,
                                          height: 183.h,
                                          width: 127.h,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => ClipRRect(borderRadius: BorderRadius.circular(10.r), child: preCachedImage(UniqueKey())),
                                          errorWidget: (context, url, error) =>
                                              ClipRRect(borderRadius: BorderRadius.circular(10.r), child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover)),
                                        ),
                                      ));
                          }),
                        ),

                        SizedBox(height: 53.h),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Lottie.asset("assets/circulo.json", height: 138.w, width: 138.w, controller: animationController),
                            ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: widget.img,
                                useOldImageOnUrlChange: true,
                                height: 120.w,
                                width: 120.w,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => ClipOval(child: preCachedImage(UniqueKey())),
                                errorWidget: (context, url, error) => ClipOval(child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Styles.regular(widget.name, c: Theme.of(context).primaryColor, ff: "RR", fs: 18.sp),
                        SizedBox(height: 30.h),
                        RotatedBox(quarterTurns: -2, child: Lottie.asset("assets/flecha.json", height: 160.w, width: 160.w)),
                        SizedBox(height: 57.h),
                        // CALL END
                        SvgView(
                          'assets/Icons/call_end.svg',
                          height: 84.12.w,
                          width: 84.12.w,
                          fit: BoxFit.cover,
                          onTap: () async {
                            await playerEndCall!.play(AssetSource('audio/call_end.mp3'),volume: 1);
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
                                "State": "lib/ui/video_call/video_dial_page.dart/cutCall/userCut/234",
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
                  );
                } else if (parseCall.value['Accepted'] == true && parseCall.value['IsCallEnd'] == false) {
                  if (player != null) {
                    player!.dispose();
                    player = null;
                  }
                  animationController.reset();
                  return VideoCallPage(
                    uid: 1,
                    callId: parseCall.value['objectId'],
                    img: widget.img,
                    img2: widget.img2,
                    toUserGender: widget.toGender,
                    toUserId: parseCall.value['ToUser']['objectId'],
                  );
                } else {
                  return SizedBox.shrink(child: Styles.regular('Accepted True IsCallEnd False'));
                }
              } else {
                return SizedBox.shrink(child: Styles.regular('Current call is not connected!'));
              }
            } else {
              return SizedBox.shrink(child: Styles.regular('Current call is not connected!'));
            }
          }),
        ),
      ),
    );
  }
}
