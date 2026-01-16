import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:praca_inzynierska_front/screens/teachers_screen.dart';
import 'package:praca_inzynierska_front/services/teachers_api_service.dart';

// Generowanie mocka: flutter pub run build_runner build
@GenerateMocks([TeachersApiService])

void main() {
  group('TeachersScreen Mock Tests', () {

    testWidgets('TEST 1: Wyswietlanie podstawowej struktury ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TeachersScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Wybierz nauczyciela do rozmowy'), findsOneWidget);
    });

    testWidgets('TEST 2: Wyswietlanie pola wyszukiwania', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TeachersScreen(),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('TEST 3: Sprawdzenie struktury widgetow', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TeachersScreen(),
        ),
      );

      expect(find.byType(TeachersScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
