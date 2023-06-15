import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/poll_create/poll_create.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_logo.dart';
import 'show_snack_bar.dart';
import 'user_tile.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(50);
  final String title;
  final List<Widget>? upRightActions;
  final ShapeBorder? shape;

  const MyAppBar({
    super.key,
    required this.title,
    this.upRightActions,
    this.shape,
  });

  static Widget searchAction(context) => MyIconButton(
        margin: const EdgeInsets.only(
            right: LayoutConstants.kModalHorizontalPadding),
        onTap: () async {
          await showSearch<String>(
            context: context,
            delegate: CustomDelegate(),
          );
        },
        icon: Icon(Icons.search, color: Theme.of(context).primaryColorLight),
      );

  static Widget createEvent(context) => MyIconButton(
        margin: const EdgeInsets.only(
            right: LayoutConstants.kModalHorizontalPadding),
        onTap: () async {
          // the result from pop is the poll id
          final pollId = await Navigator.of(context, rootNavigator: true).push(
            ScreenTransition(
              builder: (context) => const PollCreateScreen(),
            ),
          );
          if (pollId != null) {
            // ignore: use_build_context_synchronously
            showSnackBar(context, "Successfully created event!");
          }
        },
        icon:
            Icon(Icons.add_circle, color: Theme.of(context).primaryColorLight),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      /*
      leading: Container(
        margin: EdgeInsets.all(5),
        child: Image.asset('images/logo.png'),
      ),
      */
      shape: shape ??
          Border(
            bottom: BorderSide(
              width: 1,
              color: Theme.of(context).dividerColor,
            ),
          ),
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
  Widget buildSuggestions(BuildContext context) {
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
                return const LoadingLogo();
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
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text("No results found"));
              }
              usersData = snapshot.data!;
              return ResponsiveWrapper(
                child: Scrollbar(
                  child: ListView.builder(
                    controller: ScrollController(),
                    itemCount: usersData.length + 1,
                    itemBuilder: (_, i) {
                      if (i == usersData.length) {
                        return Container(
                            height: LayoutConstants.kPaddingFromCreate);
                      }
                      var user = usersData[i];
                      return UserTileFromData(userData: user);
                    },
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }
}
