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
      backgroundColor: Colors.orange,
      //foregroundColor: Colors.orange,
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
              decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(50)),
              width: 100,
              height: 100,
              child: Center(
                child: Text(
                  "${userData?.name[0]}${userData?.surname[0]}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius / 2,
                  ),
                ),
              ),
            ),
    );
  }
}
