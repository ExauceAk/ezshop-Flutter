import 'package:flutter_test/flutter_test.dart';
import 'package:market/main.dart';

void main() {
  testWidgets('App should show login screen on start', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('EZ Shop'), findsOneWidget);
  });
}
