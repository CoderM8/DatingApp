import '../../../models/tab_model/chat_message.dart';
import '../../base/api_response.dart';

abstract class UserChatMessageProviderContract {
  Future<ApiResponse> add(ChatMessage item);
  Future<ApiResponse> addAll(List<ChatMessage> items);
  Future<ApiResponse> update(ChatMessage item);
  Future<ApiResponse> updateAll(List<ChatMessage> items);
  Future<ApiResponse> remove(ChatMessage item);
  Future<ApiResponse> getById(String id);
  Future<ApiResponse> getAll();
  Future<ApiResponse> getNewerThan(DateTime date);
  Future<ApiResponse> userMessage(String toUser, String fromUser);
}
