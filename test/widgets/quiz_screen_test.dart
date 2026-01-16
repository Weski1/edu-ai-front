import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/quiz_screen.dart';

void main() {
  group('QuizScreen Widget Tests', () {
    testWidgets('TEST 1: Wyswietlanie zakladek', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizScreen(),
        ),
      );

      expect(find.text('Moje quizy'), findsOneWidget);
      expect(find.text('Rozwiązane'), findsOneWidget);
      print('WYNIK: PASS');
    });

    testWidgets('TEST 2: Wyswietlanie TabBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizScreen(),
        ),
      );

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
      print('WYNIK: PASS');
    });

    testWidgets('TEST 3: Wyswietlanie ikon zakladek', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizScreen(),
        ),
      );

      expect(find.byIcon(Icons.quiz), findsOneWidget);
      expect(find.byIcon(Icons.assignment_turned_in), findsOneWidget);
      print('WYNIK: PASS');
    });

    testWidgets('TEST 4: Struktura podstawowa ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(DefaultTabController), findsOneWidget);
      print('WYNIK: PASS');
    });
  });
}
