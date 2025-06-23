import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalendarViewWidget extends StatefulWidget {
  final List<Map<String, dynamic>> detectionHistory;

  const CalendarViewWidget({
    super.key,
    required this.detectionHistory,
  });

  @override
  State<CalendarViewWidget> createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends State<CalendarViewWidget> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar Header
        Container(
          padding: EdgeInsets.all(4.w),
          color: AppTheme.lightTheme.colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  });
                },
                icon: CustomIconWidget(
                  iconName: 'chevron_left',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
              ),
              Text(
                _getMonthYearString(_selectedMonth),
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                },
                icon: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),

        // Calendar Grid
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Weekday Headers
                Row(
                  children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                      .map((day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),

                SizedBox(height: 2.h),

                // Calendar Days
                Expanded(
                  child: _buildCalendarGrid(),
                ),

                // Detection Details for Selected Date
                if (_selectedDate != null) ...[
                  SizedBox(height: 2.h),
                  _buildSelectedDateDetails(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final detectionsForDay = _getDetectionsForDate(date);
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == date.day;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : detectionsForDay.isNotEmpty
                      ? AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? null
                  : detectionsForDay.isNotEmpty
                      ? Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                        )
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : detectionsForDay.isNotEmpty
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: detectionsForDay.isNotEmpty || isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (detectionsForDay.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : _getHeatmapColor(detectionsForDay.length),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      children: dayWidgets,
    );
  }

  Widget _buildSelectedDateDetails() {
    final detectionsForDay = _getDetectionsForDate(_selectedDate!);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'event',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                _getDateString(_selectedDate!),
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                '${detectionsForDay.length} detection${detectionsForDay.length != 1 ? 's' : ''}',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (detectionsForDay.isEmpty) ...[
            SizedBox(height: 2.h),
            Center(
              child: Text(
                'No detections on this date',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ] else ...[
            SizedBox(height: 2.h),
            ...detectionsForDay
                .take(3)
                .map((detection) => Container(
                      margin: EdgeInsets.only(bottom: 2.w),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CustomImageWidget(
                              imageUrl: detection['imageUrl'] as String,
                              width: 12.w,
                              height: 12.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detection['cropName'] as String,
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${((detection['confidence'] as double) * 100).toInt()}% confidence',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
                ,
            if (detectionsForDay.length > 3) ...[
              Center(
                child: TextButton(
                  onPressed: () {
                    // Show all detections for this date
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        maxChildSize: 0.9,
                        minChildSize: 0.5,
                        builder: (context, scrollController) => Container(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Detections - ${_getDateString(_selectedDate!)}',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Expanded(
                                child: ListView.builder(
                                  controller: scrollController,
                                  itemCount: detectionsForDay.length,
                                  itemBuilder: (context, index) {
                                    final detection = detectionsForDay[index];
                                    return ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CustomImageWidget(
                                          imageUrl:
                                              detection['imageUrl'] as String,
                                          width: 15.w,
                                          height: 15.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title:
                                          Text(detection['cropName'] as String),
                                      subtitle: Text(
                                        '${((detection['confidence'] as double) * 100).toInt()}% confidence',
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.pushNamed(
                                          context,
                                          '/crop-detection-results',
                                          arguments: detection,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text('View all ${detectionsForDay.length} detections'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDetectionsForDate(DateTime date) {
    return widget.detectionHistory.where((detection) {
      final timestamp = detection['timestamp'] as DateTime;
      return timestamp.year == date.year &&
          timestamp.month == date.month &&
          timestamp.day == date.day;
    }).toList();
  }

  Color _getHeatmapColor(int detectionCount) {
    if (detectionCount >= 5) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else if (detectionCount >= 3) {
      return AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.7);
    } else if (detectionCount >= 2) {
      return AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.5);
    } else {
      return AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3);
    }
  }

  String _getMonthYearString(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getDateString(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
