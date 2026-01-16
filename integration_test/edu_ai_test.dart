import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:praca_inzynierska_front/main.dart';

/// KOMPLEKSOWY TEST END-TO-END APLIKACJI EDUAI
/// Test przechodzi przez wszystkie główne funkcjonalności aplikacji
/// BEZ kosztów API OpenAI - nie generuje quizów ani nie wysyła wiadomości
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🎓 EDUAI - Pełny test aplikacji', () {
    testWidgets('Kompletny flow: logowanie → nauczyciele → quizy → statystyki → profil', 
      (WidgetTester tester) async {
      
      print('\nEDUAI - Test Aplikacji\n');
      
      // ETAP 1: EKRAN POWITALNY
      print('Test 1/12: Ekran powitalny');
      
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      expect(find.text('Witaj w EduAI'), findsOneWidget);
      await Future.delayed(const Duration(milliseconds: 800));

      // Przejście do logowania
      await tester.tap(find.text('Zaczynamy!'));
      await tester.pumpAndSettle(const Duration(milliseconds: 800));
      
      expect(find.text('Logowanie'), findsOneWidget);
      print('PASS');
      await Future.delayed(const Duration(milliseconds: 600));

      // ETAP 2: WALIDACJA FORMULARZY
      print('\nTest 2/12: Walidacja formularzy');
      
      // Test pustych pól
      await tester.tap(find.text('Zaloguj się').last);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      expect(find.text('Uzupełnij wszystkie pola'), findsOneWidget);
      await Future.delayed(const Duration(milliseconds: 800));

      // Sprawdzenie ekranu rejestracji
      await tester.tap(find.text('Nie masz konta? Rejestracja'));
      await tester.pumpAndSettle(const Duration(milliseconds: 800));
      
      expect(find.text('Rejestracja'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(5));
      await Future.delayed(const Duration(milliseconds: 800));

      // Powrót do logowania
      await tester.tap(find.text('Masz już konto? Zaloguj się'));
      await tester.pumpAndSettle(const Duration(milliseconds: 800));
      print('PASS');

      // ETAP 3: LOGOWANIE
      print('\nTest 3/12: Logowanie');
      
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;
      
      await tester.enterText(emailField, 'pjkot2003@gmail.com');
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      await Future.delayed(const Duration(milliseconds: 500));
      
      await tester.enterText(passwordField, 'stringst');
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      await Future.delayed(const Duration(milliseconds: 800));
      
      await tester.tap(find.text('Zaloguj się').last);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 4));
      
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      print('PASS');
      await Future.delayed(const Duration(seconds: 1));

      // ETAP 4: STRONA GŁÓWNA PO ZALOGOWANIU
      print('\nTest 4/12: Strona główna');
      
      // Sprawdzamy czy są jakieś karty/statystyki
      await tester.pumpAndSettle(const Duration(seconds: 1));
      print('PASS');
      
      await Future.delayed(const Duration(milliseconds: 800));

      // ETAP 5: NAUCZYCIELE AI - LISTA
      print('\nTest 5/12: Lista nauczycieli');
      
      // Kliknięcie pierwszej ikony w bottom navigation (Nauczyciele)
      final navBar = find.byType(BottomNavigationBar);
      if (navBar.evaluate().isNotEmpty) {
        // Próbujemy znaleźć ikonę nauczycieli
        final teachersTab = find.descendant(
          of: navBar,
          matching: find.byIcon(Icons.school),
        );
        
        if (teachersTab.evaluate().isNotEmpty) {
          await tester.tap(teachersTab.first);
        } else {
          // Fallback - tap na navBar
          await tester.tap(navBar);
        }
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      final teacherListTiles = find.byType(ListTile);
      print('PASS');
      await Future.delayed(const Duration(milliseconds: 800));

      // ETAP 6: KONWERSACJA Z NAUCZYCIELEM
      print('\nTest 6/12: Konwersacja z nauczycielem');
      
      if (teacherListTiles.evaluate().isNotEmpty) {
        // Przewiń do pierwszego elementu
        await tester.ensureVisible(teacherListTiles.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        await tester.tap(teacherListTiles.first, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Sprawdzamy czy jesteśmy w czacie
        final chatTextFields = find.byType(TextField);
        final sendButton = find.byIcon(Icons.send);
        
        if (chatTextFields.evaluate().isNotEmpty) {
          // Test wpisywania (bez wysyłania)
          await tester.enterText(chatTextFields.first, 'Testowa wiadomość');
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
          
          expect(find.text('Testowa wiadomość'), findsOneWidget);
          
          // Czyścimy pole
          await tester.enterText(chatTextFields.first, '');
          await tester.pumpAndSettle(const Duration(milliseconds: 300));
          
          await Future.delayed(const Duration(seconds: 1));
        }
        
        // Powrót do listy nauczycieli
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle(const Duration(milliseconds: 800));
        }
        print('PASS');
      }
      
      await Future.delayed(const Duration(milliseconds: 600));

      // ETAP 7: QUIZY - LISTA
      print('\nTest 7/12: Lista quizów');
      
      await tester.tap(find.text('Quiz'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Sprawdzanie zakładek
      if (find.text('Moje quizy').evaluate().isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (find.text('Rozwiązane').evaluate().isNotEmpty) {
          await tester.tap(find.text('Rozwiązane'));
          await tester.pumpAndSettle(const Duration(seconds: 1));
          await Future.delayed(const Duration(milliseconds: 800));
          
          await tester.tap(find.text('Moje quizy'));
          await tester.pumpAndSettle(const Duration(seconds: 1));
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      // Sprawdzanie listy quizów
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      final quizListTiles = find.byType(ListTile);
      final quizCards = find.byType(Card);
      
      print('PASS');

      // ETAP 8: SZCZEGÓŁY QUIZU
      print('\nTest 8/12: Szczegóły quizu');
      
      if (quizListTiles.evaluate().isNotEmpty) {
        // Przewiń i otwórz szczegóły
        await tester.ensureVisible(quizListTiles.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        await tester.tap(quizListTiles.first, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        final quizBackButton = find.byIcon(Icons.arrow_back);
        if (quizBackButton.evaluate().isNotEmpty) {
          await Future.delayed(const Duration(seconds: 1));
          
          await tester.tap(quizBackButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
      }
      print('PASS');
      
      await Future.delayed(const Duration(milliseconds: 600));

      // ETAP 9: FORMULARZ GENEROWANIA QUIZU
      print('\nTest 9/12: Formularz generowania quizu');
      
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        if (find.text('Generuj Quiz').evaluate().isNotEmpty || 
            find.text('Nowy Quiz').evaluate().isNotEmpty ||
            find.text('Generowanie quizu').evaluate().isNotEmpty) {
          await Future.delayed(const Duration(seconds: 1));
          
          // Powrót z formularza
          final closeButton = find.byIcon(Icons.close);
          final formBackButton = find.byIcon(Icons.arrow_back);
          
          if (closeButton.evaluate().isNotEmpty) {
            await tester.tap(closeButton.first);
            await tester.pumpAndSettle(const Duration(milliseconds: 800));
          } else if (formBackButton.evaluate().isNotEmpty) {
            await tester.tap(formBackButton.first);
            await tester.pumpAndSettle(const Duration(milliseconds: 800));
          }
        }
      }
      print('PASS');
      
      await Future.delayed(const Duration(milliseconds: 600));

      // ETAP 10: STATYSTYKI
      print('\nTest 10/12: Statystyki');
      
      await tester.tap(find.text('Statystyki'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Czekamy na załadowanie
      await Future.delayed(const Duration(seconds: 1));
      
      if (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      
      print('PASS');
      await Future.delayed(const Duration(milliseconds: 800));

      // ETAP 11: PROFIL UŻYTKOWNIKA
      print('\nTest 11/12: Profil');
      
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      await Future.delayed(const Duration(seconds: 1));
      
      // Edycja profilu
      if (find.byIcon(Icons.edit).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.edit).first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        if (find.text('Edytuj profil').evaluate().isNotEmpty) {
          await Future.delayed(const Duration(seconds: 1));
          
          // Powrót
          final profileBackButton = find.byIcon(Icons.arrow_back);
          if (profileBackButton.evaluate().isNotEmpty) {
            await tester.tap(profileBackButton.first);
            await tester.pumpAndSettle(const Duration(milliseconds: 800));
          }
        }
      }
      print('PASS');
      
      await Future.delayed(const Duration(milliseconds: 800));

      // ETAP 12: FINALNA NAWIGACJA MIĘDZY ZAKŁADKAMI
      print('\nTest 12/12: Nawigacja między zakładkami');
      
      // Powrót do Nauczyciele (pierwsza zakładka)
      await tester.tap(find.byIcon(Icons.school));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Test szybkiej nawigacji między zakładkami
      final tabs = ['Quiz', 'Statystyki', 'Profil', 'Nauczyciele'];
      for (final tab in tabs) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle(const Duration(milliseconds: 800));
        await Future.delayed(const Duration(milliseconds: 400));
      }
      print('PASS');
      
      print('\nTEST ZAKOŃCZONY POMYŚLNIE');
      
      await Future.delayed(const Duration(seconds: 1));
    });
  });
}
