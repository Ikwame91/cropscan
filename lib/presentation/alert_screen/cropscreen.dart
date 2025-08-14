import 'package:cropscan_pro/models/crop_detection_args.dart';
import 'package:cropscan_pro/models/crop_info.dart';
import 'package:cropscan_pro/presentation/alert_screen/widgets/crop_card.dart';
import 'package:cropscan_pro/providers/detection_history_provider.dart';
import 'package:cropscan_pro/models/crop_detection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cropscan_pro/core/app_export.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  String _selectedCropType = 'All Crops';
  String _searchQuery = '';
  bool _showHealthyOnly = false;
  bool _showUnhealthyOnly = false;

  @override
  void initState() {
    super.initState();
    // Load detection history when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetectionHistoryProvider>().loadDetectionHistory();
    });
  }

  // Get filtered crops based on selection criteria
  List<CropDetection> _getFilteredCrops(List<CropDetection> allDetections) {
    List<CropDetection> filtered = List.from(allDetections);

    // Filter by crop type
    if (_selectedCropType != 'All Crops') {
      filtered = filtered.where((detection) {
        return _getCropType(detection.cropName) == _selectedCropType;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((detection) {
        return detection.cropName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (detection.location
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Filter by health status
    if (_showHealthyOnly) {
      filtered = filtered.where((detection) {
        return detection.status.toLowerCase().contains('healthy');
      }).toList();
    } else if (_showUnhealthyOnly) {
      filtered = filtered.where((detection) {
        return !detection.status.toLowerCase().contains('healthy');
      }).toList();
    }

    return filtered;
  }

  // Get unique crop types from real data
  List<String> _getCropTypes(List<CropDetection> detections) {
    final types = detections
        .map((detection) => _getCropType(detection.cropName))
        .toSet()
        .toList();
    types.sort();
    return ['All Crops', ...types];
  }

  // Map crop names to types
  String _getCropType(String cropName) {
    final name = cropName.toLowerCase();
    if (name.contains('corn') || name.contains('maize')) return 'Maize';
    if (name.contains('tomato')) return 'Tomato';
    if (name.contains('pepper')) return 'Bell Pepper';
    if (name.contains('cassava')) return 'Cassava';
    return 'Other';
  }

  // Get crop statistics
  Map<String, int> _getCropStats(List<CropDetection> detections) {
    int healthy = 0;
    int needsAttention = 0;

    for (var detection in detections) {
      if (detection.status.toLowerCase().contains('healthy')) {
        healthy++;
      } else {
        needsAttention++;
      }
    }

    return {
      'healthy': healthy,
      'needsAttention': needsAttention,
    };
  }

  // Convert CropDetection to format expected by CropCard
  Map<String, dynamic> _convertToCardFormat(CropDetection detection) {
    final base = context.read<DetectionHistoryProvider>().toMap(detection);
    final isHealthy = detection.status.toLowerCase().contains('healthy');
    return {
      ...base,
      'health': (detection.confidence * 100).round(),
      'harvestInDays': _calculateHarvestDays(detection.cropName, isHealthy),
      'issues': _getIssueCount(detection.status),
      'expectedYield': _calculateExpectedYield(detection.cropName, isHealthy),
      'scannedAgo': _formatTimeAgo(detection.detectedAt),
    };
  }

  // Calculate estimated harvest days based on crop type and health
  int _calculateHarvestDays(String cropName, bool isHealthy) {
    final detection = context
        .read<DetectionHistoryProvider>()
        .getFilteredHistory(cropFilter: cropName)
        .firstOrNull;
    final baseDays = detection
                ?.enhancedCropInfo?.maintenance?.watering?.criticalStages
                ?.contains('fruiting') ??
            false
        ? 70
        : 90;
    return isHealthy ? baseDays : baseDays + 15;
  }

  // Get issue count based on status
  int _getIssueCount(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('disease')) return 2;
    if (statusLower.contains('pest')) return 1;
    if (statusLower.contains('virus')) return 3;
    return 0;
  }

  // Calculate expected yield based on crop and health
  double _calculateExpectedYield(String cropName, bool isHealthy) {
    final name = cropName.toLowerCase();
    double baseYield = 2.0;

    if (name.contains('tomato'))
      baseYield = 30.0;
    else if (name.contains('pepper'))
      baseYield = 15.0;
    else if (name.contains('corn') || name.contains('maize')) baseYield = 5.0;

    // Reduce yield for unhealthy crops
    return isHealthy ? baseYield : baseYield * 0.7;
  }

  // Format time ago
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<DetectionHistoryProvider>(
          builder: (context, historyProvider, child) {
            final allDetections = historyProvider.detectionHistory;
            final filteredDetections = _getFilteredCrops(allDetections);
            final cropTypes = _getCropTypes(allDetections);
            final stats = _getCropStats(filteredDetections);

            if (historyProvider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Loading your crops...',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Header Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Crops',
                            style: GoogleFonts.poppins(
                              textStyle: AppTheme
                                  .lightTheme.textTheme.headlineMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              // Refresh Button
                              GestureDetector(
                                onTap: () {
                                  historyProvider.loadDetectionHistory();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.lightTheme.colorScheme.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.lightTheme.dividerColor,
                                    ),
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'refresh',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                    size: 20,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              // Add New Crop Button
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // Statistics
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            '${stats['healthy']}',
                            'Healthy Crops',
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                          _buildStatItem(
                            '${stats['needsAttention']}',
                            'Need Attention',
                            color: AppTheme.lightTheme.colorScheme.error,
                          ),
                          _buildStatItem(
                            '${allDetections.length}',
                            'Total Scanned',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // Search Bar
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search crops or locations...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppTheme.lightTheme.dividerColor),
                          ),
                          filled: true,
                          fillColor: AppTheme.lightTheme.colorScheme.surface,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      // Filter Buttons
                      Row(
                        children: [
                          _buildFilterChip(
                            'Healthy Only',
                            _showHealthyOnly,
                            () {
                              setState(() {
                                _showHealthyOnly = !_showHealthyOnly;
                                if (_showHealthyOnly)
                                  _showUnhealthyOnly = false;
                              });
                            },
                            Colors.green,
                          ),
                          SizedBox(width: 2.w),
                          _buildFilterChip(
                            'Issues Only',
                            _showUnhealthyOnly,
                            () {
                              setState(() {
                                _showUnhealthyOnly = !_showUnhealthyOnly;
                                if (_showUnhealthyOnly)
                                  _showHealthyOnly = false;
                              });
                            },
                            Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Horizontal filter tabs for crop types
                Container(
                  height: 6.h,
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: cropTypes.length,
                    separatorBuilder: (context, index) => SizedBox(width: 2.w),
                    itemBuilder: (context, index) {
                      final cropType = cropTypes[index];
                      final isSelected = _selectedCropType == cropType;
                      return ChoiceChip(
                        label: Text(
                          cropType,
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.lightTheme.colorScheme.primary,
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.dividerColor,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCropType = cropType;
                            });
                          }
                        },
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                      );
                    },
                  ),
                ),

                SizedBox(height: 2.h),

                // List of Crop Cards
                Expanded(
                  child: _buildCropsList(filteredDetections),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCropsList(List<CropDetection> detections) {
    if (detections.isEmpty) {
      return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  kBottomNavigationBarHeight,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: "eco",
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 60,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No crops match your search'
                        : 'No crops scanned yet',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Try adjusting your search or filters'
                        : 'Start scanning crops to build your crop management dashboard',
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<DetectionHistoryProvider>().loadDetectionHistory();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: detections.length,
        itemBuilder: (context, index) {
          final detection = detections[index];
          final cropData = _convertToCardFormat(detection);

          return Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: CropCard(
              crop: cropData,
              onTap: () => _navigateToDetectionResults(context, detection),
              onAction: () => _showCropActions(context, detection),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            textStyle: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            textStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterChip(
      String label, bool isSelected, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppTheme.lightTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: isSelected
                ? color
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _navigateToDetectionResults(
      BuildContext context, CropDetection detection) {
    final args = CropDetectionResultsArgs(
      imagePath: detection.imageUrl,
      detectedCrop: detection.rawDetectedCrop ?? detection.cropName,
      confidence: detection.confidence,
      cropInfo: CropInfoMapper.getCropInfo(detection.cropName),
      enhancedCropInfo: detection.enhancedCropInfo,
      isFromHistory: true,
    );

    Navigator.pushNamed(
      context,
      '/crop-detection-results',
      arguments: args,
    );
  }

  void _showCropActions(BuildContext context, CropDetection detection) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility),
              title: Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _navigateToDetectionResults(context, detection);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Re-scan Crop'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/crop-scanner-camera');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Record', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteCrop(context, detection);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCrop(BuildContext context, CropDetection detection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Crop Record'),
        content: Text(
            'Are you sure you want to delete this crop detection record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<DetectionHistoryProvider>()
                  .deleteDetection(detection.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Crop record deleted')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
