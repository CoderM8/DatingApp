import 'dart:ui';

import 'package:eypop/ui/splash_screen_first.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static Future<void> init() async {
    await GetStorage.init();
    await Hive.initFlutter();
    await Hive.openBox('watch_photos');
    await Hive.openBox('watch_profiles');
    await Hive.openBox('watch_wishes');
    await Hive.openBox('wish_List');
    final Locale locale = Get.deviceLocale ?? const Locale('es');
    StorageService.getBox.writeIfNull('languageCode', locale.languageCode);
    themeMode = StorageService.getBox.read('themeMode') ?? 0;
  }

  static final getBox = GetStorage();
  static final Box photosBox = Hive.box('watch_photos');
  static final Box profileBox = Hive.box('watch_profiles');
  static final Box wishBox = Hive.box('watch_wishes');
}
