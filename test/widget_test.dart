import 'package:flutter_test/flutter_test.dart';

import 'package:thirdreel/app.dart';

void main() {
  testWidgets('splash screen shows the wordmark', (WidgetTester tester) async {
    await tester.pumpWidget(const ThirdReelApp());

    expect(find.text('ThirdReel'), findsOneWidget);

    // Let the splash screen's hold timer and transition finish so no
    // timers are left pending when the test tears down.
    await tester.pumpAndSettle(const Duration(milliseconds: 2000));
  });
}
