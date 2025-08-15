import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class WelcomeHeaderWidget extends StatelessWidget {
  final String userName;
  final bool isNewUser;
  final int totalScans;

  const WelcomeHeaderWidget({
    super.key,
    required this.userName,
    required this.isNewUser,
    required this.totalScans,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 3.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        userName,
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              _getSubtitle(),
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    IconData icon;
    String label;
    Color backgroundColor;

    if (isNewUser) {
      icon = Icons.eco;
      label = "New Farmer";
      backgroundColor = Colors.green.withOpacity(0.3);
    } else if (totalScans < 10) {
      icon = Icons.trending_up;
      label = "Growing";
      backgroundColor = Colors.blue.withOpacity(0.3);
    } else {
      icon = Icons.star;
      label = "Expert";
      backgroundColor = Colors.amber.withOpacity(0.3);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  String _getSubtitle() {
    if (isNewUser) {
      return "Welcome to your farming journey! Let's start with essential tips and best practices.";
    } else if (totalScans < 5) {
      return "You're building your farming knowledge! Keep scanning to unlock personalized insights.";
    } else {
      return "Here are your personalized farming insights based on your crop scanning history.";
    }
  }
}
