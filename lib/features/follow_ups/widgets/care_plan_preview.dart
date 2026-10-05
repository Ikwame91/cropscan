import 'package:cropscan_pro/app/navigation_provider.dart';
import 'package:cropscan_pro/core/app_export.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_provider.dart';
import 'package:cropscan_pro/features/follow_ups/widgets/follow_up_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

/// Home-screen summary of care-plan tasks due today or overdue.
/// Renders nothing when nothing is due.
class CarePlanPreview extends StatelessWidget {
  final int maxTasks;

  const CarePlanPreview({super.key, this.maxTasks = 3});

  @override
  Widget build(BuildContext context) {
    final followUps = context.watch<FollowUpProvider>();
    final due = followUps.dueNow;
    if (due.isEmpty) return const SizedBox.shrink();

    final theme = AppTheme.lightTheme;
    final overdue = followUps.overdueCount;

    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  overdue > 0
                      ? 'Care plan: $overdue overdue'
                      : "Today's care plan",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => context
                    .read<NavigationProvider>()
                    .navigateToTab(AppTab.carePlan),
                child: const Text('See all'),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          for (final task in due.take(maxTasks)) FollowUpTile(task: task),
          if (due.length > maxTasks)
            Text('+${due.length - maxTasks} more',
                style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
