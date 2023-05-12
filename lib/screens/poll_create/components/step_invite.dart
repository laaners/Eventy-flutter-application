import 'dart:async';

import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepInvite extends StatefulWidget {
  final List<UserModel> invitees;
  final ValueChanged<UserModel> addInvitee;
  final ValueChanged<UserModel> removeInvitee;
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
  late List<UserModel> originalInvitees;
  late Stream<UserModel> _stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    originalInvitees = [...widget.invitees];
    _stream = Provider.of<FirebaseUser>(context, listen: false)
        .getCurrentUserStream();
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
          Container(
            margin: const EdgeInsets.only(bottom: 8, top: 20),
            child: HorizontalScroller(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder(
                  stream: _stream,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<UserModel> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingSpinner();
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
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
                    UserModel user = snapshot.data!;
                    return InviteProfilePic(
                      user: user,
                      invitees: widget.invitees,
                      originalInvitees: originalInvitees,
                      addMode: false,
                      removeInvitee: widget.removeInvitee,
                      addInvitee: widget.addInvitee,
                      organizerUid: widget.organizerUid,
                    );
                  },
                ),
                ...widget.invitees.map((user) {
                  return InviteProfilePic(
                    user: user,
                    invitees: widget.invitees,
                    originalInvitees: originalInvitees,
                    addMode: false,
                    removeInvitee: widget.removeInvitee,
                    addInvitee: widget.addInvitee,
                    organizerUid: widget.organizerUid,
                  );
                }).toList()
              ],
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
  final List<UserModel> invitees;
  final List<UserModel> originalInvitees;
  final ValueChanged<UserModel> addInvitee;
  final ValueChanged<UserModel> removeInvitee;
  final UserModel user;
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
    // or user is curuid
    if ((!addMode && !isOrganizer && isInOriginalInvitees) ||
        curUid == user.uid) {
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
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
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
                  curUid == user.uid ? "You" : user.username,
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
      },
    );
  }
}

class SearchUsers extends StatefulWidget {
  final List<UserModel> invitees;
  final ValueChanged<UserModel> addInvitee;
  final ValueChanged<UserModel> removeInvitee;
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
                    : const Center(
                        child: Text("No results found."),
                      )),
          ),
        ],
      ),
    );
  }
}
