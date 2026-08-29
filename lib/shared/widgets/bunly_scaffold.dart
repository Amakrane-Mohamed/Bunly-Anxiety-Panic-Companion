import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/layout/app_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'readable_width.dart';

/// Full-screen page with a tappable back control below the island.
class BunlyScaffold extends StatelessWidget {
  const BunlyScaffold({
    super.key,
    required this.body,
    this.title,
    this.bottom,
    this.backgroundColor,
  });

  final Widget body;
  final String? title;
  final Widget? bottom;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.home,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: safe.top + 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const _BackButton(),
                if (title != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.ui(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: ReadableWidth(child: body)),
          if (bottom != null)
            ReadableWidth(
              alignment: Alignment.bottomCenter,
              maxWidth: AppLayout.sheetMax,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + safe.bottom),
                child: bottom,
              ),
            ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).maybePop();
        },
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.optionFill,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.chevron_back,
            size: 20,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
