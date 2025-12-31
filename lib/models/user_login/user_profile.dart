import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_post.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ProfilePage extends ParseObject implements ParseCloneable {
  static const String keyProfile = 'User_Profile';
  static const String keyName = 'Name';
  static const String keyDescription = 'Description';
  static const String keyLanguage = 'Language';
  static const String keyLocationName = 'Location';
  static const String keyLatitude = 'Latitude';
  static const String keyLongitude = 'Longitude';
  static const String keyLocationRadius = 'LocationRadius';
  static const String keyCountryCode = 'CountryCode';
  static const String keyLocationGeoPoint = 'LocationGeoPoint';
  static const String keyImgProfile = 'Imgprofile';
  static const String keyDefaultImg = 'DefaultImg';
  static const String keyDefaultImgUrl = 'DefaultImgUrl';
  static const String keyOwner = 'User';
  static const String keyGender = 'Gender';
  static const String keyIsDeleted = 'isDeleted';
  static const String keyIsBlocked = 'IsBlocked';
  static const String keyReachProfile = 'ReachProfile';
  static const String keyAccountType = 'AccountType';
  static const String keyImgStatus = 'img_status';
  static const String keyMedal = 'Medal';
  static const String keyNoCalls = 'NoCalls';
  static const String keyNoVideocalls = 'NoVideocalls';
  static const String keyNoChats = 'NoChats';
  static const String keyAutoDisconnectionChats = 'AutoDisconnectionChats';
  static const String keyAutoDisconnectionCalls = 'AutoDisconnectionCalls';
  static const String keyAutoDisconnectionVideoCalls = 'AutoDisconnectionVideoCalls';
  static const String keyDemo = 'Demo';

  ProfilePage() : super(keyProfile);

  ProfilePage.clone() : this();

  @override
  ProfilePage clone(Map<String, dynamic> map) => ProfilePage.clone()..fromJson(map);

  @override
  ProfilePage fromJson(Map<String, dynamic> objectData) {
    super.fromJson(objectData);
    if (objectData.containsKey(keyOwner)) {
      userId = UserLogin.clone().fromJson(objectData[keyOwner]);
    }
    return this;
  }

  UserLogin get userId => get<UserLogin>(keyOwner)!;
  set userId(UserLogin userId) => set<UserLogin>(keyOwner, userId);

  String get name => get<String>(keyName)!;
  set name(String? name) => set<String>(keyName, name!);

  String get description => get<String>(keyDescription)!;
  set description(String? description) => set<String>(keyDescription, description!);

  List get language => get<List>(keyLanguage)!;
  set language(List? language) => set<List>(keyLanguage, language!);

  String get locationName => get<String>(keyLocationName)!;
  set locationName(String? location) => set(keyLocationName, location!);

  String get latitude => get<String>(keyLatitude)!;
  set latitude(String? location) => set(keyLatitude, location!);

  String get longitude => get<String>(keyLongitude)!;
  set longitude(String? location) => set(keyLongitude, location!);

  String get medal => get<String>(keyMedal)!;
  set medal(String? medal) => set(keyMedal, medal!);

  String get locationRadius => get<String>(keyLocationRadius)!;
  set locationRadius(String? location) => set(keyLocationRadius, location!);

  ParseGeoPoint get locationGeoPoint => get<ParseGeoPoint>(keyLocationGeoPoint)!;
  set locationGeoPoint(ParseGeoPoint? location) => set(keyLocationGeoPoint, location!);

  UserPost get defaultImg => get<UserPost>(keyDefaultImg)!;
  set defaultImg(UserPost? defaultImg) => set(keyDefaultImg, defaultImg!);

  String get defaultImgUrl => get<String>(keyDefaultImgUrl)!;
  set defaultImgUrl(String? defaultImgUrl) => set(keyDefaultImgUrl, defaultImgUrl!);

  ParseFileBase get imgProfile => get<ParseFileBase>(keyImgProfile)!;
  set imgProfile(ParseFileBase? imgprofile) => set(keyImgProfile, imgprofile!);

  String get countryCode => get<String>(keyCountryCode)!;
  set countryCode(String? countryCode) => set(keyCountryCode, countryCode!);

  String get reachProfile => get<String>(keyReachProfile)!;
  set reachProfile(String? reachProfile) => set(keyReachProfile, reachProfile!);

  bool get isDeleted => get<bool>(keyIsDeleted)!;
  set isDeleted(bool? isDeleted) => set(keyIsDeleted, isDeleted!);

  String get accountType => get<String>(keyAccountType)!;
  set accountType(String? accountType) => set(keyAccountType, accountType!);

  bool get imgStatus => get<bool>(keyImgStatus)!;
  set imgStatus(bool? imgStatus) => set(keyImgStatus, imgStatus!);

  bool get isBlocked => get<bool>(keyIsBlocked)!;
  set isBlocked(bool? isBlocked) => set(keyIsBlocked, isBlocked!);

  String get gender => get<String>(keyGender)!;
  set gender(String? gender) => set(keyGender, gender!);

  bool get noCalls => get<bool>(keyNoCalls)!;
  set noCalls(bool? noCalls) => set(keyNoCalls, noCalls!);

  bool get noVideocalls => get<bool>(keyNoVideocalls)!;
  set noVideocalls(bool? noVideocalls) => set(keyNoVideocalls, noVideocalls!);

  bool get noChats => get<bool>(keyNoChats)!;
  set noChats(bool? noChats) => set(keyNoChats, noChats!);

  bool? get autoDisconnectionCalls => get<bool>(keyAutoDisconnectionCalls);
  set autoDisconnectionCalls(bool? autoDisconnectionCalls) => set<bool>(keyAutoDisconnectionCalls, autoDisconnectionCalls!);

  bool? get autoDisconnectionChats => get<bool>(keyAutoDisconnectionChats);
  set autoDisconnectionChats(bool? autoDisconnectionChats) => set<bool>(keyAutoDisconnectionChats, autoDisconnectionChats!);

  bool? get autoDisconnectionVideoCalls => get<bool>(keyAutoDisconnectionVideoCalls);
  set autoDisconnectionVideoCalls(bool? autoDisconnectionVideoCalls) => set<bool>(keyAutoDisconnectionVideoCalls, autoDisconnectionVideoCalls!);

  String get demo => get<String>(keyDemo)!;
  set demo(String? demo) => set<String>(keyDemo, demo!);
}
