import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/screens/groups/components/create_group.dart';
import 'package:dima_app/screens/groups/components/groups_list.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/search_tile.dart';
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

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: MyAppBar(
        title: "Groups",
        upRightActions: [
          MyIconButton(
            margin: const EdgeInsets.only(
                right: LayoutConstants.kModalHorizontalPadding),
            icon: Icon(Icons.group_add,
                color: Theme.of(context).primaryColorLight),
            onTap: () async {
              await MyModal.show(
                context: context,
                child: const CreateGroup(),
                heightFactor: 0.85,
                doneCancelMode: true,
                onDone: () {},
                title: "New Group",
                shrinkWrap: false,
              );
            },
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: LayoutConstants.kHorizontalPadding,
                vertical: 10,
              ),
              child: SearchTile(
                controller: _controller,
                focusNode: _focus,
                hintText: "Search for group name",
                emptySearch: () {
                  if (_controller.text.isNotEmpty) {
                    setState(() {
                      _controller.text = "";
                    });
                  }
                },
                onChanged: (text) {
                  setState(() {});
                },
              ),
            ),
            GroupsList(searchController: _controller),
          ],
        ),
      ),
    );
  }
}
