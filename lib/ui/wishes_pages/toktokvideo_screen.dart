// ignore_for_file: must_be_immutable

import 'package:eypop/Constant/constant.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'wish_video_player.dart';

class TokTokVideoScreen extends StatefulWidget {
   TokTokVideoScreen({Key? key,required this.videos}) :  super(key: key);

   ParseObject videos;

  @override
  State<TokTokVideoScreen> createState() => _TokTokVideoScreenState();
}

class _TokTokVideoScreenState extends State<TokTokVideoScreen> {


  late VideoPlayerHandler videoPlayerHandler;

  @override
  void initState() {
      // Initialize with a video URL
      videoPlayerHandler = VideoPlayerHandler(
          videoUrl: widget.videos['Post'].url.toString(),
          autoPlay: true,
          onVideoEnd: () {
            videoPlayerHandler.play();
          });

    super.initState();
  }

  @override
  void dispose() {
    if (!videoPlayerHandler.hasError) {
      videoPlayerHandler.dispose();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(videoPlayerHandler),
      onVisibilityChanged: (visibilityInfo) async {
          if (visibilityInfo.visibleFraction > 0.8) {
            videoPlayerHandler.play();
          } else {
            videoPlayerHandler.pause();
          }

      },
      child: VideoPlayerScreen(
        handler: videoPlayerHandler,
        controls: FlickVideoProgressBar(
          flickProgressBarSettings: FlickProgressBarSettings(
              padding: EdgeInsets.only(bottom: 12.h),
              height: 3.h,
              handleRadius: 8.r,
              playedColor: ConstColors.themeColor,
              handleColor: ConstColors.white,
              backgroundColor: ConstColors.white,
              bufferedColor: ConstColors.white),
        ),
        placeholder: widget.videos['PostThumbnail'] != null
            ? Stack(
          alignment: Alignment.center,
          children: [
            Image.network(widget.videos['PostThumbnail'].url.toString(),
                height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width, fit: BoxFit.cover),
            Center(child: CircularProgressIndicator(color: ConstColors.themeColor))
          ],
        )
            : null,
      ),
    );
  }
}
