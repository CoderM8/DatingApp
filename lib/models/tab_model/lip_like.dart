import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../user_login/user_login.dart';
import '../user_login/user_profile.dart';

class LipLike extends ParseObject implements ParseCloneable {
  static const String keyLipLike = 'Lip_Like';
  static const String keyLip = 'Lip_Count';
  static const String keyFromUser = 'FromUser';
  static const String keyToUser = 'ToUser';
  static const String keyFromProfile = 'FromProfile';
  static const String keyToProfile = 'ToProfile';
  static const String keyIsRead = 'isRead';
  static const String keyUsers = 'Users';
  LipLike() : super(keyLipLike);

  LipLike.clone() : this();

  @override
  LipLike clone(Map<String, dynamic> map) => LipLike.clone()..fromJson(map);

  int get liplike => get<int>(keyLip)!;
  set liplike(int? liplike) => set<int>(keyLip, liplike!);

  UserLogin? get fromUser => get<UserLogin>(keyFromUser);
  set fromUser(UserLogin? fromUserLogin) => set<UserLogin>(keyFromUser, fromUserLogin!);

  UserLogin? get toUser => get<UserLogin>(keyToUser);
  set toUser(UserLogin? toUserLogin) => set<UserLogin>(keyToUser, toUserLogin!);

  ProfilePage? get fromProfile => get<ProfilePage>(keyFromProfile);
  set fromProfile(ProfilePage? fromUserLogin) => set<ProfilePage>(keyFromProfile, fromUserLogin!);

  ProfilePage? get toProfile => get<ProfilePage>(keyToProfile);
  set toProfile(ProfilePage? toUserLogin) => set<ProfilePage>(keyToProfile, toUserLogin!);

  bool? get isRead => get<bool>(keyIsRead);
  set isRead(bool? isRead) => set<bool>(keyIsRead, isRead!);
  List get users => get<List>(keyUsers)!;
  set users(List? users) => set<List>(keyUsers, users!);
}
