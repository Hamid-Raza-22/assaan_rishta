import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Test helper functions for common testing operations

/// Wraps a widget with MaterialApp and GetMaterialApp for testing
Widget makeTestableWidget({required Widget child}) {
  return GetMaterialApp(
    home: child,
  );
}

/// Creates a simple MaterialApp wrapper for widgets
Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

/// Pumps and settles with a specific duration
Future<void> pumpWithDuration(WidgetTester tester, [Duration? duration]) async {
  await tester.pump(duration ?? const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

/// Finds widget by type and taps it
Future<void> tapWidgetByType<T>(WidgetTester tester) async {
  final finder = find.byType(T);
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Finds widget by key and taps it
Future<void> tapWidgetByKey(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Finds text and taps it
Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Enters text into a TextField by key
Future<void> enterTextByKey(WidgetTester tester, Key key, String text) async {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Scrolls until a widget is visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder,
  Finder scrollable, {
  double scrollDelta = 100.0,
}) async {
  await tester.scrollUntilVisible(
    finder,
    scrollDelta,
    scrollable: scrollable,
  );
  await tester.pumpAndSettle();
}

/// Verifies that a widget exists
void verifyWidgetExists(Finder finder) {
  expect(finder, findsOneWidget);
}

/// Verifies that multiple widgets exist
void verifyWidgetsExist(Finder finder, int count) {
  expect(finder, findsNWidgets(count));
}

/// Verifies that a widget does not exist
void verifyWidgetDoesNotExist(Finder finder) {
  expect(finder, findsNothing);
}

/// Drag helper
Future<void> dragWidget(
  WidgetTester tester,
  Finder finder,
  Offset offset,
) async {
  await tester.drag(finder, offset);
  await tester.pumpAndSettle();
}
