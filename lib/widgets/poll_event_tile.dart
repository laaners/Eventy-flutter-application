import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PollEventTile extends StatelessWidget {
  final String descTop;
  final String descMiddle;
  final String? descBottom;
  final Widget? trailing;
  final Color? bgColor;
  final VoidCallback onTap;
  final PollEventModel pollEvent;
  const PollEventTile({
    super.key,
    required this.onTap,
    required this.pollEvent,
    required this.descTop,
    required this.descMiddle,
    this.descBottom,
    this.trailing,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        /*
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
        */
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: bgColor ?? Theme.of(context).scaffoldBackgroundColor,
              width: 10,
            ),
          ),
        ),
        child: FutureBuilder(
          future: Provider.of<FirebaseUser>(context, listen: false)
              .getUserData(uid: pollEvent.organizerUid),
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                minLeadingWidth: 0,
                horizontalTitleGap: 15,
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                trailing: trailing,
                title: Text(
                  descTop,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).primaryColorLight,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      descMiddle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      descBottom ?? "Organized by ...",
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
                onTap: onTap,
              );
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
            UserModel userData = snapshot.data!;
            return ListTile(
              contentPadding: const EdgeInsets.all(0),
              minLeadingWidth: 0,
              horizontalTitleGap: 15,
              leading: ProfilePicFromData(userData: userData),
              trailing: trailing,
              title: Text(
                descTop,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).primaryColorLight,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    descMiddle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    descBottom ?? "Organized by ${userData.username}",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
              onTap: onTap,
            );
          },
        ),
      ),
    );
  }
}
