import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/quiz_attempt_screen.dart';
import 'package:praca_inzynierska_front/models/quiz.dart';

void main() {
  group('QuizAttemptScreen Widget Tests', () {
    final testQuiz = Quiz(
      id: 1,
      userId: 1,
      teacherId: 1,
      title: 'Test Quiz',
      subject: 'Math',
      difficultyLevel: DifficultyLevel.medium,
      totalQuestions: 5,
      createdAt: DateTime.now(),
      teacherName: 'Test Teacher',
      questions: [],
    );

    testWidgets('TEST 1: Struktura podstawowa ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuizAttemptScreen(quiz: testQuiz),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(QuizAttemptScreen), findsOneWidget);
      print('WYNIK: PASS');
    });

    testWidgets('TEST 2: Wyswietlanie wskaznika ladowania', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuizAttemptScreen(quiz: testQuiz),
        ),
      );

      // Ekran pokazuje wskaźnik ładowania podczas inicjalizacji
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      print('WYNIK: PASS');
    });

    testWidgets('TEST 3: Widget tworzy sie bez bledow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuizAttemptScreen(quiz: testQuiz),
        ),
      );

      await tester.pump();
      expect(find.byType(QuizAttemptScreen), findsOneWidget);
      print('WYNIK: PASS');
    });
  });
}


