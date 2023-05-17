import 'package:dima_app/widgets/logo.dart';
import 'package:flutter/material.dart';

class LoadingLogo extends StatelessWidget {
  const LoadingLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        child: SizedBox(
          height: 100,
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
    );
  }
}
