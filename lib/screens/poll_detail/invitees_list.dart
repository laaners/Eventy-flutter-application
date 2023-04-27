import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/event_create/step_invite.dart';
import 'package:dima_app/screens/profile/index.dart';
import 'package:dima_app/screens/profile/view_profile.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dima_app/widgets/tabbar_switcher.dart' as tabbar_switcher;

class InviteesList extends StatefulWidget {
  final String pollEventId;
  final PollCollection pollData;
  final List<PollEventInviteCollection> invites;
  final VoidCallback refreshPollDetail;
  const InviteesList({
    super.key,
    required this.invites,
    required this.pollEventId,
    required this.refreshPollDetail,
    required this.pollData,
  });

  @override
  State<InviteesList> createState() => _InviteesListState();
}

class _InviteesListState extends State<InviteesList> {
  Future<List<UserCollection>>? _future;
  List<String> users = [];

  @override
  initState() {
    super.initState();
    users = widget.invites.map((e) => e.inviteeId).toList();

    // this list will be passed to step_invite, must filter out from the list
    // the organizer (and the current user itself ? uid != curUid &&)
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    _future = Provider.of<FirebaseUser>(context, listen: false)
        .getUsersDataFromList(context,
            users.where((uid) => uid != widget.pollData.organizerUid).toList());
  }

  Future updateInvitees(List<String> newInvitees) async {
    LoadingOverlay.show(context);
    List<String> oldInvitees = widget.invites.map((e) => e.inviteeId).toList();
    // add new invites

    List<String> toAdd =
        newInvitees.where((newId) => !oldInvitees.contains(newId)).toList();
    await Future.wait(toAdd.map((uid) {
      return Provider.of<FirebasePollEventInvite>(context, listen: false)
          .createPollEventInvite(
        context: context,
        pollEventId: widget.pollEventId,
        inviteeId: uid,
      );
    }));

    // delete removed invites, filter out organizer (impossible case but whatever) and curuid
    // ignore: use_build_context_synchronously
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    List<String> toRemove = oldInvitees
        .where((oldId) =>
            !newInvitees.contains(oldId) &&
            oldId != widget.pollData.organizerUid &&
            oldId != curUid)
        .toList();
    await Future.wait(toRemove.map((uid) {
      return Provider.of<FirebasePollEventInvite>(context, listen: false)
          .deletePollEventInvite(
        context: context,
        pollEventId: widget.pollEventId,
        inviteeId: uid,
      );
    }));
    widget.refreshPollDetail();
    // ignore: use_build_context_synchronously
    LoadingOverlay.hide(context);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return widget.invites.isNotEmpty
        ? FutureBuilder(
            future: _future,
            builder: (
              context,
              snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingSpinner();
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
              List<UserCollection> usersData = snapshot.data!;
              return InviteesListIntermediate(
                pollEventId: widget.pollEventId,
                pollData: widget.pollData,
                users: users,
                updateInvitees: updateInvitees,
                usersDataInitial: usersData,
              );
            },
          )
        : const Scaffold(
            appBar: MyAppBar(
              title: "Partecipants",
              upRightActions: [],
            ),
            body: ResponsiveWrapper(
              child: Center(
                child: Text("No other partecipants"),
              ),
            ),
          );
  }
}

class InviteesListIntermediate extends StatefulWidget {
  final String pollEventId;
  final PollCollection pollData;
  final List<String> users;
  final ValueChanged<List<String>> updateInvitees;
  final List<UserCollection> usersDataInitial;
  const InviteesListIntermediate({
    super.key,
    required this.pollEventId,
    required this.users,
    required this.updateInvitees,
    required this.usersDataInitial,
    required this.pollData,
  });

  @override
  State<InviteesListIntermediate> createState() =>
      _InviteesListIntermediateState();
}

class _InviteesListIntermediateState extends State<InviteesListIntermediate> {
  late List<UserCollection> usersData = [];

  @override
  void initState() {
    super.initState();
    usersData = widget.usersDataInitial;
  }

  void addInvitee(UserCollection user) {
    setState(() {
      if (!usersData.map((e) => e.uid).contains(user.uid)) {
        usersData.insert(0, user);
      }
    });
  }

  void removeInvitee(UserCollection user) {
    setState(() {
      usersData.removeWhere((item) => item.uid == user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return widget.pollData.organizerUid == curUid || widget.pollData.canInvite
        ? tabbar_switcher.TabbarSwitcher(
            appBarTitle: widget.pollData.pollName,
            upRightActions: widget.pollData.organizerUid == curUid ||
                    widget.pollData.canInvite
                ? [
                    TextButton(
                      onPressed: () {
                        widget.updateInvitees(
                            usersData.map((e) => e.uid).toList());
                      },
                      child: const Icon(
                        Icons.done,
                      ),
                    )
                  ]
                : [],
            stickyHeight: 0,
            listSticky: null,
            labels: const ["Partecipants", "Invite"],
            tabbars: [
              usersData.isNotEmpty
                  ? ListView(
                      children: usersData
                          .map((user) => InviteeTile(
                                userData: user,
                              ))
                          .toList(),
                    )
                  : const Center(
                      child: Text("No other partecipants"),
                    ),
              ListView(
                children: [
                  StepInvite(
                    organizerUid: widget.pollData.organizerUid,
                    invitees: usersData,
                    addInvitee: addInvitee,
                    removeInvitee: removeInvitee,
                  ),
                  MyButton(
                    text: "INVITE",
                    onPressed: () {
                      widget
                          .updateInvitees(usersData.map((e) => e.uid).toList());
                    },
                  )
                ],
              )
            ],
          )
        : Scaffold(
            appBar: MyAppBar(
              title: widget.pollData.pollName,
              upRightActions: [],
            ),
            body: ResponsiveWrapper(
              child: usersData.isNotEmpty
                  ? ListView(
                      children: usersData
                          .map((user) => InviteeTile(
                                userData: user,
                              ))
                          .toList(),
                    )
                  : const Center(
                      child: Text("No other partecipants"),
                    ),
            ),
          );
  }
}

class InviteeTile extends StatelessWidget {
  final UserCollection userData;
  const InviteeTile({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListTile(
        leading: ProfilePic(
          loading: false,
          userData: userData,
          radius: 25,
        ),
        title: Text("${userData.name} ${userData.surname}"),
        subtitle: Text(userData.username),
        onTap: () {
          var curUid =
              Provider.of<FirebaseUser>(context, listen: false).user!.uid;
          if (curUid == userData.uid) {
            Widget newScreen = const ProfileScreen();
            Navigator.push(
              context,
              ScreenTransition(
                builder: (context) => newScreen,
              ),
            );
          } else {
            Widget newScreen = ViewProfileScreen(profileUserData: userData);
            Navigator.push(
              context,
              ScreenTransition(
                builder: (context) => newScreen,
              ),
            );
          }
        },
      ),
    );
  }
}
