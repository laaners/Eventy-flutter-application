import 'package:dima_app/constants/layout_constants.dart';
import 'package:flutter/material.dart';

class ContainerShadow extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final Color? color;
  const ContainerShadow({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin ??
          const EdgeInsets.symmetric(
            vertical: LayoutConstants.kVerticalPadding,
            horizontal: LayoutConstants.kHorizontalPadding,
          ),
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color ?? Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1.5),
          ),
        ],
        /*
        border: Border.all(
          color: Theme.of(context).focusColor,
        ),
        */
      ),
      child: child,
    );
  }
}
