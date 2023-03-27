import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangeProfileScreenState();
}

class _ChangeProfileScreenState extends State<ChangePasswordScreen> {
  final _formkey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _passwordInvisible = true;
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
        child: ListView(
          children: [
            // TODO: add current password check
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextFormField(
                controller: _passwordController,
                obscureText: _passwordInvisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
                  hintText: 'New password',
                  border: const OutlineInputBorder(),
                  labelText: 'Your new password',
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
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextFormField(
                obscureText: _passwordInvisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
                  hintText: 'New password',
                  border: const OutlineInputBorder(),
                  labelText: 'Confirm new password',
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
          ],
        ),
      ),
    );
  }
}
