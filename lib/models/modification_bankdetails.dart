import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'user_login/user_login.dart';

class ModificationBankDetailsModel extends ParseObject implements ParseCloneable {
  static const String keyBankDetailsModel = 'modificationBankDetails';
  static const String keyUserId = 'UserId';
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
  static const String keySideA = 'SideA';
  static const String keySideB = 'SideB';
  static const String keyDocumentType = 'DocumentType';

  ModificationBankDetailsModel() : super(keyBankDetailsModel);

  ModificationBankDetailsModel.clone() : this();

  @override
  ModificationBankDetailsModel clone(Map<String, dynamic> map) => ModificationBankDetailsModel.clone()..fromJson(map);

  UserLogin? get userId => get<UserLogin>(keyUserId);
  set userId(UserLogin? userId) => set<UserLogin>(keyUserId, userId!);

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

  ParseFile? get pdf => get<ParseFile>(keyPdf);
  set pdf(ParseFile? pdf) => set<ParseFile>(keyPdf, pdf!);

  ParseFile? get sideA => get<ParseFile>(keySideA);
  set sideA(ParseFile? sideA) => set<ParseFile>(keySideA, sideA!);

  ParseFile? get sideB => get<ParseFile>(keySideB);
  set sideB(ParseFile? sideB) => set<ParseFile>(keySideB, sideB!);

  String? get documentType => get<String>(keyDocumentType);
  set documentType(String? documentType) => set<String>(keyDocumentType, documentType!);

}
