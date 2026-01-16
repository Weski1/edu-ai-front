import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/dashboard_screen.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    testWidgets('TEST 1: Wyswietlanie wskaznika ladowania', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TEST 2: Struktura ekranu podstawowego', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('TEST 3: Sprawdzenie typu widgetu Center przy ladowaniu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });
  });
}
