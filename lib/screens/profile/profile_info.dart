import 'change_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../server/firebase_follow.dart';
import '../../server/firebase_user.dart';
import 'follow_list.dart';

class ProfileInfo extends StatefulWidget {
  Map<String, dynamic>? userData;

  ProfileInfo({super.key, required this.userData});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  @override
  void initState() {
    // TODO: implement initState
    initFollow();
    super.initState();
  }

  void initFollow() async {
    String uid = widget.userData!["uid"];
    await Provider.of<FirebaseFollow>(context, listen: false)
        .getFollowers(context, uid);
    // ignore: use_build_context_synchronously
    await Provider.of<FirebaseFollow>(context, listen: false)
        .getFollowing(context, uid);
  }

  @override
  Column build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: const ChangeImage(),
        ),
        Center(
          child: Consumer<FirebaseUser>(
            builder: (context, value, child) {
              return Column(
                children: [
                  Text("${value.userData!["username"]}"),
                  Text(
                      "${value.userData!["name"]} ${value.userData!["surname"]}"),
                ],
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            border: Border(),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer<FirebaseFollow>(
                builder: (context, value, child) {
                  return TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FollowListScreen(
                            users: value.followersUid,
                            title: "Followers",
                          ),
                        ),
                      );
                    },
                    child: Text("${value.followersUid.length} followers"),
                  );
                },
              ),
              const VerticalDivider(
                thickness: 2,
                color: Colors.grey,
              ),
              Consumer<FirebaseFollow>(
                builder: (context, value, child) {
                  return TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowListScreen(
                              users: value.followingUid,
                              title: "Following",
                            ),
                          ),
                        );
                      },
                      child: Text("${value.followingUid.length} following"));
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}


// todo: add ProfileViewScreen
