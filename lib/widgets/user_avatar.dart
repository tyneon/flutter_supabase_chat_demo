import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? name;
  const UserAvatar(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: name == null
          ? const CircularProgressIndicator()
          : Text(name!.substring(0, 3).toUpperCase()),
    );
  }
}
