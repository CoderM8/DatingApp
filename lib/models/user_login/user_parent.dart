import 'dart:core';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UserParent extends ParseObject implements ParseCloneable {
  static const String keyUserParent = '_User';
  static const String keyPhoneNumber = 'phone_number';
  static const String keyFullPhoneNumber = 'phone_number_full';
  static const String keyCountryCode = 'country_dial_code';
  static const String keyAuthData = 'authData';
  static const String keyUserName = 'username';
  static const String keyPassword = 'password';
  static const String keyEmail = 'email';
  UserParent() : super(keyUserParent);

  UserParent.clone() : this();

  @override
  UserParent clone(Map<String, dynamic> map) => UserParent.clone()..fromJson(map);

  String? get phone => get<String>(keyPhoneNumber);
  set phone(String? phone) => set<String>(keyPhoneNumber, phone!);

  String? get fullPhone => get<String>(keyFullPhoneNumber);
  set fullPhone(String? fullPhone) => set<String>(keyFullPhoneNumber, fullPhone!);

  String? get country => get<String>(keyCountryCode);
  set country(String? country) => set<String>(keyCountryCode, country!);

  String? get authData => get<String>(keyAuthData);
  set authData(String? authData) => set<String>(keyAuthData, authData!);

  String? get username => get<String>(keyUserName);
  set username(String? username) => set<String>(keyUserName, username!);

  String? get password => get<String>(keyPassword);
  set password(String? password) => set<String>(keyPassword, password!);

  String? get email => get<String>(keyEmail);
  set email(String? email) => set<String>(keyEmail, email!);
}
