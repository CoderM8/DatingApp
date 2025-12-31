// ignore_for_file: library_prefixes, prefer_typing_uninitialized_variables, deprecated_member_use
// ignore_for_file: avoid_print

import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/call_controller/agora_call_controller.dart';
import 'package:eypop/Controllers/call_controller/single_call_page_controller.dart';
import 'package:eypop/service/calling.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Controllers/call_controller/call_controller.dart';
import '../../Controllers/price_controller.dart';
import '../../back4appservice/user_provider/users/provider_user_api.dart';
import '../../models/user_login/user_login.dart';

class VideoCallPage extends StatefulWidget {
  final String callId;
  final String img;
  final String img2;
  final String toUserGender;
  final String toUserId;
  final int uid;

  const VideoCallPage({
    Key? key,
    required this.callId,
    required this.toUserId,
    required this.toUserGender,
    required this.uid,
    required this.img,
    required this.img2,
  }) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final CallController callController = Get.put(CallController());
  final PriceController _priceController = Get.put(PriceController());
  final AgoraVideoCallController ac = Get.put(AgoraVideoCallController());
  final SingleCallPageController singleCallPageController = Get.put(SingleCallPageController());
  bool _isMuted = false;
  bool _isSpeakerEnabled = true;
  AudioPlayer? playerEndCall;

  @override
  void initState() {
    callController.toGender.value = widget.toUserGender;
    singleCallPageController.startTimer(type: "VideoCall");
    // The following line will disable the Android and iOS Screenshot.
    ScreenProtector.preventScreenshotOn();
    // The following line will enable the Android and iOS wakelock.
    WakelockPlus.enable();
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
    final currentCall = await CallService.getCurrentCall('VideoCallPage/endCall/92');
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
    if (singleCallPageController.timer.isActive) {
      singleCallPageController.timer.cancel();
    }
    singleCallPageController.cutUserCallCoin(type: 'VideoCall');
    // The following line enable the Screenshot again.
    ScreenProtector.preventScreenshotOff();
    // The next line disables the wakelock again.
    WakelockPlus.disable();
    ac.agoraLeave();
    if (playerEndCall != null) {
      playerEndCall!.dispose();
      playerEndCall = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Obx(() {
            remoteUidVideo.value;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: (ac.rtcEngine != null && remoteUidVideo.value != 0)
                  ? SizedBox(
                      key: const ValueKey(1),
                      height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                      child: AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: ac.rtcEngine!,
                          canvas: VideoCanvas(uid: remoteUidVideo.value),
                          connection: RtcConnection(channelId: widget.callId),
                        ),
                      ),
                    )
                  : CachedNetworkImage(
                      key: const ValueKey(2),
                      imageUrl: widget.img,
                      useOldImageOnUrlChange: true,
                      height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => preCachedImage(UniqueKey()),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/profile.jpg', fit: BoxFit.cover, height: MediaQuery.sizeOf(context).height, width: MediaQuery.sizeOf(context).width),
                    ),
            );
          }),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 72.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: ac.rtcEngine != null
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
                          ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: _onToggleSpeaker,
                      child: Container(
                        height: 58.w,
                        width: 58.w,
                        padding: EdgeInsets.all(9.6.w),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: _isSpeakerEnabled ? ConstColors.themeColor : ConstColors.white),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 375),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
                          },
                          child: SvgView('assets/Icons/speaker.svg',
                              height: 28.w, width: 28.w, key: ValueKey<bool>(_isSpeakerEnabled), color: _isSpeakerEnabled ? Colors.white : Colors.black, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: _onToggleMute,
                      child: Container(
                        height: 58.w,
                        width: 58.w,
                        padding: EdgeInsets.all(9.6.w),
                        margin: EdgeInsets.symmetric(horizontal: 19.w),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: ConstColors.white),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 375),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
                          },
                          child: SvgView(_isMuted ? 'assets/Icons/mic-mute.svg' : 'assets/Icons/mic.svg',
                              height: 28.w, width: 28.w, key: ValueKey<bool>(_isMuted), color: Colors.black, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
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
                        height: 58.w,
                        width: 58.w,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: ConstColors.white),
                        child: SvgView('assets/Icons/call_end.svg', height: 48.w, width: 48.w, fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 9.h),
                buildTime(),
                SizedBox(height: 45.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTime() {
    return Obx(() {
      return Styles.regular("${singleCallPageController.minutes.value}:${singleCallPageController.seconds.value}", ff: "RR", c: Colors.white, fs: 18.sp);
      // return Styles.regular(timeCount.value, ff: "RR", c: Colors.white, fs: 18.sp);
    });
  }
}
