import 'dart:core';

import 'package:eypop/models/coins/coinprice_model.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class PurchaseHistoryModel extends ParseObject implements ParseCloneable {
  static const String keyPHistoryModel = 'PurchaseHistory';
  static const String keyUser = 'User';
  static const String keyCoinPrice = 'CoinPrice';
  static const String keyTotalCoins = 'TotalCoins';
  static const String keyTotalAmount = 'TotalAmount';
  static const String keyAmount = 'Amount';
  static const String keyStatus = 'Status';
  static const String keyReason = 'Reason';
  static const String keyType = 'Type';
  static const String keyPurchaseId = 'PurchaseId';
  static const String keyToken = 'Token';
  static const String keyErrorMessage = 'ErrorMessage';
  static const String keyID = 'ID';
  PurchaseHistoryModel() : super(keyPHistoryModel);

  PurchaseHistoryModel.clone() : this();

  @override
  PurchaseHistoryModel clone(Map<String, dynamic> map) => PurchaseHistoryModel.clone()..fromJson(map);

  UserLogin? get user => get<UserLogin>(keyUser);

  set user(UserLogin? user) => set<UserLogin>(keyUser, user!);

  CoinPrices? get coinPrices => get<CoinPrices>(keyCoinPrice);

  set coinPrices(CoinPrices? coinPrices) => set<CoinPrices>(keyCoinPrice, coinPrices!);

  int? get coins => get<int>(keyTotalCoins);

  set coins(int? coins) => set<int>(keyTotalCoins, coins!);

  int? get totalAmount => get<int>(keyTotalAmount);

  set totalAmount(int? amount) => set<int>(keyTotalAmount, amount!);

  double? get amount => get<double>(keyAmount);

  set amount(double? price) => set<double>(keyAmount, price!);

  String? get type => get<String>(keyType);

  set type(String? type) => set<String>(keyType, type!);

  String? get purchaseId => get<String>(keyPurchaseId);
  set purchaseId(String? purchaseId) => set<String>(keyPurchaseId, purchaseId!);

  int? get status => get<int>(keyStatus);
  set status(int? status) => set<int>(keyStatus, status!);

  String? get reason => get<String>(keyReason);
  set reason(String? reason) => set<String>(keyReason, reason!);

  String? get token => get<String>(keyToken);
  set token(String? token) => set<String>(keyToken, token!);

  String? get errorMessage => get<String>(keyErrorMessage);
  set errorMessage(String? errorMessage) => set<String>(keyErrorMessage, errorMessage!);
}
