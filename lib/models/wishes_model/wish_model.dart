import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_post.dart';
import 'package:eypop/models/user_login/user_postvideo.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/models/wishes_model/toktok_model.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class WishModel extends ParseObject implements ParseCloneable {
  static const String keyWish = 'Users_Wish';
  static const String keyProfile = 'Profile';
  static const String keyUser = 'User';
  static const String keyWishList = 'Wish_List';
  static const String keyPost = 'Post';
  static const String keyTime = 'Time';
  static const String keyIsVisible = 'IsVisible';
  static const String keyStatus = 'Status';
  static const String keyGender = 'Gender';
  static const String keyType = 'Type';
  static const String keyVideoThumbnail = 'VideoThumbnail';
  static const String keyIsNude = 'IsNude';
  static const String keyTokTok = 'TokTok';
  static const String keyImgPost = 'Img_Post';
  static const String keyVideoPost = 'Video_Post';
  WishModel() : super(keyWish);

  WishModel.clone() : this();
  @override
  WishModel clone(Map<String, dynamic> map) => WishModel.clone()..fromJson(map);

  UserLogin get user => get<UserLogin>(keyUser)!;
  set user(UserLogin user) => set<UserLogin>(keyUser, user);

  ProfilePage get profile => get<ProfilePage>(keyProfile)!;
  set profile(ProfilePage profile) => set<ProfilePage>(keyProfile, profile);

  TokTokModel get tokTok => get<TokTokModel>(keyTokTok)!;
  set tokTok(TokTokModel tokTok) => set<TokTokModel>(keyTokTok, tokTok);

  UserPost get imgPost => get<UserPost>(keyImgPost)!;
  set imgPost(UserPost imgPost) => set<UserPost>(keyImgPost, imgPost);

  UserPostVideo get videoPost => get<UserPostVideo>(keyVideoPost)!;
  set videoPost(UserPostVideo videoPost) => set<UserPostVideo>(keyVideoPost, videoPost);

  List get wishList => get<List>(keyWishList)!;
  set wishList(List? wishList) => set<List>(keyWishList, wishList!);

  String get time => get<String>(keyTime)!;
  set time(String? time) => set<String>(keyTime, time!);

  String get gender => get<String>(keyGender)!;
  set gender(String? gender) => set<String>(keyGender, gender!);

  ParseFileBase get post => get<ParseFileBase>(keyPost)!;
  set post(ParseFileBase? post) => set(keyPost, post!);

  bool get isVisible => get<bool>(keyIsVisible)!;
  set isVisible(bool? isVisible) => set(keyIsVisible, isVisible!);

  bool get isNude => get<bool>(keyIsNude)!;
  set isNude(bool? isNude) => set(keyIsNude, isNude!);

  int get status => get<int>(keyStatus)!;
  set status(int? status) => set(keyStatus, status!);

  String get postType => get<String>(keyType)!;
  set postType(String? postType) => set<String>(keyType, postType!);

  ParseFileBase get thumbnail => get<ParseFileBase>(keyVideoThumbnail)!;
  set thumbnail(ParseFileBase? thumbnail) => set(keyVideoThumbnail, thumbnail!);
}
