import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../user_login/user_login.dart';
import '../user_login/user_profile.dart';

class TokTokModel extends ParseObject implements ParseCloneable {
 static const String keyTokTok = 'TokTok';
 static const String keyProfile = 'User_Profile';
 static const String keyUser = 'User_Login';
 static const String keyWishList = 'Wish_List';
 static const String keyTime = 'Time';
 static const String keyIsVisible = 'IsVisible';
 static const String keyGender = 'Gender';
 static const String keyTelephone = 'Telephone';
 static const String keyWhatsapp = 'Whatsapp';
 static const String keyInstagram = 'Instagram';
 static const String keyFacebook = 'Facebook';
 static const String keyTelegram = 'Telegram';
 static const String keyOnlyFans = 'OnlyFans';
 static const String keySkype = 'Skype';
 static const String keyTelephoneEnable = 'Telephone_Enable';
 static const String keyWhatsappEnable = 'Whatsapp_Enable';
 static const String keyInstagramEnable = 'Instagram_Enable';
 static const String keyFacebookEnable = 'Facebook_Enable';
 static const String keyTelegramEnable = 'Telegram_Enable';
 static const String keyOnlyFansEnable = 'OnlyFans_Enable';
 static const String keySkypeEnable = 'Skype_Enable';
 static const String keyTelephoneDialCode = 'Telephone_DialCode';
 static const String keyWhatsappDialCode = 'Whatsapp_DialCode';
 static const String keyPhoneNumberDate = 'PhoneNumberDate';
  TokTokModel() : super(keyTokTok);

  TokTokModel.clone() : this();

  @override
  TokTokModel clone(Map<String, dynamic> map) => TokTokModel.clone()..fromJson(map);

  UserLogin get user => get<UserLogin>(keyUser)!;

  set user(UserLogin user) => set<UserLogin>(keyUser, user);

  ProfilePage get profile => get<ProfilePage>(keyProfile)!;

  set profile(ProfilePage profile) => set<ProfilePage>(keyProfile, profile);

  List get wishList => get<List>(keyWishList)!;

  set wishList(List? wishList) => set<List>(keyWishList, wishList!);

  String get time => get<String>(keyTime)!;

  set time(String? time) => set<String>(keyTime, time!);

  String get gender => get<String>(keyGender)!;

  set gender(String? gender) => set<String>(keyGender, gender!);

  String get telephoneDiaCode => get<String>(keyTelephoneDialCode)!;

  set telephoneDiaCode(String? telephoneDiaCode) => set<String>(keyTelephoneDialCode, telephoneDiaCode!);

  String get whatsappDiaCode => get<String>(keyWhatsappDialCode)!;

  set whatsappDiaCode(String? whatsappDiaCode) => set<String>(keyWhatsappDialCode, whatsappDiaCode!);

  bool get isVisible => get<bool>(keyIsVisible)!;

  set isVisible(bool? isVisible) => set(keyIsVisible, isVisible!);

  String get telephone => get<String>(keyTelephone)!;

  set telephone(String? telephone) => set<String>(keyTelephone, telephone!);

  String get whatsapp => get<String>(keyWhatsapp)!;

  set whatsapp(String? whatsapp) => set<String>(keyWhatsapp, whatsapp!);

  String get instagram => get<String>(keyInstagram)!;

  set instagram(String? instagram) => set<String>(keyInstagram, instagram!);

  String get facebook => get<String>(keyFacebook)!;

  set facebook(String? facebook) => set<String>(keyFacebook, facebook!);

  String get telegram => get<String>(keyTelegram)!;

  set telegram(String? telegram) => set<String>(keyTelegram, telegram!);

  String get onlyfans => get<String>(keyOnlyFans)!;

  set onlyfans(String? onlyfans) => set<String>(keyOnlyFans, onlyfans!);

  String get skype => get<String>(keySkype)!;

  set skype(String? skype) => set<String>(keySkype, skype!);

  bool get isWhatsappEnable => get<bool>(keyWhatsappEnable)!;

  set isWhatsappEnable(bool? isWhatsappEnable) => set(keyWhatsappEnable, isWhatsappEnable!);

  bool get isInstagramEnable => get<bool>(keyInstagramEnable)!;

  set isInstagramEnable(bool? isInstagramEnable) => set(keyInstagramEnable, isInstagramEnable!);

  bool get isTelephoneEnable => get<bool>(keyTelephoneEnable)!;

  set isTelephoneEnable(bool? isTelephoneEnable) => set(keyTelephoneEnable, isTelephoneEnable!);

  bool get isFacebookEnable => get<bool>(keyFacebookEnable)!;

  set isFacebookEnable(bool? isFacebookEnable) => set(keyFacebookEnable, isFacebookEnable!);

  bool get isTelegramEnable => get<bool>(keyTelegramEnable)!;

  set isTelegramEnable(bool? isTelegramEnable) => set(keyTelegramEnable, isTelegramEnable!);

  bool get isOnlyFansEnable => get<bool>(keyOnlyFansEnable)!;

  set isOnlyFansEnable(bool? isOnlyFansEnable) => set(keyOnlyFansEnable, isOnlyFansEnable!);

  bool get isSkypeEnable => get<bool>(keySkypeEnable)!;

  set isSkypeEnable(bool? isSkypeEnable) => set(keySkypeEnable, isSkypeEnable!);

  DateTime get phoneNumberDate => get<DateTime>(keyPhoneNumberDate)!;

  set phoneNumberDate(DateTime? phoneNumberDate) => set(keyPhoneNumberDate, phoneNumberDate!);
}
