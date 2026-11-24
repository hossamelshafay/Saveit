import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:saveit/features/chat/domain/repositories/chat_repository.dart';
import 'package:saveit/features/chat/domain/entities/chat_message.dart';
import 'package:saveit/features/auth/domain/repositories/auth_repository.dart';

class ChatState {
  const ChatState({
    this.messages = const [],
    this.canUndo = false,
    this.isThinking = false,
  });

  final List<ChatMessage> messages;
  final bool canUndo;
  final bool isThinking;
}

@injectable
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository, AuthRepository auth)
    : _session = auth.session,
      super(const ChatState());

  final ChatRepository _repository;
  final AuthSession? _session;
  List<ChatMessage> _previous = const [];
  Future<void> _pendingWrite = Future<void>.value();
  int _pendingReplies = 0;

  String? get _userId => _session?.isAnonymous == false ? _session?.id : null;

  Future<void> load() async {
    final id = _userId;
    if (id == null) return;
    try {
      final messages = await _repository.load(id);
      if (!isClosed && state.messages.isEmpty && _pendingReplies == 0) {
        _update(messages);
      }
    } catch (_) {
      // History is optional when the local cache is unavailable.
    }
  }

  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty) return;
    _pendingReplies++;
    _update([
      ChatMessage(text: message, isMe: true, time: DateTime.now()),
      ...state.messages,
    ]);
    unawaited(_save());

    String reply;
    try {
      reply = await _repository.reply(message);
      if (reply.isEmpty) {
        reply = "Sorry, I couldn't understand. Could you rephrase?";
      }
    } catch (_) {
      reply = 'Network error. Please try again.';
    }

    _pendingReplies--;
    if (isClosed) return;
    _update([
      ChatMessage(text: reply, isMe: false, time: DateTime.now()),
      ...state.messages,
    ]);
    await _save();
  }

  Future<void> newChat() async {
    _previous = state.messages;
    _update(const []);
    await _save();
  }

  Future<void> undo() async {
    final previous = _previous;
    _previous = const [];
    _update(previous);
    await _save();
  }

  void _update(List<ChatMessage> messages) {
    emit(
      ChatState(
        messages: List.unmodifiable(messages),
        canUndo: _previous.isNotEmpty,
        isThinking: _pendingReplies > 0,
      ),
    );
  }

  Future<void> _save() {
    final id = _userId;
    if (id == null) return Future<void>.value();
    final messages = state.messages;
    return _pendingWrite = _pendingWrite.then((_) async {
      try {
        await _repository.save(id, messages);
      } catch (_) {
        // The current conversation remains available in memory.
      }
    });
  }
}
