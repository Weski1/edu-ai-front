import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:praca_inzynierska_front/screens/user_profile_screen.dart';
import 'package:praca_inzynierska_front/providers/theme_provider.dart';

void main() {
  Widget createTestWidget() {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MaterialApp(
        home: UserProfileScreen(),
      ),
    );
  }

  testWidgets('UserProfileScreen wyświetla loading na starcie', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    // Powinien pokazywać loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('UserProfileScreen tworzy się poprawnie', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    // Widget powinien się zbudować
    expect(find.byType(UserProfileScreen), findsOneWidget);
  });

  testWidgets('UserProfileScreen ma podstawową strukturę', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    // Sprawdź podstawowe elementy
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(UserProfileScreen), findsOneWidget);
  });
}
