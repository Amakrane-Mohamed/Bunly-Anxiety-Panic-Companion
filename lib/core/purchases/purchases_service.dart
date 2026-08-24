import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../access/access.dart';
import 'revenue_cat_config.dart';

class PurchasesService {
  PurchasesService._();
  static final PurchasesService instance = PurchasesService._();

  var configured = false;
  var isPro = false;
  Offerings? offerings;
  String? lastError;

  bool get ready => configured && RevenueCatConfig.hasApiKey;

  Package? get annualPackage {
    final offering = _offering;
    if (offering == null) return null;
    return offering.annual ??
        _packageForProduct(RevenueCatConfig.annualProductId);
  }

  Package? get monthlyPackage {
    final offering = _offering;
    if (offering == null) return null;
    return offering.monthly ??
        _packageForProduct(RevenueCatConfig.monthlyProductId);
  }

  Offering? get _offering {
    final all = offerings;
    if (all == null) return null;
    return all.getOffering(RevenueCatConfig.offeringId) ?? all.current;
  }

  Package? _packageForProduct(String productId) {
    final offering = _offering;
    if (offering == null) return null;
    for (final package in offering.availablePackages) {
      if (package.storeProduct.identifier == productId) return package;
    }
    return null;
  }

  Future<void> configure() async {
    if (!Platform.isIOS && !Platform.isMacOS) return;
    if (!RevenueCatConfig.hasApiKey) {
      debugPrint(
        'RevenueCat: paste your appl_ key in RevenueCatConfig.appleApiKey.',
      );
      return;
    }
    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      final config = PurchasesConfiguration(RevenueCatConfig.appleApiKey)
        ..appUserID = FirebaseAuth.instance.currentUser?.uid;
      await Purchases.configure(config);
      configured = true;
      Purchases.addCustomerInfoUpdateListener((info) {
        _apply(info);
      });
      await refresh();
      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (!configured) return;
        try {
          if (user != null) {
            await Purchases.logIn(user.uid);
          } else {
            await Purchases.logOut();
          }
          await refresh();
        } catch (error) {
          debugPrint('RevenueCat identity: $error');
        }
      });
    } catch (error) {
      lastError = '$error';
      debugPrint('RevenueCat configure failed: $error');
    }
  }

  Future<void> refresh() async {
    if (!configured) return;
    try {
      offerings = await Purchases.getOfferings();
      final info = await Purchases.getCustomerInfo();
      _apply(info);
    } catch (error) {
      lastError = '$error';
      debugPrint('RevenueCat refresh failed: $error');
    }
  }

  void _apply(CustomerInfo info) {
    isPro =
        info.entitlements.all[RevenueCatConfig.entitlementId]?.isActive ??
        false;
    Access.instance.syncPremium(isPro);
  }

  Future<bool> purchase(Package package) async {
    lastError = null;
    try {
      final info = await Purchases.purchasePackage(package);
      _apply(info);
      return isPro;
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code == PurchasesErrorCode.purchaseCancelledError) return false;
      lastError = error.message ?? error.code;
      return false;
    } catch (error) {
      lastError = '$error';
      return false;
    }
  }

  Future<bool> restore() async {
    lastError = null;
    try {
      final info = await Purchases.restorePurchases();
      _apply(info);
      return isPro;
    } on PlatformException catch (error) {
      lastError = error.message ?? error.code;
      return false;
    } catch (error) {
      lastError = '$error';
      return false;
    }
  }
}
