import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class DownloadModel extends ParseObject implements ParseCloneable {
  static const String keyDownload = 'Downloads';
  static const String keyProfile = 'User_Profile';
  static const String keyUser = 'User_Login';
  static const String keyStars = 'Stars';
  static const String keyType = 'Type';
  static const String keyFile = 'File';
  DownloadModel() : super(keyDownload);

  DownloadModel.clone() : this();
  @override
  DownloadModel clone(Map<String, dynamic> map) => DownloadModel.clone()..fromJson(map);

  UserLogin get user => get<UserLogin>(keyUser)!;
  set user(UserLogin user) => set<UserLogin>(keyUser, user);

  ProfilePage get profile => get<ProfilePage>(keyProfile)!;
  set profile(ProfilePage profile) => set<ProfilePage>(keyProfile, profile);

  String get type => get<String>(keyType)!;
  set type(String? type) => set<String>(keyType, type!);

  int get stars => get<int>(keyStars)!;
  set stars(int? stars) => set(keyStars, stars!);

  ParseFileBase get file => get<ParseFileBase>(keyFile)!;
  set file(ParseFileBase? file) => set(keyFile, file!);
}
