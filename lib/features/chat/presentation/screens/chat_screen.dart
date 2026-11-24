import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveit/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saveit/features/chat/presentation/widgets/message_style.dart';
import 'package:saveit/features/chat/presentation/widgets/thinking_bubble.dart';
import 'package:saveit/features/chat/presentation/widgets/input_bar.dart';

class SaveitChatScreen extends StatelessWidget {
  const SaveitChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ChatCubit>();
    final state = cubit.state;
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
                state.isThinking ? 'Typing…' : 'Online',
                style: TextStyle(
                  fontSize: 12,
                  color: state.isThinking
                      ? const Color(0xFFFF9800)
                      : Colors.green,
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
              onPressed: cubit.newChat,
            ),
            IconButton(
              icon: Icon(
                Icons.undo,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.orange[300]
                    : Colors.orange,
              ),
              tooltip: 'Undo',
              onPressed: state.canUndo ? cubit.undo : null,
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
                  itemCount: state.messages.length + (state.isThinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (state.isThinking && index == 0) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ThinkingBubble(),
                        ),
                      );
                    }
                    final msg =
                        state.messages[state.isThinking ? index - 1 : index];
                    return MessageStyle(message: msg);
                  },
                ),
              ),
              SafeArea(top: false, child: InputBar(onSend: cubit.send)),
            ],
          ),
        ),
      ),
    );
  }
}
