import 'package:injectable/injectable.dart';
import 'package:saveit/features/chat/domain/repositories/chat_repository.dart';
import 'package:saveit/features/chat/domain/entities/chat_message.dart';
import 'package:saveit/features/chat/data/data_sources/chat_history_source.dart';
import 'package:saveit/features/chat/data/data_sources/chat_reply_source.dart';

@LazySingleton(as: ChatRepository)
class LocalChatRepository implements ChatRepository {
  LocalChatRepository(this._history, this._replies);

  final ChatHistorySource _history;
  final ChatReplySource _replies;

  @override
  Future<List<ChatMessage>> load(String userId) => _history.load(userId);

  @override
  Future<void> save(String userId, List<ChatMessage> messages) =>
      _history.save(userId, messages);

  @override
  Future<String> reply(String message) => _replies.sendMessage(message);
}
