// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/price_controller.dart';
import 'package:eypop/back4appservice/user_provider/coins/provider_coinprices_api.dart';
import 'package:eypop/models/coins/coinprice_model.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class PaymentController extends GetxController {
  Future<ParseResponse?> getData() async {
    try {
      final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Withdraw'))
        ..whereEqualTo('UserId', UserLogin()..objectId = StorageService.getBox.read('ObjectId'))
        ..orderByDescending('createdAt')
        ..includeObject(['BankDetails']);

      return await queryBuilder.query();
    } catch (e) {
      return null;
    }
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  RxList<ProductDetails> products = <ProductDetails>[].obs;
  RxList<ProductDetails> productsOffer = <ProductDetails>[].obs;
  List<String> priceList = [];
  bool _isAvailable = false;
  CoinPrices coinPriceObjectId = CoinPrices();
  late StreamSubscription subscription;

  Future<void> buyProduct(ProductDetails prod) async {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
      if (Platform.isIOS) {
        var transactions = await SKPaymentQueueWrapper().transactions();
        for (var skPaymentTransactionWrapper in transactions) {
          SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
        }
      }
      _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('HELLO BUY-PRODUCT PLATFORM-EXCEPTION ${e.message}');
      }
    }
  }

  Future<void> getUserProducts(id) async {
    Set<String> ids = {id};
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    if (response.productDetails.isNotEmpty) {
      products.add(response.productDetails[0]);
    } else {
      getUserProducts(id);
    }
  }

  Future<void> getUserProductsOffer(id) async {
    Set<String> ids = {id};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    if (response.productDetails.isNotEmpty) {
      productsOffer.add(response.productDetails[0]);
    }
  }

  Future<void> getAllPrices() async {
    await CoinPricesProviderApi().getOffer().then((value) {
      pricePlans.clear();
      for (var element in value.results ?? []) {
        if (Platform.isIOS) {
          pricePlans.add(element);
          priceList.add(element["AppleId"]);
        } else if (Platform.isAndroid) {
          pricePlans.add(element);
          priceList.add(element["GoogleId"]);
        }
      }
    });
  }

  final PriceController _priceController = Get.put(PriceController());

  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (_isAvailable) {
      subscription = _iap.purchaseStream.listen((data) async {
        if (coinPriceObjectId.objectId != null) {
          if (kDebugMode) {
            print('PRODUCT PURCHASE STATUS ${data[0].status}');
          }
          final Map<String, dynamic> params = <String, dynamic>{};
          if (data[0].status == PurchaseStatus.purchased) {
            params.addAll({
              "userId": StorageService.getBox.read('ObjectId'),
              "objectId": coinPriceObjectId.objectId,
              "type": Platform.operatingSystem,
              "purchaseId": data[0].purchaseID,
              "token": data[0].verificationData.serverVerificationData,
              "reason": "Purchased"
            });
          } else if (data[0].status == PurchaseStatus.pending) {
            if (Platform.isAndroid) {
              params.addAll({"userId": StorageService.getBox.read('ObjectId'), "objectId": coinPriceObjectId.objectId, "type": Platform.operatingSystem, "reason": "Pending"});
            }
          } else if (data[0].status == PurchaseStatus.error) {
            params.addAll({
              "userId": StorageService.getBox.read('ObjectId'),
              "objectId": coinPriceObjectId.objectId,
              "type": Platform.operatingSystem,
              "reason": "Error",
              "message": data[0].error!.message
            });
          } else if (data[0].status == PurchaseStatus.restored) {
            params.addAll({"userId": StorageService.getBox.read('ObjectId'), "objectId": coinPriceObjectId.objectId, "type": Platform.operatingSystem, "reason": "Restored"});
          } else if (data[0].status == PurchaseStatus.canceled) {
            params.addAll({"userId": StorageService.getBox.read('ObjectId'), "objectId": coinPriceObjectId.objectId, "type": Platform.operatingSystem, "reason": "Canceled"});
          }
          if (params.isNotEmpty) {
            final ParseCloudFunction function = ParseCloudFunction('PurchaseStars');
            final ParseResponse res = await function.execute(parameters: params);
            print("🤑 Hello PurchaseStars Execute: Coin objectId: ${coinPriceObjectId.objectId} code:[${res.statusCode}] result: ${res.result}");
            _priceController.isPurchase.value = false;
          }
          _priceController.isPurchase.value = false;
        }
      });
    }
  }

  @override
  Future<void> onInit() async {
    if (Platform.isIOS) {
      var transactions = await SKPaymentQueueWrapper().transactions();
      for (var skPaymentTransactionWrapper in transactions) {
        SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
      }
    }
    await initialize();
    super.onInit();
  }
}
