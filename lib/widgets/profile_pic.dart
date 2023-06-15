import 'package:dima_app/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  final UserModel userData;
  final bool loading;
  final double radius;
  const ProfilePic({
    super.key,
    required this.userData,
    required this.loading,
    required this.radius,
  });

  Widget capitalNameSurnameAvatar(context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "${userData.name[0].toUpperCase()}${userData.surname[0].toUpperCase()}",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).primaryColor,
      child: userData.profilePic != "default"
          ? (loading
              ? capitalNameSurnameAvatar(context)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Image.network(
                    userData.profilePic,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress != null) {
                        return capitalNameSurnameAvatar(context);
                      } else {
                        return child;
                      }
                      /*
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                      */
                    },
                  ),
                ))
          : capitalNameSurnameAvatar(context),
    );
  }
}
