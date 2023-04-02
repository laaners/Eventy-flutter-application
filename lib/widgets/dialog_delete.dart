import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../server/firebase_user.dart';

class DeleteDialog extends StatefulWidget {
  const DeleteDialog({super.key});

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          const Text(
              'This action cannot be undone. This will permanently delete your account.'),
          TextFormField(
            controller: _passwordController,
            obscureText: _passwordVisible,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
              hintText: 'Enter password',
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(fontStyle: FontStyle.italic),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll(Colors.red.withOpacity(0.5)),
              shadowColor:
                  MaterialStatePropertyAll(Colors.red.withOpacity(0.5))),
          onPressed: () async {
            bool reauthSuccess = await Provider.of<FirebaseUser>(context,
                    listen: false)
                .reauthenticationCurrentUser(context, _passwordController.text);
            if (reauthSuccess) {
              await Provider.of<FirebaseUser>(context, listen: false)
                  .deleteAccount(context);
              Navigator.pop(context, 'Delete');
            }
          },
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
