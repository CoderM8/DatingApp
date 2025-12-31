import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_postvideo.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class PurchaseVideo extends ParseObject implements ParseCloneable {
  static const String keyPost = 'Purchase_Video';
  static const String keyVideoPost = 'Post';
  static const String keyToProfileId = 'ToProfile';
  static const String keyToUserId = 'ToUser';
  static const String keyFromProfileId = 'FromProfile';
  static const String keyFromUserId = 'FromUser';
  PurchaseVideo() : super(keyPost);

  PurchaseVideo.clone() : this();

  @override
  PurchaseVideo clone(Map<String, dynamic> map) => PurchaseVideo.clone()..fromJson(map);

  UserLogin get touserId => get<UserLogin>(keyToUserId)!;
  set touserId(UserLogin touserId) => set<UserLogin>(keyToUserId, touserId);

  ProfilePage get toprofileId => get<ProfilePage>(keyToProfileId)!;
  set toprofileId(ProfilePage toprofileId) => set<ProfilePage>(keyToProfileId, toprofileId);

  UserLogin get fromuserId => get<UserLogin>(keyFromUserId)!;
  set fromuserId(UserLogin fromuserId) => set<UserLogin>(keyFromUserId, fromuserId);

  ProfilePage get fromprofileId => get<ProfilePage>(keyFromProfileId)!;
  set fromprofileId(ProfilePage fromprofileId) => set<ProfilePage>(keyFromProfileId, fromprofileId);

  UserPostVideo get videoPost => get<UserPostVideo>(keyVideoPost)!;
  set videoPost(UserPostVideo? videoPost) => set(keyVideoPost, videoPost!);
}
