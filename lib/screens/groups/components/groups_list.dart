import 'package:dima_app/screens/groups/components/edit_group.dart';
import 'package:dima_app/screens/groups/components/group_tile.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/group_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:provider/provider.dart';

class GroupsList extends StatelessWidget {
  final TextEditingController searchController;
  const GroupsList({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    final userUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;
    return StreamBuilder(
      stream: Provider.of<FirebaseGroups>(context, listen: false)
          .getUserCreatedGroupsSnapshot(uid: userUid),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingLogo();
        }
        if (snapshot.hasError) {
          Future.microtask(() {
            Navigator.of(context, rootNavigator: false).pushReplacement(
              ScreenTransition(
                builder: (context) => ErrorScreen(
                  errorMsg: snapshot.error.toString(),
                ),
              ),
            );
          });
          return Container();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Expanded(
            child: ListView(
              controller: ScrollController(),
              shrinkWrap: true,
              children: const [EmptyList(emptyMsg: "No groups")],
            ),
          );
        }
        List<GroupModel> groups = snapshot.data!.docs.map((e) {
          Map<String, dynamic> tmp = e.data() as Map<String, dynamic>;
          tmp["membersUids"] = List<String>.from(tmp["membersUids"]);
          return GroupModel.fromMap(tmp);
        }).toList();
        groups = groups
            .where((group) => group.groupName
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
        groups.sort((a, b) =>
            a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase()));
        return groups.isEmpty
            ? Expanded(
                child: ListView(
                  controller: ScrollController(),
                  shrinkWrap: true,
                  children: const [EmptyList(emptyMsg: "No groups")],
                ),
              )
            : Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: ScrollController(),
                    itemCount: groups.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == groups.length) {
                        return Container(
                            height: LayoutConstants.kPaddingFromCreate);
                      }
                      GroupModel group = groups[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: GroupTile(
                          group: group,
                          trailing: MyIconButton(
                            icon: const Icon(Icons.edit),
                            onTap: () async {
                              var ris = await MyModal.show(
                                context: context,
                                child: EditGroup(group: group),
                                heightFactor: 0.85,
                                doneCancelMode: true,
                                onDone: () {},
                                title: "New Group",
                                shrinkWrap: false,
                              );
                              // ris indicates if deleting group or not
                              if (ris != null && ris == true) {
                                // ignore: use_build_context_synchronously
                                await Provider.of<FirebaseGroups>(context,
                                        listen: false)
                                    .deleteGroup(
                                  uid: userUid,
                                  groupName: group.groupName,
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
      },
    );
  }
}
