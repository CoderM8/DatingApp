// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constant.dart';

class Styles {
  static Text regular(
    String text, {
    Key? key,
    double? fs,
    String? ff,
    Color? c,
    double? ls,
    TextAlign? al,
    double? h,
    FontWeight? fw,
    bool strike = false,
    int? lns,
    bool underline = false,
    TextOverflow? ov,
    FontStyle? fontStyle,
    TextStyle? style,
  }) {
    return Text(
      text,
      key: key,
      textAlign: al ?? TextAlign.left,
      maxLines: lns,
      overflow: ov,
      softWrap: true,
      textScaler: const TextScaler.linear(1),
      style: style ??
          TextStyle(
            fontSize: fs ?? 20.sp,
            fontWeight: fw,
            color: c,
            letterSpacing: ls,
            fontStyle: fontStyle,
            height: h,
            fontFamily: ff ?? "HR",
            decoration: underline
                ? TextDecoration.underline
                : strike
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
          ),
    );
  }
}

class TextFieldModel extends GetView {
  TextFieldModel(
      {Key? key,
      required this.hint,
      required this.controllers,
      this.obs = false,
      this.width,
      this.label,
      this.focusNode,
      this.validator,
      this.onChanged,
      this.onFieldSubmitted,
      this.maxLan,
      this.suffixIcon,
      this.minLine,
      this.textInputAction,
      this.maxLine,
      this.numtype = false,
      this.expands = false,
      this.height,
      this.textInputType,
      this.enabled = true,
      this.color,
      this.borderColor,
      this.hintTextColor,
      this.cursorColor,
      this.contentPadding,
      this.containerColor,
      this.textAlign,
      this.hintTextSize})
      : super(key: key);

  final String hint;
  final String? label;
  final TextEditingController controllers;
  bool numtype, expands, enabled;
  final FocusNode? focusNode;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  void Function(String)? onChanged;
  void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final double? width, height;
  final int? maxLan, maxLine, minLine;
  final Widget? suffixIcon;
  final bool secure = true, obs;
  final Color? color, borderColor, containerColor, hintTextColor, cursorColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextAlign? textAlign;
  final double? hintTextSize;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width ?? MediaQuery.sizeOf(context).width,
        height: height,
        decoration: BoxDecoration(color: containerColor ?? Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(5.r)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null)
              Padding(
                padding: EdgeInsets.only(left: 13..w, bottom: 5.h, top: 10.h),
                child: Styles.regular(label!, c: Theme.of(context).primaryColor, fs: 18.sp),
              ),
            Theme(
              data: ThemeData(
                  textSelectionTheme: TextSelectionThemeData(
                      cursorColor: ConstColors.themeColor, selectionColor: ConstColors.themeColor, selectionHandleColor: ConstColors.themeColor)),
              child: TextFormField(
                onChanged: onChanged,
                onFieldSubmitted: onFieldSubmitted,
                enabled: enabled,
                maxLines: maxLine ?? 1,
                minLines: minLine ?? 1,
                maxLength: maxLan,
                expands: expands,
                validator: validator,
                focusNode: focusNode,
                keyboardType: textInputType,
                textAlign: textAlign ?? TextAlign.start,
                textInputAction: textInputAction,
                style: TextStyle(
                    color: enabled ? color ?? Theme.of(context).primaryColor : /*ConstColors.grey*/ Theme.of(context).primaryColor,
                    fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
                controller: controllers,
                obscureText: obs,
                autofocus: false,
                cursorColor: cursorColor ?? Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  counterStyle: TextStyle(
                      color: color ?? Theme.of(context).primaryColor, fontSize: 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
                  contentPadding: contentPadding,
                  fillColor: enabled ? containerColor ?? Theme.of(context).scaffoldBackgroundColor : Colors.transparent,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      borderSide: BorderSide(width: 1, color: borderColor ?? ConstColors.themeColor)),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      borderSide: BorderSide(width: 1, color: borderColor ?? ConstColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      borderSide: BorderSide(width: 1, color: borderColor ?? ConstColors.border)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      borderSide: BorderSide(width: 1, color: borderColor ?? ConstColors.border)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)), borderSide: BorderSide(width: 1, color: ConstColors.redColor)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)), borderSide: BorderSide(width: 1, color: ConstColors.redColor)),
                  hintText: hint,
                  hintStyle: TextStyle(
                      fontFamily: "HR",
                      color: hintTextColor ?? ConstColors.subtitle,
                      fontSize: hintTextSize ?? 15.sp / PaintingBinding.instance.platformDispatcher.textScaleFactor),
                  suffixIconConstraints: BoxConstraints(minHeight: 30.h, minWidth: 24.w),
                  suffixIcon: suffixIcon,
                ),
              ),
            ),
          ],
        ));
  }
}
