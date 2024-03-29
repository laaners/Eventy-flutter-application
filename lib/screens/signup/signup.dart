import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // todo: remove appBar
      body: ResponsiveWrapper(
        hideNavigation: true,
        child: SignUpForm(),
      ),
      appBar: MyAppBar(title: "Sign Up", upRightActions: []),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordInvisible = true;

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scrollbar(
        child: ListView(
          controller: ScrollController(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 20),
            /*
            Text(
              "Sign Up",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(
              height: 30,
            ),
            */
            TextFormField(
              key: const Key("username_field"),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _usernameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.face),
                border: OutlineInputBorder(),
                labelText: 'Username',
                labelStyle: TextStyle(fontStyle: FontStyle.italic),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key("name_field"),
              controller: _nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.perm_identity),
                border: OutlineInputBorder(),
                labelText: 'Name',
                labelStyle: TextStyle(fontStyle: FontStyle.italic),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key("surname_field"),
              controller: _surnameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.perm_identity),
                border: OutlineInputBorder(),
                labelText: 'Surname',
                labelStyle: TextStyle(fontStyle: FontStyle.italic),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Surname cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key("email_field"),
              controller: _emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail),
                border: OutlineInputBorder(),
                labelText: 'E-mail',
                labelStyle: TextStyle(fontStyle: FontStyle.italic),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an e-mail address';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid e-mail address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key("password_field"),
              controller: _passwordController,
              obscureText: _passwordInvisible,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_open),
                hintText: 'Password',
                border: const OutlineInputBorder(),
                labelText: 'Your password',
                labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordInvisible = !_passwordInvisible;
                    });
                  },
                  icon: Icon(
                    _passwordInvisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key("password_confirm_field"),
              obscureText: _passwordInvisible,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_open),
                hintText: 'Password',
                border: const OutlineInputBorder(),
                labelText: 'Confirm password',
                labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordInvisible = !_passwordInvisible;
                    });
                  },
                  icon: Icon(
                    _passwordInvisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            MyButton(
              key: const Key("signup_button"),
              text: "SIGN UP",
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  LoadingOverlay.show(context);
                  // ignore: use_build_context_synchronously
                  var isNewUser =
                      await Provider.of<FirebaseUser>(context, listen: false)
                          .signUpWithEmail(
                    email: _emailController.text,
                    password: _passwordController.text,
                    username: _usernameController.text,
                    name: _nameController.text,
                    surname: _surnameController.text,
                    profilePic: "default",
                    context: context,
                  );
                  // ignore: use_build_context_synchronously
                  LoadingOverlay.hide(context);
                  if (!isNewUser) return;
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, {
                    "username": _usernameController.text,
                    "password": _passwordController.text,
                  });
                }
              },
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
