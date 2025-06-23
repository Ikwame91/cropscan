import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterOptionsWidget extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final String? selectedCropFilter;
  final double confidenceThreshold;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(String?) onCropFilterChanged;
  final Function(double) onConfidenceChanged;

  static const List<String> cropTypes = [
    'All Types',
    'Vegetable',
    'Fruit',
    'Grain',
    'Herb',
  ];

  const FilterOptionsWidget({
    super.key,
    required this.selectedDateRange,
    required this.selectedCropFilter,
    required this.confidenceThreshold,
    required this.onDateRangeChanged,
    required this.onCropFilterChanged,
    required this.onConfidenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Header
        Row(
          children: [
            CustomIconWidget(
              iconName: 'filter_list',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Filters',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            Spacer(),
            if (selectedDateRange != null ||
                (selectedCropFilter != null &&
                    selectedCropFilter != 'All Types') ||
                confidenceThreshold > 0) ...[
              TextButton(
                onPressed: () {
                  onDateRangeChanged(null);
                  onCropFilterChanged('All Types');
                  onConfidenceChanged(0.0);
                },
                child: Text(
                  'Clear All',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),

        SizedBox(height: 2.h),

        // Filter Options Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Date Range Filter
              _buildFilterChip(
                label: selectedDateRange != null
                    ? '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}'
                    : 'Date Range',
                icon: 'date_range',
                isActive: selectedDateRange != null,
                onTap: () => _showDateRangePicker(context),
              ),

              SizedBox(width: 3.w),

              // Crop Type Filter
              _buildFilterChip(
                label: selectedCropFilter ?? 'All Types',
                icon: 'category',
                isActive: selectedCropFilter != null &&
                    selectedCropFilter != 'All Types',
                onTap: () => _showCropTypeFilter(context),
              ),

              SizedBox(width: 3.w),

              // Confidence Filter
              _buildFilterChip(
                label: confidenceThreshold > 0
                    ? 'Confidence ≥ ${(confidenceThreshold * 100).toInt()}%'
                    : 'Confidence',
                icon: 'trending_up',
                isActive: confidenceThreshold > 0,
                onTap: () => _showConfidenceFilter(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 1.h,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          border: Border.all(
            color: isActive
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isActive
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isActive
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isActive) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeChanged(picked);
    }
  }

  void _showCropTypeFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Crop Type',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...cropTypes
                .map((type) => ListTile(
                      title: Text(type),
                      leading: Radio<String>(
                        value: type,
                        groupValue: selectedCropFilter ?? 'All Types',
                        onChanged: (value) {
                          onCropFilterChanged(
                              value == 'All Types' ? null : value);
                          Navigator.pop(context);
                        },
                        activeColor: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      onTap: () {
                        onCropFilterChanged(type == 'All Types' ? null : type);
                        Navigator.pop(context);
                      },
                    ))
                ,
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showConfidenceFilter(BuildContext context) {
    double tempThreshold = confidenceThreshold;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Minimum Confidence Level',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Show detections with confidence ≥ ${(tempThreshold * 100).toInt()}%',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 2.h),
              Slider(
                value: tempThreshold,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: '${(tempThreshold * 100).toInt()}%',
                onChanged: (value) {
                  setState(() {
                    tempThreshold = value;
                  });
                },
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onConfidenceChanged(tempThreshold);
                        Navigator.pop(context);
                      },
                      child: Text('Apply'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}