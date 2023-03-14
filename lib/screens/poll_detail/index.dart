import 'package:dima_app/screens/error.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PollDetailScreen extends StatefulWidget {
  final String pollId;

  const PollDetailScreen({
    super.key,
    required this.pollId,
  });

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  PollCollection? pollData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("Poll ${pollData?.pollName}"),
      body: FutureBuilder<PollCollection?>(
        future: Provider.of<FirebasePoll>(context, listen: false)
            .getPollData(context, widget.pollId),
        builder: (
          BuildContext context,
          AsyncSnapshot<PollCollection?> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingSpinner();
          }
          if (snapshot.hasError || !snapshot.hasData) {
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
          PollCollection pollData = snapshot.data!;
          print(pollData.toString());
          return ListView(
            children: [
              Text(pollData.organizerUid),
              Text(pollData.deadline),
              Text(pollData.public.toString()),
            ],
          );
        },
      ),
    );
  }
}
