import 'package:flutter/material.dart';

class TextDividerWidget extends StatelessWidget {
  const TextDividerWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        Expanded(child: Divider()),
        Text(text),
        Expanded(child: Divider()),
      ],
    );
  }
}
