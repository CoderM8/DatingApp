import 'dart:core';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class CoinPrices extends ParseObject implements ParseCloneable {
  static const String keyPrices = 'Coin_Price';
  static const String keyCoins = 'Coins';
  static const String keyPrice = 'Price';
  static const String keyOffer = 'Offer';
  static const String keyStatus = 'Status';
  static const String keyAppleId = 'AppleId';
  static const String keyGoogleId = 'GoogleId';
  CoinPrices() : super(keyPrices);

  CoinPrices.clone() : this();

  @override
  CoinPrices clone(Map<String, dynamic> map) => CoinPrices.clone()..fromJson(map);

  int? get coins => get<int>(keyCoins);
  set coins(int? chatMessage) => set<int>(keyCoins, chatMessage!);

  int? get price => get<int>(keyPrice);
  set price(int? call) => set<int>(keyPrice, call!);

  bool? get offer => get<bool>(keyOffer);
  set offer(bool? offer) => set<bool>(keyOffer, offer!);

  bool? get status => get<bool>(keyStatus);
  set status(bool? status) => set<bool>(keyStatus, status!);

  String? get googleId => get<String>(keyGoogleId);
  set googleId(String? googleId) => set<String>(keyGoogleId, googleId!);

  String? get appleId => get<String>(keyAppleId);
  set appleId(String? appleId) => set<String>(keyAppleId, appleId!);
}
