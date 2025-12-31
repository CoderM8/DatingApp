import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'user_login/user_login.dart';

class BankDetailsModel extends ParseObject implements ParseCloneable {
  static const String keyBankDetailsModel = 'BankDetails';
  static const String keyUserId = 'UserId';
  static const String keyStatus = 'Status';
  static const String keyName = 'Name';
  static const String keySurname = 'Surname';
  static const String keyTaxNumber = 'TaxNumber';
  static const String keyTelephoneNumber = 'TelephoneNumber';
  static const String keyHome = 'Home';
  static const String keyCity = 'City';
  static const String keyPostalCode = 'PostalCode';
  static const String keyCountry = 'Country';
  static const String keyBankName = 'BankName';
  static const String keyBankCountry = 'BankCountry';
  static const String keyAccountNumber = 'AccountNumber';
  static const String keyCode = 'Code';
  static const String keyPayPalAccount = 'PayPalAccount';
  static const String keyPdf = 'Pdf';
  static const String keyEmail = 'Email';
  static const String keyRequestStatus = 'Request_Status';
  static const String keySideA = 'SideA';
  static const String keySideB = 'SideB';
  static const String keyDocumentType = 'DocumentType';
  static const String keyReason = 'Reason';
  static const String keyEnable = 'Enable';
  static const String keyIBAN = 'IBAN';
  static const String keySwift = 'Swift';
  static const String keyWesternUnion = 'WesternUnion';
  static const String keyBizun = 'Bizun';

  BankDetailsModel() : super(keyBankDetailsModel);

  BankDetailsModel.clone() : this();

  @override
  BankDetailsModel clone(Map<String, dynamic> map) => BankDetailsModel.clone()..fromJson(map);

  UserLogin? get userId => get<UserLogin>(keyUserId);
  set userId(UserLogin? userId) => set<UserLogin>(keyUserId, userId!);

  bool? get status => get<bool>(keyStatus);
  set status(bool? status) => set<bool>(keyStatus, status!);

  String? get name => get<String>(keyName);
  set name(String? name) => set<String>(keyName, name!);

  String? get surname => get<String>(keySurname);
  set surname(String? surname) => set<String>(keySurname, surname!);

  String? get taxNumber => get<String>(keyTaxNumber);
  set taxNumber(String? taxNumber) => set<String>(keyTaxNumber, taxNumber!);

  String? get telephoneNumber => get<String>(keyTelephoneNumber);
  set telephoneNumber(String? telephoneNumber) => set<String>(keyTelephoneNumber, telephoneNumber!);

  String? get home => get<String>(keyHome);
  set home(String? home) => set<String>(keyHome, home!);

  String? get city => get<String>(keyCity);
  set city(String? city) => set<String>(keyCity, city!);

  String? get postalCode => get<String>(keyPostalCode);
  set postalCode(String? postalCode) => set<String>(keyPostalCode, postalCode!);

  String? get country => get<String>(keyCountry);
  set country(String? country) => set<String>(keyCountry, country!);

  String? get bankName => get<String>(keyBankName);
  set bankName(String? bankName) => set<String>(keyBankName, bankName!);

  String? get bankCountry => get<String>(keyBankCountry);
  set bankCountry(String? bankCountry) => set<String>(keyBankCountry, bankCountry!);

  String? get accountNumber => get<String>(keyAccountNumber);
  set accountNumber(String? accountNumber) => set<String>(keyAccountNumber, accountNumber!);

  String? get code => get<String>(keyCode);
  set code(String? code) => set<String>(keyCode, code!);

  String? get paypalAccount => get<String>(keyPayPalAccount);
  set paypalAccount(String? paypalAccount) => set<String>(keyPayPalAccount, paypalAccount!);

  String? get email => get<String>(keyEmail);
  set email(String? email) => set<String>(keyEmail, email!);

  String? get requestStatus => get<String>(keyRequestStatus);
  set requestStatus(String? requestStatus) => set<String>(keyRequestStatus, requestStatus!);

  String? get documentType => get<String>(keyDocumentType);
  set documentType(String? documentType) => set<String>(keyDocumentType, documentType!);

  String? get reason => get<String>(keyReason);
  set reason(String? reason) => set<String>(keyReason, reason!);

  String? get iban => get<String>(keyIBAN);
  set iban(String? iban) => set<String>(keyIBAN, iban!);

  String? get swift => get<String>(keySwift);
  set swift(String? swift) => set<String>(keySwift, swift!);

  String? get westernUnion => get<String>(keyWesternUnion);
  set westernUnion(String? westernUnion) => set<String>(keyWesternUnion, westernUnion!);

  String? get bizun => get<String>(keyBizun);
  set bizun(String? bizun) => set<String>(keyBizun, bizun!);

  ParseFile? get pdf => get<ParseFile>(keyPdf);
  set pdf(ParseFile? pdf) => set<ParseFile>(keyPdf, pdf!);

  ParseFile? get sideA => get<ParseFile>(keySideA);
  set sideA(ParseFile? sideA) => set<ParseFile>(keySideA, sideA!);

  ParseFile? get sideB => get<ParseFile>(keySideB);
  set sideB(ParseFile? sideB) => set<ParseFile>(keySideB, sideB!);

  bool? get enable => get<bool>(keyEnable);
  set enable(bool? enable) => set<bool>(keyEnable, enable!);
}
