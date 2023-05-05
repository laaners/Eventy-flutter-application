import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/profile/follow_buttons.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/themes/layout_constants.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/event_list.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/poll_list.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/my_app_bar.dart';
import 'profile_info.dart';

class ViewProfileScreen extends StatefulWidget {
  final UserCollection profileUserData;
  const ViewProfileScreen({
    super.key,
    required this.profileUserData,
  });

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  late UserCollection userData;
  bool _refresh = true;

  @override
  void initState() {
    userData = Provider.of<FirebaseUser>(context, listen: false).userData!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _refresh = !_refresh;
        });
        return;
      },
      child: TabbarSwitcher(
        appBarTitle: widget.profileUserData.name,
        labels: const ["Polls", "Events"],
        tabbars: [
          PollList(userUid: widget.profileUserData.uid),
          EventList(userUid: widget.profileUserData.uid),
        ],
        listSticky: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ProfilePic(
                  userData: widget.profileUserData,
                  loading: false,
                  radius: LayoutConstants.kProfilePicRadiusLarge,
                ),
                FutureBuilder<bool>(
                    future: Provider.of<FirebaseFollow>(context, listen: false)
                        .isFollowing(
                      context,
                      userData.uid,
                      widget.profileUserData.uid,
                    ),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<bool?> snapshot,
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
                      bool isFollowing = snapshot.data!;
                      return Positioned(
                        bottom: -10,
                        child: TextButton.icon(
                          onPressed: () async {
                            print("------------------------");
                            if (isFollowing) {
                              print("remove");
                              await Provider.of<FirebaseFollow>(context,
                                      listen: false)
                                  .removeFollower(
                                      context,
                                      widget.profileUserData.uid,
                                      userData.uid,
                                      true);
                              print("done remove");
                            } else {
                              print("add");
                              await Provider.of<FirebaseFollow>(context,
                                      listen: false)
                                  .addFollower(
                                      context,
                                      widget.profileUserData.uid,
                                      userData.uid,
                                      true);
                              print("done add");
                            }
                            /*
                                // TODO: async/await seems to not work properly, isFollowing retrieves old data.
                                // add delay of two seconds
                                await Future.delayed(
                                    const Duration(milliseconds: 100));
                                initIsFollowing();
                                */
                            await Future.delayed(
                                const Duration(milliseconds: 100));
                            isFollowing = !isFollowing;
                            print(isFollowing);
                            setState(() {
                              _refresh = !_refresh;
                            });
                          },
                          icon: Icon(
                            isFollowing
                                ? Icons.person_remove
                                : Icons.person_add,
                          ),
                          label: Text(isFollowing ? "Unfollow" : "Follow"),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.secondaryContainer,
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                            fixedSize: MaterialStateProperty.all(
                              const Size(LayoutConstants.kButtonWidth,
                                  LayoutConstants.kButtonHeight),
                            ),
                          ),
                        ),
                      );
                    }),
              ],
            ),
            const SizedBox(height: LayoutConstants.kHeight),
            ProfileInfo(userData: widget.profileUserData),
            FollowButtons(userData: widget.profileUserData),
          ],
        ),
        stickyHeight: 350,
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
    );
  }
}
