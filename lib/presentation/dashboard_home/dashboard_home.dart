import 'package:cropscan_pro/models/crop_detection_args.dart';
import 'package:cropscan_pro/models/crop_info.dart';
import 'package:cropscan_pro/providers/detection_history_provider.dart';
import 'package:cropscan_pro/providers/naviagtion_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/recent_detection_card_widget.dart';
import './widgets/scan_crop_card_widget.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  Future<void> _handleRefresh(BuildContext context) async {
    final detectionHistoryProvider =
        Provider.of<DetectionHistoryProvider>(context, listen: false);

    await detectionHistoryProvider.loadDetectionHistory();
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
                  'CropVision',
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
                        Navigator.pushNamed(context, '/detection-history'),
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
                              Navigator.pushNamed(context, '/cropscreen'),
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
                                onTap: () {
                                  debugPrint(
                                      "Dashboard tap: cropName=${detection.cropName}, rawDetectedCrop=${detection.rawDetectedCrop}, hasEnhancedInfo=${detection.enhancedCropInfo != null}");
                                  final args = CropDetectionResultsArgs(
                                    imagePath: detection.imageUrl,
                                    detectedCrop: detection.rawDetectedCrop ??
                                        CropInfoMapper.getRawLabel(
                                            detection.cropName),
                                    confidence: detection
                                        .confidence, // ✅ Real confidence
                                    cropInfo: CropInfoMapper.getCropInfo(
                                        detection.cropName),
                                    enhancedCropInfo:
                                        detection.enhancedCropInfo,
                                    isFromHistory: true,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    '/crop-detection-results',
                                    arguments: args,
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 3.h),

                    // ✅ NEW: Farming Tips Section (instead of alerts)
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
  Widget _buildFarmingTipsSection(BuildContext context) {
    final tips = [
      {
        'title': 'Morning Inspections',
        'description':
            'Check your crops early morning for best disease detection',
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
      },
      {
        'title': 'Photo Quality',
        'description': 'Take clear, well-lit photos focusing on leaf details',
        'icon': Icons.photo_camera,
        'color': Colors.blue,
      },
      {
        'title': 'Regular Monitoring',
        'description': 'Scan your crops weekly for early problem detection',
        'icon': Icons.schedule,
        'color': Colors.green,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farming Tips',
          style: GoogleFonts.poppins(
            textStyle: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        ...tips.map((tip) => Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: (tip['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tip['icon'] as IconData,
                      color: tip['color'] as Color,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          tip['description'] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
