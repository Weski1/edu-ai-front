import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/password_reset_request_screen.dart';

void main() {
  group('PasswordResetRequestScreen Widget Tests', () {
    testWidgets('TEST 1: Wyswietlanie tytulu ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PasswordResetRequestScreen(),
        ),
      );

      expect(find.text('Resetowanie hasła'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('TEST 2: Wyswietlanie pola email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PasswordResetRequestScreen(),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('TEST 3: Wyswietlanie przycisku wyslij', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PasswordResetRequestScreen(),
        ),
      );

      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('TEST 4: Struktura podstawowa ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PasswordResetRequestScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(PasswordResetRequestScreen), findsOneWidget);
    });
  });
}
