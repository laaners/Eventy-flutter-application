import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/profile/follow_list.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/tables/follow_collection.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowButtons extends StatelessWidget {
  final UserCollection? userData;
  const FollowButtons({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FollowCollection>(
      future: Provider.of<FirebaseFollow>(context, listen: false)
          .getFollow(userData!.uid),
      builder: (
        BuildContext context,
        AsyncSnapshot<FollowCollection> snapshot,
      ) {
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
        if (!snapshot.hasData) {
          return Container();
        }
        FollowCollection follow = snapshot.data!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowListScreen(
                        users: follow.followers,
                        title: "${userData?.username} Followers",
                      ),
                    ),
                  );
                },
                child: Text("${follow.followers.length} followers")),
            const VerticalDivider(thickness: 2),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowListScreen(
                      users: follow.following,
                      title: "${userData?.username} Following",
                    ),
                  ),
                );
              },
              child: Text("${follow.following.length} following"),
            ),
          ],
        );
      },
    );
  }
}
