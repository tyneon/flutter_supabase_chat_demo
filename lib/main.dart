import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:supabase_chat/app_theme.dart';
import 'package:supabase_chat/cameras.dart';
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
  await Firebase.initializeApp();
  await Permission.notification.isDenied.then((isDenied) {
    if (isDenied) {
      Permission.notification.request();
    }
  });
  await Cameras.init();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsyncValue = ref.watch(authProvider);
    return MaterialApp(
      theme: appTheme,
      home: authAsyncValue.isLoading
          ? const Center(child: CircularProgressIndicator())
          : authAsyncValue.value != null
              ? const ChatsListScreen()
              : const LoginScreen(),
    );
  }
}
