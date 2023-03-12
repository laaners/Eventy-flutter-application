import 'package:flutter/material.dart';
import '../screens/poll_detail/index.dart';

class PollList extends StatefulWidget {
  final List<String> polls;
  final double height;

  const PollList({super.key, required this.polls, required this.height});

  @override
  State<PollList> createState() => _PollListState();
}

class _PollListState extends State<PollList> {
  late ScrollController controller;
  late int pollsToLoad;
  List<Map<String, dynamic>> pollsData = [];

  @override
  void initState() {
    pollsToLoad = widget.height ~/ 80.round();
    initPollsData(0,
        widget.polls.length < pollsToLoad ? widget.polls.length : pollsToLoad);
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    pollsData = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: pollsData.isEmpty
          ? const Center(
              child: Text("empty"),
            )
          : ListView.builder(
              controller: controller,
              itemBuilder: (context, index) {
                return PollTile(
                  pollData: pollsData[index],
                );
              },
              itemCount: pollsData.length,
            ),
    );
  }

  initPollsData(int i, int j) {}

  void _scrollListener() {
    if (controller.position.extentAfter < 500) {
      if (pollsData.length < widget.polls.length - pollsToLoad) {
        initPollsData(pollsData.length, pollsData.length + pollsToLoad);
      } else if (pollsData.length < widget.polls.length) {
        initPollsData(pollsData.length, widget.polls.length);
      }
    }
  }
}

class PollTile extends StatelessWidget {
  final Map<String, dynamic> pollData;

  const PollTile({super.key, required this.pollData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListTile(
        // todo: change Avatar to LocationPic
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
        ),
        title: Text("${pollData['pollName']}"),
        subtitle: Text("${pollData['deadline']}"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PollDetailScreen(pollData: pollData)),
          );
        },
      ),
    );
  }
}
