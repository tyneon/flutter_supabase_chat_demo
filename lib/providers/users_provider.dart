import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_chat/models/chat_user.dart';
import 'package:supabase_chat/providers/auth_provider.dart';

part 'users_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<ChatUser> userData(UserDataRef ref) {
  final authAsyncValue = ref.watch(authProvider);
  if (authAsyncValue.hasError || authAsyncValue.value == null) {
    throw Exception("Not authenticated");
  }
  final userId = authAsyncValue.value!;
  final snapshots = Supabase.instance.client
      .from('users')
      .stream(primaryKey: ['id']).eq('id', userId);
  return snapshots.map((snapshot) => ChatUser.fromJson(snapshot.first));
}

@riverpod
Future<ChatUser> chatUserById(ChatUserByIdRef ref, int id) async {
  final data =
      await Supabase.instance.client.from('users').select().eq('id', id);
  return ChatUser.fromJson(data.first);
}

@riverpod
Future<List<ChatUser>> allUsers(AllUsersRef ref) async {
  final data = await Supabase.instance.client.from('users').select();
  List<ChatUser> value = [];
  for (final item in data) {
    value.add(ChatUser.fromJson(item));
  }
  return value;
}
