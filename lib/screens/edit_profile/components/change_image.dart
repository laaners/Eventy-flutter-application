import 'dart:io';
import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChangeImage extends StatefulWidget {
  final File? photo;
  final ValueChanged<File?> changePhoto;
  final bool initialRemoved;
  final ValueChanged<bool> changeInitialRemoved;
  const ChangeImage({
    super.key,
    this.photo,
    required this.changePhoto,
    required this.initialRemoved,
    required this.changeInitialRemoved,
  });

  @override
  State<ChangeImage> createState() => _ChangeImageState();
}

class _ChangeImageState extends State<ChangeImage> {
  bool loading = false;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        widget.changePhoto(File(pickedFile.path));
        // uploadFile(context);
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
        widget.changePhoto(File(pickedFile.path));
        // uploadFile(context);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          StreamBuilder(
            stream: Provider.of<FirebaseUser>(context, listen: false)
                .getCurrentUserStream(),
            builder: (
              BuildContext context,
              AsyncSnapshot<UserModel> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingSpinner();
              }
              return ProfilePicTemporary(
                userData: snapshot.data!,
                loading: loading,
                radius: LayoutConstants.kProfilePicRadiusLarge,
                imageFile: widget.photo,
                initialRemoved: widget.initialRemoved,
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
                setState(() {
                  widget.changePhoto(null);
                  widget.changeInitialRemoved(true);
                });
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

class ProfilePicTemporary extends StatelessWidget {
  final UserModel userData;
  final bool loading;
  final double radius;
  final File? imageFile;
  final bool initialRemoved;
  const ProfilePicTemporary({
    super.key,
    required this.userData,
    required this.loading,
    required this.radius,
    this.imageFile,
    required this.initialRemoved,
  });

  Widget capitalNameSurnameAvatar(context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "${userData.name[0].toUpperCase()}${userData.surname[0].toUpperCase()}",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).primaryColor,
      child: imageFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.file(
                imageFile!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.fill,
              ),
            )
          : userData.profilePic != "default" && !initialRemoved
              ? (loading
                  ? capitalNameSurnameAvatar(context)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: Image.network(
                        userData.profilePic,
                        width: radius * 2,
                        height: radius * 2,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress != null) {
                            return capitalNameSurnameAvatar(context);
                          } else {
                            return child;
                          }
                        },
                      ),
                    ))
              : capitalNameSurnameAvatar(context),
    );
  }
}
