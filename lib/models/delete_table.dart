import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class DeleteConnection extends ParseObject implements ParseCloneable {

static const String keyDeleteConnection = 'DeleteConversion';
static const String keyType = 'Type';
static const String keyFromUser = 'FromUser';
static const String keyToUser = 'ToUser';
static const String keyFromProfile = 'FromProfile';
static const String keyToProfile = 'ToProfile';
  DeleteConnection() : super(keyDeleteConnection);

  DeleteConnection.clone() : this();

  @override
  DeleteConnection clone(Map<String, dynamic> map) => DeleteConnection.clone()..fromJson(map);

  String get type => get<String>(keyType)!;
  set type(String? type) => set<String>(keyType, type!);

  UserLogin? get fromUser => get<UserLogin>(keyFromUser);
  set fromUser(UserLogin? fromUserLogin) => set<UserLogin>(keyFromUser, fromUserLogin!);

  UserLogin? get toUser => get<UserLogin>(keyToUser);
  set toUser(UserLogin? toUserLogin) => set<UserLogin>(keyToUser, toUserLogin!);

  ProfilePage? get fromProfile => get<ProfilePage>(keyFromProfile);
  set fromProfile(ProfilePage? fromUserLogin) => set<ProfilePage>(keyFromProfile, fromUserLogin!);

  ProfilePage? get toProfile => get<ProfilePage>(keyToProfile);
  set toProfile(ProfilePage? toUserLogin) => set<ProfilePage>(keyToProfile, toUserLogin!);
}
