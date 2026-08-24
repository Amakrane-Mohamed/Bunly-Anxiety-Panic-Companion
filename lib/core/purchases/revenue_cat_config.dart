/// RevenueCat keys and product ids for tonight’s dashboard setup.
///
/// In RevenueCat:
/// 1. Create the project, add iOS app `com.bunlyapp.bunly`.
/// 2. Paste the public Apple API key below (`appl_…`).
/// 3. App Store products: `bunly_annual` and `bunly_monthly`.
/// 4. Entitlement `Bunly Pro` attached to both products.
/// 5. Offering `default` with Annual + Monthly packages.
///
/// Or pass `--dart-define=REVENUECAT_APPLE_API_KEY=appl_…` at build time.
abstract final class RevenueCatConfig {
  static const appleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_API_KEY',
    defaultValue: 'appl_OpKzcPxotOSXNjkesjzfKkvPyMk',
  );

  static const entitlementId = String.fromEnvironment(
    'REVENUECAT_ENTITLEMENT',
    defaultValue: 'bunly_pro',
  );

  static const offeringId = 'default';
  static const annualProductId = 'bunly_annual';
  static const monthlyProductId = 'bunly_monthly';

  static bool get hasApiKey {
    final key = appleApiKey.trim();
    return key.startsWith('appl_') && !key.contains('YOUR_');
  }
}
