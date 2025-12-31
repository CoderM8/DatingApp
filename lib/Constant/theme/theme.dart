import 'package:eypop/Constant/constant.dart';
import 'package:eypop/ui/splash_screen_first.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Color bottomColor() {
  return isDarkMode.value ? const Color(0xff414141) : Colors.white;
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: Colors.black,
    dialogBackgroundColor: ConstColors.black,
    hintColor: const Color(0xff585858),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        unselectedItemColor: ConstColors.bottomBorder,
        selectedItemColor: ConstColors.themeColor,
        selectedLabelStyle: TextStyle(color: ConstColors.bottomBorder, fontSize: 13.sp, fontFamily: 'HR'),
        unselectedLabelStyle: TextStyle(color: ConstColors.bottomBorder, fontSize: 13.sp, fontFamily: 'HR')),
    primaryColor: ConstColors.white,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0, titleTextStyle: TextStyle(color: Colors.white)),
    textTheme: TextTheme(bodyMedium: TextStyle(fontFamily: "HR", fontSize: 18.sp, color: const Color(0xffB7B7B7))),
    textSelectionTheme: TextSelectionThemeData(cursorColor: ConstColors.themeColor, selectionColor: ConstColors.themeColor, selectionHandleColor: ConstColors.themeColor),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: ConstColors.themeColor, primary: Colors.black),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: const Color(0xffF8FAFD),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    brightness: Brightness.light,
    hintColor: const Color(0xffEDF4FF),
    dialogBackgroundColor: ConstColors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: ConstColors.themeColor,
        unselectedItemColor: ConstColors.bottomBorder,
        selectedLabelStyle: TextStyle(color: ConstColors.bottomBorder, fontSize: 13.sp, fontFamily: 'HR'),
        unselectedLabelStyle: TextStyle(color: ConstColors.bottomBorder, fontSize: 13.sp, fontFamily: 'HR')),
    primaryColor: ConstColors.black,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0, titleTextStyle: TextStyle(color: Colors.black)),
    textTheme: TextTheme(bodyMedium: TextStyle(fontFamily: "HR", fontSize: 18.sp, color: const Color(0xff000000))),
    textSelectionTheme: TextSelectionThemeData(cursorColor: ConstColors.themeColor, selectionColor: ConstColors.themeColor, selectionHandleColor: ConstColors.themeColor),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: ConstColors.themeColor, primary: Colors.white),
  );

  static setSystemOverlay(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        if (PaintingBinding.instance.platformDispatcher.platformBrightness == Brightness.dark) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.dark.copyWith(
              systemNavigationBarColor: Colors.black,
              systemNavigationBarIconBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.light,
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.dark,
            ),
          );
          isDarkMode.value = true;
        } else {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.light.copyWith(
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.light,
            ),
          );
          isDarkMode.value = false;
        }
        break;
      case ThemeMode.light:
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.light.copyWith(
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
          ),
        );
        isDarkMode.value = false;
        break;
      case ThemeMode.dark:
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark,
          ),
        );
        isDarkMode.value = true;
        break;
    }
  }
}

class ThemeModeNotifier with ChangeNotifier {
  ThemeMode _themeMode;

  @override
  notifyListeners();

  ThemeModeNotifier(this._themeMode);

  ThemeMode get getThemeMode => _themeMode;

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    Get.changeThemeMode(mode);
    AppTheme.setSystemOverlay(mode);
    notifyListeners();
  }
}
