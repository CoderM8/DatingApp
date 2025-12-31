import 'package:eypop/models/tab_model/visits.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/user_login/user_login.dart';
import '../../../models/user_login/user_profile.dart';
import '../../base/api_response.dart';
import '../../repositories_api/tab_api/visits.dart';

class VisitsProviderApi implements VisitsProviderContract {
  VisitsProviderApi();

  @override
  Future<ApiResponse> add(Visits item) async {
    return getApiResponse<Visits>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<Visits> items) async {
    final List<dynamic> responses = [];

    for (final Visits item in items) {
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
    return getApiResponse<Visits>(await Visits().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<Visits>(await Visits().getObject(id));
  }

  @override
  Future<ApiResponse> getNewerThan() async {
    final QueryBuilder<Visits> query = QueryBuilder<Visits>(Visits())..orderByAscending('createdAt');

    return getApiResponse<Visits>(await query.query());
  }

  @override
  Future<ApiResponse> userProfileQuery(String id) async {
    final QueryBuilder<Visits> query = QueryBuilder<Visits>(Visits())..whereEqualTo('Profile_Id', (ProfilePage()..objectId = id).toPointer());

    return getApiResponse<Visits>(await query.query());
  }

  Future<ApiResponse?> getVisitsNotification({String? userid}) async {
    try {
      QueryBuilder<ParseObject> heartMessagequeryFromUser = QueryBuilder<ParseObject>(Visits())
        ..whereEqualTo('FromUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> heartMessagequeryToUser = QueryBuilder<ParseObject>(Visits())
        ..whereEqualTo('ToUser', (UserLogin()..objectId = userid).toPointer());

      QueryBuilder<ParseObject> mainQuery = QueryBuilder.or(
        Visits(),
        [heartMessagequeryFromUser, heartMessagequeryToUser],
      )
        ..orderByDescending('createdAt')
        ..includeObject(['ToProfile', 'FromProfile', 'ToUser', 'FromUser']);

      var apiResponse = await mainQuery.query();
      // print('Api heart message ${apiResponse.results}');
      return getApiResponse<ParseObject>(apiResponse);
    } catch (e, t) {
      if (kDebugMode) {
        print(e);
        print('treeeeddd  getVisitsNotification$t');
      }
      return null;
    }
  }

  Future<ApiResponse?> getUnReadVisitNotification({String? userid}) async {
    try {
      QueryBuilder<Visits> query = QueryBuilder<Visits>(Visits())
        ..whereEqualTo('ToUser', UserLogin()..objectId = userid)
        ..whereEqualTo('isRead', false);
      return getApiResponse<Visits>(await query.query());
    } catch (e, t) {
      if (kDebugMode) {
        print(e);
        print('treeeeddd  getUnReadVisitNotification$t');
      }
      return null;
    }
  }

  @override
  Future<ApiResponse> remove(Visits item) async {
    return getApiResponse<Visits>(await item.delete());
  }

  @override
  Future<ApiResponse> update(Visits item) async {
    return getApiResponse<Visits>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<Visits> items) async {
    final List<dynamic> responses = [];

    for (final Visits item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
