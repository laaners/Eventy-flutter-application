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
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
      horizontalTitleGap: 0,
      subtitle: TextFormField(
        autofocus: false,
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          suffixIcon: IconButton(
            iconSize: 25,
            onPressed: emptySearch,
            icon: Icon(
              controller.text.isEmpty ? Icons.search : Icons.cancel,
            ),
          ),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
