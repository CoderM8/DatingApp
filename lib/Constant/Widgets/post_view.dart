import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'button.dart';

class PostView extends StatelessWidget {
  const PostView(
      {Key? key,
      this.imgStatus = true,
      required this.img,
      required this.isNude,
      this.onTap,
      this.onTapX,
      this.onLongPress,
      this.height,
      this.memCacheHeight,
      this.isMe = false,
      this.isTWish = false,
      this.isVideo = false,
      this.border})
      : super(key: key);
  final VoidCallback? onTap, onTapX,  onLongPress;
  final String img;
  final double? height;

  /// DEFAULT 400
  final int? memCacheHeight;
  final bool imgStatus, isNude, isVideo, isMe, isTWish;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    if (img.isNotEmpty) {
      return GestureDetector(
        onTap: imgStatus ? onTap : onTapX,
        onLongPress: onLongPress,
        child: Stack(
          children: [
            ImageView(
              img,
              memCacheHeight: memCacheHeight,
              height: height,
              border: border,
              placeholder: preCached(UniqueKey()),
            ),
            if (isMe) ...[
              Positioned(
                top: 12.h,
                left: 12.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isTWish) ...[
                      SvgButton(
                          svg: 'assets/Icons/bottomWish.svg',
                          svgColor: ConstColors.redColor,
                          height: 40.w,
                          width: 40.w,
                          buttonColor: ConstColors.white.withOpacity(0.6)),
                      SizedBox(height: 5.h),
                    ],
                    if (isNude) ...[
                      if (isVideo)
                        SvgButton(svg: 'assets/Icons/xxx.svg', height: 40.w, width: 40.w, buttonColor: ConstColors.white.withOpacity(0.6))
                      else
                        SvgButton(
                            svg: 'assets/Icons/xxx.svg',
                            svgColor: ConstColors.redColor,
                            height: 40.w,
                            width: 40.w,
                            buttonColor: ConstColors.white.withOpacity(0.6)),
                    ],
                  ],
                ),
              ),
            ] else ...[
              if (isNude)
                BlurryContainer(
                  height: height,
                  width: MediaQuery.sizeOf(context).width,
                  blur: 30,
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  borderRadius: BorderRadius.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(),
                      SvgView('assets/Icons/IsNude.svg', fit: BoxFit.cover, color: ConstColors.white, height: 27.w, width: 25.w),
                      SizedBox(height: 8.3.h),
                      Styles.regular("Content_warning".tr, fs: 13.sp, c: ConstColors.white, ff: "HR", al: TextAlign.center),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
            ],
            if (!imgStatus)
              Container(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                color: Colors.black.withOpacity(0.8),
                child: SvgView("assets/Icons/ProfileDelete.svg", height: 51.w, width: 51.w, fit: BoxFit.scaleDown),
              )
          ],
        ),
      );
    } else {
      return preCachedSquare();
    }
  }
}

class ImageView extends StatelessWidget {
  final String url;
  final VoidCallback? onTap;

  /// default: MediaQuery.sizeOf(context).height
  final double? height;

  /// default: MediaQuery.sizeOf(context).width
  final double? width;

  /// default: preCachedSquare()
  final Widget? placeholder;

  /// default: const Center(child: Icon(Icons.error))
  final Widget? errorWidget;

  /// default: false
  final bool circle;

  /// default: BoxFit.cover
  final BoxFit? fit;

  /// default: BorderRadius.zero,
  final BorderRadiusGeometry? borderRadius;

  /// default: Border.all(color: const Color(0xffC1C1C1), width: 2.w),
  final BoxBorder? border;

  /// default: 400
  final int? memCacheHeight;

  /// alignment : Alignment.topCenter
  final Alignment? alignment;

  const ImageView(this.url,
      {Key? key,
      this.circle = false,
      this.height,
      this.width,
      this.placeholder,
      this.errorWidget,
      this.fit,
      this.borderRadius,
      this.border,
      this.memCacheHeight,
      this.alignment,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        imageUrl: url,
        height: height ?? MediaQuery.sizeOf(context).height,
        width: width ?? MediaQuery.sizeOf(context).width,
        //this line
        memCacheHeight: memCacheHeight ?? 400,
        fit: fit ?? BoxFit.cover,
        imageBuilder: (context, image) {
          return InkWell(
            onTap: onTap,
            child: Container(
              height: height ?? MediaQuery.sizeOf(context).height,
              width: width ?? MediaQuery.sizeOf(context).width,
              decoration: circle
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: border,
                      image: DecorationImage(image: image, alignment: alignment ?? Alignment.center, fit: fit ?? BoxFit.cover))
                  : BoxDecoration(borderRadius: borderRadius, border: border, image: DecorationImage(image: image, fit: fit ?? BoxFit.cover)),
            ),
          );
        },
        placeholder: (context, url) {
          if (circle) {
            return SizedBox(
                height: height ?? MediaQuery.sizeOf(context).height,
                width: width ?? MediaQuery.sizeOf(context).width,
                child: ClipOval(child: (placeholder ?? preCachedSquare())));
          } else {
            return SizedBox(
              height: height ?? MediaQuery.sizeOf(context).height,
              width: width ?? MediaQuery.sizeOf(context).width,
              child: ClipRRect(borderRadius: borderRadius ?? BorderRadius.zero, child: (placeholder ?? preCachedSquare())),
            );
          }
        },
        errorWidget: (context, url, error) {
          return Container(
            height: height ?? MediaQuery.sizeOf(context).height,
            width: width ?? MediaQuery.sizeOf(context).width,
            decoration: circle ? BoxDecoration(shape: BoxShape.circle, border: border) : BoxDecoration(borderRadius: borderRadius, border: border),
            child: errorWidget ?? Center(child: Icon(Icons.error, color: Theme.of(context).primaryColor)),
          );
        });
  }
}
