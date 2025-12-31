// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:ui';

import 'package:eypop/Controllers/notification_controller.dart';
import 'package:eypop/service/local_notification_services.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:eypop/ui/splash_screen_first.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';
import 'Constant/constant.dart';
import 'Constant/theme/theme.dart';
import 'Constant/translate.dart';
import 'Controllers/user_controller.dart';
import 'firebase_options.dart';

const String kGoogleAPIKey = 'AIzaSyBYhT3S8BkUf6dOmkZLuoBUuuYUZsNBb5c';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  analytics;

  await Parse().initialize(keyParseApplicationId, keyParseServerUrl,
      clientKey: keyParseClientKey, liveQueryUrl: 'https://eypopv13.b4a.io/', autoSendSessionId: true, masterKey: keyParseMasterKey, debug: keyDebug);

  Get.put(UserController());
  try {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    localVersion = int.parse(packageInfo.buildNumber);
  } on Exception catch (e) {
    if (kDebugMode) {
      print('HELLO INFO APP DATA ERROR $e');
    }
  }

  final String? objectId = StorageService.getBox.read('ObjectId');

  /// B4APP TOKEN SETUP FOR NOTIFICATION
  initInstallationParseToken();
  //if (Platform.isIOS) getBackgroundDataIos();

  if (objectId != null) {
    onlineUser();
    FirebaseCrashlytics.instance.setUserIdentifier(objectId);
  }
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1000 << 20;
  await LocalNotificationService().init();
  await initializeDateFormatting();
  runApp(
    ChangeNotifierProvider<ThemeModeNotifier>(
      create: (_) {
        final ThemeMode theme = ThemeMode.values[themeMode];
        ThemeModeNotifier(theme).setThemeMode(theme);
        return ThemeModeNotifier(theme);
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && Platform.isIOS) {
      await initInstallationParseToken().whenComplete(() {
        if (receiveNotification.isNotEmpty) {
          NotificationController().notificationNavSwitch(
            receiveNotification['translatedAlert'],
            receiveNotification['aps']['alert']['body'],
            receiveNotification['senderId'],
            receiveNotification['FromProfileId'],
            receiveNotification['ToProfileId'],
            receiveNotification['senderName'],
            receiveNotification['avatar'],
            receiveNotification['url'] ?? '',
          );
        }
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangePlatformBrightness() {
    if (themeMode == 0) {
      AppTheme.setSystemOverlay(ThemeMode.values[themeMode]);
    }
    super.didChangePlatformBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, widget) {
          return InAppNotification(
            child: GetMaterialApp(
              translations: Languages(),
              debugShowCheckedModeBanner: false,
              title: 'Eypop',
              locale: Locale(StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: context.watch<ThemeModeNotifier>().getThemeMode,
              home: SplashScreenFirst(),
            ),
          );
        });
  }
}
