import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class SettingsItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;
  final bool showArrow;
  final Widget? trailing;
  final Color? iconColor;
  final bool isDestructive;

  const SettingsItemWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.isToggle = false,
    this.toggleValue,
    this.onToggleChanged,
    this.onTap,
    this.showArrow = false,
    this.trailing,
    this.iconColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isToggle ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          child: Row(
            children: [
              // Leading Icon
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.lightTheme.colorScheme.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive
                      ? Colors.red
                      : (iconColor ?? AppTheme.lightTheme.colorScheme.primary),
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
                        color: isDestructive
                            ? Colors.red
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        subtitle!,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing Widget
              if (isToggle) ...[
                Switch.adaptive(
                  value: toggleValue ?? false,
                  onChanged: onToggleChanged,
                  activeColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              ] else if (trailing != null) ...[
                trailing!,
              ] else if (showArrow) ...[
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withOpacity(0.4),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
