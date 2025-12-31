import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UserPost extends ParseObject implements ParseCloneable {
  static const String keyPost = 'Img_Post';
  static const String keyImgPost = 'Post';
  static const String keyProfileId = 'Profile';
  static const String keyUserId = 'User';
  static const String keyType = 'Type';
  static const String keyIsNude = 'IsNude';
  static const String keyStatus = 'Status';
  static const String keyAccountType = 'AccountType';
  UserPost() : super(keyPost);

  UserPost.clone() : this();

  @override
  UserPost clone(Map<String, dynamic> map) => UserPost.clone()..fromJson(map);

  @override
  UserPost fromJson(Map<String, dynamic> objectData) {
    super.fromJson(objectData);
    if (objectData.containsKey(keyProfileId)) {
      profileId = ProfilePage.clone().fromJson(objectData[keyProfileId]);
    }
    return this;
  }

  UserLogin get userId => get<UserLogin>(keyUserId)!;
  set userId(UserLogin userLogin) => set<UserLogin>(keyUserId, userLogin);

  ProfilePage get profileId => get<ProfilePage>(keyProfileId)!;
  set profileId(ProfilePage profileId) => set<ProfilePage>(keyProfileId, profileId);

  ParseFileBase get imgPost => get<ParseFileBase>(keyImgPost)!;
  set imgPost(ParseFileBase? imgPost) => set(keyImgPost, imgPost!);

  String get type => get<String>(keyType)!;
  set type(String? type) => set(keyType, type!);

  String get accountType => get<String>(keyAccountType)!;
  set accountType(String? accountType) => set(keyAccountType, accountType!);

  bool get isNude => get<bool>(keyIsNude)!;
  set isNude(bool? isNude) => set(keyIsNude, isNude!);

  bool get status => get<bool>(keyStatus)!;
  set status(bool? status) => set(keyStatus, status!);
}
