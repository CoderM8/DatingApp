import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UserPostVideo extends ParseObject implements ParseCloneable {
  static const String keyPostVideo = 'Video_Post';
  static const String keyVideoPost = 'Post';
  static const String keyVideoThumbnail = 'PostThumbnail';
  static const String keyVideoProfileId = 'Profile';
  static const String keyVideoUser = 'User';
  static const String keyVideoType = 'Type';
  static const String keyStatus = 'Status';
  static const String keyIsNude = 'IsNude';
  static const String keyAccountType = 'AccountType';
  UserPostVideo() : super(keyPostVideo);

  UserPostVideo.clone() : this();

  @override
  UserPostVideo clone(Map<String, dynamic> map) => UserPostVideo.clone()..fromJson(map);

  @override
  UserPostVideo fromJson(Map<String, dynamic> objectData) {
    super.fromJson(objectData);
    if (objectData.containsKey(keyVideoProfileId)) {
      profileId = ProfilePage.clone().fromJson(objectData[keyVideoProfileId]);
    }
    return this;
  }

  ProfilePage get profileId => get<ProfilePage>(keyVideoProfileId)!;
  set profileId(ProfilePage profileId) => set<ProfilePage>(keyVideoProfileId, profileId);

  UserLogin get userId => get<UserLogin>(keyVideoProfileId)!;
  set userId(UserLogin userId) => set<UserLogin>(keyVideoUser, userId);

  ParseFileBase get videoPost => get<ParseFileBase>(keyVideoPost)!;
  set videoPost(ParseFileBase? videoPost) => set(keyVideoPost, videoPost!);

  ParseFileBase get videoPostThumbnail => get<ParseFileBase>(keyVideoThumbnail)!;
  set videoPostThumbnail(ParseFileBase? videoPostThumbnail) => set(keyVideoThumbnail, videoPostThumbnail!);

  String get type => get<String>(keyVideoType)!;
  set type(String? type) => set(keyVideoType, type!);

  String get accountType => get<String>(keyAccountType)!;
  set accountType(String? accountType) => set(keyAccountType, accountType!);

  bool get status => get<bool>(keyStatus)!;
  set status(bool? status) => set(keyStatus, status);

  bool get isNude => get<bool>(keyIsNude)!;
  set isNude(bool? isNude) => set(keyIsNude, isNude);
}
