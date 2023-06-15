import 'package:dima_app/models/group_model.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/container_shadow.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:dima_app/widgets/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewGroup extends StatefulWidget {
  final GroupModel group;
  const ViewGroup({super.key, required this.group});

  @override
  State<ViewGroup> createState() => _ViewGroupState();
}

class _ViewGroupState extends State<ViewGroup> {
  Future<List<UserModel>>? _future;

  @override
  void initState() {
    super.initState();
    _future = Provider.of<FirebaseUser>(context, listen: false)
        .getUsersDataFromList(uids: widget.group.membersUids);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (
        context,
        snapshot,
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
        List<UserModel> usersData = snapshot.data!;
        return ViewGroupBody(
          groupName: widget.group.groupName,
          members: usersData,
        );
      },
    );
  }
}

class ViewGroupBody extends StatefulWidget {
  final String groupName;
  final List<UserModel> members;
  const ViewGroupBody(
      {super.key, required this.members, required this.groupName});

  @override
  State<ViewGroupBody> createState() => _ViewGroupBodyState();
}

class _ViewGroupBodyState extends State<ViewGroupBody> {
  List<UserModel> members = [];

  @override
  void initState() {
    super.initState();
    members = widget.members;
  }

  @override
  Widget build(BuildContext context) {
    return MyModal(
      doneCancelMode: false,
      onDone: () {},
      heightFactor: 0.85,
      titleWidget: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8, top: 8),
            alignment: Alignment.topLeft,
            child: Text(
              widget.groupName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 0, top: 8),
            alignment: Alignment.topLeft,
            child: Text(
              "Members: ${members.length}",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        controller: ScrollController(),
        itemCount: members.length,
        itemBuilder: (BuildContext context, int index) {
          UserModel user = members[index % members.length];
          return UserTileFromData(userData: user);
        },
      ),
    );
  }
}
