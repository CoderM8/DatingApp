import 'package:eypop/models/new_notification/new_notification_pair.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../user_login/user_login.dart';

class CallModel extends ParseObject implements ParseCloneable {
  static const String keyChatMessage = 'Calls';
  static const String keyToUser = 'ToUser';
  static const String keyToUserId = 'ToProfile';
  static const String keyFromUser = 'FromUser';
  static const String keyFromUserId = 'FromProfile';
  static const String keyCallReason = 'Reason';
  static const String keyStatus = 'Status';
  static const String keyIsVoiceCall = 'IsVoiceCall';
  static const String keyCallDuration = 'CallDuration';
  static const String keyCallAccepted = 'Accepted';
  static const String keyCallChannelName = 'ChannelName';
  static const String keyCallerType = 'CallerType';
  static const String keyCallEnd = 'IsCallEnd';
  static const String keyIsRead = 'isRead';
  static const String keyUsers = 'Users';
  static const String keyPairNotification = 'PairNotification';
  CallModel() : super(keyChatMessage);

  CallModel.clone() : this();

  static CallModel convertParseObjectToDietPlan(ParseObject object) {
    var callModel = CallModel();
    callModel.toUser = object[keyToUser];
    callModel.toUserID = object[keyToUserId];
    callModel.fromUser = object[keyFromUser];
    callModel.fromUserId = object[keyFromUserId];
    callModel.reason = object[keyCallReason];
    callModel.isVoice = object[keyIsVoiceCall];
    callModel.duration = object[keyCallDuration];
    callModel.accepted = object[keyCallAccepted];
    callModel.channelName = object[keyCallChannelName];
    callModel.callerType = object[keyCallerType];
    callModel.isCallEnd = object[keyCallEnd];
    callModel.isRead = object[keyIsRead];
    callModel.users = object[keyUsers];
    callModel.status = object[keyStatus];
    return callModel;
  }

  @override
  CallModel clone(Map<String, dynamic> map) => CallModel.clone()..fromJson(map);

  UserLogin? get toUser => get<UserLogin>(keyToUser);
  set toUser(UserLogin? toUser) => set<UserLogin>(keyToUser, toUser!);

  ProfilePage? get toUserId => get<ProfilePage>(keyToUserId);
  set toUserID(ProfilePage? toUserId) => set<ProfilePage>(keyToUserId, toUserId!);

  UserLogin? get fromUser => get<UserLogin>(keyFromUser);
  set fromUser(UserLogin? fromUser) => set<UserLogin>(keyFromUser, fromUser!);

  ProfilePage? get fromUserId => get<ProfilePage>(keyFromUserId);
  set fromUserId(ProfilePage? fromUserId) => set<ProfilePage>(keyFromUserId, fromUserId!);

  String? get reason => get<String>(keyCallReason);
  set reason(String? reason) => set<String>(keyCallReason, reason!);

  int? get status => get<int>(keyStatus);
  set status(int? status) => set<int>(keyStatus, status!);

  bool? get isVoice => get<bool>(keyIsVoiceCall);
  set isVoice(bool? voice) => set<bool>(keyIsVoiceCall, voice!);

  String? get duration => get<String>(keyCallDuration);
  set duration(String? duration) => set<String>(keyCallDuration, duration!);

  bool? get accepted => get<bool>(keyCallAccepted);
  set accepted(bool? accept) => set<bool>(keyCallAccepted, accept!);

  String? get channelName => get<String>(keyCallChannelName);
  set channelName(String? channelName) => set<String>(keyCallChannelName, channelName!);

  String? get callerType => get<String>(keyCallerType);
  set callerType(String? callerType) => set<String>(keyCallerType, callerType!);

  bool? get isCallEnd => get<bool>(keyCallEnd);
  set isCallEnd(bool? callEnd) => set<bool>(keyCallEnd, callEnd!);

  bool? get isRead => get<bool>(keyIsRead);
  set isRead(bool? isRead) => set<bool>(keyIsRead, isRead!);

  List get users => get<List>(keyUsers)!;
  set users(List? users) => set<List>(keyUsers, users!);

  PairNotifications get pairNotification => get<PairNotifications>(keyPairNotification)!;
  set pairNotification(PairNotifications? pairNotification) => set<PairNotifications>(keyPairNotification, pairNotification!);
}
