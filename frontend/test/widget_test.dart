import 'package:flutter_test/flutter_test.dart';
import 'package:electric_sync/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ElectricSyncApp());

    // Verify splash screen appears initially
    expect(find.text('ElectricSync'), findsOneWidget);

    // Let the animations and timer finish so the test doesn't fail with pending timers
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
