// ignore_for_file: use_key_in_widget_constructors

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/service/calling.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../Constant/constant.dart';
import '../../Controllers/call_controller/call_controller.dart';
import '../../back4appservice/user_provider/users/provider_user_api.dart';
import '../../models/call/calls.dart';
import '../../models/user_login/user_login.dart';
import '../../service/local_storage.dart';
import 'call_page.dart';

class DialCall extends StatefulWidget {
  final String callId;
  final String img;
  final String name;
  final String name2;
  final String location;
  final String location2;
  final String img2;
  final String toGender;

  const DialCall({
    required this.callId,
    required this.img,
    required this.name,
    required this.name2,
    required this.img2,
    required this.location,
    required this.location2,
    required this.toGender,
  });

  @override
  State<DialCall> createState() => _DialCallState();
}

class _DialCallState extends State<DialCall> with SingleTickerProviderStateMixin {
  final CallController callController = Get.put(CallController());
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
    if (playerEndCall != null) {
      playerEndCall!.dispose();
      playerEndCall = null;
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
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 30))
      ..forward().whenComplete(() async {
        if (player != null) {
          player!.dispose();
          player = null;
        }
        await playerEndCall!.play(AssetSource('audio/call_end.mp3'), volume: 1);
        final DateTime dateTime = await currentTime();
        final callModel = CallModel()
          ..objectId = parseCall.value['objectId']
          ..set('endTime', dateTime)
          ..set('IsCallEnd', true)
          ..set('Log', {
            "CallId": parseCall.value['objectId'],
            "Event": 'EndCall',
            "Users": "senderId: ${parseCall.value['FromUser']['objectId']} UserId: ${parseCall.value['ToUser']['objectId']}",
            "State": "DialPage/initState/AutoCut 30 second/95",
          });
        await callModel.save();
        CallService.makeCall(
          userId: parseCall.value['ToUser']['objectId'],
          type: "Cut",
          fromProfileId: parseCall.value['FromProfile']['objectId'],
          callId: parseCall.value['objectId'],
          isVoiceCall: true,
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
        backgroundColor: Colors.white,
        body: Obx(() {
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
                return Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.img,
                      useOldImageOnUrlChange: true,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => preCachedImage(UniqueKey()),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/profile.jpg', height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width, fit: BoxFit.cover),
                    ),
                    GradientWidget(
                      colors: [ConstColors.black.withOpacity(0.5), ConstColors.black.withOpacity(0.5), const Color(0xFF072DFF).withOpacity(0.7)],
                      child: Padding(
                        padding: EdgeInsets.only(top: 91.h),
                        child: Column(
                          children: [
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
                            SizedBox(height: 8.h),
                            Styles.regular(widget.name, c: Colors.white),
                            SizedBox(height: 8.h),
                            Styles.regular(widget.location, c: Colors.white),
                            SizedBox(height: 5.h),
                            RotatedBox(quarterTurns: -2, child: Lottie.asset("assets/flecha.json", height: 160.w, width: 160.w)),
                            SizedBox(height: 15.h),
                            Container(
                                height: 120.w,
                                width: 120.w,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2.5, color: ConstColors.themeColor)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60.w),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.img2,
                                    useOldImageOnUrlChange: true,
                                    height: 120.w,
                                    width: 120.w,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [const Icon(Icons.error, color: Colors.black, size: 30), Styles.regular("Unable to load", c: Colors.black)],
                                    ),
                                  ),
                                )),
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
                                        "Users": "senderId: ${parseCall.value['FromUser']['objectId']} UserId: ${parseCall.value['ToUser']['objectId']}",
                                        "State": "DialPage/cutCall/userCut/255",
                                      });
                                    await callModel.save();
                                    CallService.makeCall(
                                      userId: parseCall.value['ToUser']['objectId'],
                                      type: "Cut",
                                      fromProfileId: parseCall.value['FromProfile']['objectId'],
                                      callId: parseCall.value['objectId'],
                                      isVoiceCall: true,
                                    );
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
                    ),
                  ],
                );
              }
              if (parseCall.value['Accepted'] == true && parseCall.value['IsCallEnd'] == false) {
                if (player != null) {
                  player!.dispose();
                  player = null;
                }
                animationController.reset();
                return CallPage(
                  uid: 1,
                  callId: parseCall.value['objectId'],
                  name2: widget.name2,
                  name: widget.name,
                  img: widget.img,
                  img2: widget.img2,
                  location: widget.location,
                  location2: widget.location2,
                  toUserGender: widget.toGender,
                  toUserId: parseCall.value['ToUser']['objectId'],
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
    );
  }
}
