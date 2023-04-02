import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const MyButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: onPressed,
        style: const ButtonStyle(
          padding:
              MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(20)),
          textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 18)),
        ),
        child: Text(text),
      ),
    );
  }
}
