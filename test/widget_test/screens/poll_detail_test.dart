import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/poll_create/components/step_invite.dart';
import 'package:dima_app/screens/poll_detail/components/availability_legend.dart';
import 'package:dima_app/screens/poll_detail/components/date_detail.dart';
import 'package:dima_app/screens/poll_detail/components/date_tile.dart';
import 'package:dima_app/screens/poll_detail/components/dates_list.dart';
import 'package:dima_app/screens/poll_detail/components/dates_view_calendar.dart';
import 'package:dima_app/screens/poll_detail/components/dates_view_horizontal.dart';
import 'package:dima_app/screens/poll_detail/components/invitee_votes_view.dart';
import 'package:dima_app/screens/poll_detail/components/invitees_list.dart';
import 'package:dima_app/screens/poll_detail/components/invitees_pill.dart';
import 'package:dima_app/screens/poll_detail/components/location_detail.dart';
import 'package:dima_app/screens/poll_detail/components/location_tile.dart';
import 'package:dima_app/screens/poll_detail/components/locations_list.dart';
import 'package:dima_app/screens/poll_detail/components/most_voted_date_tile.dart';
import 'package:dima_app/screens/poll_detail/components/most_voted_location_tile.dart';
import 'package:dima_app/screens/poll_detail/components/my_poll.dart';
import 'package:dima_app/screens/poll_detail/components/poll_event_options.dart';
import 'package:dima_app/screens/poll_detail/poll_detail.dart';
import 'package:dima_app/screens/poll_event/poll_event.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:dima_app/widgets/container_shadow.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:dima_app/widgets/profile_pics_stack.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:dima_app/widgets/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../mocks/mock_clock_manager.dart';
import '../../mocks/mock_firebase_groups.dart';
import '../../mocks/mock_firebase_notification.dart';
import '../../mocks/mock_firebase_poll_event.dart';
import '../../mocks/mock_firebase_poll_event_invite.dart';
import '../../mocks/mock_firebase_user.dart';
import '../../mocks/mock_firebase_vote.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Poll detail screen test', () {
    testWidgets('AvailabilityLegend component renders correctly',
        (tester) async {
      int filterAvailability = -2;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  AvailabilityLegend(
                    filterAvailability: filterAvailability,
                    changeFilterAvailability: (value) {
                      filterAvailability = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is InkWell),
        findsNWidgets(5),
      );
    });

    testWidgets('DateDetail component renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      VoteDateModel testVoteDate = MockFirebaseVote.testVoteDate;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: DateDetail(
                  pollId: MockFirebasePollEvent.testPollId,
                  organizerUid: testPollEventModel.organizerUid,
                  invites: [],
                  modifyVote: (value) {},
                  voteDate: testVoteDate,
                  isClosed: testPollEventModel.isClosed,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is AvailabilityLegend),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is MyPolls),
        findsOneWidget,
      );
      [
        Availability.yes,
        Availability.iff,
        Availability.not,
        Availability.empty,
      ].forEach((availability) {
        Map<String, dynamic> votesKind = VoteDateModel.getVotesKind(
          voteDate: testVoteDate,
          kind: availability,
          invites: MockFirebasePollEvent.testInvites,
          organizerUid: testPollEventModel.organizerUid,
        );
        expect(
          find.text(
              " ${votesKind.length} ${Availability.description(availability)}"),
          findsOneWidget,
        );
      });
    });

    testWidgets('DateTile component renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      VoteDateModel testVoteDate = MockFirebaseVote.testVoteDate;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: DateTile(
                  pollId: MockFirebasePollEvent.testPollId,
                  organizerUid: testPollEventModel.organizerUid,
                  invites: MockFirebasePollEvent.testInvites,
                  voteDate: testVoteDate,
                  modifyVote: (value) {},
                  isClosed: testPollEventModel.isClosed,
                  votingUid: testPollEventModel.organizerUid,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is ContainerShadow),
        findsOneWidget,
      );
      await tester
          .tap(find.byWidgetPredicate((widget) => widget is ContainerShadow));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is DateDetail),
        findsOneWidget,
      );
    });

    testWidgets('DatesList component renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: DatesList(
                  pollId: MockFirebasePollEvent.testPollId,
                  organizerUid: testPollEventModel.organizerUid,
                  invites: MockFirebasePollEvent.testInvites,
                  isClosed: testPollEventModel.isClosed,
                  votingUid: testPollEventModel.organizerUid,
                  dates: testPollEventModel.dates,
                  deadline: testPollEventModel.deadline,
                  votesDates: MockFirebasePollEvent.testVotesDates,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is AvailabilityLegend),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is DatesViewCalendar),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is DatesViewHorizontal),
        findsOneWidget,
      );
    });

    testWidgets('DatesViewCalendar component renders correctly',
        (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: DatesViewCalendar(
                  pollId: MockFirebasePollEvent.testPollId,
                  organizerUid: testPollEventModel.organizerUid,
                  invites: MockFirebasePollEvent.testInvites,
                  dates: testPollEventModel.dates,
                  deadline: testPollEventModel.deadline,
                  votesDates: MockFirebasePollEvent.testVotesDates,
                  filterDates: (value) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is TableCalendar),
        findsOneWidget,
      );
    });

    testWidgets('DatesViewHorizontal component renders correctly',
        (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: DatesViewHorizontal(
                  pollId: MockFirebasePollEvent.testPollId,
                  organizerUid: testPollEventModel.organizerUid,
                  invites: MockFirebasePollEvent.testInvites,
                  dates: testPollEventModel.dates,
                  deadline: testPollEventModel.deadline,
                  votesDates: MockFirebasePollEvent.testVotesDates,
                  isClosed: testPollEventModel.isClosed,
                  updateFilterAfterVote: () {},
                  votingUid: testPollEventModel.organizerUid,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is DateTile),
        findsNWidgets(MockFirebasePollEvent.testVotesDates.length),
      );
    });

    testWidgets('InviteeVotesView component renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: ListView(
                  children: [
                    InviteeVotesView(
                      invites: MockFirebasePollEvent.testInvites,
                      votesDates: MockFirebasePollEvent.testVotesDates,
                      isClosed: testPollEventModel.isClosed,
                      pollData: testPollEventModel,
                      pollEventId: MockFirebasePollEvent.testPollId,
                      refreshPollDetail: () {},
                      userData: UserModel(
                        uid: 'user1',
                        email: 'test email',
                        username: 'test username',
                        name: 'test name',
                        surname: 'test surname',
                        profilePic: 'default',
                      ),
                      votesLocations: MockFirebasePollEvent.testVotesLocations,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is TabBar),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is LocationsList),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is DatesList),
        findsNothing,
      );

      await tester.tap(find.text("Dates"));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is LocationsList),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is DatesList),
        findsOneWidget,
      );
    });

    testWidgets('InviteesList component renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
            ChangeNotifierProvider<FirebaseNotification>(
              create: (context) => MockFirebaseNotification(),
            ),
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
            Provider<FirebaseGroups>(
              create: (context) => MockFirebaseGroups(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: InviteesList(
                  invites: MockFirebasePollEvent.testInvites,
                  votesDates: MockFirebasePollEvent.testVotesDates,
                  isClosed: testPollEventModel.isClosed,
                  pollData: testPollEventModel,
                  pollEventId: MockFirebasePollEvent.testPollId,
                  refreshPollDetail: () {},
                  votesLocations: MockFirebasePollEvent.testVotesLocations,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is TabbarSwitcher),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is UserTileFromData),
        findsAtLeastNWidgets(1),
      );

      await tester.tap(find.text("Invite"));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is StepInvite),
        findsOneWidget,
      );
    });

    testWidgets('InviteesPill component renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: InviteesPill(
                pollEventId: MockFirebasePollEvent.testPollId,
                invites: [],
                refreshPollDetail: () {},
                pollData: testPollEventModel,
                votesLocations: [],
                votesDates: [],
                isClosed: testPollEventModel.isClosed,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is ProfilePicsStack),
        findsNothing,
      );
      expect(
        find.text("0 invited"),
        findsOneWidget,
      );
    });

    testWidgets('LocationDetail component renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: ListView(
                  children: [
                    LocationDetail(
                      pollId: MockFirebasePollEvent.testPollId,
                      organizerUid: testPollEventModel.organizerUid,
                      invites: [],
                      location: testPollEventModel.locations[0],
                      modifyVote: (value) {},
                      isClosed: testPollEventModel.isClosed,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is AvailabilityLegend),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is MyPolls),
        findsOneWidget,
      );
      [
        Availability.yes,
        Availability.iff,
        Availability.not,
        Availability.empty,
      ].forEach((availability) {
        Map<String, dynamic> votesKind = VoteLocationModel.getVotesKind(
          voteLocation: MockFirebaseVote.testVoteLocation,
          kind: availability,
          invites: MockFirebasePollEvent.testInvites,
          organizerUid: testPollEventModel.organizerUid,
        );
        expect(
          find.text(
              " ${votesKind.length} ${Availability.description(availability)}"),
          findsOneWidget,
        );
      });
    });

    testWidgets('LocationTile component renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: LocationTile(
                  pollId: MockFirebasePollEvent.testPollId,
                  organizerUid: testPollEventModel.organizerUid,
                  invites: [],
                  location: testPollEventModel.locations[0],
                  modifyVote: (value) {},
                  isClosed: testPollEventModel.isClosed,
                  voteLocation: MockFirebaseVote.testVoteLocation,
                  votingUid: testPollEventModel.organizerUid,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is MyListTile),
        findsOneWidget,
      );

      await tester
          .tap(find.byWidgetPredicate((widget) => widget is MyListTile));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is LocationDetail),
        findsOneWidget,
      );
    });

    testWidgets('LocationsList component renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: LocationsList(
                  pollId: MockFirebasePollEvent.testPollId,
                  organizerUid: testPollEventModel.organizerUid,
                  invites: [],
                  isClosed: testPollEventModel.isClosed,
                  votingUid: testPollEventModel.organizerUid,
                  locations: testPollEventModel.locations,
                  votesLocations: MockFirebasePollEvent.testVotesLocations,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is LocationTile),
        findsNWidgets(2),
      );
    });

    testWidgets('MostVotedDateTile component renders correctly',
        (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: MostVotedDateTile(
                  votesDates: MockFirebasePollEvent.testVotesDates,
                  pollData: testPollEventModel,
                  pollId: MockFirebasePollEvent.testPollId,
                  invites: MockFirebasePollEvent.testInvites,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is MyListTile),
        findsOneWidget,
      );

      await tester
          .tap(find.byWidgetPredicate((widget) => widget is MyListTile));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is DateDetail),
        findsOneWidget,
      );
    });

    testWidgets('MostVotedLocationTile component renders correctly',
        (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: MostVotedLocationTile(
                  votesLocations: MockFirebasePollEvent.testVotesLocations,
                  pollData: testPollEventModel,
                  pollId: MockFirebasePollEvent.testPollId,
                  invites: MockFirebasePollEvent.testInvites,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is MyListTile),
        findsOneWidget,
      );

      await tester
          .tap(find.byWidgetPredicate((widget) => widget is MyListTile));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is LocationDetail),
        findsOneWidget,
      );
    });

    testWidgets('MyPolls component renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: MyPolls(
                organizerUid: testPollEventModel.organizerUid,
                curUid: testPollEventModel.organizerUid,
                pollId: "1",
                isClosed: testPollEventModel.isClosed,
                onVoted: (value1, value2) async => false,
                pollTitle: Container(),
                pollOptions: [
                  MyPollOption(title: Text("option 1"), votes: 2),
                  MyPollOption(title: Text("option 2"), votes: 3),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("option 1"), findsOneWidget);
      expect(find.text("option 2"), findsOneWidget);
    });

    testWidgets('PollEventOptions component renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: PollEventOptions(
                  pollData: testPollEventModel,
                  pollEventId: MockFirebasePollEvent.testPollId,
                  invites: MockFirebasePollEvent.testInvites,
                  refreshPollDetail: () {},
                  votesLocations: MockFirebasePollEvent.testVotesLocations,
                  votesDates: MockFirebasePollEvent.testVotesDates,
                  isClosed: testPollEventModel.isClosed,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is ListTile),
        findsNWidgets(3),
      );
    });

    testWidgets('PollDetailScreen renders correctly', (tester) async {
      PollEventModel testPollEventModel =
          MockFirebasePollEvent.testPollEventModel;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
            ChangeNotifierProvider<FirebaseNotification>(
              create: (context) => MockFirebaseNotification(),
            ),
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            Provider<FirebaseGroups>(
              create: (context) => MockFirebaseGroups(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: PollDetailScreen(
              pollId: MockFirebasePollEvent.testPollId,
              pollData: testPollEventModel,
              pollInvites: MockFirebasePollEvent.testInvites,
              votesLocations: MockFirebasePollEvent.testVotesLocations,
              votesDates: MockFirebasePollEvent.testVotesDates,
              refreshPollDetail: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is TabbarSwitcher),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is InviteesPill),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is UserTileFromUid),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is MostVotedLocationTile),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is MostVotedDateTile),
        findsOneWidget,
      );

      await tester.fling(
        find.byWidgetPredicate((widget) => widget is MostVotedDateTile),
        Offset(0, -150),
        1000,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) => widget is LocationsList),
        findsOneWidget,
      );

      await tester.tap(find.text("Dates"));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is DatesList),
        findsOneWidget,
      );
    });

    testWidgets('PollEventScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
            ChangeNotifierProvider<FirebaseNotification>(
              create: (context) => MockFirebaseNotification(),
            ),
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            Provider<FirebasePollEvent>(
              create: (context) => MockFirebasePollEvent(),
            ),
            Provider<FirebasePollEventInvite>(
              create: (context) => MockFirebasePollEventInvite(),
            ),
            Provider<FirebaseGroups>(
              create: (context) => MockFirebaseGroups(),
            ),
            Provider<FirebaseVote>(
              create: (context) => MockFirebaseVote(),
            ),
          ],
          child: MaterialApp(
            home: PollEventScreen(
              pollEventId: MockFirebasePollEvent.testPollId,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is PollDetailScreen),
        findsOneWidget,
      );
    });
  });
}
