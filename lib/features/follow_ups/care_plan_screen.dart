import 'package:cropscan_pro/app/navigation_provider.dart';
import 'package:cropscan_pro/core/app_export.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_provider.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_task.dart';
import 'package:cropscan_pro/features/follow_ups/widgets/follow_up_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

/// The Care plan tab: what to do now, what's coming up, and what's done.
class CarePlanScreen extends StatelessWidget {
  const CarePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final followUps = context.watch<FollowUpProvider>();
    final theme = AppTheme.lightTheme;
    final dueNow = followUps.dueNow;
    final upcoming = followUps.upcoming;
    final completed = followUps.completed.take(10).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Care plan'),
        automaticallyImplyLeading: false,
      ),
      body: followUps.isLoading
          ? const Center(child: CircularProgressIndicator())
          : followUps.tasks.isEmpty
              ? const _EmptyCarePlan()
              : ListView(
                  padding: EdgeInsets.all(4.w),
                  children: [
                    _Section(
                      title: 'To do now',
                      emptyText: 'Nothing due today.',
                      tasks: dueNow,
                    ),
                    _Section(
                      title: 'Coming up',
                      emptyText: 'No upcoming reminders.',
                      tasks: upcoming,
                    ),
                    if (completed.isNotEmpty)
                      _Section(title: 'Done', tasks: completed),
                  ],
                ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? emptyText;
  final List<FollowUpTask> tasks;

  const _Section({required this.title, required this.tasks, this.emptyText});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title${tasks.isEmpty ? '' : ' (${tasks.length})'}',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 1.h),
          if (tasks.isEmpty && emptyText != null)
            Text(emptyText!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          else
            for (final task in tasks) FollowUpTile(task: task),
        ],
      ),
    );
  }
}

class _EmptyCarePlan extends StatelessWidget {
  const _EmptyCarePlan();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_note, size: 48, color: theme.colorScheme.primary),
            SizedBox(height: 2.h),
            Text('No care plan yet',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Text(
              'After a scan, tap "Start care plan" to get dated reminders to '
              'treat, re-apply and rescan your crop.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan a crop'),
              onPressed: () =>
                  context.read<NavigationProvider>().navigateToCamera(),
            ),
          ],
        ),
      ),
    );
  }
}
