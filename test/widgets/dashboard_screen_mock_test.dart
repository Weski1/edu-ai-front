import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:praca_inzynierska_front/screens/dashboard_screen.dart';
import 'package:praca_inzynierska_front/services/quiz_api_service.dart';

// Generowanie mocka: flutter pub run build_runner build
@GenerateMocks([QuizApiService])

void main() {
  group('DashboardScreen Mock Tests', () {
    testWidgets('TEST 1: Wyswietlanie wskaznika ladowania', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('TEST 2: Struktura ekranu', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('TEST 3: Sprawdzenie podstawowych widgetow', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
