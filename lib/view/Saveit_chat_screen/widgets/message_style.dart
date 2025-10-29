import 'package:flutter/material.dart';
import 'chat_message.dart';

class MessageStyle extends StatelessWidget {
  final ChatMessage message;

  const MessageStyle({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isMe
        ? const Color(0xFF2E7D32) // Green for user messages
        : isDark
        ? Colors.grey[800] // Dark gray for assistant in dark mode
        : Colors.grey[200]; // Light gray for assistant in light mode

    final fg = isMe || isDark ? Colors.white : Colors.black87;

    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.all(
              color: isMe
                  ? Colors.green[700] ?? Colors.green
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: align,
            children: [
              Text(message.text, style: TextStyle(color: fg, fontSize: 15)),
              const SizedBox(height: 4),
              Text(
                "${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}",
                style: TextStyle(
                  fontSize: 11,
                  color: isMe ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
