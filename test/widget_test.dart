import 'package:flutter_test/flutter_test.dart';
import 'package:igotuu/main.dart';

void main() {
  testWidgets('IgotuuApp launches and mounts without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const IgotuuApp());
    // Verifies app mounts cleanly
    expect(find.byType(IgotuuApp), findsOneWidget);
  });
}
