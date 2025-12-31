import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/post_view.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/ui/wishes_pages/wish_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// when open video pass value in [url]
/// [image] use if open image pass image url when open video pass videoThumb to show placeholder
class ChatVideoScreen extends StatefulWidget {
  const ChatVideoScreen({Key? key, this.url = "", required this.image, this.isLandscape = false}) : super(key: key);
  final String url;
  final String image;
  final bool isLandscape;

  @override
  State<ChatVideoScreen> createState() => _ChatVideoScreenState();
}

class _ChatVideoScreenState extends State<ChatVideoScreen> {
  late VideoPlayerHandler videoPlayerHandler;

  @override
  void initState() {
    if (widget.url.isNotEmpty) {
      // Initialize with a video URL
      videoPlayerHandler = VideoPlayerHandler(
          videoUrl: widget.url,
          autoPlay: true,
          onVideoEnd: () {
            videoPlayerHandler.play();
          });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.url.isNotEmpty) {
      videoPlayerHandler.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            SvgView('assets/Icons/cancelbutton.svg', width: 45.w, height: 45.w, padding: EdgeInsets.only(right: 10.w), onTap: () => Get.back()),
          ],
        ),
        body: Center(
          child: widget.url.isEmpty
              ? ImageView(
                  widget.image,
                  height: widget.isLandscape ? 292.h : 698.h,
                  width: MediaQuery.sizeOf(context).width,
                  placeholder: preCachedImage(const ValueKey(0)),
                )
              : (!videoPlayerHandler.hasError)
                  ? SizedBox(
                      height: widget.isLandscape ? 292.h : 698.h,
                      width: MediaQuery.sizeOf(context).width,
                      child: VideoPlayerScreen(
                        handler: videoPlayerHandler,
                        placeholder: Image.network(widget.image, height: widget.isLandscape ? 292.h : 698.h, width: MediaQuery.of(context).size.width, fit: BoxFit.cover),
                      ),
                    )
                  : const SizedBox.shrink(),
        ));
  }
}
