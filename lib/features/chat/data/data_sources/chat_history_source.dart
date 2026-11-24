import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saveit/features/chat/domain/entities/chat_message.dart';

@lazySingleton
class ChatHistorySource {
  String _key(String userId) => 'chat_history_$userId';

  Future<List<ChatMessage>> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key(userId));
    if (stored == null) return [];
    return (jsonDecode(stored) as List).map((message) {
      return ChatMessage(
        text: message['text'],
        isMe: message['isMe'],
        time: DateTime.parse(message['time'] as String),
      );
    }).toList();
  }

  Future<void> save(String userId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final data = messages
        .map(
          (message) => {
            'text': message.text,
            'isMe': message.isMe,
            'time': message.time.toIso8601String(),
          },
        )
        .toList();
    await prefs.setString(_key(userId), jsonEncode(data));
  }
}
