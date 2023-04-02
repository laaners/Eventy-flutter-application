import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(title: "", upRightActions: []),
      body: SignUpForm(),
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
  bool _usernameAlreadyExist = false;

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
      child: ListView(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _usernameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.face, color: Colors.grey),
                border: OutlineInputBorder(),
                labelText: 'Username',
                labelStyle: TextStyle(fontStyle: FontStyle.italic),
              ),
              onChanged: (username) async {
                // TODO: add delay to the call
                bool tmp =
                    await Provider.of<FirebaseUser>(context, listen: false)
                        .usernameAlreadyExists(username);
                setState(() {
                  _usernameAlreadyExist = tmp;
                  print(_usernameAlreadyExist);
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username cannot be empty';
                } else if (_usernameAlreadyExist) {
                  return 'Username already exists';
                }
                return null;
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.perm_identity, color: Colors.grey),
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
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: TextFormField(
              controller: _surnameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.perm_identity, color: Colors.grey),
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
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail, color: Colors.grey),
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
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _passwordInvisible,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
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
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: TextFormField(
              obscureText: _passwordInvisible,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
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
          ),
          MyButton(
            text: "SIGN UP",
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // ignore: use_build_context_synchronously
                if (await Provider.of<FirebaseUser>(context, listen: false)
                    .signUpWithEmail(
                  email: _emailController.text,
                  password: _passwordController.text,
                  username: _usernameController.text,
                  name: _nameController.text,
                  surname: _surnameController.text,
                  profilePic: "default",
                  context: context,
                )) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Welcome, ${_usernameController.text}!"),
                  ),
                );
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
    );
  }
}
