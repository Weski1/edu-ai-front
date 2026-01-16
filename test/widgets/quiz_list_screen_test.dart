import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/quiz_list_screen.dart';

void main() {
  testWidgets('QuizListScreen wyświetla AppBar gdy showAppBar=true', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizListScreen(showAppBar: true),
      ),
    );

    // Sprawdź czy jest AppBar
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('QuizListScreen wyświetla loading na starcie', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizListScreen(),
      ),
    );

    // Powinien pokazywać loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('QuizListScreen ma strukturę Scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizListScreen(),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('QuizListScreen akceptuje parametr showAppBar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizListScreen(showAppBar: false),
      ),
    );

    await tester.pump();
    
    // Widget powinien się zbudować
    expect(find.byType(QuizListScreen), findsOneWidget);
  });

  testWidgets('QuizListScreen tworzy się bez błędów', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizListScreen(),
      ),
    );

    await tester.pump();

    // Podstawowa struktura powinna istnieć
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(QuizListScreen), findsOneWidget);
  });
}
