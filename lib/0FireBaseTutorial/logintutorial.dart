import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reddit_tutorial/0FireBaseTutorial/firebase_auth_methods.dart';

class LoginScreenTutorial extends StatefulWidget {
  const LoginScreenTutorial({super.key});

  @override
  State<LoginScreenTutorial> createState() => _LoginScreenTutorialState();
}

class _LoginScreenTutorialState extends State<LoginScreenTutorial> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void signUpUser() async {
    FirebaseAuthMethods(FirebaseAuth.instance).signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      context: context,
    );
  }

  void loginUser() async {
    FirebaseAuthMethods(FirebaseAuth.instance).loginWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: "Email",
            contentPadding: EdgeInsets.all(2),
          ),
        ),
        TextField(
          controller: _passwordController,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          decoration: const InputDecoration(
            hintText: "Password",
            contentPadding: EdgeInsets.all(2),
          ),
        ),
        TextButton(
          onPressed: signUpUser,
          child: const Text("Register"),
        ),
        TextButton(
          onPressed: loginUser,
          child: const Text("Sign in"),
        ),
      ],
    );
  }
}
