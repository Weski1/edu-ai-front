import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/main.dart';
import 'package:provider/provider.dart';
import 'package:praca_inzynierska_front/providers/theme_provider.dart';

void main() {
  testWidgets('MainApp uruchamia się poprawnie', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    // Sprawdź czy aplikacja się załadowała
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('MainApp ma ThemeProvider', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    // Sprawdź czy jest Provider
    expect(find.byType(ChangeNotifierProvider<ThemeProvider>), findsOneWidget);
  });

  testWidgets('MainApp wyświetla WelcomeScreen na starcie', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    // Powinien pokazać WelcomeScreen
    expect(find.text('Witaj w EduAI'), findsOneWidget);
  });

  testWidgets('MainApp ma poprawną lokalizację PL', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    // Aplikacja powinna używać polskiej lokalizacji
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.supportedLocales, contains(const Locale('pl', 'PL')));
  });

  testWidgets('MainApp ma wyłączony debug banner', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.debugShowCheckedModeBanner, false);
  });
}
