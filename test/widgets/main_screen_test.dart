import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/main_screen.dart';

void main() {
  testWidgets('MainScreen pokazuje loading podczas inicjalizacji', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(token: 'test-token'),
      ),
    );

    // Przed załadowaniem powinien pokazywać loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('MainScreen ma podstawową strukturę Scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(token: 'test-token'),
      ),
    );

    await tester.pump();

    // Sprawdź czy jest podstawowa struktura
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('MainScreen przyjmuje token jako parametr', (WidgetTester tester) async {
    const testToken = 'my-test-token-123';
    
    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(token: testToken),
      ),
    );

    await tester.pump();

    // Widget powinien się zbudować bez błędów
    expect(find.byType(MainScreen), findsOneWidget);
  });

  testWidgets('MainScreen wyświetla loading indicator na początku', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(token: 'test-token'),
      ),
    );

    // Sprawdź loading screen
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
