import 'package:dima_app/providers/theme_switch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/error.dart';
import '../screens/profile/index.dart';
import 'profile_pic.dart';
import '../screens/profile/view_profile.dart';
import '../server/firebase_user.dart';
import '../server/tables/user_collection.dart';
import '../transitions/screen_transition.dart';
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
        child: Icon(
          Icons.search,
          color: Provider.of<ThemeSwitch>(context).themeData.primaryColor,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title),
      backgroundColor: Colors.transparent,
      iconTheme:
          Provider.of<ThemeSwitch>(context).themeData.appBarTheme.iconTheme,
      actions: upRightActions,
    );
  }
}

class CustomDelegate extends SearchDelegate<String> {
  List<UserCollection> usersData = [];

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
    return query.isEmpty
        ? Container()
        : FutureBuilder(
            future: Provider.of<FirebaseUser>(context, listen: false)
                .getUsersData(context, query),
            builder: (
              context,
              snapshot,
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
              usersData = snapshot.data!;
              return ListView.builder(
                itemCount: usersData.length,
                itemBuilder: (_, i) {
                  var user = usersData[i];
                  return UserTileSearch(
                    userData: user,
                  );
                },
              );
            },
          );
  }
}

class UserTileSearch extends StatelessWidget {
  final UserCollection userData;
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewProfileScreen(userData: userData),
              ),
            );
          }
        },
      ),
    );
  }
}
