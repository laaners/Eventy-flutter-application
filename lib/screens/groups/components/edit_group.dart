import 'package:dima_app/models/group_model.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/poll_create/components/step_invite.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditGroup extends StatefulWidget {
  final GroupModel group;
  const EditGroup({super.key, required this.group});

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  Future<List<UserModel>>? _future;

  @override
  void initState() {
    super.initState();
    _future = Provider.of<FirebaseUser>(context, listen: false)
        .getUsersDataFromList(uids: widget.group.membersUids);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingLogo();
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
        List<UserModel> usersData = snapshot.data!;
        return EditGroupBody(
            groupName: widget.group.groupName, members: usersData);
      },
    );
  }
}

class EditGroupBody extends StatefulWidget {
  final String groupName;
  final List<UserModel> members;
  const EditGroupBody(
      {super.key, required this.members, required this.groupName});

  @override
  State<EditGroupBody> createState() => _EditGroupBodyState();
}

class _EditGroupBodyState extends State<EditGroupBody> {
  List<UserModel> members = [];
  TextEditingController groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    members = widget.members;
    groupNameController.text = widget.groupName;
  }

  void checkFields() async {
    final userUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;

    bool ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: members.isEmpty,
      title: "Empty group",
      content: "A group must have at least a member",
    );
    if (ret) return;

    // check if modified name equals to already existing group
    if (groupNameController.text != widget.groupName) {
      GroupModel? group =
          await Provider.of<FirebaseGroups>(context, listen: false).createGroup(
        uid: userUid,
        groupName: groupNameController.text,
        membersUids: members.map((e) => e.uid).toList(),
      );

      // group create will return NULL if the group ALREADY EXISTS
      // ignore: use_build_context_synchronously
      ret = MyAlertDialog.showAlertIfCondition(
        context: context,
        condition: group == null,
        title: "Duplicate Group",
        content: "A group with this name already exists",
      );
      if (ret) return;
    }

    // ignore: use_build_context_synchronously
    LoadingOverlay.show(context);

    // ignore: use_build_context_synchronously
    await Provider.of<FirebaseGroups>(context, listen: false).deleteGroup(
      uid: userUid,
      groupName: widget.groupName,
    );

    // ignore: use_build_context_synchronously
    await Provider.of<FirebaseGroups>(context, listen: false).createGroup(
      uid: userUid,
      groupName: groupNameController.text,
      membersUids: members.map((e) => e.uid).toList(),
    );

    // ignore: use_build_context_synchronously
    LoadingOverlay.hide(context);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MyModal.modalWidget(
      context: context,
      heightFactor: 0.85,
      doneCancelMode: true,
      shrinkWrap: false,
      onDone: checkFields,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    "Editing \"${widget.groupName}\"",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                MyIconButton(
                  icon: const Icon(Icons.delete),
                  onTap: () async {
                    bool ris = await MyAlertDialog.showAlertConfirmCancel(
                      context: context,
                      title: "Delete this group?",
                      content: "This action cannot be undone, are you sure?",
                      trueButtonText: "Confirm",
                    );
                    if (ris) {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, ris);
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8, top: 8),
            alignment: Alignment.topLeft,
            child: Text(
              "Group Name",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          MyTextField(
            maxLength: 40,
            maxLines: 1,
            hintText: widget.groupName,
            controller: groupNameController,
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8, top: 8),
            alignment: Alignment.topLeft,
            child: Text(
              "Members: ${members.length}",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          StepInvite(
            organizerUid:
                Provider.of<FirebaseUser>(context, listen: false).user!.uid,
            invitees: members,
            addInvitee: (UserModel user) {
              setState(() {
                if (!members.map((_) => _.uid).toList().contains(user.uid)) {
                  // inviteeIds.add(uid);
                  members.insert(0, user);
                }
              });
            },
            removeInvitee: (UserModel user) {
              setState(() {
                members.removeWhere((item) => item.uid == user.uid);
              });
            },
          ),
        ],
      ),
    );
  }
}
