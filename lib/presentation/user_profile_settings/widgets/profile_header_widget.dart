import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/user_profile.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfile? userProfile;
  final int totalScans;
  final List<String> cropsDetected;
  final String lastScanDate;
  final VoidCallback? onEditName;
  final VoidCallback? onEditRegion;
  final VoidCallback? onUpdateProfilePicture;

  const ProfileHeaderWidget({
    Key? key,
    this.userProfile,
    required this.totalScans,
    required this.cropsDetected,
    required this.lastScanDate,
    this.onEditName,
    this.onEditRegion,
    this.onUpdateProfilePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userName = userProfile?.name ?? 'Local Farmer';
    final userRegion = userProfile?.region ?? 'Ghana';
    final profileImagePath = userProfile?.profileImagePath;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Avatar with Update Option
              GestureDetector(
                onTap: onUpdateProfilePicture,
                child: Stack(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: profileImagePath != null &&
                                File(profileImagePath).existsSync()
                            ? Image.file(
                                File(profileImagePath),
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.person,
                                size: 10.w,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 4.w,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 4.w),

              // Farmer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            userName,
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (onEditName != null)
                          IconButton(
                            onPressed: onEditName,
                            icon:
                                Icon(Icons.edit, color: Colors.white, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    GestureDetector(
                      onTap: onEditRegion,
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.white70, size: 16),
                          SizedBox(width: 1.w),
                          Text(
                            userRegion,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          if (onEditRegion != null) ...[
                            SizedBox(width: 1.w),
                            Icon(Icons.edit, color: Colors.white70, size: 14),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Stats Row (Real Data)
          Row(
            children: [
              _buildStatItem(
                icon: Icons.scanner,
                label: "Total Scans",
                value: "$totalScans",
              ),
              SizedBox(width: 4.w),
              _buildStatItem(
                icon: Icons.eco,
                label: "Crops Found",
                value: "${cropsDetected.length}",
              ),
              SizedBox(width: 4.w),
              _buildStatItem(
                icon: Icons.calendar_today,
                label: "Last Scan",
                value: lastScanDate,
                isSmallText: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    bool isSmallText = false,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(height: 0.5.h),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallText ? 10.sp : 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 8.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
