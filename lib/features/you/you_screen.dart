import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/profile/user_plan.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final plan = UserPlan.instance;
        final store = AppStore.instance;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '${store.handledMoments} handled · ${store.checkIns.length} check-ins',
                  style: AppTypography.ui(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoListSection.insetGrouped(
                backgroundColor: Colors.transparent,
                header: Text(
                  'Companion',
                  style: AppTypography.ui(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
                children: [
                  CupertinoListTile(
                    title: const Text('Notifications'),
                    subtitle: Text(plan.wantsCheckIns ? 'On' : 'Off'),
                    trailing: const CupertinoListTileChevron(),
                  ),
                  const CupertinoListTile(
                    title: Text('Panic preferences'),
                    subtitle: Text('Breathing first'),
                    trailing: CupertinoListTileChevron(),
                  ),
                  const CupertinoListTile(
                    title: Text('Trusted contact'),
                    subtitle: Text('Not set'),
                    trailing: CupertinoListTileChevron(),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                backgroundColor: Colors.transparent,
                header: Text(
                  'Privacy & data',
                  style: AppTypography.ui(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
                children: const [
                  CupertinoListTile(
                    title: Text('Health'),
                    subtitle: Text('Coming with Apple Health'),
                    trailing: CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    title: Text('Apple Watch'),
                    subtitle: Text('Coming later'),
                    trailing: CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    title: Text('Export data'),
                    trailing: CupertinoListTileChevron(),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                backgroundColor: Colors.transparent,
                header: Text(
                  'Bunly',
                  style: AppTypography.ui(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
                children: const [
                  CupertinoListTile(
                    title: Text('Bunly Plus'),
                    subtitle: Text('Patterns, reports, deeper Journey'),
                    trailing: CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    title: Text('About'),
                    subtitle: Text('Not a medical device'),
                    trailing: CupertinoListTileChevron(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
