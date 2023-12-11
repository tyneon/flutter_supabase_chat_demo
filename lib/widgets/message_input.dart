import 'package:supabase_chat/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_chat/providers/auth_provider.dart';
import 'package:supabase_chat/providers/chat_messages_provider.dart';
import 'package:supabase_chat/models/chat.dart';

class MessageInput extends ConsumerWidget {
  final int chatId;
  const MessageInput(this.chatId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth == null) {
      throw Exception("Not auth");
    }
    final textController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(
                color: colorScheme.onBackground,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15),
                isDense: true,
              ),
              controller: textController,
              minLines: 1,
              maxLines: 4,
            ),
          ),
          IconButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                sendMessage(chatId, auth, textController.text);
                textController.clear();
              }
            },
            icon: const Icon(Icons.send),
            color: colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}
