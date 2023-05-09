import 'dart:async';

import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/profile/index.dart';
import 'package:dima_app/screens/profile/settings.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/screens/profile/view_profile.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepInvite extends StatefulWidget {
  final List<UserCollection> invitees;
  final ValueChanged<UserCollection> addInvitee;
  final ValueChanged<UserCollection> removeInvitee;
  final String organizerUid;
  const StepInvite({
    super.key,
    required this.invitees,
    required this.addInvitee,
    required this.removeInvitee,
    required this.organizerUid,
  });

  @override
  State<StepInvite> createState() => _StepInviteState();
}

class _StepInviteState extends State<StepInvite>
    with AutomaticKeepAliveClientMixin {
  late List<UserCollection> originalInvitees;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    originalInvitees = [...widget.invitees];
  }

  Future addFollowers(List<String> followersIds) async {
    await Future.wait(followersIds.map(
      (uid) => Provider.of<FirebaseUser>(context, listen: false)
          .getUserData(context, uid)
          .then(
        (value) {
          if (value != null) widget.addInvitee(value);
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 5,
        right: 15,
        left: 15,
      ),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.only(bottom: 8, top: 8)),
          PillBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Invite all your followers",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 5)),
                SizedBox(
                  width: 50 * 1.4,
                  height: 40 * 1.4,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: FutureBuilder(
                        future:
                            Provider.of<FirebaseFollow>(context, listen: false)
                                .getCurrentUserFollow(),
                        builder: (
                          context,
                          snapshot,
                        ) {
                          if (snapshot.hasError) {
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
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          // filter out organizer from followers
                          List<String> followersIds = snapshot.data!.followers
                              .where((uid) => uid != widget.organizerUid)
                              .toList();
                          return Switch(
                            value: followersIds.every((followerUid) => widget
                                .invitees
                                .map((e) => e.uid)
                                .contains(followerUid)),
                            onChanged: followersIds.isEmpty
                                ? null
                                : (value) async {
                                    int removedFollowers = 0;
                                    if (value) {
                                      await addFollowers(followersIds);
                                    } else {
                                      for (String uid in followersIds) {
                                        var curUid = Provider.of<FirebaseUser>(
                                                context,
                                                listen: false)
                                            .user!
                                            .uid;
                                        bool isOrganizer =
                                            widget.organizerUid == curUid;
                                        bool isInOriginalInvitees =
                                            originalInvitees
                                                .map((e) => e.uid)
                                                .contains(uid);
                                        // does nothing if organizer != curUid and user is in original invitees
                                        if (!(!isOrganizer &&
                                            isInOriginalInvitees)) {
                                          removedFollowers += 1;
                                          widget.removeInvitee(
                                            UserCollection(
                                              uid: uid,
                                              email: "email",
                                              username: "",
                                              name: "",
                                              surname: "",
                                              profilePic: "",
                                            ),
                                          );
                                        }
                                      }
                                    }
                                    // ignore: use_build_context_synchronously
                                    MyAlertDialog.showAlertIfCondition(
                                      context: context,
                                      condition:
                                          removedFollowers == 0 && !value,
                                      title: "Operation not allowed",
                                      content:
                                          "Only the organizer can remove old partecipants",
                                    );
                                  },
                          );
                        }),
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
              children: widget.invitees.map((user) {
                return InviteProfilePic(
                  user: user,
                  invitees: widget.invitees,
                  originalInvitees: originalInvitees,
                  addMode: false,
                  removeInvitee: widget.removeInvitee,
                  addInvitee: widget.addInvitee,
                  organizerUid: widget.organizerUid,
                );
              }).toList(),
            ),
          ),
          SearchUsers(
            invitees: widget.invitees,
            addInvitee: widget.addInvitee,
            removeInvitee: widget.removeInvitee,
            organizerUid: widget.organizerUid,
          ),
        ],
      ),
    );
  }
}

class InviteProfilePic extends StatelessWidget {
  final List<UserCollection> invitees;
  final List<UserCollection> originalInvitees;
  final ValueChanged<UserCollection> addInvitee;
  final ValueChanged<UserCollection> removeInvitee;
  final UserCollection user;
  final bool addMode;
  final String organizerUid;
  const InviteProfilePic({
    super.key,
    required this.addInvitee,
    required this.removeInvitee,
    required this.addMode,
    required this.invitees,
    required this.user,
    required this.originalInvitees,
    required this.organizerUid,
  });

  Widget? getTopIcon(context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    bool isOrganizer = organizerUid == curUid;
    bool isInOriginalInvitees =
        originalInvitees.map((e) => e.uid).contains(user.uid);
    // show nothing if in cancelmode and organizer != curUid and user is in original invitees
    if (!addMode && !isOrganizer && isInOriginalInvitees) {
      return null;
    }
    // show cancel if in cancelmode, not organizer but newly added user isn't in original invitees
    if (!addMode && !isOrganizer && !isInOriginalInvitees) {
      return Positioned(
        right: -10.0,
        top: -10.0,
        child: IconButton(
          iconSize: 25,
          padding: const EdgeInsets.all(0),
          constraints: const BoxConstraints(),
          icon: Icon(
            addMode ? Icons.add_circle : Icons.cancel,
            color: addMode
                ? Theme.of(context).primaryColorLight
                : Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            addMode ? addInvitee(user) : removeInvitee(user);
          },
        ),
      );
    }
    // show anything if organizer or in add mode (default)
    return Positioned(
      right: -10,
      top: -10,
      child: IconButton(
        iconSize: 25,
        padding: const EdgeInsets.all(0),
        constraints: const BoxConstraints(),
        icon: Icon(
          addMode ? Icons.add_circle : Icons.cancel,
          color: addMode
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).colorScheme.error,
        ),
        onPressed: () {
          addMode ? addInvitee(user) : removeInvitee(user);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            width: 75,
            child: Column(
              children: [
                ProfilePic(
                  userData: user,
                  loading: false,
                  radius: 35,
                ),
                Container(padding: const EdgeInsets.symmetric(vertical: 2)),
                Text(
                  user.username,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // show nothing if in cancelmode and organizer != curUid and user is in original invitees
          getTopIcon(context) ?? Container()
        ],
      ),
      onTap: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(user.username),
            content: Row(
              children: [
                ProfilePic(userData: user, loading: false, radius: 45),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    "${user.name}\n${user.surname}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
        /*
        var curUid =
            Provider.of<FirebaseUser>(context, listen: false).user!.uid;
        if (curUid == user.uid) {
          Widget newScreen = const ProfileScreen();
          Navigator.of(context, rootNavigator: false).push(
            ScreenTransition(
              builder: (context) => newScreen,
            ),
          );
        } else {
          Widget newScreen = ViewProfileScreen(profileUserData: user);
          Navigator.of(context).push(
            ScreenTransition(
              builder: (context) => newScreen,
            ),
          );
        }
        */
      },
    );
  }
}

class SearchUsers extends StatefulWidget {
  final List<UserCollection> invitees;
  final ValueChanged<UserCollection> addInvitee;
  final ValueChanged<UserCollection> removeInvitee;
  final String organizerUid;

  const SearchUsers({
    super.key,
    required this.addInvitee,
    required this.removeInvitee,
    required this.invitees,
    required this.organizerUid,
  });

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  List<UserCollection> usersMatching = [];
  // true after next query, false when input text is empty
  bool loadingUsers = false;
  final FocusNode _focus = FocusNode();
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
            subtitle: TextFormField(
              autofocus: false,
              controller: _controller,
              focusNode: _focus,
              decoration: InputDecoration(
                hintText: "Search here",
                isDense: true,
                suffixIcon: IconButton(
                  iconSize: 25,
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() {
                        _controller.text = "";
                      });
                    }
                  },
                  icon: Icon(
                    _controller.text.isEmpty ? Icons.search : Icons.cancel,
                  ),
                ),
                border: InputBorder.none,
              ),
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
                    // filter out organizer and current user
                    usersMatching = tmp.where((element) {
                      return !widget.invitees
                              .map((e) => e.uid)
                              .contains(element.uid) &&
                          element.uid != userData.uid &&
                          element.uid != widget.organizerUid;
                    }).toList();
                  });
                }
              },
            ),
          ),
          Container(padding: const EdgeInsets.only(bottom: 8, top: 8)),
          SizedBox(
            height: (!_focus.hasFocus && usersMatching.isEmpty) ||
                    _controller.text.isEmpty
                ? 0
                : 110,
            child: usersMatching
                    .where((element) {
                      return !widget.invitees
                              .map((e) => e.uid)
                              .contains(element.uid) &&
                          element.uid != userData.uid &&
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
                              element.uid != userData.uid &&
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
                    : const Center(
                        child: Text("No results found."),
                      )),
          ),
        ],
      ),
    );
  }
}
