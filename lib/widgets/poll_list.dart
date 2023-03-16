import 'package:dima_app/screens/error.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PollList extends StatefulWidget {
  final String userUid;
  final double height;

  const PollList({super.key, required this.userUid, required this.height});

  @override
  State<PollList> createState() => _PollListState();
}

class _PollListState extends State<PollList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<FirebasePoll>(context, listen: false)
          .getUserPolls(context, widget.userUid),
      builder: (context, snapshot) {
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
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            child: const Text("empty"),
          );
        }
        var pollsData = snapshot.data!;
        return Column(
          children: [
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
            ...pollsData.map((e) => PollTile(pollData: e)).toList(),
          ],
        );
      },
    );
  }
}

class PollTile extends StatelessWidget {
  final PollCollection pollData;

  const PollTile({super.key, required this.pollData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.place),
        ),
        title: Text(pollData.pollName),
        subtitle: Text(pollData.organizerUid),
        onTap: () {},
      ),
    );
  }
}
