import 'package:cropscan_pro/models/crop_detection_args.dart';
import 'package:cropscan_pro/models/crop_info.dart';
import 'package:cropscan_pro/models/farming_alert.dart';
import 'package:cropscan_pro/providers/detection_history_provider.dart';
import 'package:cropscan_pro/providers/farming_alerts_provider.dart';
import 'package:cropscan_pro/providers/naviagtion_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/farming_alert_card_widget.dart';
import './widgets/recent_detection_card_widget.dart';
import './widgets/scan_crop_card_widget.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  Future<void> _handleRefresh(BuildContext context) async {
    // Access providers and call their fetch methods

    final farmingAlertsProvider =
        Provider.of<FarmingAlertsProvider>(context, listen: false);
    final detectionHistoryProvider =
        Provider.of<DetectionHistoryProvider>(context, listen: false);

    // Trigger data fetching for all providers
    await Future.wait([
      farmingAlertsProvider.fetchFarmingAlerts(),
      detectionHistoryProvider.loadDetectionHistory(), // Add this line
    ]);
  }

  void _onAlertLongPress(BuildContext context, FarmingAlert alert) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        // We get the provider here within the builder, so it's scoped correctly
        final alertsProvider =
            Provider.of<FarmingAlertsProvider>(context, listen: false);
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                title: const Text('Mark as Read'),
                onTap: () {
                  Navigator.pop(context);
                  alertsProvider.markAlertAsRead(alert.id); // Dispatch action
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'snooze',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 24,
                ),
                title: const Text('Snooze'),
                onTap: () {
                  Navigator.pop(context);
                  alertsProvider.snoozeAlert(alert.id); // Dispatch action
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'share',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 24,
                ),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle share logic (might not involve a provider directly)
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToCamera(BuildContext context) {
    final navigationProvider = context.read<NavigationProvider>();
    navigationProvider.navigateToCamera();
  }

  @override
  Widget build(BuildContext context) {
    final farmingAlertsProvider = context.watch<FarmingAlertsProvider>();

    final List<FarmingAlert> farmingAlerts =
        farmingAlertsProvider.farmingAlerts;
    final bool alertsLoading = farmingAlertsProvider.isLoading;
    final String? alertsError = farmingAlertsProvider.errorMessage;
    // final int unreadAlertsCount = farmingAlertsProvider.unreadAlertsCount;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              _handleRefresh(context), // Pass context to refresh handler
          color: AppTheme.lightTheme.colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                title: Text(
                  'CropCare Vision',
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

                    // Display loading, error, or data for Detections
                    Consumer<DetectionHistoryProvider>(
                      builder: (context, historyProvider, child) {
                        final recentDetections =
                            historyProvider.getRecentDetections(limit: 3);

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
                                  'Use AI-powered detection to identify your crops and get farming insights',
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
                                        CropInfoMapper.getRawLabel(detection
                                            .cropName), // Use raw or fallback
                                    confidence: detection.confidence,
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

                    // Farming Alerts Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Farming Alerts',
                          style: GoogleFonts.poppins(
                            textStyle: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (farmingAlerts.length > 3)
                          GestureDetector(
                            onTap: () {
                              if (kDebugMode) {
                                print('View All Alerts pressed');
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.6.h),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                'View All (${farmingAlerts.length}) Alerts ',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Display loading, error, or data for Alerts
                    if (alertsLoading)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: CircularProgressIndicator(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      )
                    else if (alertsError != null)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Text(
                            'Error: $alertsError',
                            style: TextStyle(
                                color: AppTheme.lightTheme.colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if (farmingAlerts.isEmpty)
                      // Empty state for alerts
                      Container(
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
                              iconName: 'notifications',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 48,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No New Alerts',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'All clear! Check back later for important farming updates and reminders.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                textStyle:
                                    AppTheme.lightTheme.textTheme.bodyMedium,
                              ).copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          ],
                        ),
                      )
                    else
                      // Alerts List (take up to 3 for main dashboard, with view all option)
                      ...farmingAlerts.take(3).map((alert) => Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: FarmingAlertCardWidget(
                              alert: alert,
                              onLongPress: () => _onAlertLongPress(
                                  context, alert), // Pass context
                            ),
                          )),

                    SizedBox(height: 1.h), // Bottom padding for FAB
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
