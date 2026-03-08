import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/features/auth/presentation/widgets/update_profile_form_card_widget.dart';

void main() {
  late GlobalKey<FormState> formKey;
  late TextEditingController nameController;
  late TextEditingController emailController;

  setUp(() {
    formKey = GlobalKey<FormState>();
    nameController = TextEditingController();
    emailController = TextEditingController();
  });

  tearDown(() {
    nameController.dispose();
    emailController.dispose();
  });

  Widget createTestWidget({bool isBasicProfile = true}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: UpdateProfileFormCard(
            formKey: formKey,
            fullNameController: nameController,
            emailAddressController: emailController,
            profileImageUrl: '',
            isBasicProfile: isBasicProfile,
          ),
        ),
      ),
    );
  }

  group('UpdateProfileFormCard', () {
    testWidgets('should render basic profile fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Profile Picture'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('should validate required name and email fields', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final isValid = formKey.currentState?.validate();
      await tester.pump();

      expect(isValid, isFalse);
      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Email address is required'), findsOneWidget);
    });

    testWidgets('should validate email format', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');

      final isValid = formKey.currentState?.validate();
      await tester.pump();

      expect(isValid, isFalse);
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });
  });
}
