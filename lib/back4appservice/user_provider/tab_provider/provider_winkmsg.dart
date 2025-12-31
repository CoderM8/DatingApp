import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/tab_model/wink_message.dart';
import '../../../models/user_login/user_login.dart';
import '../../../models/user_login/user_profile.dart';
import '../../base/api_response.dart';
import '../../repositories_api/tab_api/winkmsg_api_plan.dart';

class WinkMsgProviderApi implements WinkMsgProviderContract {
  WinkMsgProviderApi();

  @override
  Future<ApiResponse> add(WinkMessage item) async {
    return getApiResponse<WinkMessage>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<WinkMessage> items) async {
    final List<dynamic> responses = [];

    for (final WinkMessage item in items) {
      final ApiResponse response = await add(item);

      if (!response.success) {
        return response;
      }

      response.results?.forEach(responses.add);
    }
    return ApiResponse(true, 200, responses, null);
  }

  @override
  Future<ApiResponse> getAll() async {
    return getApiResponse<WinkMessage>(await WinkMessage().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<WinkMessage>(await WinkMessage().getObject(id));
  }

  @override
  Future<ApiResponse> getNewerThan() async {
    final QueryBuilder<WinkMessage> query = QueryBuilder<WinkMessage>(WinkMessage())..orderByAscending('createdAt');

    return getApiResponse<WinkMessage>(await query.query());
  }

  @override
  Future<ApiResponse> userProfileQuery(String id) async {
    final QueryBuilder<WinkMessage> query = QueryBuilder<WinkMessage>(WinkMessage())
      ..whereEqualTo('Profile_Id', (ProfilePage()..objectId = id).toPointer());
    return getApiResponse<WinkMessage>(await query.query());
  }

  Future<ApiResponse?> getUnReadWinkNotification({String? userid}) async {
    try {
      QueryBuilder<WinkMessage> query = QueryBuilder<WinkMessage>(WinkMessage())
        ..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer())
        ..whereEqualTo('isRead', false);
      return getApiResponse<WinkMessage>(await query.query());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  @override
  Future<ApiResponse> remove(WinkMessage item) async {
    return getApiResponse<WinkMessage>(await item.delete());
  }

  @override
  Future<ApiResponse> update(WinkMessage item) async {
    return getApiResponse<WinkMessage>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<WinkMessage> items) async {
    final List<dynamic> responses = [];

    for (final WinkMessage item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
