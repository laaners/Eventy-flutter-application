import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';

import 'logo.dart';

class LoadingOverlay {
  static OverlayEntry? overlay;

  static void show(BuildContext context) {
    if (overlay != null) return;
    overlay = OverlayEntry(builder: (BuildContext context) {
      return const FullScreenLoader();
    });
    Overlay.of(context).insert(overlay!);
    Future.delayed(const Duration(seconds: 5)).then((value) {
      // if(overlay == null) // operation successful
      if (overlay != null) {
        // operation still waiting, push to error
        hide(context);
        Future.microtask(() {
          Navigator.push(
            context,
            ScreenTransition(
              builder: (context) => const ErrorScreen(
                errorMsg: "",
              ),
            ),
          );
        });
      }
    });
  }

  static void hide(BuildContext context) {
    if (overlay == null) return;
    overlay?.remove();
    overlay = null;
  }

  static Future<T> during<T>(BuildContext context, Future<T> future) {
    show(context);
    return future.whenComplete(() => hide(context));
  }

  static void remove(BuildContext context) {}
}

class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.outline),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          child: SizedBox(
            height: 170,
            width: 100,
            child: ListView(
              children: [
                const EventyLogo(extWidth: 80),
                Container(height: 20),
                const LinearProgressIndicator(),
              ],
            ), // CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
