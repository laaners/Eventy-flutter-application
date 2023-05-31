import 'package:dima_app/models/group_model.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/poll_create/components/step_invite.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditGroupWrapper extends StatefulWidget {
  final GroupModel group;
  const EditGroupWrapper({super.key, required this.group});

  @override
  State<EditGroupWrapper> createState() => _EditGroupWrapperState();
}

class _EditGroupWrapperState extends State<EditGroupWrapper> {
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
        return EditGroup(groupName: widget.group.groupName, members: usersData);
      },
    );
  }
}

class EditGroup extends StatefulWidget {
  final String groupName;
  final List<UserModel> members;
  const EditGroup({super.key, required this.members, required this.groupName});

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  List<UserModel> members = [];

  @override
  void initState() {
    super.initState();
    members = widget.members;
  }

  void checkFields() async {
    bool ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: members.isEmpty,
      title: "Empty group",
      content: "A group must have at least a member",
    );
    if (ret) return;

    final userUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;
    await Provider.of<FirebaseGroups>(context, listen: false).editGroup(
      uid: userUid,
      groupName: widget.groupName,
      membersUids: members.map((e) => e.uid).toList(),
    );

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
      title: "",
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 15, top: 8),
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Editing \"${widget.groupName}\"",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                InkWell(
                  customBorder: const CircleBorder(),
                  child: Ink(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(Icons.delete),
                  ),
                  onTap: () async {
                    bool ris = await MyAlertDialog.showAlertConfirmCancel(
                      context: context,
                      title: "Delete this group?",
                      content: "This action cannot be undone, are you sure?",
                      trueButtonText: "Confirm",
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, ris);
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 0, top: 8),
            alignment: Alignment.topLeft,
            child: Text(
              "${members.length} members",
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
