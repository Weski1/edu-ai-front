import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:praca_inzynierska_front/providers/theme_provider.dart';
import 'package:praca_inzynierska_front/config/theme_config.dart';

/// Helper do tworzenia widgetów z pełnym kontekstem aplikacji
/// Używaj tego gdy testujesz widgety wymagające Provider lub localization
Widget createTestableWidget(Widget child) {
  return ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.flutterThemeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pl', 'PL'),
            Locale('en', 'US'),
          ],
          home: child,
        );
      },
    ),
  );
}

/// Prostsza wersja bez Provider - dla prostych widgetów
Widget createSimpleTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('pl', 'PL'),
      Locale('en', 'US'),
    ],
    home: child,
  );
}
