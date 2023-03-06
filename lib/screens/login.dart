import 'package:dima_app/screens/signup.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_switch.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // todo: remove appBar
      appBar: MyAppBar("Log In"),
      body: LogInForm(),
    );
  }
}

class LogInForm extends StatefulWidget {
  const LogInForm({super.key});

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _rememberUser = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextButton(
          onPressed: () async {
            LoadingOverlay.show(context);
            await Provider.of<FirebaseUser>(context, listen: false)
                .loginWithEmail(
              email: "test13@test.it", //"ok@ok.it",
              password: "password",
              context: context,
            );
            LoadingOverlay.hide(context);
          },
          child: const Text("Firebase login"),
        ),
        const SizedBox(
          height: 50,
        ),
        const Image(
          image: AssetImage('images/logo.png'),
          height: 80,
        ),
        const Center(
          child: Text(
            "Eventy",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.normal,
              letterSpacing: 4,
            ),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.fromLTRB(22, 0, 0, 0),
          child: const Text(
            "Log In",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('images/logo.png')),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                child: TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.face, color: Colors.grey),
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    labelStyle: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  validator: (value) {
                    // todo: check if username already exists
                    if (value == null || value.isEmpty) {
                      return 'Enter your username';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: TextFormField(
                  obscureText: _passwordVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
                    hintText: 'Password',
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(children: [
                  Switch(
                    value: _rememberUser,
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        _rememberUser = value;
                        // todo: save credentials in secure storage if _rememberUser is true AND user is authenticated
                        // https://pub.dev/packages/flutter_secure_storage
                      });
                    },
                  ),
                  const Text(
                    "Remember me",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // todo: add transition to forgot password process
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ]),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Processing Data'),
                        ),
                      );
                    }
                  },
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(
                        EdgeInsets.all(20)),
                  ),
                  child: const Text(
                    "LOG IN",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
