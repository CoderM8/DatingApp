import 'package:eypop/models/user_login/user_profile.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../user_login/user_login.dart';
import '../user_login/user_post.dart';

class HeartLike extends ParseObject implements ParseCloneable {
  static const String keyHeartLike = 'Heart_Like';
  static const String keyHeart = 'Heart_Count';
  static const String keyFromUser = 'FromUser';
  static const String keyFromProfile = 'FromProfile';
  static const String keyPostId = 'PostId';
  static const String keyToUser = 'ToUser';
  static const String keyToProfile = 'ToProfile';
  static const String keyIsRead = 'isRead';
  static const String keyUsers = 'Users';
  HeartLike() : super(keyHeartLike);

  HeartLike.clone() : this();

  @override
  HeartLike clone(Map<String, dynamic> map) => HeartLike.clone()..fromJson(map);

  int get heartlike => get<int>(keyHeart)!;
  set heartlike(int? liplike) => set<int>(keyHeart, liplike!);

  UserLogin get fromUser => get<UserLogin>(keyFromUser)!;
  set fromUser(UserLogin? fromUserLogin) => set<UserLogin>(keyFromUser, fromUserLogin!);

  ProfilePage get fromProfile => get<ProfilePage>(keyFromProfile)!;
  set fromProfile(ProfilePage? fromUserLogin) => set<ProfilePage>(keyFromProfile, fromUserLogin!);

  UserPost get postId => get<UserPost>(keyPostId)!;
  set postId(UserPost? postId) => set<UserPost>(keyPostId, postId!);

  ProfilePage get toProfile => get<ProfilePage>(keyToProfile)!;
  set toProfile(ProfilePage? fromUserLogin) => set<ProfilePage>(keyToProfile, fromUserLogin!);

  UserLogin? get toUser => get<UserLogin>(keyToUser);
  set toUser(UserLogin? toUserLogin) => set<UserLogin>(keyToUser, toUserLogin!);

  bool? get isRead => get<bool>(keyIsRead);
  set isRead(bool? isRead) => set<bool>(keyIsRead, isRead!);
  List get users => get<List>(keyUsers)!;
  set users(List? users) => set<List>(keyUsers, users!);
}
