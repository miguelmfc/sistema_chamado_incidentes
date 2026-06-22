import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/main.dart';

void main() {
  testWidgets('SecCall app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SecCallApp());
    expect(find.text('SecCall'), findsWidgets);
  });
}