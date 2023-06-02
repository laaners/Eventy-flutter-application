import 'package:dima_app/screens/groups/components/group_tile.dart';
import 'package:dima_app/widgets/profile_pics_stack.dart';
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
  const GroupsList({super.key});

  @override
  Widget build(BuildContext context) {
    final userUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;
    return StreamBuilder(
      stream: Provider.of<FirebaseGroups>(context, listen: false)
          .getUserOrganizedCreatedGroupsSnapshot(uid: userUid),
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
          return const EmptyList(emptyMsg: "No groups");
        }
        List<GroupModel> groups = snapshot.data!.docs.map((e) {
          Map<String, dynamic> tmp = e.data() as Map<String, dynamic>;
          tmp["membersUids"] = List<String>.from(tmp["membersUids"]);
          return GroupModel.fromMap(tmp);
        }).toList();
        return Expanded(
          child: Scrollbar(
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: groups.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == groups.length) {
                  return Container(height: LayoutConstants.kPaddingFromCreate);
                }
                GroupModel group = groups[index];
                return GroupTile(group: group);
              },
            ),
          ),
        );
      },
    );
  }
}
