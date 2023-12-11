import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_chat/providers/auth_provider.dart';
import 'package:supabase_chat/models/chat.dart';

part 'chats_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<int>> chatIds(ChatIdsRef ref) {
  final userId = ref.watch(authProvider);
  if (userId == null) {
    throw Exception("Not authenticated");
  }
  final snapshots = Supabase.instance.client
      .from('usersChats')
      .stream(primaryKey: ['id']).eq('userId', userId);
  return snapshots.map(
      (snapshot) => snapshot.map((data) => data['chatId'] as int).toList());
}

@Riverpod(keepAlive: true)
Future<List<Chat>> chats(ChatsRef ref) async {
  final userId = ref.watch(authProvider);
  if (userId == null) {
    throw Exception("Not authenticated");
  }
  final ids = ref.watch(chatIdsProvider);
  if (ids.hasValue) {
    final chats = <Chat>[];
    for (final id in ids.value ?? []) {
      final chatData = ((await Supabase.instance.client
              .from('usersChats')
              .select()
              .eq('chatId', id)
              .neq('userId', userId)) as List<Map<String, dynamic>>)
          .first;
      chats.add(Chat(
        id: id,
        otherUserId: chatData['userId'],
      ));
    }
    return chats;
  }
  return [];
}

@riverpod
Future<Chat> createChat(
  CreateChatRef ref,
  int userId,
  int otherUserId,
) async {
  final chatId = await Supabase.instance.client
      .from('chats')
      .insert({}).select('id') as int;
  await Supabase.instance.client.from('usersChats').insert([
    {
      'userId': userId,
      'chatId': chatId,
    },
    {
      'userId': otherUserId,
      'chatId': chatId,
    }
  ]);
  return Chat(id: chatId, otherUserId: otherUserId);
}
