import 'package:dima_app/models/group_model.dart';
import 'package:dima_app/screens/groups/components/view_group.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/container_shadow.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/profile_pics_stack.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InviteGroupTile extends StatelessWidget {
  final GroupModel group;
  final Widget icon;
  final bool? maintainState;
  const InviteGroupTile({
    super.key,
    required this.group,
    required this.icon,
    this.maintainState,
  });

  @override
  Widget build(BuildContext context) {
    final userUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;
    return InkWell(
      onTap: () async {
        var ris = await MyModal.show(
          context: context,
          child: ViewGroup(group: group),
          heightFactor: 0.85,
          doneCancelMode: true,
          onDone: () {},
          title: group.groupName,
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
      child: ContainerShadow(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10),
        width: 150,
        child: Stack(
          children: [
            Positioned(
              right: -7,
              top: -7,
              child: icon,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(
                    left: group.membersUids.length < 3
                        ? (group.membersUids.length == 2 ? 20 : 35)
                        : 0,
                  ),
                  child: ProfilePicsStack(
                    maintainState: maintainState,
                    radius: 30,
                    offset: 30,
                    uids: group.membersUids.sublist(
                        0,
                        group.membersUids.length < 3
                            ? group.membersUids.length
                            : 3),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  group.groupName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  "${group.membersUids.length} members",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
