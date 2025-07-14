import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onEditProfile;

  const ProfileHeaderWidget({
    super.key,
    required this.userData,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              children: [
                // Profile Avatar
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Change profile picture functionality')),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: CustomImageWidget(
                            imageUrl: userData["avatar"] as String,
                            width: 20.w,
                            height: 20.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: CustomIconWidget(
                            iconName: 'camera_alt',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 4.w),

                // User Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              userData["name"] as String,
                              style: GoogleFonts.poppins(
                                textStyle: AppTheme
                                    .lightTheme.textTheme.titleLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: onEditProfile,
                            icon: CustomIconWidget(
                              iconName: 'edit',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 8.w,
                              minHeight: 8.w,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'location_on',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              userData["location"] as String,
                              style: GoogleFonts.poppins(
                                textStyle: AppTheme
                                    .lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'landscape',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Farm Size: ${userData["farmSize"]}',
                            style: GoogleFonts.poppins(
                              textStyle: AppTheme
                                  .lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Quick Stats Row
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: 'eco',
                    label: 'Crops',
                    value: '${(userData["cropInterests"] as List).length}',
                  ),
                  Container(
                    width: 1,
                    height: 4.h,
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                  ),
                  _buildStatItem(
                    icon: 'trending_up',
                    label: 'Experience',
                    value: userData["experienceLevel"] as String,
                  ),
                  Container(
                    width: 1,
                    height: 4.h,
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                  ),
                  _buildStatItem(
                    icon: 'agriculture',
                    label: 'Farm Type',
                    value: userData["farmType"] as String,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            textStyle: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            textStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
