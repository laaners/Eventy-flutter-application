import 'package:flutter/material.dart';

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
  }

  @override
  void dispose() {
    super.dispose();
    _focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        focusNode: _focus,
        autofocus: false,
        controller: widget.controller,
        keyboardType: TextInputType.text,
        minLines: widget.maxLines,
        maxLines: null, // widget.maxLines,
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
                    ),
                  ),
                )
              : null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(15),
          hintText: widget.hintText,
          hintMaxLines: 2,
        ),
        maxLength: widget.maxLength,
      ),
    );
  }
}
