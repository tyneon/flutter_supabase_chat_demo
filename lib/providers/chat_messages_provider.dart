import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_chat/models/message.dart';

part 'chat_messages_provider.g.dart';

@riverpod
Stream<List<Message>> chatMessages(
  ChatMessagesRef ref,
  int chatId,
) {
  final snapshots = Supabase.instance.client
      .from('messages')
      .stream(primaryKey: ['id']).eq('chatId', chatId);

  return snapshots.map((snapshot) {
    final messages = <Message>[];
    for (final data in snapshot) {
      messages.add(Message.fromJson(data));
    }
    return messages;
  });
}

Future<void> sendMessage(int chatId, int senderId, String text) async {
  await Supabase.instance.client.from('messages').insert(
        Message.newMessageToJson(
          chatId: chatId,
          senderId: senderId,
          text: text,
        ),
      );
}
