import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class LikeMessage extends ParseObject implements ParseCloneable {
  static const String keyLikeMsg = 'Like_Message';
  static const String keyMsg = 'Message';
  static const String keyFromUser = 'FromUser';
  static const String keyToUser = 'ToUser';
  static const String keyMTime = 'MessageTime';
  static const String keyFromProfile = 'FromProfile';
  static const String keyToProfile = 'ToProfile';
  static const String keyIsRead = 'isRead';
  static const String keyIsPurchased = 'isPurchased';
  static const String keyUsers = 'Users';
  LikeMessage() : super(keyLikeMsg);

  LikeMessage.clone() : this();

  @override
  LikeMessage clone(Map<String, dynamic> map) => LikeMessage.clone()..fromJson(map);

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

  String? get time => get<String>(keyMTime);
  set time(String? number) => set<String>(keyMTime, number!);

  bool? get isRead => get<bool>(keyIsRead);
  set isRead(bool? isRead) => set<bool>(keyIsRead, isRead!);

  bool? get isPurchased => get<bool>(keyIsPurchased);
  set isPurchased(bool? isPurchased) => set<bool>(keyIsPurchased, isPurchased!);

  List get users => get<List>(keyUsers)!;
  set users(List? users) => set<List>(keyUsers, users!);
}
