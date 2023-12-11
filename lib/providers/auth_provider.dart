import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

// TODO
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  int? build() => null;

  void login() {
    state = 1;
  }

  void logout() {
    state = null;
  }
}
