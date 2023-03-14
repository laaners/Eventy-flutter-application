import 'package:flutter/material.dart';

class LoadingOverlay {
  static OverlayEntry? overlay;

  static void show(BuildContext context) {
    if (overlay != null) return;
    overlay = OverlayEntry(builder: (BuildContext context) {
      return const FullScreenLoader();
    });
    Overlay.of(context).insert(overlay!);
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
      decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
