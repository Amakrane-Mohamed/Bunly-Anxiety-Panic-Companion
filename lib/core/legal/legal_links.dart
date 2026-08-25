import 'package:url_launcher/url_launcher.dart';

abstract final class LegalLinks {
  static const privacyUrl = String.fromEnvironment(
    'BUNLY_PRIVACY_URL',
    defaultValue:
        'https://dorian-cymbal-364.notion.site/Bunly-Privacy-Policy-3c729a5e9c9e804faffccf7c7ca400d3',
  );

  static const termsUrl = String.fromEnvironment(
    'BUNLY_TERMS_URL',
    defaultValue:
        'https://dorian-cymbal-364.notion.site/Bunly-Terms-of-Use-3c729a5e9c9e804a83dcca2dfbb0786e',
  );

  static const contactEmail = String.fromEnvironment(
    'BUNLY_CONTACT_EMAIL',
    defaultValue: 'hello@bunly.app',
  );

  static Future<void> openEmail() async {
    try {
      await launchUrl(Uri.parse('mailto:$contactEmail'));
    } catch (_) {}
  }

  static Future<void> call988() async {
    try {
      await launchUrl(Uri.parse('tel:988'));
    } catch (_) {}
  }

  static Future<void> text988() async {
    try {
      await launchUrl(Uri.parse('sms:988'));
    } catch (_) {}
  }

  static Future<bool> openWeb(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
