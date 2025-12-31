import 'package:eypop/models/user_login/user_login.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../Controllers/Picture_Controller/profile_pic_controller.dart';
import '../../../models/user_login/user_profile.dart';
import '../../../models/verticaltab_model/blockuser.dart';
import '../../base/api_response.dart';
import '../../repositories_api/vertical_tab/blockuser_api_plan.dart';

class BlockUSerProviderApi implements BlockUSerProviderContract {
  BlockUSerProviderApi();
  final PictureController picturex = Get.put(PictureController());
  @override
  Future<ApiResponse> add(BlockUser item) async {
    return getApiResponse<BlockUser>(await item.save());
  }

  @override
  Future<ApiResponse> addAll(List<BlockUser> items) async {
    final List<dynamic> responses = [];

    for (final BlockUser item in items) {
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
    return getApiResponse<BlockUser>(await BlockUser().getAll());
  }

  @override
  Future<ApiResponse> getById(String id) async {
    return getApiResponse<BlockUser>(await BlockUser().getObject(id));
  }


  Future<ApiResponse?> getByUserId(String id) async {
    try {
      final QueryBuilder<BlockUser> query = QueryBuilder<BlockUser>(BlockUser())
            ..whereEqualTo('FromUser', (UserLogin()..objectId = id).toPointer());
      return getApiResponse<BlockUser>(await query.query());
    } catch (e) {
    return null;
    }
  }

  @override
  Future<ApiResponse> getNewerThan() async {
    final QueryBuilder<BlockUser> query = QueryBuilder<BlockUser>(BlockUser())..orderByAscending('createdAt');

    return getApiResponse<BlockUser>(await query.query());
  }

  @override
  Future<ApiResponse> userProfileQuery(String id) async {
    final QueryBuilder<BlockUser> query = QueryBuilder<BlockUser>(BlockUser())
      ..whereEqualTo('Profile_Id', (ProfilePage()..objectId = id).toPointer());
    return getApiResponse<BlockUser>(await query.query());
  }

  @override
  Future<ApiResponse> remove(BlockUser item) async {
    return getApiResponse<BlockUser>(await item.delete());
  }

  @override
  Future<ApiResponse> update(BlockUser item) async {
    return getApiResponse<BlockUser>(await item.save());
  }

  @override
  Future<ApiResponse> updateAll(List<BlockUser> items) async {
    final List<dynamic> responses = [];

    for (final BlockUser item in items) {
      final ApiResponse response = await update(item);

      if (!response.success) {
        return response;
      }
      response.results!.forEach(responses.add);
    }

    return ApiResponse(true, 200, responses, null);
  }
}
