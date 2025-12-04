import 'package:flutter/material.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: Color.fromRGBO(4, 113, 182, 1.0));
  }
}
