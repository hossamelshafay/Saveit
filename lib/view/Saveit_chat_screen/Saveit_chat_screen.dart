import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/chat_message.dart';
import 'widgets/message_style.dart';
import 'widgets/thinking_bubble.dart';
import 'widgets/input_bar.dart';
import 'widgets/service.dart';
import 'package:firebase_auth/firebase_auth.dart'; //  اضافه مهمه

class SaveitChatScreen extends StatefulWidget {
  const SaveitChatScreen({super.key});

  @override
  State<SaveitChatScreen> createState() => _SaveitChatScreenState();
}

class _SaveitChatScreenState extends State<SaveitChatScreen> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _isThinking = false;

  List<ChatMessage> _oldMessages = []; // Store old chat for undo

  User? get _currentUser =>
      FirebaseAuth.instance.currentUser; //  المستخدم الحالي
  String get _chatKey =>
      "chat_history_${_currentUser?.uid ?? 'guest'}"; // مفتاح خاص
  bool get _isAnonymous => _currentUser?.isAnonymous ?? true; //  مجهول ولا لا

  @override
  void initState() {
    super.initState();
    if (!_isAnonymous) {
      _loadMessages(); //  بس لو مش مجهول
    }
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_chatKey);
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      setState(() {
        _messages.clear();
        _messages.addAll(
          decoded.map(
            (e) => ChatMessage(
              text: e['text'],
              isMe: e['isMe'],
              time: DateTime.parse(e['time']),
            ),
          ),
        );
      });
    }
  }

  Future<void> _saveMessages() async {
    if (_isAnonymous) return; //  ما يحفظش لو مجهول
    final prefs = await SharedPreferences.getInstance();
    final data = _messages
        .map(
          (m) => {
            'text': m.text,
            'isMe': m.isMe,
            'time': m.time.toIso8601String(),
          },
        )
        .toList();
    await prefs.setString(_chatKey, jsonEncode(data));
  }

  Future<void> _onSend(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.insert(
        0,
        ChatMessage(text: trimmed, isMe: true, time: DateTime.now()),
      );
      _isThinking = true;
    });
    await _saveMessages();

    try {
      final reply = await Service.sendMessage(trimmed);
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: reply.isEmpty
                ? "Sorry, I couldn't understand. Could you rephrase?"
                : reply,
            isMe: false,
            time: DateTime.now(),
          ),
        );
      });
      await _saveMessages();
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: "Network error. Please try again.",
            isMe: false,
            time: DateTime.now(),
          ),
        );
      });
      await _saveMessages();
    } finally {
      setState(() => _isThinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Saveit Chat',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isThinking ? 'Typing…' : 'Online',
                style: TextStyle(
                  fontSize: 12,
                  color: _isThinking ? const Color(0xFFFF9800) : Colors.green,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.add_comment,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2E7D32)
                    : Colors.green,
              ),
              tooltip: 'New Chat',
              onPressed: () async {
                // Save old messages for undo
                setState(() {
                  _oldMessages = List.from(_messages);
                  _messages.clear();
                });
                await _saveMessages(); // Save empty state
              },
            ),
            IconButton(
              icon: Icon(
                Icons.undo,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.orange[300]
                    : Colors.orange,
              ),
              tooltip: 'Undo',
              onPressed: _oldMessages.isEmpty
                  ? null
                  : () {
                      setState(() {
                        _messages.clear();
                        _messages.addAll(_oldMessages);
                        _oldMessages.clear();
                      });
                      _saveMessages();
                    },
            ),
          ],
        ),
        body: Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[50],
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: _messages.length + (_isThinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isThinking && index == 0) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ThinkingBubble(),
                        ),
                      );
                    }
                    final msg = _messages[_isThinking ? index - 1 : index];
                    return MessageStyle(message: msg);
                  },
                ),
              ),
              SafeArea(top: false, child: InputBar(onSend: _onSend)),
            ],
          ),
        ),
      ),
    );
  }
}
