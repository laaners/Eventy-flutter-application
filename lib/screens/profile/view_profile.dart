import 'package:dima_app/screens/profile/follow_buttons.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/themes/layout_constants.dart';
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
  const ViewProfileScreen({super.key, required this.profileUserData});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  bool _refresh = true;
  late UserCollection userData;
  bool? _isFollowing;

  void initIsFollowing() async {
    await Provider.of<FirebaseFollow>(context, listen: false)
        .isFollowing(
          context,
          userData.uid,
          widget.profileUserData.uid,
        )
        .then((value) => setState(() {
              _isFollowing = value;
            }));
  }

  @override
  void initState() {
    super.initState();
    userData = Provider.of<FirebaseUser>(context, listen: false).userData!;
    initIsFollowing();
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
        labels: const ["Events", "Polls"],
        tabbars: [
          EventList(userUid: widget.profileUserData.uid),
          PollList(userUid: widget.profileUserData.uid)
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
                  radius: LayoutConstants.kProfilePicRadius,
                ),
                Positioned(
                  bottom: -10,
                  child: _isFollowing == null
                      ? const SizedBox(
                          width: LayoutConstants.kButtonWidth,
                          height: LayoutConstants.kButtonWidth,
                          child: FittedBox(
                              fit: BoxFit.scaleDown, child: LoadingSpinner()))
                      : TextButton.icon(
                          onPressed: () async {
                            if (_isFollowing!) {
                              await Provider.of<FirebaseFollow>(context,
                                      listen: false)
                                  .removeFollower(
                                      context,
                                      widget.profileUserData.uid,
                                      userData.uid,
                                      true);
                            } else {
                              await Provider.of<FirebaseFollow>(context,
                                      listen: false)
                                  .addFollower(
                                      context,
                                      widget.profileUserData.uid,
                                      userData.uid,
                                      true);
                            }
                            // TODO: async/await seems to not work properly, isFollowing retrieves old data.
                            // add delay of two seconds
                            await Future.delayed(
                                const Duration(milliseconds: 100));
                            initIsFollowing();
                          },
                          icon: Icon(_isFollowing!
                              ? Icons.person_remove
                              : Icons.person_add),
                          label: Text(_isFollowing! ? "Unfollow" : "Follow"),
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
                ),
              ],
            ),
            const SizedBox(height: LayoutConstants.kHeight),
            ProfileInfo(userData: widget.profileUserData),
            const SizedBox(height: LayoutConstants.kHeight),
            FollowButtons(
              userData: widget.profileUserData,
            ),
          ],
        ),
        stickyHeight: 400,
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
    );
  }
}
