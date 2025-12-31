import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/app.dart';
import 'package:kaarya/core/services/hive/hive_service.dart';

void main() async {
  await HiveService().init();
  runApp(const ProviderScope(child: MyApp()));
}
