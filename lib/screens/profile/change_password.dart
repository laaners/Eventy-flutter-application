import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

import '../../server/firebase_user.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangeProfileScreenState();
}

class _ChangeProfileScreenState extends State<ChangePasswordScreen> {
  final _formkey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordInvisibleOld = true;
  bool _passwordInvisibleNew = true;
  bool _modified = false;

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("Change password"),
      body: Form(
        key: _formkey,
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextFormField(
                controller: _currentPasswordController,
                obscureText: _passwordInvisibleOld,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
                  hintText: 'Current password',
                  border: const OutlineInputBorder(),
                  labelText: 'Your password',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordInvisibleOld = !_passwordInvisibleOld;
                      });
                    },
                    icon: Icon(
                      _passwordInvisibleOld
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
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
              child: TextFormField(
                controller: _passwordController,
                obscureText: _passwordInvisibleNew,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
                  hintText: 'New password',
                  border: const OutlineInputBorder(),
                  labelText: 'Your new password',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordInvisibleNew = !_passwordInvisibleNew;
                      });
                    },
                    icon: Icon(
                      _passwordInvisibleNew
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
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextFormField(
                obscureText: _passwordInvisibleNew,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
                  hintText: 'New password',
                  border: const OutlineInputBorder(),
                  labelText: 'Confirm new password',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordInvisibleNew = !_passwordInvisibleNew;
                      });
                    },
                    icon: Icon(
                      _passwordInvisibleNew
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
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formkey.currentState!.validate()) {
                    bool reauthSuccess =
                        await Provider.of<FirebaseUser>(context, listen: false)
                            .reauthenticationCurrentUser(
                                context, _currentPasswordController.text);
                    if (reauthSuccess) {
                      await Provider.of<FirebaseUser>(context, listen: false)
                          .updateCurrentUserPassword(
                              context, _passwordController.text);
                    }
                  }
                },
                style: const ButtonStyle(
                  padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(
                      EdgeInsets.all(20)),
                ),
                child: const Text(
                  "SAVE",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
