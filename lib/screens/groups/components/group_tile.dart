import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/group_model.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/profile_pics_stack.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_group.dart';

class GroupTile extends StatelessWidget {
  final GroupModel group;
  final Widget? trailing;
  final bool? maintainState;
  const GroupTile({
    super.key,
    required this.group,
    this.trailing,
    this.maintainState,
  });

  @override
  Widget build(BuildContext context) {
    final userUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        /*
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
        */
      ),
      child: InkWell(
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
            await Provider.of<FirebaseGroups>(context, listen: false)
                .deleteGroup(
              uid: userUid,
              groupName: group.groupName,
            );
          }
        },
        child: Row(
          children: [
            ProfilePicsStack(
              maintainState: maintainState,
              radius: 30,
              offset: 45,
              uids: group.membersUids.sublist(0,
                  group.membersUids.length < 3 ? group.membersUids.length : 3),
            ),
            const SizedBox(width: LayoutConstants.kHorizontalPadding),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.groupName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "Group members: ${group.membersUids.length}",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!
          ],
        ),
      ),
    );
  }
}
