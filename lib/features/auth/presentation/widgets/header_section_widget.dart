import 'package:flutter/material.dart';
import 'package:kaarya/core/widgets/app_logo_widget.dart';

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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
