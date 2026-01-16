import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/widgets/profile_image_picker.dart';

void main() {
  group('ProfileImagePicker Widget Tests', () {
    testWidgets('TEST 1: Tworzenie widgetu bez zdjecia', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileImagePicker(
              currentImageUrl: null,
              onImageUpdated: (url) {},
            ),
          ),
        ),
      );

      expect(find.byType(ProfileImagePicker), findsOneWidget);
      print('WYNIK: PASS');
    });

    testWidgets('TEST 2: Wyswietlanie kontenera zdjecia', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileImagePicker(
              currentImageUrl: null,
              onImageUpdated: (url) {},
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsWidgets);
      expect(find.byType(Stack), findsWidgets);
      print('WYNIK: PASS');
    });

    testWidgets('TEST 3: Wyswietlanie ikony edycji', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileImagePicker(
              currentImageUrl: null,
              onImageUpdated: (url) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      print('WYNIK: PASS');
    });
  });
}

