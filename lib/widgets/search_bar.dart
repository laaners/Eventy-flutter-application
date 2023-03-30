import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/profile/index.dart';
import 'profile_pic.dart';
import '../screens/profile/view_profile.dart';
import '../server/tables/user_collection.dart';

class SearchBar extends StatefulWidget {
  final Widget child;
  const SearchBar({super.key, required this.child});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  List<UserCollection> usersMatching = [];
  // true after next query, false when input text is empty
  bool loadingUsers = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
            horizontalTitleGap: 0,
            trailing: IconButton(
              iconSize: 25,
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            subtitle: TextFormField(
              autofocus: false,
              decoration: const InputDecoration(hintText: "Search here"),
              onChanged: (text) async {
                if (text.isEmpty) {
                  setState(() {
                    usersMatching = [];
                    loadingUsers = false;
                  });
                  return;
                } else {
                  loadingUsers = true;
                  var tmp =
                      await Provider.of<FirebaseUser>(context, listen: false)
                          .getUsersData(context, text);
                  setState(() {
                    usersMatching = tmp;
                  });
                }
              },
            ),
          ),
          UserList(
            users: usersMatching,
          )
        ],
      ),
    );
  }
}

class UserList extends StatelessWidget {
  final List<UserCollection> users;

  const UserList({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return users.isNotEmpty
        ? HorizontalScroller(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: users
                .map(
                  (e) => ProfilePic(
                    userData: e,
                    loading: false,
                    radius: 30,
                  ),
                )
                .toList(),
          )
        : const Center(
            child: Text("No results found."),
          );

    return SizedBox(
      height: 200,
      child: users.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                children: users.map((e) => UserTile(userData: e)).toList(),
              ),
            )
          : const Center(
              child: Text("No results found."),
            ),
    );
  }
}

class UserTile extends StatelessWidget {
  final UserCollection userData;
  const UserTile({super.key, required this.userData});

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
