// This is a basic Flutter widget test for the Oscar Duty App.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oscar/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: DutyApp()));

    // Allow the app to initialize and pump multiple frames
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that the splash screen loads
    expect(find.text('Oscar Duty App'), findsOneWidget);
    expect(find.text('Professional Duty Management System'), findsOneWidget);
  });
}
