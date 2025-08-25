import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final Widget leading;
  final List<Widget> trailing;

  const SearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.leading,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: leading,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: trailing,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
