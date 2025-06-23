import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsItemWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isToggle;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;

  const SettingsItemWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isToggle = false,
    this.toggleValue = false,
    this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isToggle ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            // Icon
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && !isToggle) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle!,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),

            // Trailing Widget
            if (isToggle)
              Switch(
                value: toggleValue,
                onChanged: onToggleChanged,
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              )
            else
              CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.4),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
