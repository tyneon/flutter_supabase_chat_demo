import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_chat/models/chat_user.dart';
import 'package:supabase_chat/providers/auth_provider.dart';

part 'users_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<ChatUser> userData(UserDataRef ref) {
  final userId = ref.watch(authProvider);
  if (userId == null) {
    throw Exception("Not authenticated");
  }
  final snapshots = Supabase.instance.client
      .from('users')
      .stream(primaryKey: ['id']).eq('id', userId);
  return snapshots.map((snapshot) => ChatUser.fromJson(snapshot.first));
}

@riverpod
Future<ChatUser> chatUserById(ChatUserByIdRef ref, int id) async {
  final data =
      await Supabase.instance.client.from('users').select().eq('id', id);
  return ChatUser.fromJson((data as List<Map<String, dynamic>>).first);
}

@riverpod
Future<List<ChatUser>> allUsers(AllUsersRef ref) async {
  final data = await Supabase.instance.client.from('users').select();
  if (data.isEmpty) return <ChatUser>[];
  return data.map((item) => ChatUser.fromJson(item)).toList();
}
