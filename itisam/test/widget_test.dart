import 'package:flutter_test/flutter_test.dart';

import 'package:itisam/main.dart';

void main() {
  testWidgets('App boots and shows splash', (WidgetTester tester) async {
    await tester.pumpWidget(const ItisamApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('الاعتصام'), findsOneWidget);
  });
}