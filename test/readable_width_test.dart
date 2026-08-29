import 'package:bunly/core/layout/app_layout.dart';
import 'package:bunly/features/insights/insights_screen.dart';
import 'package:bunly/features/journey/journey_screen.dart';
import 'package:bunly/features/today/today_screen.dart';
import 'package:bunly/features/you/you_screen.dart';
import 'package:bunly/shared/widgets/readable_width.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps a phone-width column on iPad', (tester) async {
    tester.view.physicalSize = const Size(2048, 2732);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const childKey = Key('column');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReadableWidth(
            child: SizedBox(key: childKey, width: double.infinity, height: 48),
          ),
        ),
      ),
    );

    final box = tester.renderObject<RenderBox>(find.byKey(childKey));
    expect(box.size.width, AppLayout.contentMax);
  });

  testWidgets('does not shrink an iPhone layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const childKey = Key('column');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReadableWidth(
            child: SizedBox(key: childKey, width: double.infinity, height: 48),
          ),
        ),
      ),
    );

    final box = tester.renderObject<RenderBox>(find.byKey(childKey));
    expect(box.size.width, 390);
  });

  testWidgets('main tabs do not overflow on iPad', (tester) async {
    tester.view.physicalSize = const Size(1668, 2388);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const tabs = [
      TodayScreen(),
      InsightsScreen(),
      JourneyScreen(),
      YouScreen(),
    ];
    for (final tab in tabs) {
      await tester.pumpWidget(MaterialApp(home: tab));
      await tester.pump();
    }
  });
}
