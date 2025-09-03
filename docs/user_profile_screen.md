# Ekran Profilu Użytkownika - Dokumentacja

## Przegląd funkcji

Ekran profilu użytkownika to nowa funkcjonalność dodana do aplikacji Flutter, która pozwala użytkownikom zarządzać swoimi danymi osobowymi oraz przeglądać statystyki aktywności.

## Funkcjonalności

### 1. Przeglądanie profilu
- **Wyświetlanie danych osobowych**: imię, nazwisko, email, rola
- **Zdjęcie profilowe**: avatar użytkownika z inicjałami jako fallback
- **Statystyki uczestnictwa**: szczegółowe informacje o aktywności użytkownika

### 2. Edycja danych osobowych
- **Aktualizacja imienia i nazwiska**
- **Walidacja formularza**: sprawdzanie wypełnienia pól
- **Informacje zwrotne**: komunikaty o sukcesie/błędzie

### 3. Zarządzanie zdjęciem profilowym
- **Upload zdjęcia**: wybór z galerii, kompresja do 800x800px
- **Usuwanie zdjęcia**: możliwość usunięcia aktualnego avatara
- **Podgląd**: okrągły avatar z możliwością zmiany

### 4. Statystyki użytkownika
- **Ogólne statystyki**: liczba prób quizów, ukończone quizy, średnia ocena
- **Ulubiony nauczyciel**: najczęściej używany nauczyciel z liczbą konwersacji
- **Ulubiony przedmiot**: najlepiej oceniany przedmiot ze średnią oceną

### 5. Wylogowywanie
- **Bezpieczne wylogowanie**: potwierdzenie w dialogu
- **Zarządzanie sesją**: automatyczne przekierowanie na ekran logowania

## Struktura plików

### Modele
- `lib/models/user_profile.dart` - modele danych profilu zgodne z API
  - `UserProfile` - pełny profil użytkownika
  - `UserProfileStats` - statystyki aktywności
  - `ProfileUpdateRequest` - żądanie aktualizacji danych

### Serwisy
- `lib/services/user_profile_api_service.dart` - komunikacja z backendem
  - `getUserProfile()` - pobieranie profilu
  - `updateUserProfile()` - aktualizacja danych
  - `uploadProfileImage()` - upload zdjęcia (multipart)
  - `deleteProfileImage()` - usuwanie zdjęcia
  - `logoutUser()` - wylogowanie

### Ekrany
- `lib/screens/user_profile_screen.dart` - główny ekran profilu
  - Responsywny design z kartami
  - Obsługa stanów ładowania i błędów
  - Integracja z image_picker dla zdjęć

## Design i UI

### Paleta kolorów
- **Kolory funkcjonalne**: 
  - Zielony (≥80%): bardzo dobry wynik
  - Pomarańczowy (60-79%): dobry wynik  
  - Czerwony (<60%): słaby wynik
- **Kolory akcentowe**: niebieski dla głównych elementów

### Komponenty
- **Karty (Cards)**: główne sekcje z zaokrąglonymi rogami
- **Avatar**: okrągły z inicjałami lub zdjęciem
- **Statystyki**: kolorowe karty z ikonami i wartościami
- **Formularze**: OutlineInputBorder z ikonami

### Layout
- **Scrollable**: zawartość przewijana pionowo
- **Responsywny**: dostosowanie do różnych rozmiarów ekranów
- **Spacer**: konsystentne odstępy między elementami

## Integracja z API

### Endpointy
```
GET /user/profile - pobieranie profilu
PUT /user/profile - aktualizacja danych
POST /user/profile/image - upload zdjęcia
DELETE /user/profile/image - usuwanie zdjęcia
POST /user/logout - wylogowanie
```

### Autoryzacja
- Bearer token w headerach
- Automatyczne wylogowanie przy błędach 401
- Obsługa wygasłych sesji

### Debugowanie
- Szczegółowe logi żądań i odpowiedzi
- Status codes i error handling
- Informacje o rozmiarach plików

## Nawigacja

Ekran profilu został dodany jako 4. tab w `MainScreen`:
- **Ikona**: `Icons.person`
- **Label**: "Profil"
- **Pozycja**: ostatnia w bottom navigation

## Zależności

### Dodane pakiety
- `image_picker: ^1.0.7` - wybór zdjęć z galerii/aparatu
- Wykorzystuje istniejące: `http`, `shared_preferences`

### Uprawnienia
Aplikacja może wymagać uprawnień do galerii na urządzeniach mobilnych.

## Obsługa błędów

### Scenariusze błędów
1. **Brak internetu**: komunikat o problemach z połączeniem
2. **Wygasła sesja**: automatyczne przekierowanie na login
3. **Błędy serwera**: wyświetlenie szczegółów błędu
4. **Duże pliki**: ostrzeżenie o limitach (5MB)

### User Experience
- Loadery podczas operacji
- Komunikaty sukcesu/błędu via SnackBar
- Dialogi potwierdzające dla operacji destrukcyjnych
- Retry mechanizmy dla błędów sieciowych

## Bezpieczeństwo

- **Walidacja po stronie klienta**: sprawdzanie pustych pól
- **Ograniczenia plików**: maksymalny rozmiar 5MB, tylko obrazy
- **Token management**: bezpieczne przechowywanie i usuwanie tokenów
- **HTTPS**: wszystkie requesty przez bezpieczne połączenie

Ten ekran zapewnia użytkownikom pełną kontrolę nad swoim profilem oraz dostęp do szczegółowych statystyk aktywności w aplikacji.
