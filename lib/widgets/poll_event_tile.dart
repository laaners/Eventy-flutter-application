import 'package:dima_app/models/location_icons.dart';
import 'package:flutter/material.dart';

class PollEventTile extends StatelessWidget {
  final String locationBanner;
  final String descTop;
  final String descMiddle;
  final String descBottom;
  final Widget? trailing;
  final VoidCallback onTap;
  const PollEventTile({
    super.key,
    required this.locationBanner,
    this.trailing,
    required this.descTop,
    required this.onTap,
    required this.descBottom,
    required this.descMiddle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        minLeadingWidth: 0,
        horizontalTitleGap: 8,
        leading: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).focusColor,
            // color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: LocationIcons.icons[locationBanner] != null
              ? FittedBox(child: Icon(LocationIcons.icons[locationBanner]))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    "https://images.ygoprodeck.com/images/cards_cropped/42502956.jpg",
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress != null) {
                        return const Icon(Icons.place);
                      } else {
                        return child;
                      }
                    },
                  ),
                ),
        ),
        trailing: trailing,
        title: Text(
          descTop,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).primaryColorLight,
                fontStyle: FontStyle.italic,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              descMiddle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              descBottom,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
