import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/poll_detail/components/dates_list.dart';
import 'package:dima_app/screens/poll_detail/components/locations_list.dart';
import 'package:dima_app/widgets/user_tile.dart';
import 'package:flutter/material.dart';

class InviteeVotesView extends StatefulWidget {
  final PollEventModel pollData;
  final UserModel userData;
  final VoidCallback refreshPollDetail;
  final List<VoteLocationModel> votesLocations;
  final List<VoteDateModel> votesDates;
  final String pollEventId;
  final List<PollEventInviteModel> invites;
  final bool isClosed;
  const InviteeVotesView({
    super.key,
    required this.pollData,
    required this.userData,
    required this.refreshPollDetail,
    required this.votesLocations,
    required this.votesDates,
    required this.pollEventId,
    required this.invites,
    required this.isClosed,
  });

  @override
  State<InviteeVotesView> createState() => _InviteeVotesViewState();
}

class _InviteeVotesViewState extends State<InviteeVotesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserTileFromData(userData: widget.userData),
        TabBar(
          tabs: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SizedBox(height: LayoutConstants.kIconPadding),
                Text(
                  "Locations",
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
                Text(
                  "Dates",
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
        Visibility(
          visible: _tabController.index == 0,
          maintainState: true,
          maintainAnimation: true,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            opacity: _tabController.index == 0 ? 1 : 0,
            child: LocationsList(
              locations: widget.pollData.locations,
              pollId: widget.pollEventId,
              organizerUid: widget.pollData.organizerUid,
              invites: widget.invites,
              votesLocations: widget.votesLocations,
              votingUid: widget.userData.uid,
              isClosed: widget.isClosed,
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
            child: DatesList(
              dates: widget.pollData.dates,
              pollId: widget.pollEventId,
              organizerUid: widget.pollData.organizerUid,
              invites: widget.invites,
              votesDates: widget.votesDates,
              votingUid: widget.userData.uid,
              isClosed: widget.isClosed,
              deadline: widget.pollData.deadline,
            ),
          ),
        ),
      ],
    );
  }
}
