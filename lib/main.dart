import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_chat/app_theme.dart';
import 'package:supabase_chat/supabase_config.dart' as supabase;
import 'package:supabase_chat/providers/auth_provider.dart';
import 'package:supabase_chat/screens/chats_list_screen.dart';
import 'package:supabase_chat/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabase.projectUrl,
    anonKey: supabase.anonKey,
  );
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider) != null;
    return MaterialApp(
      theme: appTheme,
      home: isLoggedIn ? const ChatsListScreen() : const LoginScreen(),
    );
  }
}
