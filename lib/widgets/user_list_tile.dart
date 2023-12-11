import 'package:flutter/material.dart';

import 'package:supabase_chat/models/chat_user.dart';

class UserListTile extends StatelessWidget {
  final ChatUser user;
  final Function()? onTap;
  const UserListTile(this.user, {this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Text(user.name.substring(0, 3).toUpperCase()),
      ),
      title: Text(user.name),
    );
  }
}
