import 'package:flutter_test/flutter_test.dart';
import 'package:analyst_app/main.dart';

void main() {
  testWidgets('Analyst app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AnalystApp());
    expect(find.text('SecCall'), findsWidgets);
  });
}