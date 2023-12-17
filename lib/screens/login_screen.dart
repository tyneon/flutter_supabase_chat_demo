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
  String name = "";
  String email = "";
  String password = "";
  bool createAccount = false;

  void submitForm() {
    if (!form.currentState!.validate()) {
      return;
    }
    form.currentState!.save();
    if (createAccount) {
      ref.read(authProvider.notifier).signUp(email, password, name);
    } else {
      ref.read(authProvider.notifier).login(email, password);
    }
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
                  decoration: const InputDecoration(
                    labelText: "Your name",
                  ),
                  validator: (value) {
                    if (value == null || value == "") {
                      return "Password too short";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    name = newValue!;
                  },
                ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "E-mail",
                ),
                validator: (value) {
                  if (value == null || value == "") {
                    return "Password too short";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  email = newValue!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Password",
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Password too short";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  password = newValue!;
                },
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
