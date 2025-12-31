import 'dart:core';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Prices extends ParseObject implements ParseCloneable {
  static const String keyPrices = 'Prices';
  static const String keyChatMessage = 'ChatMessage';
  static const String keyCall = 'Call';
  static const String keyHeartLike = 'HeartLike';
  static const String keyLipLike = 'LipLike';
  static const String keyWinkMessage = 'WinkMessage';
  static const String keyHeartMessage = 'HeartMessage';
  static const String keyDefaultCoins = 'DefaultUserCoin';
  static const String keyDefaultToken = 'DefaultUserToken';
  static const String keyImagePrice = 'ImagePrice';
  static const String keyVideoPrice = 'VideoPrice';
  static const String keyCreateProfile = 'CreateProfile';
  static const String keyCreateGirlProfile = 'CreateGirlProfile';
  static const String keyWithdrawToken = 'TokenPrice100';
  Prices() : super(keyPrices);

  Prices.clone() : this();

  @override
  Prices clone(Map<String, dynamic> map) => Prices.clone()..fromJson(map);

  int? get chatMessage => get<int>(keyChatMessage);
  set chatMessage(int? chatMessage) => set<int>(keyChatMessage, chatMessage!);

  int? get call => get<int>(keyCall);
  set call(int? call) => set<int>(keyCall, call!);

  int? get heartLike => get<int>(keyHeartLike);
  set heartLike(int? heartLike) => set<int>(keyHeartLike, heartLike!);

  int? get lipLike => get<int>(keyLipLike);
  set lipLike(int? lipLike) => set<int>(keyLipLike, lipLike!);

  int? get winkMessage => get<int>(keyWinkMessage);
  set winkMessage(int? winkMessage) => set<int>(keyWinkMessage, winkMessage!);

  int? get heartMessage => get<int>(keyHeartMessage);
  set heartMessage(int? heartMessage) => set<int>(keyHeartMessage, heartMessage!);

  int? get defaultCoins => get<int>(keyDefaultCoins);
  set defaultCoins(int? defaultCoins) => set<int>(keyDefaultCoins, defaultCoins!);

  int? get imagePrice => get<int>(keyImagePrice);
  set imagePrice(int? imagePrice) => set<int>(keyImagePrice, imagePrice!);

  int? get videoPrice => get<int>(keyVideoPrice);
  set videoPrice(int? videoPrice) => set<int>(keyVideoPrice, videoPrice!);

  int? get defaultToken => get<int>(keyDefaultToken);
  set defaultToken(int? defaultToken) => set<int>(keyDefaultToken, defaultToken!);

  int? get createProfile => get<int>(keyCreateProfile);
  set createProfile(int? profilePrice) => set<int>(keyCreateProfile, profilePrice!);

  int? get createGirlProfile => get<int>(keyCreateGirlProfile);
  set createGirlProfile(int? createGirlProfile) => set<int>(keyCreateGirlProfile, createGirlProfile!);

  int? get withdrawToken => get<int>(keyWithdrawToken);
  set withdrawToken(int? withdrawToken) => set<int>(keyWithdrawToken, withdrawToken!);
}
