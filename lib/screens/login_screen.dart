import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_chat/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final form = GlobalKey<FormState>();
  bool createAccount = false;

  void submitForm() {
    if (!form.currentState!.validate()) {
      return;
    }
    form.currentState!.save();
    // TODO
    ref.read(authProvider.notifier).login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: form,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (createAccount)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Your name",
                  ),
                ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "E-mail",
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Password",
                ),
              ),
              if (createAccount)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Repeat password",
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: submitForm,
                child: Text(createAccount ? "Register" : "Log in"),
              ),
              const SizedBox(height: 20),
              Text(createAccount
                  ? "Already have an account?"
                  : "Don't have an account?"),
              TextButton(
                onPressed: () {
                  setState(() {
                    createAccount = !createAccount;
                  });
                },
                child: Text(createAccount
                    ? "Log in with existing account"
                    : "Create an account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
