import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/event_detail/index.dart';
import 'package:dima_app/server/firebase_event.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/tables/event_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventDetailCreate extends StatefulWidget {
  final String eventId;

  const EventDetailCreate({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailCreate> createState() => _EventDetailCreateState();
}

class _EventDetailCreateState extends State<EventDetailCreate>
    with AutomaticKeepAliveClientMixin {
  Future? _future;

  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    super.initState();
    _future = Provider.of<FirebasePoll>(context, listen: false).deletePoll(
      context: context,
      pollId: widget.eventId,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _future,
      builder: (
        BuildContext context,
        AsyncSnapshot snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingSpinner();
        }
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
        return EventDetailScreen(eventId: widget.eventId);
      },
    );
  }
}
