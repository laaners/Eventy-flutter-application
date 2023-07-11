import 'package:dima_app/screens/password_reset/password_reset.dart';
import 'package:dima_app/screens/signup/signup.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/logo.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // todo: remove appBar
      body: ResponsiveWrapper(
        hideNavigation: true,
        child: LogInForm(),
      ),
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

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordInvisible = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        controller: ScrollController(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          /*
          TextButton(
            key: GlobalKey(debugLabel: 'test1'),
            onPressed: () async {
              LoadingOverlay.show(context);
              await Provider.of<FirebaseUser>(context, listen: false)
                  .logInWithUsername(
                      context: context,
                      username: "usernameId17",
                      password: "password");
              // ignore: use_build_context_synchronously
              LoadingOverlay.hide(context);
            },
            child: const Text("Firebase login17"),
          ),
          TextButton(
            key: GlobalKey(debugLabel: 'test1'),
            onPressed: () async {
              LoadingOverlay.show(context);
              await Provider.of<FirebaseUser>(context, listen: false)
                  .logInWithUsername(
                      context: context, username: "Ale", password: "password");
              // ignore: use_build_context_synchronously
              LoadingOverlay.hide(context);
            },
            child: const Text("Firebase login Ale"),
          ),
          */

          const SizedBox(height: 60),
          const EventyLogo(extWidth: 180),
          const SizedBox(height: 20),
          Text(
            "Eventy",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 20),
          Text(
            "Log In",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  key: const Key("username_field"),
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.face),
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
                const SizedBox(height: 25),
                TextFormField(
                  key: const Key("password_field"),
                  controller: _passwordController,
                  obscureText: _passwordInvisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_open),
                    hintText: 'Password',
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
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
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }
                    return null;
                  },
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextButton(
                    onPressed: () {
                      Widget newScreen = const PasswordResetScreen();
                      Navigator.of(context, rootNavigator: false).push(
                        ScreenTransition(
                          builder: (context) => newScreen,
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(
                  key: const Key("login_button"),
                  text: "LOG IN",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      LoadingOverlay.show(context);
                      await Provider.of<FirebaseUser>(context, listen: false)
                          .logInWithUsername(
                        context: context,
                        username: _usernameController.text,
                        password: _passwordController.text,
                      );
                      // ignore: use_build_context_synchronously
                      LoadingOverlay.hide(context);
                    }
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextButton(
                      key: const Key("log_in_to_sign_up_screen"),
                      onPressed: () async {
                        Widget newScreen = const SignUpScreen();
                        final ris =
                            await Navigator.of(context, rootNavigator: false)
                                .push(
                          ScreenTransition(
                            builder: (context) => newScreen,
                          ),
                        );
                        if (ris != null) {
                          Map<String, dynamic> user =
                              ris as Map<String, dynamic>;
                          // ignore: use_build_context_synchronously
                          LoadingOverlay.show(context);
                          // ignore: use_build_context_synchronously
                          await Provider.of<FirebaseUser>(context,
                                  listen: false)
                              .logInWithUsername(
                            context: context,
                            username: user["username"],
                            password: user["password"],
                          );
                          // ignore: use_build_context_synchronously
                          LoadingOverlay.hide(context);
                        }
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
