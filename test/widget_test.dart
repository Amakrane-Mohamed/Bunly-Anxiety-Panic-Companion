import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bunly/app.dart';
import 'package:bunly/core/constants/app_assets.dart';
import 'package:bunly/features/splash/splash_screen.dart';

void main() {
  testWidgets('launches on the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BunlyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    expect(find.image(const AssetImage(AppAssets.bunlyIcon)), findsWidgets);
    expect(find.text('Bunly'), findsNothing);
  });
}
