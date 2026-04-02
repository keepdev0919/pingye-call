import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pingye_call/main.dart';

void main() {
  testWidgets('Settings screen renders pingye nav title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PingyeApp()),
    );
    expect(find.text('pingye'), findsOneWidget);
    expect(find.text('대기 시작'), findsOneWidget);
  });
}
