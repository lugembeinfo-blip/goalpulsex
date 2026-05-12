import 'package:flutter_test/flutter_test.dart';
import 'package:goalpulsex/main.dart';

void main() {
  testWidgets('GoalPulseX app loads', (WidgetTester tester) async {

    await tester.pumpWidget(const GoalPulseX());

    expect(find.text('GoalPulseX'), findsOneWidget);
  });
}