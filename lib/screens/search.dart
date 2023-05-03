import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
      title: "Search",
      upRightActions: [MyAppBar.SearchAction(context)],
    ));
  }
}
