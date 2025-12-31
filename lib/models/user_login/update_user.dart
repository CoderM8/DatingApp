import 'dart:core';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UpdateUser extends ParseObject implements ParseCloneable {
  static const String keyUpdateUserDetails = 'Update_user';
  static const String keyOldGender = 'OldGender';
  static const String keyNewGender = 'NewGender';
  static const String keyOldBdate = 'OldBirthDate';
  static const String keyNewBdate = 'NewBirthDate';
  static const String keyUserPointer = 'User';
  static const String keyStatus = 'Status';
  UpdateUser() : super(keyUpdateUserDetails);

  UpdateUser.clone() : this();

  @override
  UpdateUser clone(Map<String, dynamic> map) => UpdateUser.clone()..fromJson(map);

  UserLogin? get user => get<UserLogin>(keyUserPointer);
  set user(UserLogin? user) => set<UserLogin>(keyUserPointer, user!);

  DateTime? get oldDate => get<DateTime>(keyOldBdate);
  set oldDate(DateTime? oldDate) => set<DateTime>(keyOldBdate, oldDate!);

  DateTime? get newDate => get<DateTime>(keyNewBdate);
  set newDate(DateTime? newDate) => set<DateTime>(keyNewBdate, newDate!);

  String? get oldGender => get<String>(keyOldGender);
  set oldGender(String? oldGender) => set<String>(keyOldGender, oldGender!);

  String? get newGender => get<String>(keyNewGender);
  set newGender(String? newGender) => set<String>(keyNewGender, newGender!);

  String? get status => get<String>(keyStatus);
  set status(String? status) => set<String>(keyStatus, status!);
}
