import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_actions_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';

class UserProfileSettings extends StatefulWidget {
  const UserProfileSettings({super.key});

  @override
  State<UserProfileSettings> createState() => _UserProfileSettingsState();
}

class _UserProfileSettingsState extends State<UserProfileSettings> {
  // Mock user data
  final Map<String, dynamic> userData = {
    "name": "Bryan Sackey",
    "location": "Ayedusase Village, Ghana",
    "farmSize": "aura Farming",
    "avatar": "assets/images/B_farmer.jpg",
    "email": "bryansackey@gmail.com",
    "phone": "+233 556-789-012",
    "experienceLevel": "Intermediate",
    "farmType": "Mixed Crops",
    "cropInterests": ["Tomatoes", "Bell Peppers", "Maize"]
  };

  // Settings state
  bool isDarkMode = false;
  bool isOfflineSync = true;
  bool isPushNotifications = true;
  bool isWeatherAlerts = true;
  bool isCropAlerts = true;
  bool isBiometricAuth = false;
  String selectedLanguage = "English";
  String selectedTempUnit = "Celsius";
  String selectedAreaUnit = "Acres";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile Settings',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            ProfileHeaderWidget(
              userData: userData,
              onEditProfile: _handleEditProfile,
            ),

            SizedBox(height: 3.h),

            // Account Settings Section
            SettingsSectionWidget(
              title: "Account Settings",
              children: [
                SettingsItemWidget(
                  icon: 'email',
                  title: "Email",
                  subtitle: userData["email"] as String,
                  onTap: () => _navigateToEmailSettings(),
                ),
                SettingsItemWidget(
                  icon: 'lock',
                  title: "Change Password",
                  subtitle: "••••••••",
                  onTap: () => _navigateToPasswordSettings(),
                ),
                SettingsItemWidget(
                  icon: 'privacy_tip',
                  title: "Privacy Settings",
                  subtitle: "Manage data sharing",
                  onTap: () => _navigateToPrivacySettings(),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Notifications Section
            SettingsSectionWidget(
              title: "Notifications",
              children: [
                SettingsItemWidget(
                  icon: 'notifications',
                  title: "Push Notifications",
                  isToggle: true,
                  toggleValue: isPushNotifications,
                  onToggleChanged: (value) {
                    setState(() {
                      isPushNotifications = value;
                    });
                  },
                ),
                SettingsItemWidget(
                  icon: 'wb_sunny',
                  title: "Weather Alerts",
                  isToggle: true,
                  toggleValue: isWeatherAlerts,
                  onToggleChanged: (value) {
                    setState(() {
                      isWeatherAlerts = value;
                    });
                  },
                ),
                SettingsItemWidget(
                  icon: 'agriculture',
                  title: "Crop Alerts",
                  isToggle: true,
                  toggleValue: isCropAlerts,
                  onToggleChanged: (value) {
                    setState(() {
                      isCropAlerts = value;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 2.h),

            SizedBox(height: 3.h),
            // Bottom Actions
            BottomActionsWidget(
              onHelpSupport: () => _navigateToHelpSupport(),
              onTermsOfService: () => _navigateToTermsOfService(),
              onPrivacyPolicy: () => _navigateToPrivacyPolicy(),
              onSignOut: () => _handleSignOut(),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  void _handleEditProfile() {
    // Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit Profile functionality'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _navigateToEmailSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email settings functionality')),
    );
  }

  void _navigateToPasswordSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password settings functionality')),
    );
  }

  void _navigateToPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Privacy settings functionality')),
    );
  }

  void _navigateToHelpSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Help & Support functionality')),
    );
  }

  void _navigateToTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terms of Service functionality')),
    );
  }

  void _navigateToPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Privacy Policy functionality')),
    );
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text(
            'Are you sure you want to sign out? You will need to sign in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/dashboard-home',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
