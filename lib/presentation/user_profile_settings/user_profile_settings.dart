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
                  icon: 'security',
                  title: "Biometric Authentication",
                  isToggle: true,
                  toggleValue: isBiometricAuth,
                  onToggleChanged: (value) {
                    setState(() {
                      isBiometricAuth = value;
                    });
                  },
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

            // App Preferences Section
            SettingsSectionWidget(
              title: "App Preferences",
              children: [
                SettingsItemWidget(
                  icon: 'language',
                  title: "Language",
                  subtitle: selectedLanguage,
                  onTap: () => _showLanguageSelector(),
                ),
                SettingsItemWidget(
                  icon: 'thermostat',
                  title: "Temperature Unit",
                  subtitle: selectedTempUnit,
                  onTap: () => _showTemperatureUnitSelector(),
                ),
                SettingsItemWidget(
                  icon: 'square_foot',
                  title: "Area Unit",
                  subtitle: selectedAreaUnit,
                  onTap: () => _showAreaUnitSelector(),
                ),
                SettingsItemWidget(
                  icon: 'dark_mode',
                  title: "Dark Mode",
                  isToggle: true,
                  toggleValue: isDarkMode,
                  onToggleChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                  },
                ),
                SettingsItemWidget(
                  icon: 'sync',
                  title: "Offline Sync",
                  subtitle: "Sync data when online",
                  isToggle: true,
                  toggleValue: isOfflineSync,
                  onToggleChanged: (value) {
                    setState(() {
                      isOfflineSync = value;
                    });
                  },
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
                SettingsItemWidget(
                  icon: 'schedule',
                  title: "Notification Schedule",
                  subtitle: "8:00 AM - 8:00 PM",
                  onTap: () => _navigateToNotificationSchedule(),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Farming Profile Section
            SettingsSectionWidget(
              title: "Farming Profile",
              children: [
                SettingsItemWidget(
                  icon: 'eco',
                  title: "Crop Interests",
                  subtitle: (userData["cropInterests"] as List).join(", "),
                  onTap: () => _navigateToCropInterests(),
                ),
                SettingsItemWidget(
                  icon: 'trending_up',
                  title: "Experience Level",
                  subtitle: userData["experienceLevel"] as String,
                  onTap: () => _navigateToExperienceLevel(),
                ),
                SettingsItemWidget(
                  icon: 'landscape',
                  title: "Farm Type",
                  subtitle: userData["farmType"] as String,
                  onTap: () => _navigateToFarmType(),
                ),
                SettingsItemWidget(
                  icon: 'straighten',
                  title: "Farm Size",
                  subtitle: userData["farmSize"] as String,
                  onTap: () => _navigateToFarmSize(),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Data Management Section
            SettingsSectionWidget(
              title: "Data Management",
              children: [
                SettingsItemWidget(
                  icon: 'backup',
                  title: "Backup Data",
                  subtitle: "Last backup: 2 days ago",
                  onTap: () => _handleBackupData(),
                ),
                SettingsItemWidget(
                  icon: 'file_download',
                  title: "Export Detection History",
                  subtitle: "Download as CSV",
                  onTap: () => _handleExportData(),
                ),
                SettingsItemWidget(
                  icon: 'cloud_sync',
                  title: "Sync Settings",
                  subtitle: "Manage cloud synchronization",
                  onTap: () => _navigateToSyncSettings(),
                ),
                SettingsItemWidget(
                  icon: 'delete_forever',
                  title: "Clear Cache",
                  subtitle: "Free up storage space",
                  onTap: () => _handleClearCache(),
                ),
              ],
            ),

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

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Language',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            ...['English', 'Spanish', 'French', 'Hindi', 'Portuguese'].map(
              (language) => ListTile(
                title: Text(language),
                trailing: selectedLanguage == language
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    selectedLanguage = language;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemperatureUnitSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Temperature Unit',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            ...['Celsius', 'Fahrenheit'].map(
              (unit) => ListTile(
                title: Text(unit),
                trailing: selectedTempUnit == unit
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    selectedTempUnit = unit;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAreaUnitSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Area Unit',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            ...['Acres', 'Hectares', 'Square Meters'].map(
              (unit) => ListTile(
                title: Text(unit),
                trailing: selectedAreaUnit == unit
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    selectedAreaUnit = unit;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNotificationSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification schedule functionality')),
    );
  }

  void _navigateToCropInterests() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Crop interests functionality')),
    );
  }

  void _navigateToExperienceLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Experience level functionality')),
    );
  }

  void _navigateToFarmType() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Farm type functionality')),
    );
  }

  void _navigateToFarmSize() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Farm size functionality')),
    );
  }

  void _handleBackupData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Backing up data...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _handleExportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting detection history...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _navigateToSyncSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sync settings functionality')),
    );
  }

  void _handleClearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cache'),
        content: Text(
            'Are you sure you want to clear the app cache? This will free up storage space but may slow down the app temporarily.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              );
            },
            child: Text('Clear'),
          ),
        ],
      ),
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
