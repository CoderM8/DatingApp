import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:eypop/Controllers/notification_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('HELLO BACKGROUND CALLBACK ${notificationResponse.payload}');
}

final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream = StreamController<ReceivedNotification>.broadcast();

final NotificationController _notificationController = Get.put(NotificationController());

void _configureSelectNotificationSubject() {
  selectNotificationStream.stream.listen((String? payload) async {
    // ignore: avoid_print
    print('HELLO LISTEN selectNotificationStream $payload');
    Map<String, dynamic> str = jsonDecode(payload!);
    _notificationController.notificationNavSwitch(
      str['translatedAlert'],
      Platform.isIOS ? str['aps']['alert']['body'] : str['alert'],
      str['senderId'],
      str['FromProfileId'],
      str['ToProfileId'],
      str['senderName'],
      str['avatar'],
      str['url']??'',
    );
  });
}

class ReceivedNotification {
  ReceivedNotification({required this.id, required this.title, required this.body, required this.payload});

  final int id;
  final String? title, body, payload;
}

class LocalNotificationService {
  //Singleton pattern
  static final LocalNotificationService _notificationService = LocalNotificationService._internal();

  factory LocalNotificationService() => _notificationService;

  String? selectedNotificationPayload;

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String channelId = '123';
  static const String channelName = 'FlutterParse';
  final StreamController<Map<String, dynamic>> controllerPayload = StreamController<Map<String, dynamic>>();
  NotificationAppLaunchDetails? notificationAppLaunchDetails;

  Future<void> init() async {
    notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = notificationAppLaunchDetails!.notificationResponse?.payload;
    }

    final List<DarwinNotificationCategory> darwinNotificationCategories = <DarwinNotificationCategory>[];

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@mipmap/launcher_icon");

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(ReceivedNotification(id: id, title: title, body: body, payload: payload));
      },
      notificationCategories: darwinNotificationCategories,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        selectNotificationStream.add(notificationResponse.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    _configureSelectNotificationSubject();
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> showNotifications({required String title, required String body, String? payload, String? msgId, String? image}) async {
    try {
      String bigPicturePath = '';
      if (image != null && image.isNotEmpty) {
        bigPicturePath = await _downloadAndSaveFile(
          image,
          'bigPicture',
        );
      }
      await flutterLocalNotificationsPlugin.show(
          msgId.hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channelId, channelName,
              icon: "@mipmap/launcher_icon",
              priority: Priority.high,
              importance: Importance.max,
              enableVibration: true,
              ticker: 'ticker',
              // largeIcon: FilePathAndroidBitmap(largeIconPath),
              // channelDescription: 'big text channel description',
              styleInformation: image != null && image.isNotEmpty
                  ? BigPictureStyleInformation(
                      FilePathAndroidBitmap(bigPicturePath),
                      hideExpandedLargeIcon: false,
                      htmlFormatContentTitle: false,
                      htmlFormatSummaryText: false,
                    )
                  : null,
            ),
          ),
          payload: payload);
    } catch (e, t) {
      print('Get Background notification error ==> $e /// $t');
    }
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory? directory = await getExternalStorageDirectory();
    final String filePath = '${directory!.path}/$fileName.png';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> cancelNotifications(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void close() {
    controllerPayload.close();
  }
}
