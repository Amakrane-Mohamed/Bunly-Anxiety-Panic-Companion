import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/legal/legal_links.dart';
import '../../core/purchases/purchases_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_card.dart';
import '../../shared/widgets/bunly_scaffold.dart';
import '../legal/legal_screen.dart';
import 'delete_my_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var _busy = false;
  String? _restoreMessage;

  Future<void> _restoreSubscription() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _restoreMessage = null;
    });

    final success = await PurchasesService.instance.restore();
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (success) {
        _restoreMessage = 'Subscription restored!';
      } else {
        _restoreMessage = PurchasesService.instance.lastError ??
            'Couldn\'t restore subscription. Try again.';
      }
    });

    // Clear message after 4 seconds
    if (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() => _restoreMessage = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BunlyScaffold(
      title: 'Settings',
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
            'Subscription',
            style: AppTypography.ui(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          _SettingsRow(
            title: _busy ? 'Restoring…' : 'Restore Purchases',
            body: 'Restore a previous purchase or subscription.',
            onTap: _busy ? null : _restoreSubscription,
          ),
          if (_restoreMessage != null) ...[
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  _restoreMessage!,
                  style: AppTypography.ui(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand,
                  ),
                ),
              ),
            ),
          ],
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
          _SettingsRow(
            title: 'Privacy Policy',
            body: 'What we collect and why.',
            onTap: () => LegalScreen.openPrivacy(context),
          ),
          const SizedBox(height: 8),
          _SettingsRow(
            title: 'Terms of Use',
            body: 'How Bunly works, including subscriptions.',
            onTap: () => LegalScreen.openTerms(context),
          ),
          const SizedBox(height: 8),
          _SettingsRow(
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
          _SettingsRow(
            title: 'Delete my data',
            body: 'Remove companion memory on this device.',
            onTap: () => confirmAndDeleteMyData(context),
          ),
          const SizedBox(height: 22),
          Text(
            'About',
            style: AppTypography.ui(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.ink.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bunly',
                    style: AppTypography.ui(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Version 2.0.0',
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
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
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
