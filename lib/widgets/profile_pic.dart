import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screen_transition.dart';
import 'show_user_dialog.dart';

class ProfilePicFromData extends StatelessWidget {
  final UserModel userData;
  final double? radius;
  final bool? showUserName;
  final bool? notShowDialog;
  const ProfilePicFromData({
    super.key,
    this.radius,
    required this.userData,
    this.showUserName,
    this.notShowDialog,
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

  Widget profilePicBody(context) {
    double radiusVar = radius ?? LayoutConstants.kProfilePicRadiusSmall;
    return InkWell(
      onTap: notShowDialog != null && notShowDialog == true
          ? null
          : () {
              showUserDialog(context: context, user: userData);
            },
      child: CircleAvatar(
        radius: radiusVar,
        backgroundColor: Theme.of(context).primaryColor,
        child: userData.profilePic != "default"
            ? ClipRRect(
                borderRadius: BorderRadius.circular(radiusVar),
                child: Image.network(
                  userData.profilePic,
                  width: radiusVar * 2,
                  height: radiusVar * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return capitalNameSurnameAvatar(context);
                  },
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress != null) {
                      return capitalNameSurnameAvatar(context);
                    } else {
                      return child;
                    }
                  },
                ),
              )
            : capitalNameSurnameAvatar(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double radiusVar = radius ?? LayoutConstants.kProfilePicRadiusSmall;
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return showUserName != null && showUserName!
        ? Container(
            margin: const EdgeInsets.all(5),
            width: radiusVar * 2 + 5,
            child: Column(
              children: [
                profilePicBody(context),
                const SizedBox(height: 4),
                Text(
                  curUid == userData.uid ? "You" : userData.username,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        : profilePicBody(context);
  }
}

class ProfilePicFromUid extends StatefulWidget {
  final String userUid;
  final double? radius;
  final bool? maintainState;
  final bool? showUserName;
  final bool? notShowDialog;
  const ProfilePicFromUid({
    super.key,
    required this.userUid,
    this.radius,
    this.maintainState,
    this.showUserName,
    this.notShowDialog,
  });

  @override
  State<ProfilePicFromUid> createState() => _UserTileFromUidState();
}

class _UserTileFromUidState extends State<ProfilePicFromUid> {
  Future<UserModel?>? _future;

  @override
  initState() {
    super.initState();
    _future = Provider.of<FirebaseUser>(context, listen: false)
        .getUserData(uid: widget.userUid);
  }

  @override
  Widget build(BuildContext context) {
    double radiusVar = widget.radius ?? LayoutConstants.kProfilePicRadiusSmall;
    return FutureBuilder(
      future: widget.maintainState != null && widget.maintainState!
          ? _future
          : Provider.of<FirebaseUser>(context, listen: false)
              .getUserData(uid: widget.userUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.showUserName != null && widget.showUserName!
              ? Container(
                  margin: const EdgeInsets.all(5),
                  width: 75,
                  child: Column(
                    children: [
                      SizedBox(
                        height: radiusVar * 2,
                        width: radiusVar * 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "...",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: radiusVar * 2,
                  width: radiusVar * 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              ScreenTransition(
                builder: (context) => ErrorScreen(
                  errorMsg: snapshot.error.toString(),
                ),
              ),
            );
          });
          return Container();
        }
        UserModel userData = snapshot.data!;
        return ProfilePicFromData(
          userData: userData,
          radius: widget.radius,
          showUserName: widget.showUserName,
          notShowDialog: widget.notShowDialog,
        );
      },
    );
  }
}
