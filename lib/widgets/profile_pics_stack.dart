import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/error.dart';
import '../transitions/screen_transition.dart';
import 'loading_spinner.dart';
import 'package:collection/collection.dart';

class ProfilePicsStack extends StatefulWidget {
  final double radius;
  final double offset;
  final List<String> uids;
  const ProfilePicsStack({
    super.key,
    required this.radius,
    required this.offset,
    required this.uids,
  });

  @override
  State<ProfilePicsStack> createState() => _ProfilePicsStackState();
}

class _ProfilePicsStackState extends State<ProfilePicsStack> {
  Future<List<UserCollection>>? _future;

  @override
  initState() {
    super.initState();
    _future = Provider.of<FirebaseUser>(context, listen: false)
        .getUsersDataFromList(context, widget.uids);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserCollection>>(
      future: _future,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<UserCollection>> snapshot,
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
        List<UserCollection> users = snapshot.data!;
        return SizedBox(
          height: widget.radius * 2,
          width: (widget.radius * 2 - widget.offset) * widget.uids.length +
              widget.offset,
          child: Stack(
            children: [
              ...users.mapIndexed((index, user) {
                return Positioned(
                  left: (widget.radius * 2 - widget.offset) * index,
                  child: ProfilePic(
                    userData: user,
                    loading: false,
                    radius: widget.radius,
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
