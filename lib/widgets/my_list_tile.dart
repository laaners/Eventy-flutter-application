import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final Widget? leading;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double? horizontalTitleGap;
  final EdgeInsetsGeometry? contentPadding;
  final int? subtitleMaxLines;
  const MyListTile({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.horizontalTitleGap,
    this.contentPadding,
    this.subtitleMaxLines,
  });

  static Widget leadingIcon({
    required Widget icon,
    double? height,
  }) {
    return Container(
      height: height ?? double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      child: FittedBox(child: icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      child: ListTile(
        contentPadding: contentPadding ?? EdgeInsets.zero,
        minLeadingWidth: 0,
        horizontalTitleGap: horizontalTitleGap ?? 8,
        leading: leading,
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: subtitle != null
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                overflow: TextOverflow.ellipsis,
                maxLines: subtitleMaxLines ?? 1,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontStyle: FontStyle.italic,
                    ),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
