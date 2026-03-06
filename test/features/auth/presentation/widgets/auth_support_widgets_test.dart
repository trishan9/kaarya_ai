import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/features/auth/presentation/widgets/auth_page_shell_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/header_section_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/heading_with_subheading_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/login_text_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/signup_text_widget.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('AuthPageShell should render child content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthPageShell(
          child: const Text('Auth Content'),
        ),
      ),
    );

    expect(find.text('Auth Content'), findsOneWidget);
  });

  testWidgets('HeaderSection should show app branding', (tester) async {
    await tester.pumpWidget(createTestWidget(const HeaderSection()));

    expect(find.text('Kaarya'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('HeadingWithSubheadingWidget should show heading and subheading', (
    tester,
  ) async {
    await tester.pumpWidget(
      createTestWidget(
        const HeadingWithSubheadingWidget(
          heading: 'Welcome',
          subheading: 'Start your journey',
        ),
      ),
    );

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Start your journey'), findsOneWidget);
  });

  testWidgets('LoginText should render call to action', (tester) async {
    await tester.pumpWidget(createTestWidget(const LoginText()));

    expect(find.byType(GestureDetector), findsOneWidget);
    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets('SignupText should render call to action', (tester) async {
    await tester.pumpWidget(createTestWidget(const SignupText()));

    expect(find.byType(GestureDetector), findsOneWidget);
    expect(find.byType(RichText), findsOneWidget);
  });
}
