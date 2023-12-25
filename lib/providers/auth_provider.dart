import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  int? build() => null;

  Future<void> signUp(
    String email,
    String password,
    String name,
  ) async {
    final AuthResponse res = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    // TODO handle error
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final data = await Supabase.instance.client.from('users').insert({
      'email': email,
      'name': name,
      'fcm_token': fcmToken,
    }).select();
    state = data.first['id'];
  }

  Future<void> login(String email, String password) async {
    final AuthResponse res =
        await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    // TODO handle error
    final data = await Supabase.instance.client
        .from('users')
        .select()
        .eq('email', email);
    if (data.isEmpty) {
      throw Exception("No user data found for email $email");
    }
    final int userId = data.first['id'];
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (data.first['fcm_token'] != fcmToken) {
      await Supabase.instance.client.from('users').update({
        'fcm_token': fcmToken,
      }).eq('id', userId);
    }
    state = userId;
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    state = null;
  }
}
