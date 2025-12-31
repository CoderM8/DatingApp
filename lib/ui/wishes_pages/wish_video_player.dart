// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerHandler {
  late FlickManager flickManager;
  bool hasError = false; // Boolean to track error state

  // INIT FLICK VIDEO PLAYER
  VideoPlayerHandler({required String videoUrl, bool autoPlay = true, bool file = false, Function? onVideoEnd}) {
    final videoPlayerController = file ? VideoPlayerController.file(File(videoUrl)) : VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    videoPlayerController.addListener(() {
      if (videoPlayerController.value.hasError) {
        hasError = true;
        final errorMessage = videoPlayerController.value.errorDescription;
        if (kDebugMode) {
          print('VideoPlayerHandler Error: $errorMessage');
        }
      }
    });
    flickManager = FlickManager(videoPlayerController: videoPlayerController, autoPlay: autoPlay, onVideoEnd: onVideoEnd);
  }

  // CHECK VIDEO IS PLAY OR NOT
  bool get isPlaying {
    final controller = flickManager.flickVideoManager?.videoPlayerController;
    return controller != null && controller.value.isPlaying;
  }

  // CHECK VOLUME ON OR OFF
  bool get isSpeaker {
    final controller = flickManager.flickVideoManager?.videoPlayerController;
    return controller != null && controller.value.volume > 0;
  }

  // PLAY PAUSE SWITCH BUTTON
  void togglePlayPause() {
    final controlManager = flickManager.flickControlManager;
    if (controlManager != null) {
      if (isPlaying) {
        controlManager.pause();
      } else {
        controlManager.play();
      }
    }
  }

  // PLAY VIDEO
  void play() {
    flickManager.flickControlManager?.play();
  }

  // PAUSE VIDEO
  void pause() {
    flickManager.flickControlManager?.pause();
  }

  // CHANGE VOLUME MODE
  void toggleVolume() {
    final controller = flickManager.flickVideoManager?.videoPlayerController;
    if (controller != null) {
      if (controller.value.volume > 0) {
        controller.setVolume(0.0);
      } else {
        controller.setVolume(1.0);
      }
    }
  }

  // DISPOSE VIDEO PLAYER
  void dispose() {
    flickManager.dispose();
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final VideoPlayerHandler handler;
  final Widget? fallback, placeholder, controls;
  final bool showVolume, showProgressBar;

  /// default: Alignment.bottomRight,
  final AlignmentGeometry volumeAlign;

  /// default: EdgeInsets.only(bottom: 20.h, right: 10.w)
  final EdgeInsetsGeometry? volumePadding;

  /// default: EdgeInsets.only(bottom: 10.h)
  final EdgeInsetsGeometry? progressBarPadding;

  const VideoPlayerScreen({
    Key? key,
    required this.handler,
    this.fallback,
    this.placeholder,
    this.controls,
    this.volumePadding,
    this.progressBarPadding,
    this.showVolume = false,
    this.showProgressBar = true,
    this.volumeAlign = Alignment.bottomRight,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            widget.handler.togglePlayPause();
            setState(() {});
          },
          child: FlickVideoPlayer(
            key: ValueKey(widget.handler.flickManager),
            flickManager: widget.handler.flickManager,
            flickVideoWithControls: FlickVideoWithControls(
              controls: widget.controls ??
                  (widget.showProgressBar
                      ? FlickVideoProgressBar(
                          flickProgressBarSettings: FlickProgressBarSettings(
                            padding: widget.progressBarPadding ?? EdgeInsets.only(bottom: 10.h),
                            height: 3.h,
                            handleRadius: 8.r,
                            playedColor: ConstColors.white,
                            handleColor: ConstColors.white,
                            backgroundColor: ConstColors.themeColor,
                            bufferedColor: ConstColors.themeColor,
                          ),
                        )
                      : const SizedBox.shrink()),
              playerLoadingFallback: Center(child: CircularProgressIndicator(color: ConstColors.themeColor)),
              playerErrorFallback: widget.fallback ??
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.white, size: 50.w),
                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child:
                                Styles.regular('We\'re sorry, but the video cannot be played at the moment.', ff: 'HM', c: ConstColors.redColor, fs: 18.sp, al: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        ),
        if (widget.showVolume)
          Align(
            alignment: widget.volumeAlign,
            child: InkWell(
              onTap: () {
                widget.handler.toggleVolume();
                setState(() {});
              },
              child: Container(
                height: 35.w,
                width: 35.w,
                margin: widget.volumePadding ?? EdgeInsets.only(bottom: 20.h, right: 10.w),
                padding: EdgeInsets.all(9.6.w),
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.handler.isSpeaker ? ConstColors.themeColor : ConstColors.white),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: SvgView('assets/Icons/speaker.svg',
                      key: ValueKey<bool>(widget.handler.isSpeaker), color: widget.handler.isSpeaker ? Colors.white : Colors.black, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
