import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:electric_sync/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ElectricSyncApp());

    // Verify splash screen appears
    expect(find.text('ElectricSync'), findsOneWidget);
  });
}
