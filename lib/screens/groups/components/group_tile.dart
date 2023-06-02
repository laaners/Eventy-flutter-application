import 'package:dima_app/models/group_model.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/profile_pics_stack.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'edit_group.dart';

class GroupTile extends StatelessWidget {
  final GroupModel group;
  const GroupTile({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final userUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;
    return InkWell(
      onTap: () async {
        var ris = await MyModal.show(
          context: context,
          child: EditGroupWrapper(group: group),
          heightFactor: 0.85,
          doneCancelMode: true,
          onDone: () {},
          title: "New Group",
          shrinkWrap: false,
        );
        // ris indicates if deleting group or not
        if (ris != null && ris == true) {
          // ignore: use_build_context_synchronously
          await Provider.of<FirebaseGroups>(context, listen: false).deleteGroup(
            uid: userUid,
            groupName: group.groupName,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1.0),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            ProfilePicsStack(
              radius: 25,
              offset: 30,
              uids: group.membersUids.sublist(0,
                  group.membersUids.length < 3 ? group.membersUids.length : 3),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.groupName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    group.membersUids.length.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 0),
              child: InkWell(
                customBorder: const CircleBorder(),
                child: Ink(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: const Icon(Icons.more_vert),
                ),
                onTap: () async {
                  print("ok");
                },
              ),
            ),

            /*
            Expanded(
              child: ListTile(
                contentPadding: const EdgeInsets.all(0),
                minLeadingWidth: 0,
                horizontalTitleGap: 8,
                title: Text(
                  group.groupName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  "subtitle",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                trailing: null,
                onTap: () async {
                  var ris = await MyModal.show(
                    context: context,
                    child: EditGroupWrapper(group: group),
                    heightFactor: 0.85,
                    doneCancelMode: true,
                    onDone: () {},
                    title: "New Group",
                    shrinkWrap: false,
                  );
                  // ris indicates if deleting group or not
                  if (ris != null && ris == true) {
                    // ignore: use_build_context_synchronously
                    await Provider.of<FirebaseGroups>(context, listen: false)
                        .deleteGroup(
                      uid: userUid,
                      groupName: group.groupName,
                    );
                  }
                },
              ),
            ),
            */
          ],
        ),
      ),
    );
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        minLeadingWidth: 0,
        horizontalTitleGap: 8,
        title: Text(
          group.groupName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          "subtitle",
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).primaryColor,
                fontStyle: FontStyle.italic,
              ),
        ),
        trailing: null,
        onTap: () async {
          var ris = await MyModal.show(
            context: context,
            child: EditGroupWrapper(group: group),
            heightFactor: 0.85,
            doneCancelMode: true,
            onDone: () {},
            title: "New Group",
            shrinkWrap: false,
          );
          // ris indicates if deleting group or not
          if (ris != null && ris == true) {
            // ignore: use_build_context_synchronously
            await Provider.of<FirebaseGroups>(context, listen: false)
                .deleteGroup(
              uid: userUid,
              groupName: group.groupName,
            );
          }
        },
      ),
    );
  }
}
