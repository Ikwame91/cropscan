import 'package:cropscan_pro/presentation/cropcare_dashboard/widgets/disease_library.dart';
import 'package:cropscan_pro/presentation/cropcare_dashboard/widgets/analyticssummary.dart';
import 'package:cropscan_pro/presentation/cropcare_dashboard/widgets/farming_calendar.dart';
import 'package:cropscan_pro/presentation/cropcare_dashboard/widgets/personalizedTips.dart';
import 'package:cropscan_pro/presentation/cropcare_dashboard/widgets/quick_actions.dart';
import 'package:cropscan_pro/presentation/cropcare_dashboard/widgets/welcome_header.dart';
import 'package:cropscan_pro/providers/crop_care_provider.dart';
import 'package:cropscan_pro/providers/detection_history_provider.dart';
import 'package:cropscan_pro/providers/userprofile.dart';
import 'package:cropscan_pro/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CropCareDashboard extends StatefulWidget {
  const CropCareDashboard({super.key});

  @override
  State<CropCareDashboard> createState() => _CropCareDashboardState();
}

class _CropCareDashboardState extends State<CropCareDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropCareProvider>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Consumer3<CropCareProvider, DetectionHistoryProvider,
          UserProfileProvider>(
        builder:
            (context, cropCareProvider, historyProvider, userProvider, child) {
          if (cropCareProvider.isLoading) {
            return _buildLoadingState();
          }

          if (cropCareProvider.errorMessage != null) {
            return _buildErrorState(cropCareProvider.errorMessage!);
          }

          // Determine if user is new (no scan history)
          final isNewUser = historyProvider.detectionHistory.isEmpty;
          final hasRecentScans = historyProvider.detectionHistory.length >= 3;

          return RefreshIndicator(
            onRefresh: () => cropCareProvider.refreshData(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dynamic Welcome Header
                  WelcomeHeaderWidget(
                    userName: userProvider.userName,
                    isNewUser: isNewUser,
                    totalScans: historyProvider.totalScans,
                  ),

                  SizedBox(height: 2.h),

                  // Content based on user journey stage
                  if (isNewUser) ...[
                    // NEW USER EXPERIENCE
                    _buildNewUserContent(cropCareProvider, historyProvider),
                  ] else if (hasRecentScans) ...[
                    // EXPERIENCED USER WITH ANALYTICS
                    _buildExperiencedUserContent(
                        cropCareProvider, historyProvider),
                  ] else ...[
                    // INTERMEDIATE USER (some scans but not enough for full analytics)
                    _buildIntermediateUserContent(
                        cropCareProvider, historyProvider),
                  ],

                  SizedBox(height: 2.h),

                  // Always show farming calendar (relevant to all users)
                  FarmingCalendarWidget(
                    events:
                        cropCareProvider.getRelevantActivities(historyProvider),
                  ),

                  SizedBox(height: 2.h),

                  // Quick Actions (scan encouragement and navigation)
                  QuickActionsWidget(
                    isNewUser: isNewUser,
                    totalScans: historyProvider.totalScans,
                  ),

                  SizedBox(height: 2.h),

                  // Disease Library (always useful)
                  DiseaseLibraryWidget(
                    userCrops: _getUserCrops(historyProvider),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewUserContent(CropCareProvider cropCareProvider,
      DetectionHistoryProvider historyProvider) {
    return Column(
      children: [
        // Onboarding message
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.eco,
                size: 12.w,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                "Welcome to CropScan Pro!",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                "Get started with these essential farming tips, then scan your first crop to unlock personalized insights!",
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Essential tips for new users
        PersonalizedTipsWidget(
          title: "Essential Farming Tips",
          subtitle: "Start with these fundamentals",
          tips: cropCareProvider.getPersonalizedTips(null), // null = new user
          showViewAll: true,
        ),
      ],
    );
  }

  Widget _buildIntermediateUserContent(CropCareProvider cropCareProvider,
      DetectionHistoryProvider historyProvider) {
    return Column(
      children: [
        // Encouragement to scan more
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 8.w,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Keep Scanning!",
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Scan ${3 - historyProvider.totalScans} more crops to unlock detailed analytics",
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Show some basic analytics + personalized tips
        PersonalizedTipsWidget(
          title: "Tips for Your Crops",
          subtitle: "Based on your recent scans",
          tips: cropCareProvider.getPersonalizedTips(historyProvider),
          showViewAll: true,
        ),
      ],
    );
  }

  Widget _buildExperiencedUserContent(CropCareProvider cropCareProvider,
      DetectionHistoryProvider historyProvider) {
    return Column(
      children: [
        // Analytics Summary
        AnalyticsSummaryWidget(
          totalScans: historyProvider.totalScans,
          averageConfidence: historyProvider.averageConfidence,
          mostScannedCrop: historyProvider.mostIdentifiedCrop,
          recentTrend: _calculateRecentTrend(historyProvider),
        ),

        SizedBox(height: 3.h),

        // Highly personalized tips
        PersonalizedTipsWidget(
          title: "Personalized Recommendations",
          subtitle: "Based on your scan history and current season",
          tips: cropCareProvider.getPersonalizedTips(historyProvider),
          showViewAll: true,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 2.h),
          Text(
            "Loading crop care information...",
            style: AppTheme.lightTheme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 20.w,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            SizedBox(height: 2.h),
            Text(
              "Oops! Something went wrong",
              style: AppTheme.lightTheme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              error,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () => context.read<CropCareProvider>().refreshData(),
              icon: Icon(Icons.refresh),
              label: Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getUserCrops(DetectionHistoryProvider historyProvider) {
    if (historyProvider.detectionHistory.isEmpty) {
      return ['tomato', 'maize', 'pepper']; // Default supported crops
    }

    return historyProvider.detectionHistory
        .map((detection) => detection.cropName.toLowerCase())
        .toSet()
        .toList();
  }

  String _calculateRecentTrend(DetectionHistoryProvider historyProvider) {
    final recentScans = historyProvider.detectionHistory.take(5).toList();
    final olderScans =
        historyProvider.detectionHistory.skip(5).take(5).toList();

    if (recentScans.isEmpty || olderScans.isEmpty) return "stable";

    // ✅ CLEANER: Using the isHealthy getter
    final recentHealthy =
        recentScans.where((scan) => scan.isHealthy).length / recentScans.length;
    final olderHealthy =
        olderScans.where((scan) => scan.isHealthy).length / olderScans.length;

    if (recentHealthy > olderHealthy + 0.2) return "improving";
    if (recentHealthy < olderHealthy - 0.2) return "declining";
    return "stable";
  }
}
