import 'package:dima_app/models/availability.dart';
import 'package:flutter/material.dart';

class AvailabilityLegend extends StatelessWidget {
  final int filterAvailability;
  final ValueChanged<int> changeFilterAvailability;
  const AvailabilityLegend({
    super.key,
    required this.filterAvailability,
    required this.changeFilterAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              -2,
              Availability.yes,
              Availability.iff,
              Availability.not,
              Availability.empty
            ].map((availability) {
              String legendText = "";
              switch (availability) {
                case Availability.yes:
                  legendText = "Attending";
                  break;
                case Availability.iff:
                  legendText = "If need be";
                  break;
                case Availability.not:
                  legendText = "Not attending";
                  break;
                case Availability.empty:
                  legendText = "Pending";
                  break;
                default:
                  legendText = "All";
                  break;
              }
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: availability == filterAvailability
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).focusColor,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                padding: EdgeInsets.only(
                    top: 3,
                    bottom: 3,
                    left: 8,
                    right: availability == -2 ? 8 : 3),
                child: InkWell(
                  onTap: () {
                    changeFilterAvailability(availability);
                  },
                  child: availability == -2
                      ? Text(
                          legendText,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: availability == filterAvailability
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                        )
                      : Row(
                          children: [
                            Text(
                              legendText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: availability == filterAvailability
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                  ),
                            ),
                            Container(width: 5),
                            Icon(
                              Availability.icons[availability],
                              color: availability == filterAvailability
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onBackground,
                            ),
                          ],
                        ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
