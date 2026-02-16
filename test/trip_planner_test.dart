import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelsphere/screens/user/planner/trip_planner_screen.dart';

void main() {
  testWidgets('TripPlannerScreen renders correctly', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: TripPlannerScreen(),
    ));

    // Verify title
    expect(find.text('Plan Your Trip'), findsOneWidget);

    // Verify inputs exist
    expect(find.text('Where do you want to go?'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('Budget per Person'), findsOneWidget);

    // Verify button
    expect(find.text('Generate Itinerary ✨'), findsOneWidget);
  });

  testWidgets('TripPlannerScreen updates state', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: TripPlannerScreen(),
    ));

    // Interact with travelers counter
    // Initial state is 2
    expect(find.text('2'), findsOneWidget);

    // Tap add button
    await tester.tap(find.icon(Icons.add));
    await tester.pump();

    // Should be 3
    expect(find.text('3'), findsOneWidget);
  });
}
