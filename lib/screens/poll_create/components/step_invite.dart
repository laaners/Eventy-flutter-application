import 'dart:async';
import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'invite_groups.dart';
import 'invite_profile_pic.dart';
import 'invite_users.dart';

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
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late List<UserModel> originalInvitees;
  late Stream<UserModel> _stream;

  @override
  bool get wantKeepAlive => true;

  bool searchForUsers = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    originalInvitees = [...widget.invitees];
    _tabController = TabController(length: 2, vsync: this);

    _stream = Provider.of<FirebaseUser>(context, listen: false)
        .getCurrentUserStream();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8, top: 0),
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
                for (UserModel user in widget.invitees)
                  InviteProfilePic(
                    user: user,
                    invitees: widget.invitees,
                    originalInvitees: originalInvitees,
                    addMode: false,
                    removeInvitee: widget.removeInvitee,
                    addInvitee: widget.addInvitee,
                    organizerUid: widget.organizerUid,
                  ),
              ],
            ),
          ),
          TabBar(
            tabs: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SizedBox(height: LayoutConstants.kIconPadding),
                  Icon(Icons.person_add_alt_1),
                  Text(
                    "Add user",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: LayoutConstants.kIconPadding),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SizedBox(height: LayoutConstants.kIconPadding),
                  Icon(Icons.group_add),
                  Text(
                    "Add group",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: LayoutConstants.kIconPadding),
                ],
              ),
            ],
            controller: _tabController,
            onTap: (index) {
              setState(() {});
            },
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          const SizedBox(height: LayoutConstants.kHeight),
          Visibility(
            visible: _tabController.index == 0,
            maintainState: true,
            maintainAnimation: true,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              opacity: _tabController.index == 0 ? 1 : 0,
              child: InviteUsers(
                invitees: widget.invitees,
                addInvitee: widget.addInvitee,
                removeInvitee: widget.removeInvitee,
                organizerUid: widget.organizerUid,
              ),
            ),
          ),
          Visibility(
            visible: _tabController.index == 1,
            maintainState: true,
            maintainAnimation: true,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              opacity: _tabController.index == 1 ? 1 : 0,
              child: InviteGroups(
                invitees: widget.invitees,
                addInvitee: widget.addInvitee,
                removeInvitee: widget.removeInvitee,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
