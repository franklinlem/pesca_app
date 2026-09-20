import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesca_app/core/widgets/catch_and_release_badge.dart';
import 'package:pesca_app/core/widgets/pro_badge.dart';

void main() {
  testWidgets('Renders CatchAndReleaseBadge correctly for released fish', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CatchAndReleaseBadge(isReleased: true, isLarge: true),
        ),
      ),
    );

    expect(find.text('Pescou & Soltou 🌿'), findsOneWidget);
  });

  testWidgets('Renders ProBadge correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProBadge(),
        ),
      ),
    );

    expect(find.text('PRO'), findsOneWidget);
  });
}
