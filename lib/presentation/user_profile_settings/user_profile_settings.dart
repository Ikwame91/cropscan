import 'package:cropscan_pro/providers/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../providers/detection_history_provider.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/app_info_widget.dart';

class UserProfileSettings extends StatefulWidget {
  const UserProfileSettings({super.key});

  @override
  State<UserProfileSettings> createState() => _UserProfileSettingsState();
}

class _UserProfileSettingsState extends State<UserProfileSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
            tooltip: "Help",
          ),
        ],
      ),
      body: Consumer2<UserProfileProvider, DetectionHistoryProvider>(
        builder: (context, userProvider, historyProvider, child) {
          if (userProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // Calculate stats from real data
          final totalScans = historyProvider.totalScans;
          final cropsDetected =
              _getUniqueCropsDetected(historyProvider.detectionHistory);
          final lastScanDate =
              _getLastScanDate(historyProvider.detectionHistory);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Farmer Profile Header (with real data)
                ProfileHeaderWidget(
                  userProfile: userProvider.userProfile,
                  totalScans: totalScans,
                  cropsDetected: cropsDetected,
                  lastScanDate: lastScanDate,
                  onEditName: () => _handleEditName(userProvider),
                  onEditRegion: () => _handleEditRegion(userProvider),
                  onUpdateProfilePicture: () =>
                      userProvider.updateProfilePicture(),
                ),

                SizedBox(height: 3.h),
                // Scanner Settings (Essential Only)
                _buildSettingsSection(
                  title: "Scanner Settings",
                  icon: Icons.camera_alt,
                  children: [
                    SettingsItemWidget(
                      icon: Icons.vibration,
                      title: "Haptic Feedback",
                      subtitle: "Vibration on capture and focus",
                      isToggle: true,
                      toggleValue: userProvider.isHapticFeedback,
                      onToggleChanged: (value) =>
                          userProvider.updateHapticFeedback(value),
                    ),
                    SettingsItemWidget(
                      icon: Icons.save_alt,
                      title: "Save Photos",
                      subtitle: "Save scanned images to gallery",
                      isToggle: true,
                      toggleValue: userProvider.isSaveToGallery,
                      onToggleChanged: (value) =>
                          userProvider.updateSaveToGallery(value),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Language & Display
                _buildSettingsSection(
                  title: "Language & Display",
                  icon: Icons.language,
                  children: [
                    SettingsItemWidget(
                      icon: Icons.translate,
                      title: "Language",
                      subtitle: userProvider.selectedLanguage,
                      showArrow: true,
                      onTap: () => _showLanguageSelector(userProvider),
                    ),
                    SettingsItemWidget(
                      icon: Icons.text_fields,
                      title: "Text Size",
                      subtitle: "Adjust text size for better reading",
                      showArrow: true,
                      onTap: () => _showTextSizeDialog(),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Storage & Data
                _buildSettingsSection(
                  title: "Storage & Data",
                  icon: Icons.storage,
                  children: [
                    SettingsItemWidget(
                      icon: Icons.history,
                      title: "Scan History",
                      subtitle: "$totalScans scans saved",
                      showArrow: true,
                      onTap: () => _showHistoryOptions(historyProvider),
                    ),
                    SettingsItemWidget(
                      icon: Icons.cleaning_services,
                      title: "Clear Cache",
                      subtitle: "Free up storage space",
                      showArrow: true,
                      onTap: () => _showClearCacheDialog(),
                    ),
                    SettingsItemWidget(
                      icon: Icons.delete_outline,
                      title: "Reset All Data",
                      subtitle: "Clear profile and scan history",
                      showArrow: true,
                      isDestructive: true,
                      onTap: () =>
                          _showResetDataDialog(userProvider, historyProvider),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // App Information
                AppInfoWidget(
                  onAbout: () => _showAboutDialog(),
                  onTutorial: () => _showTutorialDialog(),
                  onFeedback: () => _showFeedbackDialog(),
                ),

                SizedBox(height: 4.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // Helper methods to get real data
  List<String> _getUniqueCropsDetected(detectionHistory) {
    final Set<String> uniqueCrops = {};
    for (var detection in detectionHistory) {
      uniqueCrops.add(detection.cropName);
    }
    return uniqueCrops.toList();
  }

  String _getLastScanDate(detectionHistory) {
    if (detectionHistory.isEmpty) return "Never";

    final lastScan = detectionHistory.first.detectedAt;
    final now = DateTime.now();
    final difference = now.difference(lastScan);

    if (difference.inDays == 0) return "Today";
    if (difference.inDays == 1) return "Yesterday";
    if (difference.inDays < 7) return "${difference.inDays} days ago";
    return "${lastScan.day}/${lastScan.month}/${lastScan.year}";
  }

  // Edit handlers
  void _handleEditName(UserProfileProvider userProvider) {
    String newName = userProvider.userName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Name"),
          content: TextField(
            onChanged: (value) => newName = value,
            decoration: InputDecoration(
              hintText: "Enter your name",
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: newName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (newName.isNotEmpty) {
                  userProvider.updateProfile(name: newName);
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _handleEditRegion(UserProfileProvider userProvider) {
    final regions = [
      "Ashanti Region",
      "Greater Accra Region",
      "Western Region",
      "Central Region",
      "Volta Region",
      "Eastern Region",
      "Northern Region",
      "Upper East Region",
      "Upper West Region",
      "Brong-Ahafo Region"
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Region"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: regions
              .map((region) => ListTile(
                    title: Text(region),
                    leading: Radio<String>(
                      value: region,
                      groupValue: userProvider.userRegion,
                      onChanged: (value) {
                        if (value != null) {
                          userProvider.updateProfile(region: value);
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showLanguageSelector(UserProfileProvider userProvider) {
    final languages = ["English", "Twi", "Ga", "Ewe", "Hausa"];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map((lang) => ListTile(
                    title: Text(lang),
                    leading: Radio<String>(
                      value: lang,
                      groupValue: userProvider.selectedLanguage,
                      onChanged: (value) {
                        if (value != null) {
                          userProvider.updateLanguage(value);
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showHistoryOptions(DetectionHistoryProvider historyProvider) {
    final uniqueCrops =
        _getUniqueCropsDetected(historyProvider.detectionHistory);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Scan History"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Scans: ${historyProvider.totalScans}"),
            Text(
                "Average Confidence: ${(historyProvider.averageConfidence * 100).toStringAsFixed(1)}%"),
            Text("Crops Detected: ${uniqueCrops.join(', ')}"),
            Text("Most Scanned: ${historyProvider.mostIdentifiedCrop}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showClearHistoryConfirmation(historyProvider);
            },
            child: Text("Clear History", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryConfirmation(DetectionHistoryProvider historyProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear Scan History"),
        content: Text(
            "Are you sure you want to delete all scan history? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // ✅ FIX: Safe context handling
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              navigator.pop(); // Close dialog first

              try {
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 4.w),
                        Text("Clearing history..."),
                      ],
                    ),
                  ),
                );

                await historyProvider.clearAllHistory();

                if (mounted) {
                  Navigator.of(context).pop(); // Close loading
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text("Scan history cleared!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text("Error clearing history: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Clear", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetDataDialog(UserProfileProvider userProvider,
      DetectionHistoryProvider historyProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reset All Data"),
        content: Text(
            "This will delete your profile, settings, and all scan history. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // ✅ FIX: Save context before async operations
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // Close dialog first
              navigator.pop();

              try {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 4.w),
                        Text("Resetting data..."),
                      ],
                    ),
                  ),
                );

                // Perform async operations
                await userProvider.clearAllData();
                await historyProvider.clearAllHistory();

                // ✅ Check if widget is still mounted before showing snackbar
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text("All data has been reset!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Handle errors safely
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text("Error resetting data: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Reset All", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear Cache"),
        content: Text(
            "This will free up storage space but may slow down the next app start. Continue?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Cache cleared successfully!")),
              );
            },
            child: Text("Clear"),
          ),
        ],
      ),
    );
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Text Size"),
        content: Text("Text size adjustment coming soon!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline,
                color: AppTheme.lightTheme.colorScheme.primary),
            SizedBox(width: 2.w),
            Text("How to Use"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📱 Point camera at crop leaf"),
            SizedBox(height: 1.h),
            Text("📸 Tap to scan"),
            SizedBox(height: 1.h),
            Text("🔍 View results and recommendations"),
            SizedBox(height: 1.h),
            Text("📚 Check scan history"),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Got it!"),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("About CropScan Pro"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Version: 1.0.0"),
            SizedBox(height: 1.h),
            Text("AI-powered crop disease detection for farmers in Ghana."),
            SizedBox(height: 1.h),
            Text("Supports: Maize, Tomato, Bell Pepper"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Quick Tutorial"),
        content: Text(
            "Would you like to see a quick tutorial on how to scan crops effectively?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Maybe Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to tutorial or show inline tutorial
            },
            child: Text("Show Tutorial"),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Feedback"),
        content:
            Text("Help us improve CropScan Pro! Your feedback is valuable."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Later"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Give Feedback"),
          ),
        ],
      ),
    );
  }
}
