import 'package:flutter/material.dart';

class HeadingWithSubheadingWidget extends StatelessWidget {
  const HeadingWithSubheadingWidget({
    super.key,
    required this.heading,
    required this.subheading,
  });

  final String heading;
  final String subheading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),

      child: Column(
        children: [
          Text(
            heading,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),

          Text(
            subheading,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
