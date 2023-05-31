import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/screens/groups/components/create_group.dart';
import 'package:dima_app/screens/groups/components/groups_list.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';

import 'package:dima_app/widgets/my_app_bar.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: MyAppBar(
        title: "Groups",
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: InkWell(
                      onTap: () {
                        MyModal.show(
                          context: context,
                          child: const CreateGroup(),
                          heightFactor: 0.85,
                          doneCancelMode: true,
                          onDone: () {},
                          title: "New Group",
                          shrinkWrap: false,
                        );
                      },
                      child: const Icon(Icons.group_add, size: 60),
                    ),
                  ),
                  Text(
                    "Create a new group",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            const GroupsList(),
            Container(height: LayoutConstants.kPaddingFromCreate),
          ],
        ),
      ),
    );
  }
}
