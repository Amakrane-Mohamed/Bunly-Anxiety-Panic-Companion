import 'package:flutter/foundation.dart';

import '../purchases/purchases_service.dart';
import '../store/local_disk.dart';

/// Who can open the full companion: paid, or a tester with 7789.
class Access extends ChangeNotifier {
  Access._();
  static final Access instance = Access._();

  static const testerCode = '7789';
  static const _onboardedKey = 'bunly.onboarded';
  static const _testerKey = 'bunly.tester';

  var onboarded = false;
  var tester = false;
  var premium = false;

  bool get unlocked => tester || premium;

  Future<void> hydrate() async {
    final prefs = await LocalDisk.open();
    onboarded = prefs?.getBool(_onboardedKey) ?? false;
    tester = prefs?.getBool(_testerKey) ?? false;
    premium = PurchasesService.instance.isPro;
    notifyListeners();
  }

  Future<void> markOnboarded() async {
    if (onboarded) return;
    onboarded = true;
    final prefs = await LocalDisk.open();
    await prefs?.setBool(_onboardedKey, true);
    notifyListeners();
  }

  Future<void> enableTester() async {
    tester = true;
    final prefs = await LocalDisk.open();
    await prefs?.setBool(_testerKey, true);
    notifyListeners();
  }

  void syncPremium(bool value) {
    if (premium == value) return;
    premium = value;
    notifyListeners();
  }

  Future<void> reset() async {
    onboarded = false;
    tester = false;
    premium = false;
    final prefs = await LocalDisk.open();
    await prefs?.remove(_onboardedKey);
    await prefs?.remove(_testerKey);
    notifyListeners();
  }
}
