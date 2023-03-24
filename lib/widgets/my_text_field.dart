import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  void _onFocusChange() {
    debugPrint("\t\t\tFocus: ${_focus.hasFocus.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Palette.greyColor),
      ),
      child: TextFormField(
        focusNode: _focus,
        autofocus: false,
        controller: widget.controller,
        keyboardType: TextInputType.text,
        minLines: widget.maxLines,
        maxLines: null, // widget.maxLines,
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
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Container(
                    alignment: Alignment.topRight,
                    child: Text(
                      "$currentLength/$maxLength",
                      style: const TextStyle(
                        color: Palette.greyColor,
                      ),
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
          hintMaxLines: 2,
        ),
        maxLength: widget.maxLength,
      ),
    );
  }
}
