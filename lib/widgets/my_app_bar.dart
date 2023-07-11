import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/services/poll_event_methods.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:flutter/material.dart';

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

  static Widget createEvent(context) => MyIconButton(
        margin: const EdgeInsets.only(
            right: LayoutConstants.kModalHorizontalPadding),
        onTap: () async {
          await PollEventUserMethods.createNewPoll(context: context);
        },
        icon:
            Icon(Icons.add_circle, color: Theme.of(context).primaryColorLight),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        overflow: TextOverflow.fade,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      actions: upRightActions,
      scrolledUnderElevation: 0,
    );
  }
}
