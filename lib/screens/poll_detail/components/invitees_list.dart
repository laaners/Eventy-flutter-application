import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/poll_create/components/step_invite.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:dima_app/widgets/show_user_dialog.dart';
import 'package:dima_app/widgets/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dima_app/widgets/tabbar_switcher.dart';

import 'invitee_votes_view.dart';

class InviteesList extends StatefulWidget {
  final PollEventModel pollData;
  final String pollEventId;
  final List<PollEventInviteModel> invites;
  final List<VoteLocationModel> votesLocations;
  final List<VoteDateModel> votesDates;
  final bool isClosed;
  final VoidCallback refreshPollDetail;
  const InviteesList({
    super.key,
    required this.invites,
    required this.pollEventId,
    required this.pollData,
    required this.votesLocations,
    required this.votesDates,
    required this.refreshPollDetail,
    required this.isClosed,
  });

  @override
  State<InviteesList> createState() => _InviteesListState();
}

class _InviteesListState extends State<InviteesList> {
  Future<List<UserModel>>? _future;
  List<String> users = [];

  @override
  initState() {
    super.initState();
    users = widget.invites.map((e) => e.inviteeId).toList();

    // this list will be passed to step_invite, must filter out from the list
    // the organizer (and the current user itself ? uid != curUid &&)
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    _future =
        Provider.of<FirebaseUser>(context, listen: false).getUsersDataFromList(
      uids: users
          .where((uid) => uid != widget.pollData.organizerUid && uid != curUid)
          .toList(),
    );
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
    await Future.wait(
      toRemove.map((uid) {
        return Provider.of<FirebasePollEventInvite>(context, listen: false)
            .deletePollEventInvite(
          context: context,
          pollEventId: widget.pollEventId,
          inviteeId: uid,
        );
      }),
    );
    widget.refreshPollDetail();
    // ignore: use_build_context_synchronously
    LoadingOverlay.hide(context);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingLogo();
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
        List<UserModel> usersData = snapshot.data!;
        return InviteesListIntermediate(
          isClosed: widget.isClosed,
          pollEventId: widget.pollEventId,
          pollData: widget.pollData,
          users: users,
          updateInvitees: updateInvitees,
          usersDataInitial: usersData,
          refreshPollDetail: widget.refreshPollDetail,
          votesLocations: widget.votesLocations,
          votesDates: widget.votesDates,
          invites: widget.invites,
        );
      },
    );
  }
}

class InviteesListIntermediate extends StatefulWidget {
  final String pollEventId;
  final PollEventModel pollData;
  final List<PollEventInviteModel> invites;
  final List<String> users;
  final ValueChanged<List<String>> updateInvitees;
  final List<UserModel> usersDataInitial;
  final VoidCallback refreshPollDetail;
  final List<VoteLocationModel> votesLocations;
  final List<VoteDateModel> votesDates;
  final bool isClosed;

  const InviteesListIntermediate({
    super.key,
    required this.pollEventId,
    required this.users,
    required this.updateInvitees,
    required this.usersDataInitial,
    required this.pollData,
    required this.refreshPollDetail,
    required this.votesLocations,
    required this.votesDates,
    required this.invites,
    required this.isClosed,
  });

  @override
  State<InviteesListIntermediate> createState() =>
      _InviteesListIntermediateState();
}

class _InviteesListIntermediateState extends State<InviteesListIntermediate> {
  late List<UserModel> usersData = [];

  @override
  void initState() {
    super.initState();
    usersData = widget.usersDataInitial;
  }

  void addInvitee(UserModel user) {
    setState(() {
      if (!usersData.map((e) => e.uid).contains(user.uid)) {
        usersData.insert(0, user);
      }
    });
  }

  void removeInvitee(UserModel user) {
    setState(() {
      usersData.removeWhere((item) => item.uid == user.uid);
    });
  }

  Widget userListOrEmpty() {
    return usersData.isNotEmpty
        ? Scrollbar(
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: usersData.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == usersData.length) {
                  return Container(height: LayoutConstants.kPaddingFromCreate);
                }
                UserModel userData = usersData[index];
                return UserTileFromData(
                  userData: userData,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: LayoutConstants.kHorizontalPadding),
                  trailing: MyIconButton(
                    icon: const Icon(Icons.event_note),
                    onTap: () async {
                      var curUid =
                          Provider.of<FirebaseUser>(context, listen: false)
                              .user!
                              .uid;
                      if (curUid == userData.uid) {
                        showUserDialog(context: context, user: userData);
                      } else {
                        MyModal.show(
                          context: context,
                          shrinkWrap: false,
                          title: "${userData.username}'s preferences",
                          child: InviteeVotesView(
                            isClosed: widget.isClosed,
                            pollData: widget.pollData,
                            userData: userData,
                            refreshPollDetail: widget.refreshPollDetail,
                            votesLocations: widget.votesLocations,
                            votesDates: widget.votesDates,
                            invites: widget.invites,
                            pollEventId: widget.pollEventId,
                          ),
                          heightFactor: 0.85,
                          doneCancelMode: false,
                          onDone: () {},
                        );
                      }
                    },
                  ),
                );
              },
            ),
          )
        : const EmptyList(emptyMsg: "No other partecipants");
  }

  @override
  Widget build(BuildContext context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return widget.pollData.organizerUid ==
            curUid // || widget.pollData.canInvite
        ? TabbarSwitcher(
            appBarTitle: widget.pollData.pollEventName,
            upRightActions: [
              TextButton(
                onPressed: () {
                  widget.updateInvitees(usersData.map((e) => e.uid).toList());
                },
                child: const Icon(Icons.done),
              )
            ],
            stickyHeight: 0,
            listSticky: null,
            labels: const ["Partecipants", "Invite"],
            tabbars: [
              userListOrEmpty(),
              ListView(
                controller: ScrollController(),
                children: [
                  Container(
                    margin: const EdgeInsets.all(15),
                    child: StepInvite(
                      organizerUid: widget.pollData.organizerUid,
                      invitees: usersData,
                      addInvitee: addInvitee,
                      removeInvitee: removeInvitee,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: MyButton(
                      text: "INVITE",
                      onPressed: () {
                        widget.updateInvitees(
                            usersData.map((e) => e.uid).toList());
                      },
                    ),
                  )
                ],
              ),
            ],
          )
        : Scaffold(
            appBar: MyAppBar(title: widget.pollData.pollEventName),
            body: ResponsiveWrapper(child: userListOrEmpty()),
          );
  }
}
