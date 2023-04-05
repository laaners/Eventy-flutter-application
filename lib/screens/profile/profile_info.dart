import 'package:dima_app/screens/error.dart';
import 'package:dima_app/server/tables/follow_collection.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../server/firebase_follow.dart';
import 'follow_list.dart';

class ProfileInfo extends StatelessWidget {
  final UserCollection? userData;

  const ProfileInfo({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: ProfilePic(
                  userData: userData,
                  loading: false,
                  radius: 90,
                ),
              ),
              Text(
                '@${userData!.username}',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text("${userData?.name} ${userData?.surname}",
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
        FutureBuilder<FollowCollection>(
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
                  child: Text("${follow.followers.length} followers"),
                ),
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
        )
      ],
    );
  }
}

// todo: add ProfileViewScreen
