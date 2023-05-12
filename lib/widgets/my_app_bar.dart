import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/profile/profile.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_spinner.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(50);
  final String title;
  final List<Widget> upRightActions;

  const MyAppBar({
    super.key,
    required this.title,
    required this.upRightActions,
  });

  static Widget SearchAction(context) => TextButton(
        onPressed: () async {
          await showSearch<String>(
            context: context,
            delegate: CustomDelegate(),
          );
        },
        child: const Icon(
          Icons.search,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        overflow: TextOverflow.fade,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      // backgroundColor: Colors.transparent,
      actions: upRightActions,
      scrolledUnderElevation: 0,
    );
  }
}

class CustomDelegate extends SearchDelegate<String> {
  List<UserModel> usersData = [];

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    print(query.isEmpty);
    return query.isEmpty
        ? Container()
        : FutureBuilder(
            future: Provider.of<FirebaseUser>(context, listen: false)
                .getUsersData(pattern: query),
            builder: (
              context,
              snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingSpinner();
              }
              if (snapshot.hasError) {
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
              if (!snapshot.hasData) {
                return Container();
              }
              usersData = snapshot.data!;
              return ResponsiveWrapper(
                child: ListView.builder(
                  itemCount: usersData.length + 1,
                  itemBuilder: (_, i) {
                    if (i == usersData.length) {
                      return Container(
                          height: LayoutConstants.kPaddingFromCreate);
                    }
                    var user = usersData[i];
                    return UserTileSearch(
                      userData: user,
                    );
                  },
                ),
              );
            },
          );
  }
}

class UserTileSearch extends StatelessWidget {
  final UserModel userData;
  const UserTileSearch({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListTile(
        leading: ProfilePic(
          loading: false,
          userData: userData,
          radius: 25,
        ),
        title: Text("${userData.name} ${userData.surname}"),
        subtitle: Text(userData.username),
        onTap: () {
          var curUid =
              Provider.of<FirebaseUser>(context, listen: false).user!.uid;
          if (curUid == userData.uid) {
            Widget newScreen = const ProfileScreen();
            Navigator.push(
              context,
              ScreenTransition(
                builder: (context) => newScreen,
              ),
            );
          } else {
            // Widget newScreen = ViewProfileScreen(profileUserData: userData);
            Widget newScreen = const ProfileScreen();
            Navigator.push(
              context,
              ScreenTransition(
                builder: (context) => newScreen,
              ),
            );
          }
        },
      ),
    );
  }
}
