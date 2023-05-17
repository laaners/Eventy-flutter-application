import 'package:dima_app/constants/layout_constants.dart';
import 'package:flutter/material.dart';

class LocationTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double? horizontalTitleGap;
  const LocationTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.horizontalTitleGap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        minLeadingWidth: 0,
        horizontalTitleGap: horizontalTitleGap ?? 8,
        leading: leading,
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).primaryColor,
                fontStyle: FontStyle.italic,
              ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
