import 'package:cropscan_pro/models/crop_detection.dart';
import 'package:cropscan_pro/models/crop_detection_args.dart';
import 'package:cropscan_pro/models/farming_alert.dart';
import 'package:cropscan_pro/presentation/crop_scanner_camera/widgets/crop_info.dart';
import 'package:cropscan_pro/providers/farming_alerts_provider.dart';
import 'package:cropscan_pro/providers/naviagtion_provider.dart';
import 'package:cropscan_pro/providers/recent_detection_providers.dart';
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
    final recentDetectionsProvider =
        Provider.of<RecentDetectionsProvider>(context, listen: false);
    final farmingAlertsProvider =
        Provider.of<FarmingAlertsProvider>(context, listen: false);

    // Trigger data fetching for both providers
    await Future.wait([
      recentDetectionsProvider.fetchRecentDetections(),
      farmingAlertsProvider.fetchFarmingAlerts(),
    ]);
  }

  void _onDetectionCardTap(BuildContext context, CropDetection detection) {
    // Create the proper arguments object
    final args = CropDetectionResultsArgs(
      imagePath: detection.imageUrl,
      detectedCrop: detection.cropName,
      confidence: detection.confidence,
      cropInfo: CropInfoMapper.getCropInfo(detection.cropName),
    );

    Navigator.pushNamed(
      context,
      '/crop-detection-results',
      arguments: args,
    );
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
    final recentDetectionsProvider = context.watch<RecentDetectionsProvider>();
    final farmingAlertsProvider = context.watch<FarmingAlertsProvider>();

    final List<CropDetection> recentDetections =
        recentDetectionsProvider.recentDetections;
    final bool detectionsLoading = recentDetectionsProvider.isLoading;
    final String? detectionsError = recentDetectionsProvider.errorMessage;

    final List<FarmingAlert> farmingAlerts =
        farmingAlertsProvider.farmingAlerts;
    final bool alertsLoading = farmingAlertsProvider.isLoading;
    final String? alertsError = farmingAlertsProvider.errorMessage;
    final int unreadAlertsCount = farmingAlertsProvider.unreadAlertsCount;

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
                  'CropScan ',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                    if (detectionsLoading)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: CircularProgressIndicator(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      )
                    else if (detectionsError != null)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Text(
                            'Error: $detectionsError',
                            style: TextStyle(
                                color: AppTheme.lightTheme.colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if (recentDetections.isEmpty)
                      // Empty state for detections
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
                              iconName: 'camera_alt',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 48,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Scan Your First Crop',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Use AI-powered detection to identify your crops and get farming insights',
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
                      SizedBox(
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
                              onTap: () =>
                                  _onDetectionCardTap(context, detection),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 3.h),

                    // Farming Alerts Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Farming Alerts',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            '$unreadAlertsCount', // Display unread count from provider
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
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

                    if (farmingAlerts.length > 3)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (kDebugMode) {
                              print('View All Alerts pressed');
                            }
                          },
                          child:
                              Text('View All Alerts (${farmingAlerts.length})'),
                        ),
                      ),

                    SizedBox(height: 10.h), // Bottom padding for FAB
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
