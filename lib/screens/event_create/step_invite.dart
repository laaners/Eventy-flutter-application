import 'dart:async';

import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/profile/index.dart';
import 'package:dima_app/screens/profile/profile_pic.dart';
import 'package:dima_app/screens/profile/view_profile.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepInvite extends StatefulWidget {
  final List<String> inviteeIds;
  final ValueChanged<String> addInvitee;
  final ValueChanged<String> removeInvitee;
  const StepInvite({
    super.key,
    required this.inviteeIds,
    required this.addInvitee,
    required this.removeInvitee,
  });

  @override
  State<StepInvite> createState() => _StepInviteState();
}

class _StepInviteState extends State<StepInvite> {
  @override
  Widget build(BuildContext context) {
    List<String> followers =
        Provider.of<FirebaseFollow>(context, listen: false).followersUid;
    return Container(
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, top: 8, left: 15),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: const Text(
              "Invite people to the event",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          PillBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Invite all your followers",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  width: 50 * 1.4,
                  height: 40 * 1.4,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      value: widget.inviteeIds
                          .any((element) => followers.contains(element)),
                      onChanged: (value) async {
                        if (value) {
                          for (String uid in followers) {
                            widget.addInvitee(uid);
                          }
                        } else {
                          for (String uid in followers) {
                            widget.removeInvitee(uid);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8, top: 20),
            child: HorizontalScroller(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.inviteeIds.map((uid) {
                return InviteProfilePic(
                  inviteeIds: widget.inviteeIds,
                  userUid: uid,
                  addMode: false,
                  removeInvitee: widget.removeInvitee,
                  addInvitee: widget.addInvitee,
                );
              }).toList(),
            ),
          ),
          SearchUsers(
            inviteeIds: widget.inviteeIds,
            addInvitee: widget.addInvitee,
            removeInvitee: widget.removeInvitee,
          ),
        ],
      ),
    );
  }
}

class InviteProfilePic extends StatefulWidget {
  final List<String> inviteeIds;
  final String userUid;
  final bool addMode;
  final ValueChanged<String> addInvitee;
  final ValueChanged<String> removeInvitee;
  const InviteProfilePic({
    super.key,
    required this.userUid,
    required this.addInvitee,
    required this.removeInvitee,
    required this.addMode,
    required this.inviteeIds,
  });

  @override
  State<InviteProfilePic> createState() => _InviteProfilePicState();
}

class _InviteProfilePicState extends State<InviteProfilePic> {
  Future<UserCollection?>? _future;

  @override
  void initState() {
    super.initState();
    _future = Provider.of<FirebaseUser>(context, listen: false)
        .getUserData(context, widget.userUid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<FirebaseUser>(context, listen: false)
          .getUserData(context, widget.userUid),
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.transparent,
            height: 80,
            width: 80,
          );
        }
        if (snapshot.hasError) {
          Future.microtask(() {
            Navigator.of(context).pop();
            Navigator.push(
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
        if (!snapshot.hasData) {
          return Container();
        }
        UserCollection userData = snapshot.data!;
        return AnimatedOpacity(
          opacity: widget.inviteeIds.contains(widget.userUid) ? 0.8 : 0.0,
          duration: const Duration(milliseconds: 20000),
          child: InkWell(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(5),
                  width: 75,
                  child: AnimatedOpacity(
                    opacity:
                        widget.inviteeIds.contains(widget.userUid) ? 0.8 : 0.0,
                    duration: const Duration(milliseconds: 200000000),
                    child: Column(
                      children: [
                        ProfilePic(
                          userData: userData,
                          loading: false,
                          radius: 35,
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 2)),
                        Text(
                          userData.username,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 2.0,
                  top: 2.0,
                  child: IconButton(
                    iconSize: 25,
                    padding: const EdgeInsets.all(0),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      widget.addMode ? Icons.add_circle : Icons.cancel,
                      color: widget.addMode ? Colors.blue : Colors.red,
                    ),
                    onPressed: () {
                      widget.addMode
                          ? widget.addInvitee(widget.userUid)
                          : widget.removeInvitee(widget.userUid);
                      setState(() {
                        _future = null;
                      });
                      setState(() {
                        _future =
                            Provider.of<FirebaseUser>(context, listen: false)
                                .getUserData(context, widget.userUid);
                      });
                    },
                  ),
                ),
              ],
            ),
            onTap: () {
              var curUid =
                  Provider.of<FirebaseUser>(context, listen: false).user!.uid;
              if (curUid == userData.uid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProfileScreen(userData: userData),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}

class SearchUsers extends StatefulWidget {
  final List<String> inviteeIds;
  final ValueChanged<String> addInvitee;
  final ValueChanged<String> removeInvitee;
  const SearchUsers({
    super.key,
    required this.addInvitee,
    required this.removeInvitee,
    required this.inviteeIds,
  });

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  List<UserCollection> usersMatching = [];
  // true after next query, false when input text is empty
  bool loadingUsers = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserCollection userData =
        Provider.of<FirebaseUser>(context, listen: false).userData!;
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
            horizontalTitleGap: 0,
            trailing: IconButton(
              iconSize: 25,
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            subtitle: TextFormField(
              controller: _controller,
              autofocus: false,
              decoration: const InputDecoration(hintText: "Search here"),
              onChanged: (text) async {
                if (text.isEmpty) {
                  setState(() {
                    usersMatching = [];
                    loadingUsers = false;
                  });
                  return;
                } else {
                  loadingUsers = true;
                  List<UserCollection> tmp =
                      await Provider.of<FirebaseUser>(context, listen: false)
                          .getUsersData(context, text);
                  setState(() {
                    usersMatching = tmp;
                  });
                }
              },
            ),
          ),
          Container(
            height: 150,
            child: usersMatching.isNotEmpty
                ? HorizontalScroller(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: usersMatching
                        .where((element) {
                          return !widget.inviteeIds.contains(element.uid) &&
                              element.uid != userData.uid;
                        })
                        .toList()
                        .map(
                          (e) => InviteProfilePic(
                            inviteeIds: widget.inviteeIds,
                            userUid: e.uid,
                            addInvitee: widget.addInvitee,
                            removeInvitee: widget.removeInvitee,
                            addMode: widget.inviteeIds.contains(e.uid)
                                ? false
                                : true,
                          ),
                        )
                        .toList(),
                  )
                : (_controller.text.isEmpty
                    ? Container()
                    : const Center(
                        child: Text("No results found."),
                      )),
          ),
        ],
      ),
    );
  }
}
