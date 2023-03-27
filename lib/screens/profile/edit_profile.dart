import 'package:dima_app/screens/profile/change_image.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../server/firebase_user.dart';
import '../../server/tables/user_collection.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  late UserCollection? userData;

  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _usernameAlreadyExist = false;

  @override
  void initState() {
    // TODO: implement initState
    userData = Provider.of<FirebaseUser>(context, listen: false).userData;

    _usernameController.text = userData!.username;
    _nameController.text = userData!.name;
    _surnameController.text = userData!.surname;
    _emailController.text = userData!.email;

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Edit Profile",
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
      body: Form(
        key: _formkey,
        // TODO: (?) remove update button and make the update on back button using
        // onWillpop attribute which intercepts the pop of the screen and checks
        // whether the data inserted is valid
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: ChangeImage(),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _usernameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.face, color: Colors.grey),
                  border: OutlineInputBorder(),
                  hintText: userData!.username,
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
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.perm_identity, color: Colors.grey),
                  border: OutlineInputBorder(),
                  hintText: userData!.name,
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
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextFormField(
                controller: _surnameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.perm_identity, color: Colors.grey),
                  border: OutlineInputBorder(),
                  hintText: userData!.surname,
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
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.mail, color: Colors.grey),
                  border: OutlineInputBorder(),
                  hintText: userData!.email,
                  labelStyle: TextStyle(fontStyle: FontStyle.italic),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an e-mail address';
                  }
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid e-mail address';
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
                    // TODO: add updateUserData() here or in onWillPopAttribute,
                    // in the second case the info is update pressing back: if the
                    // operation is successful pop the window else display error message.
                    // ignore: use_build_context_synchronously
                    //await Provider.of<FirebaseUser>(context, listen: false).updateUserData(context, username, name, surname, email))
                    ScaffoldMessenger.of(context).showSnackBar(
                      // TODO: personalize message.
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
                  "UPDATE",
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
