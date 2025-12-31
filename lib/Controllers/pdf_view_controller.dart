import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vocsy_esys_flutter_share/vocsy_esys_flutter_share.dart';

import '../back4appservice/bankDetails_provider_api.dart';

class PdfViewController extends GetxController {
  Future<void> share({
    required String pdflink,
    required String invoiceNUmber,
  }) async {
    try {
      var request = await HttpClient().getUrl(Uri.parse(pdflink));
      var response = await request.close();
      var list = await consolidateHttpClientResponseBytes(response);
      await VocsyShare.file('Eypop', '$invoiceNUmber.pdf', list, '*/*');
    } catch (e) {
      if (kDebugMode) {
        print('Hello e e $e');
      }
    }
  }

  RxString name = "".obs;
  RxString surName = "".obs;
  RxString taxId = "".obs;
  RxString phoneNumber = "".obs;
  RxString home = "".obs;
  RxString city = "".obs;
  RxString postalCode = "".obs;
  RxString country = "".obs;
  RxBool action = false.obs;
  RxString bankName = "".obs;
  RxString bankCountry = "".obs;
  RxString accountNumber = "".obs;
  RxString code = "".obs;

  RxBool isModified = false.obs;
  RxBool isCheck = false.obs;

  bankDetails() async {
    await BankDetailsProviderApi().getById().then((value) {
      if (value != null) {
        name.value = value.results![0]["Name"];
        surName.value = value.results![0]["Surname"];
        taxId.value = value.results![0]["TaxNumber"];
        phoneNumber.value = value.results![0]["TelephoneNumber"];
        home.value = value.results![0]["Home"];
        city.value = value.results![0]["City"];
        postalCode.value = value.results![0]["PostalCode"];
        country.value = value.results![0]["Country"];
        action.value = value.results![0]["Status"];
        bankName.value = value.results![0]["BankName"];
        bankCountry.value = value.results![0]["BankCountry"];
        accountNumber.value = value.results![0]["AccountNumber"];
        code.value = value.results![0]["Code"];
        isModified.value = true;
        if (action.value) {
          isCheck.value = true;
        }
      }
    });
  }

  @override
  void onInit() {
    bankDetails();
    super.onInit();
  }
}
