import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class RoundButton extends StatelessWidget {
  final String svg;
  final VoidCallback? onTap;
  final bool enable;
  final Color? color;
  final double? height, width;

  const RoundButton({Key? key, this.onTap, this.enable = true, this.color, required this.svg, this.height, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: key,
      onTap: enable ? onTap : null,
      child: Container(
        height: height ?? 40.w,
        width: width ?? 40.w,
        padding: EdgeInsets.all(7.2.w),
        decoration: BoxDecoration(shape: BoxShape.circle, color: color ?? const Color(0xffEAEBEF)),
        child: SvgView(svg, fit: BoxFit.scaleDown, color: enable ? null : Colors.grey),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton(
      {Key? key, required this.title, this.width, this.height, this.onTap, this.fontSize, this.circleRadius, this.color1, this.color2, this.textColor, this.enable = true})
      : super(key: key);
  final double? width, height, fontSize, circleRadius;
  final Color? color1, color2, textColor;
  final String title;
  final VoidCallback? onTap;
  final bool enable;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: key,
      onTap: enable ? onTap : null,
      child: Container(
        alignment: Alignment.center,
        height: height ?? 50.h,
        width: width ?? MediaQuery.sizeOf(Get.context!).width,
        decoration: !enable
            ? BoxDecoration(color: ConstColors.greyButtonColor, borderRadius: BorderRadius.circular(circleRadius ?? 60.r))
            : BoxDecoration(
                borderRadius: BorderRadius.circular(circleRadius ?? 60.r),
                gradient: LinearGradient(
                  colors: [
                    color1 ?? ConstColors.darkRedColor,
                    color2 ?? ConstColors.lightRedColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 1.0],
                ),
              ),
        padding: EdgeInsets.only(left: 15.w, right: 15.w),
        child: Styles.regular(title, c: textColor ?? ConstColors.white, al: TextAlign.center, ff: 'HB', fs: fontSize ?? 18.sp),
      ),
    );
  }
}

class SvgView extends StatelessWidget {
  const SvgView(this.svg, {Key? key, this.color, this.height, this.width, this.onTap, this.padding, this.fit = BoxFit.contain, this.network = false}) : super(key: key);
  final String svg;
  final Color? color;
  final double? height, width;
  final BoxFit fit;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool network;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: network
            ? SvgPicture.network(svg,
                colorFilter: color != null ? ColorFilter.mode(color ?? ConstColors.themeColor, BlendMode.srcIn) : null, height: height, width: width, fit: fit)
            : SvgPicture.asset(svg, colorFilter: color != null ? ColorFilter.mode(color ?? ConstColors.themeColor, BlendMode.srcIn) : null, height: height, width: width, fit: fit),
      ),
    );
  }
}

class Back extends StatelessWidget {
  const Back({Key? key, this.color, this.height, this.width, this.onTap, this.padding, this.icon, this.svg}) : super(key: key);
  final Color? color;
  final double? height, width;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final String? svg;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      padding: padding,
      onPressed: onTap ?? () => Get.back(),
      icon: icon ?? SvgView(svg ?? 'assets/Icons/back.svg', color: color ?? Theme.of(context).primaryColor, height: height ?? 22.w, width: width ?? 22.w, fit: BoxFit.cover),
    );
  }
}

class Dots extends StatelessWidget {
  const Dots({Key? key, required this.select, this.selectColor, this.height = 30, this.width = 30}) : super(key: key);
  final bool select;
  final Color? selectColor;
  final double height, width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.w,
      width: width.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ConstColors.subtitle, width: 1.w)),
      child: Container(
        height: (height - 6).w,
        width: (width - 6).w,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ConstColors.subtitle, width: 1.w, style: select == false ? BorderStyle.none : BorderStyle.solid),
            color: select ? (selectColor ?? ConstColors.themeColor) : Colors.transparent),
      ),
    );
  }
}

class GradientWidget extends StatelessWidget {
  const GradientWidget({Key? key, this.child, this.height, this.width, this.colors}) : super(key: key);
  final Widget? child;
  final double? height, width;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? MediaQuery.sizeOf(context).height,
      width: width ?? MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors ??
                [
                  ConstColors.themeColor,
                  ConstColors.themeColor,
                  Theme.of(context).dialogBackgroundColor,
                ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.1, 0.9]),
      ),
      child: child,
    );
  }
}

class SvgButton extends StatelessWidget {
  const SvgButton({Key? key, required this.svg, this.buttonColor, this.svgColor, this.onTap, this.height, this.width}) : super(key: key);

  final Color? buttonColor, svgColor;
  final String svg;
  final VoidCallback? onTap;
  final double? height, width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height ?? 44.w,
        width: width ?? 44.w,
        padding: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: buttonColor ?? ConstColors.white, border: Border.all(color: ConstColors.bottomBorder)),
        child: SvgView(svg, color: svgColor),
      ),
    );
  }
}
