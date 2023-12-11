import 'package:supabase_chat/providers/chat_messages_provider.dart';
import 'package:supabase_chat/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_chat/models/chat.dart';
import 'package:supabase_chat/providers/auth_provider.dart';
import 'package:supabase_chat/providers/chats_provider.dart';
import 'package:supabase_chat/providers/users_provider.dart';
import 'package:supabase_chat/widgets/message_input.dart';
import 'package:supabase_chat/widgets/messages_list.dart';
import 'package:supabase_chat/widgets/user_avatar.dart';

class ChatScreen extends ConsumerWidget {
  final Chat chat;
  const ChatScreen(this.chat, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUserAsyncValue =
        ref.watch(chatUserByIdProvider(chat.otherUserId));
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            UserAvatar(otherUserAsyncValue.value?.name),
            const SizedBox(width: 10),
            Text(otherUserAsyncValue.value?.name ?? "Loading"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: MessagesList(chat.id)),
          MessageInput(chat.id),
        ],
      ),
    );
  }
}
