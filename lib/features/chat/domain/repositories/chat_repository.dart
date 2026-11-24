import 'package:saveit/features/chat/domain/entities/chat_message.dart';

abstract interface class ChatRepository {
  Future<List<ChatMessage>> load(String userId);
  Future<void> save(String userId, List<ChatMessage> messages);
  Future<String> reply(String message);
}
