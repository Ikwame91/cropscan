import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_export.dart';

class ModernFilterWidget extends StatelessWidget {
  final String currentSortBy;
  final String currentFilterBy;
  final Function(String) onSortChanged;
  final Function(String) onFilterChanged;

  const ModernFilterWidget({
    super.key,
    required this.currentSortBy,
    required this.currentFilterBy,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Filter Chips
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'All',
                  'all',
                  currentFilterBy,
                  onFilterChanged,
                  Icons.grid_view,
                ),
                SizedBox(width: 2.w),
                _buildFilterChip(
                  context,
                  'Healthy',
                  'healthy',
                  currentFilterBy,
                  onFilterChanged,
                  Icons.check_circle,
                  color: Colors.green,
                ),
                SizedBox(width: 2.w),
                _buildFilterChip(
                  context,
                  'Issues',
                  'diseased',
                  currentFilterBy,
                  onFilterChanged,
                  Icons.warning,
                  color: Colors.red,
                ),
                SizedBox(width: 2.w),
                _buildFilterChip(
                  context,
                  'This Week',
                  'this_week',
                  currentFilterBy,
                  onFilterChanged,
                  Icons.calendar_today,
                ),
                SizedBox(width: 2.w),
                _buildFilterChip(
                  context,
                  'This Month',
                  'this_month',
                  currentFilterBy,
                  onFilterChanged,
                  Icons.date_range,
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 3.w),

        // Sort Button
        GestureDetector(
          onTap: () => _showSortOptions(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  _getSortLabel(currentSortBy),
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value,
    String currentValue,
    Function(String) onChanged,
    IconData icon, {
    Color? color,
  }) {
    final isSelected = currentValue == value;
    final chipColor = color ?? AppTheme.lightTheme.colorScheme.primary;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withOpacity(0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? chipColor : AppTheme.lightTheme.dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? chipColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 14,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                color: isSelected
                    ? chipColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 3.h),
            _buildSortOption(
                context, 'Newest First', 'newest', Icons.arrow_downward),
            _buildSortOption(
                context, 'Oldest First', 'oldest', Icons.arrow_upward),
            _buildSortOption(
                context, 'Highest Confidence', 'confidence', Icons.trending_up),
            _buildSortOption(
                context, 'Alphabetical', 'alphabetical', Icons.sort_by_alpha),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
      BuildContext context, String label, String value, IconData icon) {
    final isSelected = currentSortBy == value;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isSelected
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: AppTheme.lightTheme.colorScheme.primary,
            )
          : null,
      onTap: () {
        onSortChanged(value);
        Navigator.pop(context);
      },
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'newest':
        return 'Newest';
      case 'oldest':
        return 'Oldest';
      case 'confidence':
        return 'Confidence';
      case 'alphabetical':
        return 'A-Z';
      default:
        return 'Sort';
    }
  }
}
