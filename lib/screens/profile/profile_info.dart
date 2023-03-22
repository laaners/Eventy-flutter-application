import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/profile/profile_pic.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../server/firebase_follow.dart';
import 'follow_list.dart';

class ProfileInfo extends StatefulWidget {
  final UserCollection? userData;

  const ProfileInfo({super.key, required this.userData});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  List<String>? following = [];
  List<String>? followers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    followers = [];
    following = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    bool isCurrentUser = curUid == widget.userData?.uid;
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: ProfilePic(
                  userData: widget.userData,
                  loading: false,
                  radius: 90,
                ),
              ),
              Text(widget.userData!.username),
              Text("${widget.userData?.uid} ${widget.userData?.surname}"),
            ],
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
              isCurrentUser
                  ? Consumer<FirebaseFollow>(
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
                    )
                  : FutureBuilder<List<String>?>(
                      future:
                          Provider.of<FirebaseFollow>(context, listen: false)
                              .getFollowers(context, widget.userData!.uid),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<List<String>?> snapshot,
                      ) {
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
                        return TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FollowListScreen(
                                  users: snapshot.data!,
                                  title:
                                      "${widget.userData?.username} Followers",
                                ),
                              ),
                            );
                          },
                          child: Text(
                              "${snapshot.data != null ? snapshot.data?.length : 0} followers"),
                        );
                      },
                    ),
              const VerticalDivider(
                thickness: 2,
                color: Colors.grey,
              ),
              isCurrentUser
                  ? Consumer<FirebaseFollow>(
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
                          child: Text("${value.followingUid.length} following"),
                        );
                      },
                    )
                  : FutureBuilder<List<String>?>(
                      future:
                          Provider.of<FirebaseFollow>(context, listen: false)
                              .getFollowing(context, widget.userData!.uid),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<List<String>?> snapshot,
                      ) {
                        return TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FollowListScreen(
                                  users: snapshot.data!,
                                  title:
                                      "${widget.userData?.username} Following",
                                ),
                              ),
                            );
                          },
                          child: Text(
                              "${snapshot.data != null ? snapshot.data?.length : 0} following"),
                        );
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
