import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BottomActionsWidget extends StatelessWidget {
  final VoidCallback onHelpSupport;
  final VoidCallback onTermsOfService;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onSignOut;

  const BottomActionsWidget({
    super.key,
    required this.onHelpSupport,
    required this.onTermsOfService,
    required this.onPrivacyPolicy,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Help & Support Section
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildActionItem(
                icon: 'help_outline',
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: onHelpSupport,
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                indent: 4.w,
                endIndent: 4.w,
              ),
              _buildActionItem(
                icon: 'description',
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: onTermsOfService,
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                indent: 4.w,
                endIndent: 4.w,
              ),
              _buildActionItem(
                icon: 'policy',
                title: 'Privacy Policy',
                subtitle: 'Learn how we protect your data',
                onTap: onPrivacyPolicy,
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Sign Out Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSignOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: AppTheme.lightTheme.colorScheme.onError,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'logout',
                  color: AppTheme.lightTheme.colorScheme.onError,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Sign Out',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onError,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // App Version
        Text(
          'CropScan Pro v1.0.0',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: AppTheme.lightTheme.colorScheme.secondary,
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
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            // Chevron
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
