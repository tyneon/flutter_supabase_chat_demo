import 'package:supabase_chat/providers/chat_messages_provider.dart';
import 'package:supabase_chat/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_chat/screens/chat_screen.dart';
import 'package:supabase_chat/models/chat.dart';
import 'package:supabase_chat/widgets/user_avatar.dart';

class ChatListTile extends ConsumerWidget {
  final Chat chat;
  const ChatListTile(this.chat, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topMessageAsyncValue = ref.watch(chatMessagesProvider(chat.id));
    final otherChatUserAsyncData =
        ref.watch(chatUserByIdProvider(chat.otherUserId));
    final name = otherChatUserAsyncData.value?.name ?? "Loading";
    final topMessage = topMessageAsyncValue.value?.lastOrNull;
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(chat),
          ),
        );
      },
      leading: UserAvatar(name),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(
            topMessage?.timestampString ?? "",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      subtitle: Text(
        otherChatUserAsyncData.isLoading
            ? "..."
            : topMessage?.text ?? "No messages",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
