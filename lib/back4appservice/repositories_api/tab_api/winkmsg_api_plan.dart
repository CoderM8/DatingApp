import '../../../models/tab_model/wink_message.dart';
import '../../base/api_response.dart';

abstract class WinkMsgProviderContract {
  Future<ApiResponse> add(WinkMessage item);

  Future<ApiResponse> userProfileQuery(String id);

  Future<ApiResponse> addAll(List<WinkMessage> items);

  Future<ApiResponse> update(WinkMessage item);

  Future<ApiResponse> updateAll(List<WinkMessage> items);

  Future<ApiResponse> remove(WinkMessage item);

  Future<ApiResponse> getById(String id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan();
}
