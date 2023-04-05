import 'package:flutter/material.dart';

class EventyLogo extends StatelessWidget {
  final double extWidth;
  late double intWidth = extWidth * .86;
  late double extRadius = .16 * extWidth;
  late double intRadius = .11 * intWidth;
  late double antennaHeight = 0.17 * extWidth;

  EventyLogo({super.key, this.extWidth = 370});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 0.9 * extWidth,
          width: extWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(extRadius),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        Container(
          transform: Matrix4.identity()
            ..translate(0.0, (extWidth - intWidth) * .5, 0.0),
          height: 0.7 * intWidth,
          width: intWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.zero, bottom: Radius.circular(intRadius)),
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        Antenna(
          height: antennaHeight,
          isLeft: true,
        ),
        Antenna(
          height: antennaHeight,
          isLeft: false,
        ),
        Eye(
          width: extWidth / 4,
          isLeft: true,
        ),
        Eye(
          width: extWidth / 4,
          isLeft: false,
        ),
        Mouth(width: extWidth / 4)
      ],
    );
  }
}

class Antenna extends StatelessWidget {
  final double height;
  final bool isLeft;

  const Antenna({super.key, required this.height, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      transform: isLeft
          ? (Matrix4.identity()..translate(-1.67 * height, -2.67 * height, 0.0))
          : (Matrix4.identity()..translate(1.67 * height, -2.67 * height, 0.0)),
      height: height,
      width: height / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height),
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class Eye extends StatelessWidget {
  final double width;
  final double radiusFactor = .15;
  final bool isLeft;

  const Eye({super.key, required this.width, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      transform: isLeft
          ? (Matrix4.identity()..translate(-.95 * width, -.27 * width, .0))
          : (Matrix4.identity()..translate(.95 * width, -.27 * width, .0)),
      height: 0.85 * width,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusFactor * width),
        border: Border.all(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            width: width / 6),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}

class Mouth extends StatelessWidget {
  final double width;
  final double radiusFactor = .15;

  const Mouth({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      transform: Matrix4.identity()..translate(.95 * width, .8 * width, .0),
      height: 0.85 * width,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusFactor * width),
        border: Border.all(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            width: width / 6),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}
