import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/login/login.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class ProfilePicsStack extends StatefulWidget {
  final double radius;
  final double offset;
  final List<String> uids;
  final bool? rl;
  final bool? maintainState;
  const ProfilePicsStack({
    super.key,
    required this.radius,
    required this.offset,
    required this.uids,
    this.rl,
    this.maintainState,
  });

  @override
  State<ProfilePicsStack> createState() => _ProfilePicsStackState();
}

class _ProfilePicsStackState extends State<ProfilePicsStack> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.radius * 2,
      width: (widget.radius * 2 - widget.offset) * 3 + widget.offset,
      child: Stack(
        children: [
          ...widget.uids.mapIndexed((index, user) {
            return Positioned(
              left: widget.rl != null
                  ? null
                  : (widget.radius * 2 - widget.offset) * index,
              right: widget.rl != null
                  ? (widget.radius * 2 - widget.offset) * index
                  : null,
              child: ProfilePicFromUid(
                userUid: user,
                radius: widget.radius,
                maintainState: widget.maintainState,
              ),
            );
          }).toList(),
          if (widget.uids.isEmpty)
            StreamBuilder(
              stream: Provider.of<FirebaseUser>(context, listen: false)
                  .getCurrentUserStream(),
              builder: (
                BuildContext context,
                AsyncSnapshot<UserModel> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: widget.radius * 2,
                    width: widget.radius * 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const LogInScreen();
                }
                UserModel userData = snapshot.data!;
                return Positioned(
                  left: widget.rl != null ? null : 0,
                  right: widget.rl != null ? 0 : null,
                  child: ProfilePicFromData(
                    userData: userData,
                    radius: widget.radius,
                  ),
                );
              },
            ),
          for (var index = widget.uids.length; index < 2; index++)
            Positioned(
              left: widget.rl != null
                  ? null
                  : (widget.radius * 2 - widget.offset) * index,
              right: widget.rl != null
                  ? (widget.radius * 2 - widget.offset) * index
                  : null,
              child: Container(width: widget.radius * 2),
            )
        ],
      ),
    );
  }
}
