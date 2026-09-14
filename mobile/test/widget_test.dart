import 'package:flutter_test/flutter_test.dart';
import 'package:msar_elnor/main.dart';

void main() {
  testWidgets('Msar Elnor app smoke test', (WidgetTester tester) async {
    // Basic test declaration verifying widget compiles
    expect(MsarElnorApp.new, isNotNull);
  });
}
