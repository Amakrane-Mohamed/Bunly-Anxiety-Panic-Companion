import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app.dart';
import '../../core/access/access.dart';
import '../../core/audio/app_audio.dart';
import '../../core/legal/legal_links.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_card.dart';
import '../../shared/widgets/bunly_scaffold.dart';
import '../auth/auth_service.dart';
import '../legal/crisis_sheet.dart';
import '../legal/legal_screen.dart';
import '../welcome/welcome_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  var _busy = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  Future<void> _signOut() async {
    if (_busy) return;
    setState(() => _busy = true);
    await AuthService.signOut();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Signed out.')));
  }

  Future<void> _delete() async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.46),
      builder: (context) => const _DeleteDialog(),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    final outcome = await AuthService.deleteAccount();
    if (outcome == AuthOutcome.failed) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AuthService.lastMessage ?? 'Couldn’t delete the account.',
          ),
        ),
      );
      return;
    }
    await AppStore.instance.erase();
    await Access.instance.reset();
    if (!mounted) return;
    await NativeChrome.hideTabs();
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      AppMotion.fadeTo(const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final signedIn = user != null;

    return BunlyScaffold(
      title: 'Account',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'Bunly is a companion, not medical care, therapy, or emergency help.',
            style: AppTypography.ui(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'If you are in danger, call your local emergency number. In the US and Canada, call or text 988.',
            style: AppTypography.ui(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 16),
          _AccountRow(
            title: 'Crisis help',
            body: 'Call or text 988 in the US and Canada.',
            onTap: () => CrisisSheet.open(context),
          ),
          const SizedBox(height: 22),
          Text(
            'Your account',
            style: AppTypography.ui(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          if (signedIn) ...[
            Text(
              user.email ?? user.displayName ?? 'Signed in',
              style: AppTypography.ui(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            _AccountRow(
              title: _busy ? 'One moment…' : 'Sign out',
              body: 'Stay on this device. Your notes stay here.',
              onTap: _busy ? null : _signOut,
            ),
            const SizedBox(height: 8),
            _AccountRow(
              title: 'Delete account',
              body: 'Removes your Bunly account and data on this device.',
              destructive: true,
              onTap: _busy ? null : _delete,
            ),
          ] else
            Text(
              'You are not signed in.',
              style: AppTypography.ui(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.inkMuted,
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
    this.destructive = false,
  });

  final String title;
  final String body;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ink = destructive ? AppColors.sos : AppColors.ink;
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

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFDF8F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Delete your account?',
              style: AppTypography.display(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This removes your Bunly account and the companion data on this device. It does not cancel a subscription. Manage that in Settings.',
              style: AppTypography.ui(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(true),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.sos,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Delete account',
                    textAlign: TextAlign.center,
                    style: AppTypography.ui(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Keep it',
                  textAlign: TextAlign.center,
                  style: AppTypography.ui(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
