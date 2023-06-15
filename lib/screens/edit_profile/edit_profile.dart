import 'dart:io';

import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/edit_profile/components/change_image.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/my_button.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();

  File? _photo;
  bool _initialRemoved = false;
  bool _usernameAlreadyExist = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.userData.username;
    _nameController.text = widget.userData.name;
    _surnameController.text = widget.userData.surname;
    _emailController.text = widget.userData.email;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "Edit Profile"),
      body: Builder(
        builder: (BuildContext context) {
          return ResponsiveWrapper(
            child: Form(
              key: _formkey,
              child: Scrollbar(
                child: ListView(
                  controller: ScrollController(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: LayoutConstants.kHorizontalPadding,
                  ),
                  children: [
                    const SizedBox(height: 20),
                    ChangeImage(
                        photo: _photo,
                        changePhoto: (File? newPhoto) {
                          setState(() {
                            _photo = newPhoto;
                          });
                        },
                        initialRemoved: _initialRemoved,
                        changeInitialRemoved: (bool value) {
                          setState(() {
                            _initialRemoved = value;
                          });
                        }),
                    const SizedBox(height: 40),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.face),
                        border: const OutlineInputBorder(),
                        hintText: widget.userData.username,
                        labelStyle:
                            const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onChanged: (username) async {
                        bool tmp = await Provider.of<FirebaseUser>(context,
                                listen: false)
                            .usernameAlreadyExists(username: username);
                        setState(() {
                          _usernameAlreadyExist = tmp;
                          print(_usernameAlreadyExist);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username cannot be empty';
                        } else if (_usernameAlreadyExist &&
                            widget.userData.username != value) {
                          return 'Username already exists';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.perm_identity),
                        border: const OutlineInputBorder(),
                        hintText: widget.userData.name,
                        labelStyle:
                            const TextStyle(fontStyle: FontStyle.italic),
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
                      controller: _surnameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.perm_identity),
                        //border: const OutlineInputBorder(),
                        hintText: widget.userData.surname,
                        //labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Surname cannot be empty';
                        }
                        return null;
                      },
                    ),
                    /*
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: widget.userData.email,
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.mail),
                        border: const OutlineInputBorder(),
                        hintText: widget.userData.email,
                        labelStyle: const TextStyle(fontStyle: FontStyle.italic),
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
                    */
                    const SizedBox(height: 50),
                    MyButton(
                      text: "SAVE",
                      onPressed: () async {
                        LoadingOverlay.show(context);
                        if (_formkey.currentState!.validate()) {
                          // ignore: use_build_context_synchronously
                          if (await Provider.of<FirebaseUser>(context,
                                  listen: false)
                              .updateUserData(
                            username: _usernameController.text,
                            name: _nameController.text,
                            surname: _surnameController.text,
                            email: _emailController.text,
                            profilePic: widget.userData.profilePic,
                            updateProfilePic: _initialRemoved,
                            photo: _photo,
                          )) {
                            // ignore: use_build_context_synchronously
                            LoadingOverlay.hide(context);

                            // ignore: use_build_context_synchronously
                            showSnackBar(
                                context, "Your information has been updated!");
                            setState(() {
                              _initialRemoved = false;
                            });
                            return;
                          }
                        }
                        // ignore: use_build_context_synchronously
                        LoadingOverlay.hide(context);
                      },
                    ),
                    Container(height: LayoutConstants.kPaddingFromCreate),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
