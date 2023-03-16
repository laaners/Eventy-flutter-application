import 'package:dima_app/screens/error.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:dima_app/widgets/user_list.dart';
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
      appBar: MyAppBar("Poll Detail"),
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
          return Container(
            margin: const EdgeInsets.all(10),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Center(
                    child: Text(
                      pollData.pollName,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
                const Text(
                  "Organized by",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                UserTile(userUid: pollData.organizerUid),
                const Text(
                  "About this event",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                Text(pollData.pollDesc.isEmpty
                    ? "The organized did not provide any description"
                    : pollData.pollDesc),
                Container(
                  width: 40,
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  child: SizedBox(
                    child: PillBox(
                      child: const Text(
                        "Virtual meeting",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(pollData.deadline),
                Text(pollData.public.toString()),
              ],
            ),
          );
        },
      ),
    );
  }
}
