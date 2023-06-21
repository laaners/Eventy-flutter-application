import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/show_user_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InviteProfilePic extends StatelessWidget {
  final List<UserModel> invitees;
  final List<UserModel> originalInvitees;
  final ValueChanged<UserModel> addInvitee;
  final ValueChanged<UserModel> removeInvitee;
  final UserModel user;
  final bool addMode;
  final String organizerUid;
  const InviteProfilePic({
    super.key,
    required this.addInvitee,
    required this.removeInvitee,
    required this.addMode,
    required this.invitees,
    required this.user,
    required this.originalInvitees,
    required this.organizerUid,
  });

  Widget? getTopIcon(context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    bool isOrganizer = organizerUid == curUid;
    bool isInOriginalInvitees =
        originalInvitees.map((e) => e.uid).contains(user.uid);
    // show nothing if in cancelmode and organizer != curUid and user is in original invitees
    // or user is curuid
    if ((!addMode && !isOrganizer && isInOriginalInvitees) ||
        curUid == user.uid) {
      return null;
    }
    // show cancel if in cancelmode, not organizer but newly added user isn't in original invitees
    if (!addMode && !isOrganizer && !isInOriginalInvitees) {
      return Positioned(
        right: -10.0,
        top: -10.0,
        child: IconButton(
          iconSize: 25,
          padding: const EdgeInsets.all(0),
          constraints: const BoxConstraints(),
          icon: Icon(
            addMode ? Icons.add_circle : Icons.cancel,
            color: addMode
                ? Theme.of(context).primaryColorLight
                : Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            addMode ? addInvitee(user) : removeInvitee(user);
          },
        ),
      );
    }
    // show anything if organizer or in add mode (default)
    return Positioned(
      right: -5,
      top: -5,
      child: MyIconButton(
        icon: Icon(
          size: LayoutConstants.kIconSize,
          addMode ? Icons.add_circle : Icons.cancel,
          color: addMode
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).colorScheme.error,
        ),
        onTap: () {
          addMode ? addInvitee(user) : removeInvitee(user);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return InkWell(
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            width: 75,
            child: Column(
              children: [
                ProfilePic(
                  userData: user,
                  loading: false,
                  radius: 35,
                ),
                Container(padding: const EdgeInsets.symmetric(vertical: 2)),
                Text(
                  curUid == user.uid ? "You" : user.username,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // show nothing if in cancelmode and organizer != curUid and user is in original invitees
          getTopIcon(context) ?? Container()
        ],
      ),
      onTap: () {
        showUserDialog(context: context, user: user);
      },
    );
  }
}
