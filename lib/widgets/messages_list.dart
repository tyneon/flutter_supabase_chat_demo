import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';

import 'package:supabase_chat/models/message.dart';
import 'package:supabase_chat/providers/auth_provider.dart';
import 'package:supabase_chat/providers/chat_messages_provider.dart';
import 'package:supabase_chat/widgets/message_bubble.dart';

class MessagesList extends ConsumerWidget {
  final int chatId;
  const MessagesList(this.chatId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final messages = ref.watch(chatMessagesProvider(chatId));
    if (!messages.hasValue ||
        messages.value == null ||
        messages.value!.isEmpty) {
      return const Center(
        child: Text("Start messaging!"),
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      reverse: true,
      physics: const ScrollPhysics(),
      child: GroupedListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        elements: messages.value!,
        groupBy: (message) => message.groupDateTime,
        groupSeparatorBuilder: (value) => Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.only(
              top: 6,
              bottom: 4,
              left: 8,
              right: 8,
            ),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Text(
              Message.groupDateTimeString(value),
              // style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        itemBuilder: (context, message) => MessageBubble(
          message,
          weAreSender: auth == message.senderId,
        ),
        shrinkWrap: true,
      ),
    );
  }
}
