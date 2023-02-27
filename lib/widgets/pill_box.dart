import 'package:dima_app/providers/theme_switch.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Provider.of<ThemeSwitch>(context, listen: false)
                .themeData
                .scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 6), // changes position of shadow
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
