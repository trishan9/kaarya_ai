import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/features/auth/presentation/widgets/profile_overview_card_widget.dart';

void main() {
  Widget createTestWidget({
    String userName = 'Test User',
    String userEmail = 'test@example.com',
    String userProfilePicture = '',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ProfileOverviewCard(
          userName: userName,
          userEmail: userEmail,
          userProfilePicture: userProfilePicture,
        ),
      ),
    );
  }

  group('ProfileOverviewCard', () {
    testWidgets('should show user details and profile section title', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Profile Overview'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Kathmandu, Nepal'), findsOneWidget);
      expect(find.text('Flutter Engineer | AI Resume Builder'), findsOneWidget);
    });

    testWidgets('should render fallback image when profile picture is empty', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(userProfilePicture: ''));

      expect(find.byIcon(Icons.person), findsNothing);
      expect(find.byType(ProfileOverviewCard), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
