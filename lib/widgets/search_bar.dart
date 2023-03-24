import 'package:dima_app/server/firebase_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/profile/index.dart';
import '../screens/profile/profile_pic.dart';
import '../screens/profile/view_profile.dart';
import '../server/tables/user_collection.dart';

class SearchBar extends StatefulWidget {
  final Widget child;
  const SearchBar({super.key, required this.child});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _controller = TextEditingController();
  bool _folded = true;
  List<UserCollection> usersMatching = [];
  // true after next query, false when input text is empty
  bool loadingUsers = false;

  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  void _onFocusChange() {
    print("\t\t\tFocus: ${_focus.hasFocus.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: AnimatedContainer(
            margin: const EdgeInsets.all(10),
            width: _folded ? MediaQuery.of(context).size.width : 56,
            height: 40,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurStyle: BlurStyle.inner,
                ),
              ],
            ),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    child: _folded
                        ? Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: TextField(
                              controller: _controller,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: const InputDecoration(
                                hintText: 'Search username...',
                                border: InputBorder.none,
                              ),
                              focusNode: _focus,
                              onChanged: (text) async {
                                if (text.isEmpty) {
                                  setState(
                                    () {
                                      usersMatching = [];
                                      loadingUsers = false;
                                    },
                                  );
                                  return;
                                } else {
                                  loadingUsers = true;
                                  var tmp = await Provider.of<FirebaseUser>(
                                          context,
                                          listen: false)
                                      .getUsersData(context, text);
                                  setState(() {
                                    usersMatching = tmp;
                                  });
                                }
                              },
                            ),
                          )
                        : null,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    setState(() {
                      _folded = !_folded;
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Icon(!_folded ? Icons.search : Icons.close),
                  ),
                )
              ],
            ),
          ),
        ),
        _folded
            ? UserList(
                users: usersMatching,
              )
            : widget.child,
      ],
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
        ? Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return UserTile(
                  userData: users[index],
                );
              },
              itemCount: users.length,
            ),
          )
        : const Center(
            child: Text("No results found."),
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
          radius: 30,
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
