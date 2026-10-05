import 'package:cropscan_pro/features/diagnosis/diagnosis_args.dart';
import 'package:cropscan_pro/features/guide/crop_care_provider.dart';
import 'package:cropscan_pro/features/history/detection_history_provider.dart';
import 'package:cropscan_pro/app/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:cropscan_pro/core/app_export.dart';
import 'package:cropscan_pro/features/follow_ups/widgets/care_plan_preview.dart';
import 'package:cropscan_pro/features/home/widgets/recent_detection_card_widget.dart';
import 'package:cropscan_pro/features/weather/weather_provider.dart';
import 'package:cropscan_pro/features/weather/widgets/weather_card.dart';
import 'package:cropscan_pro/features/home/widgets/scan_crop_card_widget.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  Future<void> _handleRefresh(BuildContext context) async {
    await Future.wait([
      context.read<DetectionHistoryProvider>().loadDetectionHistory(),
      context.read<WeatherProvider>().refresh(),
    ]);
  }

  void _navigateToCamera(BuildContext context) {
    final navigationProvider = context.read<NavigationProvider>();
    navigationProvider.navigateToCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _handleRefresh(context),
          color: AppTheme.lightTheme.colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                title: Text(
                  'CropScan Pro',
                  style: GoogleFonts.playfairDisplay(
                    textStyle:
                        AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.detectionHistory),
                    icon: CustomIconWidget(
                      iconName: 'history',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.all(4.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 3.h),

                    // Scan Crop Card
                    ScanCropCardWidget(
                      onTap: () => _navigateToCamera(context),
                    ),
                    SizedBox(height: 3.h),

                    // ✅ NEW: Quick Stats Card
                    _buildQuickStatsCard(context),
                    SizedBox(height: 3.h),

                    const WeatherCard(),
                    SizedBox(height: 3.h),

                    const CarePlanPreview(),

                    // Recent Detections Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Detections',
                            style: GoogleFonts.poppins(
                              textStyle: AppTheme
                                  .lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.detectionHistory),
                          child: Text(
                            'View All',
                            style: GoogleFonts.poppins(
                              textStyle: AppTheme
                                  .lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Recent Detections List
                    Consumer<DetectionHistoryProvider>(
                      builder: (context, historyProvider, child) {
                        final recentDetections =
                            historyProvider.getRecentDetections(limit: 7);

                        if (historyProvider.isLoading) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: CircularProgressIndicator(
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          );
                        }

                        if (recentDetections.isEmpty) {
                          return Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: AppTheme.lightTheme.dividerColor,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                CustomIconWidget(
                                  iconName: 'eco',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 48,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Scan Your First Crop',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Use AI-powered detection to identify your crops and get instant health analysis',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    textStyle: AppTheme
                                        .lightTheme.textTheme.bodyMedium,
                                  ).copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return SizedBox(
                          height: 31.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: recentDetections.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 3.w),
                            itemBuilder: (context, index) {
                              final detection = recentDetections[index];
                              return RecentDetectionCardWidget(
                                detection: detection,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.cropDetectionResults,
                                  arguments: DiagnosisArgs(
                                      detectionId: detection.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 3.h),

                    _buildFarmingTipsSection(context),
                    SizedBox(height: 4.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Quick Stats Card
  Widget _buildQuickStatsCard(BuildContext context) {
    return Consumer<DetectionHistoryProvider>(
      builder: (context, historyProvider, child) {
        final totalScans = historyProvider.detectionHistory.length;
        final healthyCount = historyProvider.detectionHistory
            .where((d) => d.status.toLowerCase().contains('healthy'))
            .length;
        final diseaseCount = totalScans - healthyCount;

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
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Scans',
                  totalScans.toString(),
                  Icons.camera_alt,
                  Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Healthy',
                  healthyCount.toString(),
                  Icons.check_circle,
                  Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Issues Found',
                  diseaseCount.toString(),
                  Icons.warning,
                  Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 1.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: color.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ✅ NEW: Farming Tips Section (replaces alerts)
  /// Tips picked from the disease database and farming guide for the
  /// diseases and crops in this farmer's scans.
  Widget _buildFarmingTipsSection(BuildContext context) {
    final history = context.watch<DetectionHistoryProvider>();
    final tips = context
        .watch<CropCareProvider>()
        .getPersonalizedTips(history, limit: 3);
    if (tips.isEmpty) return const SizedBox.shrink();

    final theme = AppTheme.lightTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          history.totalScans == 0 ? 'Farming tips' : 'Tips for your crops',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2.h),
        for (final tip in tips)
          Card(
            margin: EdgeInsets.only(bottom: 1.5.h),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor),
            ),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
              leading: CustomIconWidget(
                iconName: tip.iconName,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text(tip.title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(tip.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall),
              onTap: CropCareProvider.rawLabelOf(tip) == null
                  ? null
                  : () => Navigator.pushNamed(
                        context,
                        AppRoutes.diseaseDetail,
                        arguments: CropCareProvider.rawLabelOf(tip),
                      ),
            ),
          ),
      ],
    );
  }
}
