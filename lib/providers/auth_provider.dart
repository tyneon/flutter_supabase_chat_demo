import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

// TODO
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
    final data = await Supabase.instance.client.from('users').insert({
      'email': email,
      'name': name,
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
    state = data.first['id'];
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    state = null;
  }
}
