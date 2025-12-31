import 'dart:core';

import 'package:eypop/models/user_login/user_post.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';


//2gMsqZyuSG\\// kWjj90SF86 \\ C2RG52NbQ6 \\ W1FA3kkUHe \\ lifrxds6GA \\UGyAJA4pmk \\ b1auaxQsNM
class UserLogin extends ParseObject implements ParseCloneable {
  static const String keyUserLogin = 'User_login';
  static const String keyEmail = 'Email';
  static const String keyMNumber = 'MoNumber';
  static const String keyGender = 'Gender';
  static const String keyDob = 'BirthDate';
  static const String keyDefault = 'DefaultProfile';
  static const String keyLatestPost = 'UserPost';
  static const String keyDefaultLoginId = 'DefaultUser';
  static const String keyChatMessageCoin = 'ChatMessageCoin';
  static const String keyChatMessageToken = 'ChatMessageToken';
  static const String keyHeartLikeCoin = 'HeartLikeCoin';
  static const String keyHeartLikeToken = 'HeartLikeToken';
  static const String keyLipLikeCoin = 'LipLikeCoin';
  static const String keyLipLikeToken = 'LipLikeToken';
  static const String keyWinkMessageCoin = 'WinkMessageCoin';
  static const String keyWinkMessageToken = 'WinkMessageToken';
  static const String keyHeartMessageCoin = 'HeartMessageCoin';
  static const String keyHeartMessageToken = 'HeartMessageToken';
  static const String keyCallCoin = 'CallCoin';
  static const String keyCallToken = 'CallToken';
  static const String keyImageCoin = 'ImageCoin';
  static const String keyImageToken = 'ImageToken';
  static const String keyVideoCoin = 'VideoCoin';
  static const String keyVideoToken = 'VideoToken';
  static const String keyTotalCoin = 'TotalCoin';
  static const String keyTotalToken = 'TotalToken';
  static const String keyIsBusy = 'IsBusy';
  static const String keyNoChats = 'NoChats';
  static const String keyNoCalls = 'NoCalls';
  static const String keyNoVideocalls = 'NoVideocalls';
  static const String keyAutoDisconnectionChats = 'AutoDisconnectionChats';
  static const String keyAutoDisconnectionCalls = 'AutoDisconnectionCalls';
  static const String keyAutoDisconnectionVideoCalls = 'AutoDisconnectionVideoCalls';
  static const String keyInfluencerCall = 'InfluencerCall';
  static const String keyInfluencerVideocall = 'InfluencerVideocall';
  static const String keyHasLoggedIn = 'HasLoggedIn';
  static const String keyShowOnline = 'showOnline';
  static const String keyLastOnline = 'lastOnline';
  static const String keyLocationRadius = 'LocationRadius';
  static const String keyLocationGeoPoint = 'LocationGeoPoint';
  static const String keyLocationName = 'Location';

  static const String keyCall = "CallNotification";
  static const String keyChat = "ChatNotification";
  static const String keyWinkMessage = "WinkMessageNotification";
  static const String keyLipLike = "LipLikeNotification";
  static const String keyHeartLike = "HeartLikeNotification";
  static const String keyHeartMessage = "HeartMessageNotification";
  static const String keyVisit = "VisitNotification";
  static const String keyWish = "wishNotification";
  static const String keyGift = "GiftNotification";
  static const String keyOffer = "OfferNotification";
  static const String keyIsDeleted = "isDeleted";
  static const String keyLocal = "Local";
  static const String keyBlockStartDate = "BlockStartDate";
  static const String keyBlockDays = "BlockDays";
  static const String keyBlockEndDate = "BlockEndDate";
  static const String keyIpAddress = "IpAddress";
  static const String keyDeviceId = "DeviceId";
  static const String keyVersion = "Version";
  static const String keySendMail = "SendMail";
  static const String keyNowDate = "MailDate";
  UserLogin() : super(keyUserLogin);

  UserLogin.clone() : this();

  @override
  UserLogin clone(Map<String, dynamic> map) => UserLogin.clone()..fromJson(map);

  @override
  UserLogin fromJson(Map<String, dynamic> objectData) {
    super.fromJson(objectData);
    if (objectData.containsKey(keyDefault)) {
      defaultProfileId = ProfilePage.clone().fromJson(objectData[keyDefault]);
    }
    return this;
  }

  ProfilePage get defaultProfileId => get<ProfilePage>(keyDefault)!;
  set defaultProfileId(ProfilePage defaultProfileId) => set<ProfilePage>(keyDefault, defaultProfileId);

  ParseUser get userId => get<ParseUser>(keyDefaultLoginId)!;
  set userId(ParseUser defaultProfileId) => set<ParseUser>(keyDefaultLoginId, defaultProfileId);

  UserPost? get latestPost => get<UserPost>(keyLatestPost);
  set latestPost(UserPost? latestPost) => set<UserPost>(keyLatestPost, latestPost!);

  String? get email => get<String>(keyEmail);
  set email(String? email) => set<String>(keyEmail, email!);

  DateTime? get dob => get<DateTime>(keyDob);
  set dob(DateTime? dob) => set<DateTime>(keyDob, dob!);

  int? get number => get<int>(keyMNumber);
  set number(int? number) => set<int>(keyMNumber, number!);

  String? get gender => get<String>(keyGender);
  set gender(String? gender) => set<String>(keyGender, gender!);

  int? get chatMessageCoin => get<int>(keyChatMessageCoin);
  set chatMessageCoin(int? chatMessageCoin) => set<int>(keyChatMessageCoin, chatMessageCoin!);

  int? get chatMessageToken => get<int>(keyChatMessageToken);
  set chatMessageToken(int? chatMessageToken) => set<int>(keyChatMessageToken, chatMessageToken!);

  int? get heartLikeCoin => get<int>(keyHeartLikeCoin);
  set heartLikeCoin(int? heartLikeCoin) => set<int>(keyHeartLikeCoin, heartLikeCoin!);

  int? get heartLikeToken => get<int>(keyHeartLikeToken);
  set heartLikeToken(int? heartLikeToken) => set<int>(keyHeartLikeToken, heartLikeToken!);

  int? get imageCoin => get<int>(keyImageCoin);
  set imageCoin(int? imageCoin) => set<int>(keyImageCoin, imageCoin!);

  int? get imageToken => get<int>(keyImageToken);
  set imageToken(int? imageToken) => set<int>(keyImageToken, imageToken!);

  int? get videoCoin => get<int>(keyVideoCoin);
  set videoCoin(int? videoCoin) => set<int>(keyVideoCoin, videoCoin!);

  int? get videoToken => get<int>(keyVideoToken);
  set videoToken(int? videoToken) => set<int>(keyVideoToken, videoToken!);

  int? get lipLikeCoin => get<int>(keyLipLikeCoin);
  set lipLikeCoin(int? lipLikeCoin) => set<int>(keyLipLikeCoin, lipLikeCoin!);

  int? get lipLikeToken => get<int>(keyLipLikeToken);
  set lipLikeToken(int? lipLikeToken) => set<int>(keyLipLikeToken, lipLikeToken!);

  int? get winkMessageCoin => get<int>(keyWinkMessageCoin);
  set winkMessageCoin(int? winkMessageCoin) => set<int>(keyWinkMessageCoin, winkMessageCoin!);

  int? get winkMessageToken => get<int>(keyWinkMessageToken);
  set winkMessageToken(int? winkMessageToken) => set<int>(keyWinkMessageToken, winkMessageToken!);

  int? get heartMessageCoin => get<int>(keyHeartMessageCoin);
  set heartMessageCoin(int? heartMessageCoin) => set<int>(keyHeartMessageCoin, heartMessageCoin!);

  int? get heartMessageToken => get<int>(keyHeartMessageToken);
  set heartMessageToken(int? heartMessageToken) => set<int>(keyHeartMessageToken, heartMessageToken!);

  int? get callCoin => get<int>(keyCallCoin);
  set callCoin(int? callCoin) => set<int>(keyCallCoin, callCoin!);

  int? get callToken => get<int>(keyCallToken);
  set callToken(int? callToken) => set<int>(keyCallToken, callToken!);

  int? get totalCoin => get<int>(keyTotalCoin);
  set totalCoin(int? totalCoin) => set<int>(keyTotalCoin, totalCoin!);

  int? get totalToken => get<int>(keyTotalToken);
  set totalToken(int? totalToken) => set<int>(keyTotalToken, totalToken!);

  bool? get userisbusy => get<bool>(keyIsBusy);
  set userisbusy(bool? userisbusy) => set<bool>(keyIsBusy, userisbusy!);

  bool? get noCalls => get<bool>(keyNoCalls);
  set noCalls(bool? noCalls) => set<bool>(keyNoCalls, noCalls!);

  bool? get noChats => get<bool>(keyNoChats);
  set noChats(bool? noChats) => set<bool>(keyNoChats, noChats!);

  bool? get noVideocalls => get<bool>(keyNoVideocalls);
  set noVideocalls(bool? noVideocalls) => set<bool>(keyNoVideocalls, noVideocalls!);

  bool? get autoDisconnectionCalls => get<bool>(keyAutoDisconnectionCalls);
  set autoDisconnectionCalls(bool? autoDisconnectionCalls) => set<bool>(keyAutoDisconnectionCalls, autoDisconnectionCalls!);

  bool? get autoDisconnectionChats => get<bool>(keyAutoDisconnectionChats);
  set autoDisconnectionChats(bool? autoDisconnectionChats) => set<bool>(keyAutoDisconnectionChats, autoDisconnectionChats!);

  bool? get autoDisconnectionVideoCalls => get<bool>(keyAutoDisconnectionVideoCalls);
  set autoDisconnectionVideoCalls(bool? autoDisconnectionVideoCalls) => set<bool>(keyAutoDisconnectionVideoCalls, autoDisconnectionVideoCalls!);

  bool? get influencerCall => get<bool>(keyInfluencerCall);
  set influencerCall(bool? influencerCall) => set<bool>(keyInfluencerCall, influencerCall!);

  bool? get influencerVideocall => get<bool>(keyInfluencerVideocall);
  set influencerVideocall(bool? influencerVideocall) => set<bool>(keyInfluencerVideocall, influencerVideocall!);

  bool? get showOnline => get<bool>(keyShowOnline);
  set showOnline(bool? showOnline) => set<bool>(keyShowOnline, showOnline!);

  bool? get hasLoggedIn => get<bool>(keyHasLoggedIn);
  set hasLoggedIn(bool? hasLoggedIn) => set<bool>(keyHasLoggedIn, hasLoggedIn!);

  DateTime? get lastOnline => get<DateTime>(keyLastOnline);
  set lastOnline(DateTime? lastOnline) => set<DateTime>(keyLastOnline, lastOnline!);

  String get locationRadius => get<String>(keyLocationRadius)!;
  set locationRadius(String? location) => set(keyLocationRadius, location!);

  ParseGeoPoint get locationGeoPoint => get<ParseGeoPoint>(keyLocationGeoPoint)!;
  set locationGeoPoint(ParseGeoPoint? location) => set(keyLocationGeoPoint, location!);

  String get locationName => get<String>(keyLocationName)!;
  set locationName(String? location) => set(keyLocationName, location!);

  String get local => get<String>(keyLocal)!;
  set local(String? local) => set(keyLocal, local!);

  bool? get call => get<bool>(keyCall);
  set call(bool? call) => set<bool>(keyCall, call!);

  bool? get chat => get<bool>(keyChat);
  set chat(bool? chat) => set<bool>(keyChat, chat!);

  bool? get winkMessage => get<bool>(keyWinkMessage);
  set winkMessage(bool? winkMessage) => set<bool>(keyWinkMessage, winkMessage!);

  bool? get lipLike => get<bool>(keyLipLike);
  set lipLike(bool? lipLike) => set<bool>(keyLipLike, lipLike!);

  bool? get heartLike => get<bool>(keyHeartLike);
  set heartLike(bool? smile) => set<bool>(keyHeartLike, smile!);

  bool? get gift => get<bool>(keyGift);
  set gift(bool? gift) => set<bool>(keyGift, gift!);

  bool? get heartMessage => get<bool>(keyHeartMessage);
  set heartMessage(bool? heartMessage) => set<bool>(keyHeartMessage, heartMessage!);

  bool? get visit => get<bool>(keyVisit);
  set visit(bool? visit) => set<bool>(keyVisit, visit!);

  bool? get wish => get<bool>(keyWish);
  set wish(bool? wish) => set<bool>(keyWish, wish!);

  bool? get isDeleted => get<bool>(keyIsDeleted);
  set isDeleted(bool? isDeleted) => set<bool>(keyIsDeleted, isDeleted!);

  bool? get offer => get<bool>(keyOffer);
  set offer(bool? offer) => set<bool>(keyOffer, offer!);

  DateTime? get blockStartDat => get<DateTime>(keyBlockStartDate);
  set blockStartDat(DateTime? blockStartDat) => set<DateTime>(keyBlockStartDate, blockStartDat!);

  String get blockDays => get<String>(keyBlockDays)!;
  set blockDays(String? blockDays) => set(keyBlockDays, blockDays!);

  List get deviceId => get<List>(keyDeviceId)!;
  set deviceId(List? deviceId) => set<List>(keyDeviceId, deviceId!);

  List get ipAddress => get<List>(keyIpAddress)!;
  set ipAddress(List? ipAddress) => set<List>(keyIpAddress, ipAddress!);

  String get version => get<String>(keyVersion)!;
  set version(String? version) => set<String>(keyVersion, version!);

  DateTime? get blockEndDate => get<DateTime>(keyBlockEndDate);
  set blockEndDate(DateTime? blockEndDate) => set<DateTime>(keyBlockEndDate, blockEndDate!);

  bool? get sendMail => get<bool>(keySendMail);
  set sendMail(bool? sendMail) => set<bool>(keySendMail, sendMail!);

  DateTime? get nowDate => get<DateTime>(keyNowDate);
  set nowDate(DateTime? nowDate) => set<DateTime>(keyNowDate, nowDate!);
}
