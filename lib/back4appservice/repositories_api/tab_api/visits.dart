import '../../../models/tab_model/visits.dart';
import '../../base/api_response.dart';

abstract class VisitsProviderContract {
  Future<ApiResponse> add(Visits item);

  Future<ApiResponse> userProfileQuery(String id);

  Future<ApiResponse> addAll(List<Visits> items);

  Future<ApiResponse> update(Visits item);

  Future<ApiResponse> updateAll(List<Visits> items);

  Future<ApiResponse> remove(Visits item);

  Future<ApiResponse> getById(String id);

  Future<ApiResponse> getAll();

  Future<ApiResponse> getNewerThan();
}
