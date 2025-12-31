// ignore_for_file: null_check_always_fails

import 'dart:io';

import 'package:eypop/Constant/constant.dart';
import 'package:eypop/back4appservice/bankDetails_provider_api.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/modified_bank_provider.dart';
import 'package:eypop/models/bank_detail_model.dart';
import 'package:eypop/models/modification_bankdetails.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class BankDetailsController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController taxNumberController = TextEditingController();
  final TextEditingController telephoneNumberController = TextEditingController();
  final TextEditingController homeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  File? pdfFile;
  final ImagePicker _imagePicker = ImagePicker();
  final RxString isName = "".obs;
  final RxString isSurname = "".obs;
  final RxString isTaxNUmber = "".obs;
  final RxString isTelephoneNumber = "".obs;
  final RxString isEmail = "".obs;
  final RxString isHome = "".obs;
  final RxString isCity = "".obs;
  final RxString isPostalCode = "".obs;
  final RxString isCountry = "".obs;
  final RxString bankObjectId = "".obs;
  final RxString rejectReason = "".obs;
  final RxBool isAcceptCondition = false.obs;
  final RxBool isRemember = false.obs;
  final RxBool dataExits = false.obs;
  final RxBool status = false.obs;
  final RxBool enable = true.obs; // [true] when admin enable to edit details and create new account first time
  final RxString requestStatus = "".obs;
  final RxBool isButtonEnable = true.obs;
  final RxBool isLoading = false.obs;

  // NEW
  final RxInt selectDoc = 0.obs;
  final RxMap selectDocList = {}.obs;
  final RxList documentList = [
    {'id': 'Document', 'title': "ID_document_side".tr, 'svg': "assets/Icons/document.svg", "side": 2},
    {'id': 'License', 'title': "License_side".tr, 'svg': "assets/Icons/document.svg", "side": 2},
    {'id': 'Passport', 'title': "Passport".tr, 'svg': "assets/Icons/passport.svg", "side": 1}
  ].obs;
  final RxString docType = ''.obs;
  final RxString isWesternUnion = ''.obs;
  final RxString isWesternUnionName = ''.obs;
  final RxString isIban = ''.obs;
  final RxString isSwift = ''.obs;
  final RxString isSwiftCode = ''.obs;
  final RxString isBizun = ''.obs;
  final RxString isPaypal = ''.obs;

  @override
  Future<void> onInit() async {
    isLoading.value = true;
    await getUserBankDetails().whenComplete(() => isLoading.value = false);
    super.onInit();
  }

  Future<void> getUserBankDetails() async {
    selectDocList.clear();
    final ApiResponse? apiResponse = await BankDetailsProviderApi().getById();
    if (apiResponse != null && apiResponse.result != null) {
      if (kDebugMode) {
        print('HELLO GET BANK DETAILS obj ${apiResponse.result['objectId']}');
      }
      bankObjectId.value = apiResponse.result["objectId"];
      nameController.text = apiResponse.result["Name"] ?? '';
      isName.value = apiResponse.result["Name"] ?? '';
      surnameController.text = apiResponse.result["Surname"] ?? '';
      isSurname.value = apiResponse.result["Surname"] ?? '';
      taxNumberController.text = apiResponse.result["TaxNumber"] ?? '';
      isTaxNUmber.value = apiResponse.result["TaxNumber"] ?? '';
      telephoneNumberController.text = apiResponse.result["TelephoneNumber"] ?? '';
      isTelephoneNumber.value = apiResponse.result["TelephoneNumber"] ?? '';
      homeController.text = apiResponse.result["Home"] ?? '';
      isHome.value = apiResponse.result["Home"] ?? '';
      cityController.text = apiResponse.result["City"] ?? '';
      isCity.value = apiResponse.result["City"] ?? '';
      postalCodeController.text = apiResponse.result["PostalCode"] ?? '';
      isPostalCode.value = apiResponse.result["PostalCode"] ?? '';
      countryController.text = apiResponse.result["Country"] ?? '';
      isCountry.value = apiResponse.result["Country"] ?? '';
      emailController.text = apiResponse.result["Email"] ?? "";
      isEmail.value = apiResponse.result["Email"] ?? "";
      status.value = apiResponse.result["Status"] ?? false;
      requestStatus.value = apiResponse.result["Request_Status"] ?? "";
      isIban.value = apiResponse.result["IBAN"] ?? "";
      isBizun.value = apiResponse.result["Bizun"] ?? "";
      isPaypal.value = apiResponse.result["PayPalAccount"] ?? "";
      if (apiResponse.result["WesternUnion"] != null) {
        isWesternUnion.value = apiResponse.result["WesternUnion"] ?? "";
        isWesternUnionName.value = apiResponse.result["WesternUnionName"] ?? "";
      }
      if (apiResponse.result["Swift"] != null) {
        isSwift.value = apiResponse.result["Swift"] ?? "";
        isSwiftCode.value = apiResponse.result["SwiftCode"] ?? "";
      }
      if (requestStatus.value.contains('PENDING')) {
        enable.value = false;
      } else {
        if (requestStatus.value.contains('SUCCESS')) {
          enable.value = (apiResponse.result["Enable"] ?? false);
        } else {
          rejectReason.value = apiResponse.result["Reason"] ?? 'rechazado por admin';
        }
      }
      if (apiResponse.result['SideA'] != null) {
        selectDocList.update('A', (x) => {'Path': apiResponse.result['SideA'].url, 'Save': true, 'Type': "Net"},
            ifAbsent: () => {'Path': apiResponse.result['SideA'].url, 'Save': true, 'Type': "Net"});
      }
      if (apiResponse.result['SideB'] != null) {
        selectDocList.update('B', (x) => {'Path': apiResponse.result['SideB'].url, 'Save': true, 'Type': "Net"},
            ifAbsent: () => {'Path': apiResponse.result['SideB'].url, 'Save': true, 'Type': "Net"});
      }
      docType.value = apiResponse.result['DocumentType'] ?? '';
      final index = documentList.indexWhere((element) => element['id'] == docType.value);
      selectDoc.value = index.isNegative ? 0 : index;
      isAcceptCondition.value = true;
      dataExits.value = true;
    }
    update();
  }

  Future<void> sendEypoperRequest() async {
    isButtonEnable.value = false;
    final items = selectDocList.values.where((element) => element['Save'] == true).toList();
    final BankDetailsModel bankDetailModel = BankDetailsModel();
    final ModificationBankDetailsModel modifyModel = ModificationBankDetailsModel();
    bankDetailModel.userId = UserLogin()..objectId = StorageService.getBox.read("ObjectId");
    modifyModel.userId = UserLogin()..objectId = StorageService.getBox.read("ObjectId");
    // new for upload document
    if (items.isNotEmpty) {
      if (items[0] != null && items[0]['Type'].toString().contains('File')) {
        bankDetailModel.sideA = ParseFile(File(items[0]['Path']));
        modifyModel.sideA = ParseFile(File(items[0]['Path']));
      }
      if (items.length >= 2 && items[1] != null && items[1]['Type'].toString().contains('File')) {
        bankDetailModel.sideB = ParseFile(File(items[1]['Path']));
        modifyModel.sideB = ParseFile(File(items[1]['Path']));
      }
      bankDetailModel.documentType = docType.value; // documentType
      modifyModel.documentType = docType.value; // documentType
    }
    bankDetailModel.name = nameController.text.trim(); // first name
    bankDetailModel.surname = surnameController.text.trim(); // last name
    bankDetailModel.taxNumber = taxNumberController.text.trim(); // identification number
    bankDetailModel.telephoneNumber = telephoneNumberController.text.trim(); // phone number
    bankDetailModel.email = emailController.text.trim(); // email address
    bankDetailModel.home = homeController.text.trim(); // address
    bankDetailModel.postalCode = postalCodeController.text.trim(); // postal code
    bankDetailModel.city = cityController.text.trim(); // city
    bankDetailModel.country = countryController.text.trim(); // county
    bankDetailModel.status = false;
    bankDetailModel.enable = false; // [true]  by admin edit details
    bankDetailModel.requestStatus = 'PENDING';
    if (bankObjectId.value.isNotEmpty) {
      // update if already create eypoper account
      bankDetailModel.objectId = bankObjectId.value;
      await BankDetailsProviderApi().update(bankDetailModel);
    } else {
      await BankDetailsProviderApi().add(bankDetailModel);

      /// cloud function (Create_Influencer) (template 13)
      final ParseCloudFunction function = ParseCloudFunction('Create_Influencer');
      final Map<String, dynamic> params = <String, dynamic>{
        'Email_Id': bankDetailModel.email,
        'First_Name': bankDetailModel.name ?? nameController.text.trim(),
        'UserId': StorageService.getBox.read("ObjectId")
      };
      await function.execute(parameters: params);
    }

    modifyModel.name = nameController.text.trim(); // first name
    modifyModel.surname = surnameController.text.trim(); // last name
    modifyModel.taxNumber = taxNumberController.text.trim(); // identification number
    modifyModel.telephoneNumber = telephoneNumberController.text.trim(); // phone number
    modifyModel.email = emailController.text.trim(); // email address
    modifyModel.home = homeController.text.trim(); // address
    modifyModel.postalCode = postalCodeController.text.trim(); // postal code
    modifyModel.city = cityController.text.trim(); // city
    modifyModel.country = countryController.text.trim(); // county
    await ModificationBankDetailsProviderApi().add(modifyModel);
    isButtonEnable.value = true;
    await getUserBankDetails();
    update();
    Get.back();
  }

  Future<bool> makePayment(
      {required double amount, required int totalCoin, required PaymentType type, required String account, required String code}) async {
    isLoading.value = true;

    /// cloud function [Withdraw.js]
    final ParseCloudFunction function = ParseCloudFunction('WithdrawToken');
    final Map<String, dynamic> params = <String, dynamic>{
      'userId': StorageService.getBox.read('ObjectId'),
      'bankObjectId': bankObjectId.value,
      'amount': amount.toStringAsFixed(2),
      'mail': account,
      'code': code,
      'type': type.name,
      'totalCoin': totalCoin
    };
    final ParseResponse response = await function.execute(parameters: params);
    if (kDebugMode) {
      print('Hello WithdrawToken ${response.success} Result: ${response.result}');
    }
    if (response.success) {
      // update details in [BankDetails] Table
      if (isRemember.value) {
        final BankDetailsModel bankDetailModel = BankDetailsModel();
        bankDetailModel.objectId = bankObjectId.value;
        switch (type) {
          case PaymentType.WesternUnion:
            bankDetailModel.westernUnion = account;
            bankDetailModel['WesternUnionName'] = code;
            break;
          case PaymentType.Iban:
            bankDetailModel.iban = account;
            break;
          case PaymentType.Swift:
            bankDetailModel.swift = account;
            bankDetailModel['SwiftCode'] = code;
            break;
          case PaymentType.Bizun:
            bankDetailModel.bizun = account;
            break;
          case PaymentType.Paypal:
            bankDetailModel.paypalAccount = account;
            break;
        }
        // update if already create eypoper account
        await BankDetailsProviderApi().update(bankDetailModel);
        isRemember.value = false;
      }
    }
    isLoading.value = false;
    return response.success;
  }

  Future<File?> uploadDocs({ImageSource source = ImageSource.gallery}) async {
    final file = await _imagePicker.pickImage(source: source);
    if (file == null) {
      return null;
    }
    return File(file.path);
  }
}
