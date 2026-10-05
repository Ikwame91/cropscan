import 'package:cropscan_pro/core/app_export.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_provider.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_task.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

IconData followUpIcon(FollowUpType type) => switch (type) {
      FollowUpType.treat => Icons.healing,
      FollowUpType.reapply => Icons.water_drop,
      FollowUpType.inspect => Icons.visibility,
      FollowUpType.rescan => Icons.camera_alt,
    };

/// "Overdue by 2 days", "Due today", "Tomorrow", "Mon 14 Oct".
String describeDue(FollowUpTask task, DateTime now) {
  if (task.isDone) {
    return 'Done ${DateFormat('d MMM').format(task.completedAt!)}';
  }
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
  final days = due.difference(today).inDays;
  if (days < 0) return 'Overdue by ${-days} day${days == -1 ? '' : 's'}';
  if (days == 0) return 'Due today';
  if (days == 1) return 'Tomorrow';
  if (days < 7) return DateFormat('EEEE').format(due);
  return DateFormat('EEE d MMM').format(due);
}

/// One care-plan task with a checkbox. Tap to see its details.
class FollowUpTile extends StatelessWidget {
  final FollowUpTask task;
  final bool compact;

  const FollowUpTile({super.key, required this.task, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<FollowUpProvider>();
    final now = provider.now;
    final theme = AppTheme.lightTheme;
    final overdue = task.isOverdue(now);
    final dueColor = task.isDone
        ? theme.colorScheme.onSurfaceVariant
        : overdue
            ? theme.colorScheme.error
            : task.isDueToday(now)
                ? AppTheme.getWarningColor(true)
                : theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.only(bottom: 1.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: overdue
              ? theme.colorScheme.error.withValues(alpha: 0.5)
              : theme.dividerColor,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 3.w, right: 1.w),
        leading: CircleAvatar(
          backgroundColor: dueColor.withValues(alpha: 0.12),
          child: Icon(followUpIcon(task.type), color: dueColor, size: 20),
        ),
        title: Text(
          task.title,
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          task.outcome ?? describeDue(task, now),
          style: theme.textTheme.bodySmall?.copyWith(color: dueColor),
        ),
        trailing: Checkbox(
          value: task.isDone,
          onChanged: (checked) => checked == true
              ? provider.complete(task.id)
              : provider.reopen(task.id),
        ),
        onTap: () => showFollowUpDetails(context, task),
      ),
    );
  }
}

void showFollowUpDetails(BuildContext context, FollowUpTask task) {
  final provider = context.read<FollowUpProvider>();
  final theme = AppTheme.lightTheme;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 75.h),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(task.title,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 0.5.h),
              Text(describeDue(task, provider.now),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              SizedBox(height: 2.h),
              for (final line in task.details)
                Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Text('•  $line', style: theme.textTheme.bodyMedium),
                ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  if (!task.isDone)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          provider.snooze(task.id);
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Remind me tomorrow'),
                      ),
                    ),
                  if (!task.isDone) SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        task.isDone
                            ? provider.reopen(task.id)
                            : provider.complete(task.id);
                        Navigator.pop(sheetContext);
                      },
                      child: Text(task.isDone ? 'Mark not done' : 'Mark done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
