import 'package:flutter/material.dart';
import 'package:kaarya/widgets/app_logo_widget.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        AppLogoWidget(logoSize: 32),

        Text(
          "Kaarya",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
