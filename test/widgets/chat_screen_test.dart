import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/chat_screen.dart';
import 'package:praca_inzynierska_front/models/teacher.dart';

void main() {
  group('ChatScreen Widget Tests', () {
    final testTeacher = Teacher(
      id: 1,
      name: 'Pan Kowalski',
      subject: 'Matematyka',
    );

    testWidgets('TEST 1: Wyswietlanie nazwy nauczyciela w AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(conversationId: 1, teacherName: testTeacher.name),
        ),
      );

      expect(find.text('Pan Kowalski'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('TEST 2: Wyswietlanie pola tekstowego do wprowadzania wiadomosci', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(conversationId: 1, teacherName: testTeacher.name),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('TEST 3: Wyswietlanie przycisku wyslij', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(conversationId: 1, teacherName: testTeacher.name),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('TEST 4: Struktura podstawowa ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(conversationId: 1, teacherName: testTeacher.name),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(ChatScreen), findsOneWidget);
    });
  });
}
