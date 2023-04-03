import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// A pill-shaped wrapper/box with shadow, child can be any widget
class PillBox extends StatelessWidget {
  final Widget child;
  const PillBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FittedBox(
        fit: BoxFit.fill,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 30, 0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
