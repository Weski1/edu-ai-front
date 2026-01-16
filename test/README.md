# Testy GUI/Widget dla Praca Inżynierska

## Struktura testów

### Testy widgetów (`test/widgets/`)
Szybkie testy jednostkowe interfejsu użytkownika:

1. **welcome_screen_test.dart** - Ekran powitalny
2. **login_screen_test.dart** - Formularz logowania
3. **register_screen_test.dart** - Formularz rejestracji
4. **main_screen_test.dart** - Główny ekran z nawigacją
5. **user_profile_screen_test.dart** - Profil użytkownika
6. **quiz_list_screen_test.dart** - Lista quizów
7. **main_app_test.dart** - Główna aplikacja
8. **common_widgets_test.dart** - Wspólne komponenty UI

### Testy integracyjne (`integration_test/`)
Testy pełnego flow aplikacji:

1. **login_flow_test.dart** - Pełny proces logowania

## Uruchamianie testów

### Testy widgetów (szybkie):
```bash
# Wszystkie testy widgetów
flutter test

# Konkretny plik
flutter test test/widgets/login_screen_test.dart

# Z pokryciem kodu
flutter test --coverage
```

### Testy integracyjne (wolniejsze, wymagają połączenia z backendem):
```bash
# Wszystkie testy integracyjne
flutter test integration_test

# Konkretny plik
flutter test integration_test/login_flow_test.dart

# Na fizycznym urządzeniu/emulatorze
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/login_flow_test.dart
```

## Dane testowe

**Email testowy:** pjkot2003@gmail.com  
**Hasło:** stringst

## Co testujemy

### Testy widgetów sprawdzają:
- ✅ Renderowanie elementów UI
- ✅ Walidację formularzy
- ✅ Interakcje użytkownika (kliknięcia, wprowadzanie tekstu)
- ✅ Wyświetlanie komunikatów błędów
- ✅ Obecność przycisków i ikon
- ✅ Strukturę komponentów

### Testy integracyjne sprawdzają:
- ✅ Pełny flow logowania
- ✅ Nawigację między ekranami
- ✅ Komunikację z API
- ✅ Walidację danych z serwera

## Raport pokrycia

Po uruchomieniu `flutter test --coverage` wygenerowany zostanie raport:
```bash
# Wygeneruj raport HTML (wymaga lcov)
genhtml coverage/lcov.info -o coverage/html

# Otwórz raport
start coverage/html/index.html
```

## Najlepsze praktyki

1. **Izolacja testów** - każdy test jest niezależny
2. **Czytelne nazwy** - opisują co testują
3. **Szybkie testy widgetów** - uruchamiaj często podczas rozwoju
4. **Wolniejsze testy integracyjne** - uruchamiaj przed commitami
5. **Mock'owanie** - dla testów widgetów nie używamy prawdziwego API
