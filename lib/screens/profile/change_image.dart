import 'dart:io';

import 'package:dima_app/themes/layout_constants.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';
import 'package:path/path.dart';

class ChangeImage extends StatefulWidget {
  const ChangeImage({super.key});

  @override
  State<ChangeImage> createState() => _ChangeImageState();
}

class _ChangeImageState extends State<ChangeImage> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  bool loading = false;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile(context);
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera(BuildContext context) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 30,
    );

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile(context);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile(BuildContext context) async {
    if (_photo == null) return;
    setState(() {
      loading = true;
    });
    final userId = Provider.of<FirebaseUser>(context, listen: false)
        .user
        ?.uid; // basename(_photo!.path);
    final destination = 'profile_pics/$userId';
    try {
      var ref =
          firebase_storage.FirebaseStorage.instance.ref().child(destination);
      await ref.putFile(_photo!);
      String profileUrl = await ref.getDownloadURL();
      // ignore: use_build_context_synchronously
      await Provider.of<FirebaseUser>(context, listen: false)
          .updateProfilePic(context, profileUrl);
      print(url);
      setState(() {
        loading = false;
      });
    } catch (e) {
      print('error occured');
    }
  }

  Future removePhoto(BuildContext context) async {
    setState(() {
      loading = true;
    });
    final userId = Provider.of<FirebaseUser>(context, listen: false)
        .user
        ?.uid; // basename(_photo!.path);
    try {
      await Provider.of<FirebaseUser>(context, listen: false)
          .updateProfilePic(context, "default");
      setState(() {
        loading = false;
      });
    } catch (e) {
      print('error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Consumer<FirebaseUser>(
            builder: (context, value, child) {
              return ProfilePic(
                userData: value.userData,
                loading: loading,
                radius: LayoutConstants.kProfilePicRadiusLarge,
              );
            },
          ),
          Container(
            // translate the button to the top right corner
            transform: Matrix4.identity()
              ..translate(LayoutConstants.kProfilePicRadiusLarge / 1.414,
                  -LayoutConstants.kProfilePicRadiusLarge / 1.414, 0.0),
            child: ElevatedButton(
              onPressed: () {
                removePhoto(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(LayoutConstants.kIconPadding),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.close, size: LayoutConstants.kIconSize),
            ),
          ),
          Container(
            // translate the button to the bottom left corner
            transform: Matrix4.identity()
              ..translate(LayoutConstants.kProfilePicRadiusLarge / 1.414,
                  LayoutConstants.kProfilePicRadiusLarge / 1.414, 0.0),
            child: ElevatedButton(
              onPressed: () async {
                _showPicker(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(LayoutConstants.kIconPadding),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.photo_camera,
                  size: LayoutConstants.kIconSize),
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text(
                    'Gallery',
                  ),
                  onTap: () {
                    imgFromGallery(context);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text(
                  'Camera',
                ),
                onTap: () {
                  imgFromCamera(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
