import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bonly_mascot.dart';
import '../../shared/widgets/bunly_scaffold.dart';

class TalkScreen extends StatefulWidget {
  const TalkScreen({super.key});

  @override
  State<TalkScreen> createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    AppStore.instance.addBondlyNote(_input.text);
    _input.clear();
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return BunlyScaffold(
          title: 'Know the pattern',
          bottom: _Composer(controller: _input, onSend: _send),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              children: [
                const BonlyMascot(mood: BonlyMood.calm, height: 96),
                const SizedBox(height: 10),
                Text(
                  'Tell me what’s here. I’ll learn your usual days.',
                  textAlign: TextAlign.center,
                  style: AppTypography.ui(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: store.bondlyNotes.isEmpty
                      ? Center(
                          child: Text(
                            'Nothing yet. Say anything.',
                            style: AppTypography.ui(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: store.bondlyNotes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.optionFill,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    10,
                                    14,
                                    10,
                                  ),
                                  child: Text(
                                    store.bondlyNotes[index],
                                    style: AppTypography.ui(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            style: AppTypography.ui(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              hintText: 'A message for Bondly',
              hintStyle: AppTypography.ui(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.inkMuted,
              ),
              filled: true,
              fillColor: AppColors.optionFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSend,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                CupertinoIcons.arrow_up,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
