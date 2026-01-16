import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/quiz_taking_screen.dart';

void main() {
  group('QuizTakingScreen Widget Tests', () {
    testWidgets('TEST 1: Wyswietlanie wskaznika ladowania', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizTakingScreen(quizId: 1),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TEST 2: Struktura podstawowa ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizTakingScreen(quizId: 1),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(QuizTakingScreen), findsOneWidget);
    });

    testWidgets('TEST 3: Wyswietlanie AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizTakingScreen(quizId: 1),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
