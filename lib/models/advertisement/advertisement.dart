import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Advertisement extends ParseObject implements ParseCloneable {
  static const String keyAds = 'My_Ads';
  static const String keyGender = 'Gender';
  static const String keyExternalLink = 'ExternalLink';
  static const String keyActive = 'Active';
  static const String keyEveryXProfiles = 'EveryXProfiles';
  static const String keyRepeat = 'Repeat';
  static const String keyService = 'Service';
  static const String keyImage = 'Image';
  static const String keyInternalLink = 'InternalLink';
  static const String keyDelete = 'Delete';
  static const String keyConditionAdvertisement = 'ConditionAdvertisement';
  Advertisement() : super(keyAds);

  Advertisement.clone() : this();

  @override
  Advertisement clone(Map<String, dynamic> map) => Advertisement.clone()..fromJson(map);

  String get gender => get<String>(keyGender)!;
  set gender(String? gender) => set(keyGender, gender!);

  String get externalLink => get<String>(keyExternalLink)!;
  set externalLink(String? externalLink) => set(keyExternalLink, externalLink!);

  bool get isActive => get<bool>(keyActive)!;
  set isActive(bool? isActive) => set(keyActive, isActive!);

  int? get everyXProfiles => get<int>(keyEveryXProfiles);
  set everyXProfiles(int? everyXProfiles) => set<int>(keyEveryXProfiles, everyXProfiles!);

  bool get isRepeat => get<bool>(keyRepeat)!;
  set isRepeat(bool? isRepeat) => set(keyRepeat, isRepeat!);

  String get service => get<String>(keyService)!;
  set service(String? service) => set(keyService, service!);

  ParseFileBase get image => get<ParseFileBase>(keyImage)!;
  set image(ParseFileBase? image) => set(keyImage, image!);

  String get internalLink => get<String>(keyInternalLink)!;
  set internalLink(String? internalLink) => set(keyInternalLink, internalLink!);

  bool get isDelete => get<bool>(keyDelete)!;
  set isDelete(bool? isDelete) => set(keyDelete, isDelete!);

  String get conditionAdvertisement => get<String>(keyConditionAdvertisement)!;
  set conditionAdvertisement(String? conditionAdvertisement) => set(keyConditionAdvertisement, conditionAdvertisement!);
}