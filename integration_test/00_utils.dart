import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future tapOnWidget({
  required String key,
  required WidgetTester tester,
}) async {
  final widget = find.byKey(Key(key));
  expect(widget, findsOneWidget);
  await tester.tap(widget);
  await tester.pumpAndSettle();
}

Future fillTextWidget({
  required String key,
  required String text,
  required WidgetTester tester,
}) async {
  final widget = find.byKey(Key(key));
  expect(widget, findsOneWidget);
  await tester.enterText(widget, text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}
