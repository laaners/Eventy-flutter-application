import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';

class PollDetailScreen extends StatefulWidget {
  final String organizerUid;
  final String pollName;
  const PollDetailScreen({
    super.key,
    required this.organizerUid,
    required this.pollName,
  });

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Poll Details"),
      body: ListView(
        children: [
          Text(widget.organizerUid),
          Text(widget.pollName),
        ],
      ),
    );
  }
}
