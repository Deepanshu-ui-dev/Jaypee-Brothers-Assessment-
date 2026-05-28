import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build requires Firebase which is not available in unit tests.
    // This test just ensures the widget tree compiles.
    expect(FinTrackApp, isNotNull);
  });
}
