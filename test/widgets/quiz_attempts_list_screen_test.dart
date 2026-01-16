import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/quiz_attempts_list_screen.dart';

void main() {
  group('QuizAttemptsListScreen Widget Tests', () {
    testWidgets('TEST 1: Wyswietlanie tytulu ekranu z AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizAttemptsListScreen(),
        ),
      );

      expect(find.text('Moje podejścia do quizów'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('TEST 2: Wyswietlanie wskaznika ladowania', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizAttemptsListScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TEST 3: Struktura podstawowa ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizAttemptsListScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(QuizAttemptsListScreen), findsOneWidget);
    });

    testWidgets('TEST 4: Ekran bez AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizAttemptsListScreen(showAppBar: false),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
