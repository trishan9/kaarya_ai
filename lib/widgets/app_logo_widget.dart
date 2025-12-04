import 'package:flutter/material.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key, this.logoSize});

  final logoSize;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/kaarya_logo.png', width: logoSize ?? 110);
  }
}
