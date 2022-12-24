import 'package:dima_app/providers/theme_switch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../themes/palette.dart';

class MyTextField extends StatefulWidget {
  final int maxLength;
  final int maxLines;
  final String hintText;
  final TextEditingController controller;
  const MyTextField({
    super.key,
    required this.maxLength,
    required this.maxLines,
    required this.hintText,
    required this.controller,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Palette.greyColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: TextInputType.text,
        maxLines: widget.maxLines,
        style: TextStyle(
          color: Provider.of<ThemeSwitch>(context).themeData.primaryColor,
        ),
        buildCounter: (
          context, {
          required currentLength,
          required isFocused,
          maxLength,
        }) {
          return isFocused
              ? Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "$currentLength/$maxLength",
                    style: const TextStyle(
                      color: Palette.greyColor,
                    ),
                  ),
                )
              : null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(15),
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Palette.greyColor,
          ),
        ),
        autofocus: false,
        maxLength: widget.maxLength,
      ),
    );
  }
}
