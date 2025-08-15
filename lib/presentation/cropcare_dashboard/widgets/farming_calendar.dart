import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/farming_calendar_event.dart';

class FarmingCalendarWidget extends StatelessWidget {
  final List<FarmingCalendarEvent> events;

  const FarmingCalendarWidget({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(height: 2.h),
          _buildEventsList(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final currentMonth = DateTime.now().month;
    final monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.calendar_today,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Farming Calendar",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                "Activities for ${monthNames[currentMonth]}",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList(BuildContext context) {
    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: events.map((event) => _buildEventCard(context, event)).toList(),
    );
  }

  Widget _buildEventCard(BuildContext context, FarmingCalendarEvent event) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getCategoryColor(event.category).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(event.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(event.category),
                    color: _getCategoryColor(event.category),
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (event.cropTypes.isNotEmpty) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          "Crops: ${event.cropTypes.join(', ')}",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildPriorityBadge(event.priority),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              event.description,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            if (event.actionItems.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                "Action Items:",
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              ...event.actionItems.take(3).map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 0.5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 0.8.h, right: 2.w),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(event.category),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )),
              if (event.actionItems.length > 3) ...[
                SizedBox(height: 0.5.h),
                Text(
                  "+${event.actionItems.length - 3} more items",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today,
            size: 12.w,
            color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 2.h),
          Text(
            "No activities this month",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Check back next month for seasonal farming activities!",
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'planting':
        return Colors.green;
      case 'care':
        return Colors.blue;
      case 'prevention':
        return Colors.orange;
      case 'harvesting':
        return Colors.purple;
      case 'preparation':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'planting':
        return Icons.eco;
      case 'care':
        return Icons.favorite;
      case 'prevention':
        return Icons.shield;
      case 'harvesting':
        return Icons.agriculture;
      case 'preparation':
        return Icons.build;
      default:
        return Icons.event;
    }
  }
}
