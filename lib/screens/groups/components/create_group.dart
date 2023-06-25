import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/poll_create/components/step_invite.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  List<UserModel> members = [];
  TextEditingController groupNameController = TextEditingController();

  void checkFields() async {
    bool ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: groupNameController.text.isEmpty,
      title: "Missing name",
      content: "You must give a name to the group",
    );
    if (ret) return;

    ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: members.isEmpty,
      title: "Empty group",
      content: "A group must have at least a member",
    );
    if (ret) return;

    final userUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;
    await Provider.of<FirebaseGroups>(context, listen: false).createGroup(
      uid: userUid,
      groupName: groupNameController.text,
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
      title: "New Group",
      child: Column(
        children: [
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
            hintText: "Group Name",
            controller: groupNameController,
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 0, top: 8),
            alignment: Alignment.topLeft,
            child: Text(
              "Members",
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
