import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  final _storage = const FlutterSecureStorage();

  @override
  FutureOr<int?> build() async => autoLogin();

  Future<void> storeCredentials(
    String email,
    String password,
  ) async {
    await _storage.write(
      key: "credentials",
      value: json.encode(
        {
          'email': email,
          'password': password,
        },
      ),
    );
  }

  Future<int?> autoLogin() async {
    final data = await _storage.read(key: "credentials");
    if (data == null) {
      return null;
    }
    final credentials = json.decode(data);
    login(credentials['email'], credentials['password']);
    return null;
  }

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
    await storeCredentials(email, password);
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final data = await Supabase.instance.client.from('users').insert({
      'email': email,
      'name': name,
      'fcm_token': fcmToken,
    }).select();
    state = AsyncData(data.first['id']);
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
    await storeCredentials(email, password);
    final int userId = data.first['id'];
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (data.first['fcm_token'] != fcmToken) {
      await Supabase.instance.client.from('users').update({
        'fcm_token': fcmToken,
      }).eq('id', userId);
    }
    state = AsyncData(userId);
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    await _storage.delete(key: "credentials");
    state = const AsyncData(null);
  }
}
