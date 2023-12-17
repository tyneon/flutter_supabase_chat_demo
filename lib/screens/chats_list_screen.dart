import 'package:supabase_chat/providers/users_provider.dart';
import 'package:supabase_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_chat/providers/auth_provider.dart';
import 'package:supabase_chat/providers/chats_provider.dart';
import 'package:supabase_chat/widgets/chat_list_tile.dart';
import 'package:supabase_chat/widgets/user_list_tile.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsyncValue = ref.watch(chatsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supabase Chat Demo"),
        actions: [
          IconButton(
            onPressed: ref.read(authProvider.notifier).logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const Dialog(child: ChatUsersList()),
          );
        },
        child: const Icon(Icons.message),
      ),
      body: switch (chatsAsyncValue) {
        AsyncData(:final value) => value.isNotEmpty
            ? ListView(
                children: value.map((chat) => ChatListTile(chat)).toList(),
              )
            : const Center(
                child: Text("Start chatting!"),
              ),
        AsyncError(:final error, :final stackTrace) => Center(
            child: Text(
              "ERROR: $error",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        _ => const Center(
            child: CircularProgressIndicator(),
          ),
      },
    );
  }
}

class ChatUsersList extends ConsumerWidget {
  const ChatUsersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsyncValue = ref.watch(allUsersProvider);
    final auth = ref.watch(authProvider);
    if (auth == null) {
      throw Exception("Not authenticated");
    }
    if (usersAsyncValue.hasError) {
      return Text('ERROR: ${usersAsyncValue.error}');
    }
    if (usersAsyncValue.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: usersAsyncValue.value!
          .map((user) => UserListTile(
                user,
                onTap: () {
                  Navigator.of(context).pop();
                  ref
                      .watch(createChatProvider(
                        auth,
                        user.id,
                      ))
                      .when(
                        data: (chat) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(chat),
                            ),
                          );
                        },
                        loading: () {},
                        error: (error, stackTrace) {
                          print(error);
                          print(stackTrace);
                        },
                      );
                },
              ))
          .toList(),
    );
  }
}
