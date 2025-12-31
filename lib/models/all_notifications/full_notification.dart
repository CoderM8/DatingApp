import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../user_login/user_login.dart';
import '../user_login/user_profile.dart';

class FullNotifications extends ParseObject implements ParseCloneable {
  static const String keyNotification = 'PartsNotifications';
  static const String keyToProfile = 'ToProfile';
  static const String keyFromProfile = 'FromProfile';
  static const String keyFromUser = 'FromUser';
  static const String keyToUser = 'ToUser';
  static const String keyIsRead = 'isRead';
  static const String keyIsPurchased = 'isPurchased';
  static const String keyNotificationType = 'Type';

  FullNotifications() : super(keyNotification);
  FullNotifications.clone() : this();

  // static Notifications convertParseObjectToDietPlan(ParseObject object) {
  //   var dietPlan = Notifications();
  //   dietPlan.toProfile = object['ToProfile']!;
  //   dietPlan.fromProfile = object['FromProfile']!;
  //   dietPlan.toUser = object['ToUser'];
  //   dietPlan.fromUser = object['FromUser'];
  //   dietPlan.isRead = object['isRead'];
  //   dietPlan.notificationType = object['Type'];
  //   return dietPlan;
  // }

  @override
  clone(Map<String, dynamic> map) => FullNotifications.clone()..fromJson(map);

  @override
  FullNotifications fromJson(Map<String, dynamic> objectData) {
    super.fromJson(objectData);
    if (objectData.containsKey(keyToProfile)) {
      toProfile = ProfilePage.clone().fromJson(objectData[keyToProfile]);
    }
    return this;
  }

  ProfilePage get toProfile => get<ProfilePage>(keyToProfile)!;
  set toProfile(ParseObject userId) => set<ParseObject>(keyToProfile, userId);

  ProfilePage get fromProfile => get<ProfilePage>(keyFromProfile)!;
  set fromProfile(ParseObject fromUser) => set<ParseObject>(keyFromProfile, fromUser);

  UserLogin? get fromUser => get<UserLogin>(keyFromUser);
  set fromUser(ParseObject? fromUserLogin) => set<ParseObject>(keyFromUser, fromUserLogin!);

  UserLogin? get toUser => get<UserLogin>(keyToUser);
  set toUser(ParseObject? toUserLogin) => set<ParseObject>(keyToUser, toUserLogin!);

  bool? get isRead => get<bool>(keyIsRead);
  set isRead(bool? isRead) => set<bool>(keyIsRead, isRead!);

  bool? get isPurchased => get<bool>(keyIsPurchased);
  set isPurchased(bool? isPurchased) => set<bool>(keyIsPurchased, isPurchased!);

  String? get notificationType => get<String>(keyNotificationType);
  set notificationType(String? notificationType) => set<String>(keyNotificationType, notificationType!);
}
