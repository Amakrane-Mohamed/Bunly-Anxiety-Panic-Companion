import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/access/access.dart';
import 'core/purchases/purchases_service.dart';
import 'core/store/app_store.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;
  debugPaintBaselinesEnabled = false;
  debugPaintLayerBordersEnabled = false;
  await Firebase.initializeApp();
  try {
    await AuthService.initialize();
  } catch (error) {
    debugPrint('Launch auth failed: $error');
  }
  try {
    await AppStore.instance.hydrate();
  } catch (error) {
    debugPrint('Launch hydrate failed: $error');
  }
  try {
    await PurchasesService.instance.configure();
  } catch (error) {
    debugPrint('Launch purchases failed: $error');
  }
  try {
    await Access.instance.hydrate();
  } catch (error) {
    debugPrint('Launch access failed: $error');
  }
  if (!Access.instance.onboarded) {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      debugPrint('Launch sign-out failed: $error');
    }
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.splash,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const BunlyApp());
}
