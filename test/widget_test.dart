// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prova_planner/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProvaPlannerApp());

    // Verify that the app starts with SplashScreen
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Pump frames to handle the timer
    await tester.pump(const Duration(seconds: 4));
    
    // Verify that the splash screen navigation completed
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
