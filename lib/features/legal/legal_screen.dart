import 'package:flutter/material.dart';

import '../../core/legal/legal_copy.dart';
import '../../core/legal/legal_links.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_scaffold.dart';

enum LegalKind { privacy, terms }

class LegalScreen extends StatelessWidget {
  const LegalScreen.privacy({super.key}) : kind = LegalKind.privacy;
  const LegalScreen.terms({super.key}) : kind = LegalKind.terms;

  final LegalKind kind;

  static Future<void> openPrivacy(BuildContext context) {
    return _open(context, LegalLinks.privacyUrl, const LegalScreen.privacy());
  }

  static Future<void> openTerms(BuildContext context) {
    return _open(context, LegalLinks.termsUrl, const LegalScreen.terms());
  }

  static Future<void> _open(
    BuildContext context,
    String url,
    Widget page,
  ) async {
    if (await LegalLinks.openWeb(url)) return;
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(AppMotion.fadeTo(page));
  }

  @override
  Widget build(BuildContext context) {
    final privacy = kind == LegalKind.privacy;
    return BunlyScaffold(
      title: privacy ? 'Privacy Policy' : 'Terms of Use',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            privacy
                ? LegalCopy.privacyPolicy(LegalLinks.contactEmail)
                : LegalCopy.termsOfUse(LegalLinks.contactEmail),
            style: AppTypography.ui(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
