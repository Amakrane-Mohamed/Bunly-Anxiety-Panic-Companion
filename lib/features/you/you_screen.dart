import 'package:flutter/material.dart';

import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/readable_width.dart';
import 'you_body.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        return ColoredBox(
          color: AppColors.home,
          child: ReadableWidth(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                safe.top + 8,
                20,
                20 + safe.bottom,
              ),
              children: const [YouBody()],
            ),
          ),
        );
      },
    );
  }
}
