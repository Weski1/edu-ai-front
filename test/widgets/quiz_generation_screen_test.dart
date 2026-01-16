import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/quiz_generation_screen.dart';

void main() {
  group('QuizGenerationScreen Widget Tests', () {
    testWidgets('TEST 1: Wyswietlanie ekranu generowania quizu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizGenerationScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(QuizGenerationScreen), findsOneWidget);
    });

    testWidgets('TEST 2: Wyswietlanie paska ladowania podczas ladowania nauczycieli', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizGenerationScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TEST 3: Struktura podstawowa ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizGenerationScreen(),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });
  });
}
