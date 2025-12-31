// ignore_for_file: library_prefixes, prefer_typing_uninitialized_variables, deprecated_member_use
// ignore_for_file: avoid_print

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/call_controller/agora_call_controller.dart';
import 'package:eypop/Controllers/call_controller/single_call_page_controller.dart';
import 'package:eypop/service/calling.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Controllers/call_controller/call_controller.dart';
import '../../Controllers/price_controller.dart';
import '../../back4appservice/user_provider/users/provider_user_api.dart';
import '../../models/user_login/user_login.dart';

class CallPage extends StatefulWidget {
  final String callId;
  final String? name;
  final String? location;
  final String? location2;
  final String? name2;
  final String? img;
  final String? img2;
  final String toUserGender;
  final String toUserId;
  final int uid;

  const CallPage({
    Key? key,
    required this.callId,
    required this.toUserId,
    required this.toUserGender,
    required this.uid,
    this.img,
    this.img2,
    this.location,
    this.location2,
    this.name,
    this.name2,
  }) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final CallController callController = Get.put(CallController());
  final PriceController _priceController = Get.put(PriceController());
  final SingleCallPageController singleCallPageController = Get.put(SingleCallPageController());
  final AgoraVideoCallController ac = Get.put(AgoraVideoCallController());
  bool _isMuted = false;
  bool _isSpeakerEnabled = false;
  AudioPlayer? playerEndCall;

  @override
  void initState() {
    callController.toGender.value = widget.toUserGender;
    // AGORA RTC INIT PASS [1] WHEN YOU DIAL CALL EVERY TIME
    // AGORA RTC INIT PASS [2] WHEN RECEIVED INCOMING CALL EVERY TIME
    ac.agoraInitialize(callId: widget.callId, uid: widget.uid, isVoiceCall: true);
    singleCallPageController.startTimer(type: "AudioCall");
    playerEndCall = AudioPlayer();
    super.initState();
  }

// Toggle mute for both Audio/Video
  void _onToggleMute() {
    if (ac.rtcEngine != null) {
      setState(() {
        _isMuted = !_isMuted;
      });
      ac.rtcEngine!.muteLocalAudioStream(_isMuted);
    }
  }

  // Toggle speaker phone for Audio Call
  void _onToggleSpeaker() {
    if (ac.rtcEngine != null) {
      setState(() {
        _isSpeakerEnabled = !_isSpeakerEnabled;
      });
      ac.rtcEngine!.setEnableSpeakerphone(_isSpeakerEnabled);
    }
  }

  Future<void> endCall() async {
    final currentCall = await CallService.getCurrentCall('CallPage/EndCall/97');
    if (currentCall != null) {
      await FlutterCallkitIncoming.endCall(currentCall['id']);
    }
  }

  @override
  void dispose() {
    endCall();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _priceController.isPurchase.value = false;
      _priceController.isShowConnectCallButton.value = false;
    });
    ac.agoraLeave();
    if (singleCallPageController.timer.isActive) {
      singleCallPageController.timer.cancel();
    }
    singleCallPageController.cutUserCallCoin(type: 'AudioCall');
    if (playerEndCall != null) {
      playerEndCall!.dispose();
      playerEndCall = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: [
            Image.network(
              widget.img!,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            GradientWidget(
              colors: [ConstColors.black.withOpacity(0.5), ConstColors.black.withOpacity(0.5), const Color(0xFF072DFF).withOpacity(0.7)],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform(
                    transform: Matrix4.translationValues(0, 50, 0),
                    child: Column(
                      children: [
                        Container(
                          height: 120.w,
                          width: 120.w,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2.5, color: ConstColors.themeColor)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60.w),
                            child: Image.network(
                              widget.img!,
                              height: 45.w,
                              width: 45.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Styles.regular(widget.name!, c: Colors.white),
                        SizedBox(height: 8.h),
                        Styles.regular(widget.location!, c: Colors.white),
                      ],
                    ),
                  ),
                  Transform(
                    transform: Matrix4.translationValues(0, -100.h, 0),
                    child: Column(
                      children: [
                        Transform(
                          transform: Matrix4.translationValues(0, 15.h, 0),
                          child: Lottie.asset("assets/corazones.json", height: 360.h, width: 120.w),
                        ),
                        Container(
                          height: 120.w,
                          width: 120.w,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2.5, color: ConstColors.themeColor)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60.w),
                            child: Image.network(
                              widget.img2!,
                              height: 45.w,
                              width: 45.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Styles.regular(widget.name2!, c: Colors.white),
                        SizedBox(height: 8.h),
                        Styles.regular(widget.location2!, c: Colors.white),
                        SizedBox(height: 30.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _onToggleSpeaker,
                              child: Container(
                                height: 55.w,
                                width: 55.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isSpeakerEnabled ? ConstColors.themeColor : Colors.grey,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 375),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
                                  },
                                  child: SvgView('assets/Icons/speaker.svg', key: ValueKey<bool>(_isSpeakerEnabled), color: Colors.white, height: 30.w, width: 30.w),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await playerEndCall!.play(AssetSource('audio/call_end.mp3'),volume: 1);
                                callController.selfCut.value = true;
                                await ac.agoraLeave();
                                singleCallPageController.cutCall();
                                await endCall();
                                final UserLogin userLogin = UserLogin();
                                userLogin.objectId = widget.toUserId;
                                userLogin.local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
                                UserLoginProviderApi().update(userLogin);
                                if (playerEndCall != null) {
                                  playerEndCall!.dispose();
                                  playerEndCall = null;
                                }
                              },
                              child: Container(
                                height: 65.w,
                                width: 65.w,
                                margin: EdgeInsets.symmetric(horizontal: 20.w),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                child: const Icon(Icons.call, color: Colors.white, size: 45),
                              ),
                            ),
                            GestureDetector(
                              onTap: _onToggleMute,
                              child: Container(
                                height: 55.w,
                                width: 55.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: ConstColors.themeColor),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 375),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
                                  },
                                  child: SvgView(_isMuted ? 'assets/Icons/mic-mute.svg' : 'assets/Icons/mic.svg',
                                      key: ValueKey<bool>(_isMuted), color: Colors.white, height: 30.w, width: 30.w),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        buildTime(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTime() {
    return Obx(() {
      return Styles.regular("${singleCallPageController.minutes.value}:${singleCallPageController.seconds.value}", ff: "RR", c: Colors.white, fs: 18.sp);
    });
  }
}
