import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../user_login/user_login.dart';
import '../user_login/user_profile.dart';

class WinkMessage extends ParseObject implements ParseCloneable {
  static const String keyWinkMsg = 'Wink_Message';
  static const String keyMsg = 'Message';
  static const String keyFromUser = 'FromUser';
  static const String keyToUser = 'ToUser';
  static const String keyFromProfile = 'FromProfile';
  static const String keyToProfile = 'ToProfile';
  static const String keyIsPurchase = 'IsPurchase';
  static const String keyIsRead = 'isRead';
  WinkMessage() : super(keyWinkMsg);

  WinkMessage.clone() : this();

  @override
  WinkMessage clone(Map<String, dynamic> map) => WinkMessage.clone()..fromJson(map);

  String get message => get<String>(keyMsg)!;
  set message(String? message) => set<String>(keyMsg, message!);

  UserLogin? get fromUser => get<UserLogin>(keyFromUser);
  set fromUser(UserLogin? fromUserLogin) => set<UserLogin>(keyFromUser, fromUserLogin!);

  UserLogin? get toUser => get<UserLogin>(keyToUser);
  set toUser(UserLogin? toUserLogin) => set<UserLogin>(keyToUser, toUserLogin!);

  ProfilePage? get fromProfile => get<ProfilePage>(keyFromProfile);
  set fromProfile(ProfilePage? fromUserLogin) => set<ProfilePage>(keyFromProfile, fromUserLogin!);

  ProfilePage? get toProfile => get<ProfilePage>(keyToProfile);
  set toProfile(ProfilePage? toUserLogin) => set<ProfilePage>(keyToProfile, toUserLogin!);

  bool? get isPurchase => get<bool>(keyIsPurchase);
  set isPurchase(bool? isPurchase) => set<bool>(keyIsPurchase, isPurchase!);

  bool? get isRead => get<bool>(keyIsRead);
  set isRead(bool? isRead) => set<bool>(keyIsRead, isRead!);
}
