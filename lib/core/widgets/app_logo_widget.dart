import 'package:flutter/material.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key, this.logoSize = 110});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/kaarya_logo.png', width: logoSize);
  }
}
