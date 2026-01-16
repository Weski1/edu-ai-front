import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/conversation_list_screen.dart';
import 'package:praca_inzynierska_front/models/teacher.dart';

void main() {
  group('ConversationListScreen Widget Tests', () {
    final testTeacher = Teacher(
      id: 1,
      name: 'Pan Kowalski',
      subject: 'Matematyka',
    );

    testWidgets('TEST 1: Struktura podstawowa ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ConversationListScreen(teacher: testTeacher),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(ConversationListScreen), findsOneWidget);
    });

    testWidgets('TEST 2: Wyswietlanie przycisku nowej konwersacji', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ConversationListScreen(teacher: testTeacher),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('TEST 3: Wyswietlanie AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ConversationListScreen(teacher: testTeacher),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
