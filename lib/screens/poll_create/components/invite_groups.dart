import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/group_model.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:dima_app/widgets/search_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'invite_group_tile.dart';

class InviteGroups extends StatefulWidget {
  final List<UserModel> invitees;
  final ValueChanged<UserModel> addInvitee;
  final ValueChanged<UserModel> removeInvitee;
  const InviteGroups({
    super.key,
    required this.invitees,
    required this.addInvitee,
    required this.removeInvitee,
  });

  @override
  State<InviteGroups> createState() => _InviteGroupsState();
}

class _InviteGroupsState extends State<InviteGroups> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  late Stream<QuerySnapshot<Object?>>? _stream;

  @override
  void initState() {
    super.initState();
    final userUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;
    _stream = Provider.of<FirebaseGroups>(context, listen: false)
        .getUserCreatedGroupsSnapshot(uid: userUid);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          SearchTile(
            controller: _controller,
            focusNode: _focus,
            hintText: "Search for group name",
            emptySearch: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  _controller.text = "";
                  final userUid =
                      Provider.of<FirebaseUser>(listen: false, context)
                          .user!
                          .uid;
                  _stream = Provider.of<FirebaseGroups>(context, listen: false)
                      .getUserCreatedGroupsSnapshot(uid: userUid);
                });
              }
            },
            onChanged: (text) {
              setState(() {
                final userUid =
                    Provider.of<FirebaseUser>(listen: false, context).user!.uid;
                _stream = Provider.of<FirebaseGroups>(context, listen: false)
                    .getUserCreatedGroupsSnapshot(uid: userUid);
              });
            },
          ),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: _stream,
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
              groups.sort((a, b) => a.groupName
                  .toLowerCase()
                  .compareTo(b.groupName.toLowerCase()));
              groups = groups
                  .where((group) => group.groupName
                      .toLowerCase()
                      .contains(_controller.text.toLowerCase()))
                  .toList();
              return groups.isEmpty
                  ? const EmptyList(emptyMsg: "No polls or events")
                  : HorizontalScroller(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groups.map((group) {
                        bool addMode = group.membersUids.any((memberUid) =>
                            !widget.invitees
                                .map((e) => e.uid)
                                .toList()
                                .contains(memberUid));
                        return InviteGroupTile(
                          maintainState: true,
                          group: group,
                          icon: MyIconButton(
                            icon: Icon(
                              addMode ? Icons.add_circle : Icons.cancel,
                              size: LayoutConstants.kIconSize,
                              color: addMode
                                  ? Theme.of(context).primaryColorLight
                                  : Theme.of(context).colorScheme.error,
                            ),
                            onTap: () async {
                              List<UserModel> membersData =
                                  await Provider.of<FirebaseUser>(context,
                                          listen: false)
                                      .getUsersDataFromList(
                                          uids: group.membersUids);
                              for (UserModel member in membersData) {
                                addMode
                                    ? widget.addInvitee(member)
                                    : widget.removeInvitee(member);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
            },
          ),
        ],
      ),
    );
  }
}
