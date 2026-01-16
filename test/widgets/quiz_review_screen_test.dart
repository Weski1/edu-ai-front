import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/quiz_review_screen.dart';

void main() {
  group('QuizReviewScreen Widget Tests', () {
    testWidgets('TEST 1: Wyswietlanie tytulu ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizReviewScreen(
            quizId: 1,
            quizTitle: 'Test Quiz Review',
          ),
        ),
      );

      expect(find.text('Test Quiz Review'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('TEST 2: Wyswietlanie wskaznika ladowania', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizReviewScreen(
            quizId: 1,
            quizTitle: 'Test Quiz',
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TEST 3: Struktura podstawowa ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizReviewScreen(
            quizId: 1,
            quizTitle: 'Test Quiz',
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(QuizReviewScreen), findsOneWidget);
    });
  });
}
