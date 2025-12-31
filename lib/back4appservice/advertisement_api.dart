import 'package:eypop/models/advertisement/advertisement.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'base/api_response.dart';

class AdvertisementApi {
  AdvertisementApi();

  Future<ApiResponse> add(Advertisement item) async {
    return getApiResponse<Advertisement>(await item.save());
  }

  Future<ApiResponse> addAll(List<Advertisement> items) async {
    final List<dynamic> responses = [];

    for (final Advertisement item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  Future<ApiResponse> getAll() async {
    return getApiResponse<Advertisement>(await Advertisement().getAll());
  }

  Future<ApiResponse?> getByAdvertisement({required String service}) async {
    try {
      final QueryBuilder<Advertisement> query = QueryBuilder<Advertisement>(Advertisement())
        ..whereEqualTo('Gender', StorageService.getBox.read('Gender'))
        ..whereEqualTo('Service', service)
        ..whereEqualTo('Active', true)
        ..whereEqualTo('Delete', false);
      return getApiResponse<Advertisement>(await query.query());
    } catch (e,t) {
      if (kDebugMode) {
       // print('Hello getByAdvertisement ERROR ------> $e');
       // print('Hello getByAdvertisement TRACE ------> $t');
      }
      return null;
    }
  }

  Future<ApiResponse> remove(Advertisement item) async {
    return getApiResponse<Advertisement>(await item.delete());
  }

  Future<ApiResponse> update(Advertisement item) async {
    return getApiResponse<Advertisement>(await item.save());
  }


  Future<ApiResponse> updateAll(List<Advertisement> items) async {
    final List<dynamic> responses = [];

    for (final Advertisement item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }
}
