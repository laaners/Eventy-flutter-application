import 'package:flutter/material.dart';
import '../../widgets/my_app_bar.dart';
import 'profile_info.dart';

class ViewProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ViewProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("${userData['username']}"),
      body: ProfileInfo(
        userData: userData,
      ),
    );
  }
}
