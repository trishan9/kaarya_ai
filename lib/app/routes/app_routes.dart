import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Push a new route onto the stack
  static void push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Push with no transition - use for pages with WebView to avoid fade on navigate.
  static Future<T?> pushNoTransition<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder<T>(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  /// Replace current route with a new one
  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Push a new route and remove all previous routes
  static void pushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  /// Pop the current route
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  /// Pop to first route (root)
  static void popToFirst(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  static void popToFirstGlobal() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  static Future<T?> pushAndRemoveUntilGlobal<T>(Widget page) {
    return navigatorKey.currentState!.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }
}
