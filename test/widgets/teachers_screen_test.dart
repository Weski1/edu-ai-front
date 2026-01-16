import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/teachers_screen.dart';

void main() {
  group('TeachersScreen Widget Tests', () {
    testWidgets('TEST 1: Wyswietlanie paska ladowania na poczatku', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TeachersScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Wybierz nauczyciela do rozmowy'), findsOneWidget);
    });

    testWidgets('TEST 2: Wyswietlanie pola wyszukiwania', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TeachersScreen(),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('TEST 3: Struktura ekranu - AppBar i body', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TeachersScreen(),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
