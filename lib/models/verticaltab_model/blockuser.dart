import 'package:eypop/models/user_login/user_post.dart';
import 'package:eypop/models/user_login/user_postvideo.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../user_login/user_login.dart';
import '../user_login/user_profile.dart';

class BlockUser extends ParseObject implements ParseCloneable {
  static const String keyBlock = 'Block_User';
  static const String keyEmail = 'Email';
  static const String keyFromUser = 'FromUser';
  static const String keyToUser = 'ToUser';
  static const String keyType = 'Type';
  static const String keyPostType = 'PostType';
  static const String keyFromProfile = 'FromProfile';
  static const String keyToProfile = 'ToProfile';
  static const String keyUsers = 'Users';
  static const String keyImage = 'Image';
  static const String keyVideo = 'Video';
  BlockUser() : super(keyBlock);

  BlockUser.clone() : this();

  @override
  BlockUser clone(Map<String, dynamic> map) => BlockUser.clone()..fromJson(map);

  String get emailuser => get<String>(keyEmail)!;
  set emailuser(String? emailuser) => set<String>(keyEmail, emailuser!);

  UserLogin? get fromUser => get<UserLogin>(keyFromUser);
  set fromUser(UserLogin? fromUserLogin) => set<UserLogin>(keyFromUser, fromUserLogin!);

  UserLogin? get toUser => get<UserLogin>(keyToUser);
  set toUser(UserLogin? toUserLogin) => set<UserLogin>(keyToUser, toUserLogin!);

  ProfilePage? get fromProfile => get<ProfilePage>(keyFromProfile);
  set fromProfile(ProfilePage? fromUserLogin) => set<ProfilePage>(keyFromProfile, fromUserLogin!);

  UserPost? get image => get<UserPost>(keyImage);
  set image(UserPost? image) => set<UserPost>(keyImage, image!);

  UserPostVideo? get video => get<UserPostVideo>(keyVideo);
  set video(UserPostVideo? video) => set<UserPostVideo>(keyVideo, video!);

  String? get type => get<String>(keyType);
  set type(String? type) => set<String>(keyType, type!);

  String? get postType => get<String>(keyPostType);
  set postType(String? postType) => set<String>(keyPostType, postType!);

  ProfilePage? get toProfile => get<ProfilePage>(keyToProfile);
  set toProfile(ProfilePage? toUserLogin) => set<ProfilePage>(keyToProfile, toUserLogin!);

  List get users => get<List>(keyUsers)!;
  set users(List? users) => set<List>(keyUsers, users!);
}
