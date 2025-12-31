import 'package:eypop/back4appservice/advertisement_api.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AdvertisementController extends GetxController {
  final RxList<ParseObject> adsMuroData = <ParseObject>[].obs;
  final RxList<ParseObject> adsTokTokData = <ParseObject>[].obs;
  final RxList<bool> closeAds = <bool>[].obs;

  Future<void> getAdvertisementData(String service) async {
    if (service == 'muro') {
      adsMuroData.clear();
    } else {
      adsTokTokData.clear();
    }
    ApiResponse? data = await AdvertisementApi().getByAdvertisement(service: service);
    if (data != null) {
      for (var e in data.results ?? []) {
        // if(e['ConditionAdvertisement'].toString().isNotEmpty && e['ConditionAdvertisement'] != null){
        /// cloud function (ConditionForAdvertisement)
        final ParseCloudFunction function = ParseCloudFunction('ConditionForAdvertisement');
        final Map<String, dynamic> params = <String, dynamic>{
          'userId': StorageService.getBox.read('ObjectId'),
          'condition': e['ConditionAdvertisement'].toString(),
        };
        ParseResponse response = await function.execute(parameters: params);
        //print('Hello Cloud Code Return ------> ${response.result}');
        if (response.result == true) {
          if (service == 'muro') {
            adsMuroData.add(e);
          } else {
            adsTokTokData.add(e);
          }
        }
        // }
      }
    }
  }

  @override
  void onInit() {
    getAdvertisementData('muro');
    super.onInit();
  }
}
