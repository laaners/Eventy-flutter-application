import 'package:dima_app/screens/error.dart';
import 'package:dima_app/server/firebase_event.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/event_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with AutomaticKeepAliveClientMixin {
  Future<EventCollection?>? _future;

  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    super.initState();
    _future = Provider.of<FirebaseEvent>(context, listen: false).getEventData(
      context: context,
      id: widget.eventId,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<EventCollection?>(
      future: _future,
      builder: (
        BuildContext context,
        AsyncSnapshot<EventCollection?> snapshot,
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
        EventCollection eventData = snapshot.data!;
        print(eventData);
        var curUid =
            Provider.of<FirebaseUser>(context, listen: false).user!.uid;
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _future = Provider.of<FirebaseEvent>(context, listen: false)
                  .getEventData(
                context: context,
                id: widget.eventId,
              );
            });
            return;
          },
          child: Scaffold(
            appBar: const MyAppBar(
              title: "",
              upRightActions: [],
            ),
            body: ResponsiveWrapper(
              child: ListView(
                children: [
                  Text(eventData.eventName),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
