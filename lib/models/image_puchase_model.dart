import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_post.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';


class PurchaseImage extends ParseObject implements ParseCloneable {
 static const String keyPost = 'Purchase_Img';
 static const String keyImgPost = 'Post';
 static const String keyToProfileId = 'ToProfile';
 static const String keyToUserId = 'ToUser';
 static const String keyFromProfileId = 'FromProfile';
 static const String keyFromUserId = 'FromUser';
  PurchaseImage() : super(keyPost);

  PurchaseImage.clone() : this();

  @override
  PurchaseImage clone(Map<String, dynamic> map) =>
      PurchaseImage.clone()..fromJson(map);

  UserLogin get touserId => get<UserLogin>(keyToUserId)!;
  set touserId(UserLogin touserId) => set<UserLogin>(keyToUserId, touserId);

  ProfilePage get toprofileId => get<ProfilePage>(keyToProfileId)!;
  set toprofileId(ProfilePage toprofileId) =>
      set<ProfilePage>(keyToProfileId, toprofileId);

  UserLogin get fromuserId => get<UserLogin>(keyFromUserId)!;
  set fromuserId(UserLogin fromuserId) =>
      set<UserLogin>(keyFromUserId, fromuserId);

  ProfilePage get fromprofileId => get<ProfilePage>(keyFromProfileId)!;
  set fromprofileId(ProfilePage fromprofileId) =>
      set<ProfilePage>(keyFromProfileId, fromprofileId);

  UserPost get imgPost => get<UserPost>(keyImgPost)!;
  set imgPost(UserPost? imgPost) => set(keyImgPost, imgPost!);
}
