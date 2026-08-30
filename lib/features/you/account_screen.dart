import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/legal/legal_links.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_card.dart';
import '../../shared/widgets/bunly_scaffold.dart';
import '../legal/legal_screen.dart';
import 'delete_my_data.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BunlyScaffold(
      title: 'Account',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'Bunly is a companion, not medical care or therapy.',
            style: AppTypography.ui(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Legal',
            style: AppTypography.ui(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          _AccountRow(
            title: 'Privacy Policy',
            body: 'What we collect and why.',
            onTap: () => LegalScreen.openPrivacy(context),
          ),
          const SizedBox(height: 8),
          _AccountRow(
            title: 'Terms of Use',
            body: 'How Bunly works, including subscriptions.',
            onTap: () => LegalScreen.openTerms(context),
          ),
          const SizedBox(height: 8),
          _AccountRow(
            title: 'Email us',
            body: LegalLinks.contactEmail,
            onTap: LegalLinks.openEmail,
          ),
          const SizedBox(height: 22),
          Text(
            'Your data',
            style: AppTypography.ui(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          _AccountRow(
            title: 'Delete my data',
            body: 'Remove companion memory on this device.',
            onTap: () => confirmAndDeleteMyData(context),
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.title,
    required this.body,
    this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.ink;
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              AppAudio.tap();
              onTap!();
            },
      child: BunlyCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.ui(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: AppTypography.ui(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: ink.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
