import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/search_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'invite_profile_pic.dart';

class InviteUsers extends StatefulWidget {
  final List<UserModel> invitees;
  final ValueChanged<UserModel> addInvitee;
  final ValueChanged<UserModel> removeInvitee;
  final String organizerUid;

  const InviteUsers({
    super.key,
    required this.addInvitee,
    required this.removeInvitee,
    required this.invitees,
    required this.organizerUid,
  });

  @override
  State<InviteUsers> createState() => _InviteUsersState();
}

class _InviteUsersState extends State<InviteUsers> {
  List<UserModel> usersMatching = [];
  // true after next query, false when input text is empty
  bool loadingUsers = false;
  final FocusNode _focus = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          SearchTile(
            controller: _controller,
            focusNode: _focus,
            hintText: "Search for username",
            emptySearch: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  _controller.text = "";
                });
              }
            },
            onChanged: (text) async {
              if (text.isEmpty) {
                setState(() {
                  usersMatching = [];
                  loadingUsers = false;
                });
                return;
              } else {
                loadingUsers = true;
                List<UserModel> tmp =
                    await Provider.of<FirebaseUser>(context, listen: false)
                        .getUsersData(pattern: text);
                setState(() {
                  // filter out organizer and current user
                  usersMatching = tmp.where((element) {
                    return !widget.invitees
                            .map((e) => e.uid)
                            .contains(element.uid) &&
                        element.uid != curUid &&
                        element.uid != widget.organizerUid;
                  }).toList();
                });
              }
            },
          ),
          Container(padding: const EdgeInsets.only(bottom: 8, top: 8)),
          SizedBox(
            height: (!_focus.hasFocus && usersMatching.isEmpty) ||
                    _controller.text.isEmpty
                ? 0
                : 150,
            child: usersMatching
                    .where((element) {
                      return !widget.invitees
                              .map((e) => e.uid)
                              .contains(element.uid) &&
                          element.uid != curUid &&
                          element.uid != widget.organizerUid;
                    })
                    .toList()
                    .isNotEmpty
                ? HorizontalScroller(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: usersMatching
                        .where((element) {
                          return !widget.invitees
                                  .map((e) => e.uid)
                                  .contains(element.uid) &&
                              element.uid != curUid &&
                              element.uid != widget.organizerUid;
                        })
                        .toList()
                        .map(
                          (e) => InviteProfilePic(
                            invitees: widget.invitees,
                            originalInvitees: [],
                            organizerUid: "",
                            user: e,
                            addInvitee: widget.addInvitee,
                            removeInvitee: widget.removeInvitee,
                            addMode: widget.invitees
                                    .map((e) => e.uid)
                                    .contains(e.uid)
                                ? false
                                : true,
                          ),
                        )
                        .toList(),
                  )
                : (_controller.text.isEmpty
                    ? Container()
                    : ListView(
                        controller: ScrollController(),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: const [
                          EmptyList(emptyMsg: "No groups found")
                        ],
                      )),
          ),
        ],
      ),
    );
  }
}
