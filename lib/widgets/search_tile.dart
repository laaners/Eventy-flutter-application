import 'package:flutter/material.dart';

class SearchTile extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final VoidCallback emptySearch;
  final ValueChanged<String> onChanged;

  const SearchTile({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.emptySearch,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        suffixIcon: IconButton(
          iconSize: 20,
          onPressed: emptySearch,
          icon: Icon(
            controller.text.isEmpty ? Icons.search : Icons.cancel,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
