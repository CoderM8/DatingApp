import 'dart:core';

import 'package:eypop/models/user_login/user_login.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../user_login/user_profile.dart';

class ChatMessage extends ParseObject implements ParseCloneable {
  static const String keyChatMessage = 'Chat_Message';
  static const String keyToProfile = 'ToProfile';
  static const String keyFromProfile = 'FromProfile';
  static const String keyMessage = 'Message';
  static const String keyMTime = 'MessageTime';
  static const String keyFromUser = 'FromUser';
  static const String keyToUser = 'ToUser';
  static const String keyIsRead = 'isRead';
  static const String keyIsPurchased = 'isPurchased';
  static const String keyUsers = 'Users';
  ChatMessage() : super(keyChatMessage);
  ChatMessage.clone() : this();

  @override
  ChatMessage clone(Map<String, dynamic> map) => ChatMessage.clone()..fromJson(map);

  @override
  ChatMessage fromJson(Map<String, dynamic> objectData) {
    super.fromJson(objectData);
    if (objectData.containsKey(keyToProfile)) {
      toProfile = ProfilePage.clone().fromJson(objectData[keyToProfile]);
    }
    return this;
  }

  ProfilePage get toProfile => get<ProfilePage>(keyToProfile)!;
  set toProfile(ProfilePage userId) => set<ProfilePage>(keyToProfile, userId);

  String? get objectid => get<String>('objectId');

  ProfilePage get fromProfile => get<ProfilePage>(keyFromProfile)!;
  set fromProfile(ProfilePage fromUser) => set<ProfilePage>(keyFromProfile, fromUser);

  String? get message => get<String>(keyMessage);
  set message(String? password) => set<String>(keyMessage, password!);

  String? get time => get<String>(keyMTime);
  set time(String? number) => set<String>(keyMTime, number!);

  List get users => get<List>(keyUsers)!;
  set users(List? users) => set<List>(keyUsers, users!);

  UserLogin? get fromUser => get<UserLogin>(keyFromUser);
  set fromUser(UserLogin? fromUserLogin) => set<UserLogin>(keyFromUser, fromUserLogin!);

  UserLogin? get toUser => get<UserLogin>(keyToUser);
  set toUser(UserLogin? toUserLogin) => set<UserLogin>(keyToUser, toUserLogin!);

  bool? get isRead => get<bool>(keyIsRead);
  set isRead(bool? isRead) => set<bool>(keyIsRead, isRead!);

  bool? get isPurchased => get<bool>(keyIsPurchased);
  set isPurchased(bool? isPurchased) => set<bool>(keyIsPurchased, isPurchased!);
}
