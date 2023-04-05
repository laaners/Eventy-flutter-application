import 'package:dima_app/server/tables/user_collection.dart';
import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  final UserCollection? userData;
  final bool loading;
  final double radius;
  const ProfilePic({
    super.key,
    required this.userData,
    required this.loading,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).primaryColor,
      child: userData?.profilePic != "default"
          ? (loading
              ? const Center(child: CircularProgressIndicator())
              : ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Image.network(
                    userData!.profilePic,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ))
          : Container(
              margin: const EdgeInsets.all(10),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${userData?.name[0].toUpperCase()}${userData?.surname[0].toUpperCase()}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
    );
  }
}
