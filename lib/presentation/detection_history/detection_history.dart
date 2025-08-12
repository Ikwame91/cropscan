// ignore_for_file: use_build_context_synchronously

import 'package:cropscan_pro/models/crop_detection.dart';
import 'package:cropscan_pro/providers/detection_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calendar_view_widget.dart';
import './widgets/detection_card_widget.dart';
import './widgets/filter_options_widget.dart';
import './widgets/statistics_summary_widget.dart';

class DetectionHistory extends StatefulWidget {
  const DetectionHistory({super.key});

  @override
  State<DetectionHistory> createState() => _DetectionHistoryState();
}

class _DetectionHistoryState extends State<DetectionHistory>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isCalendarView = false;
  bool _isSelectionMode = false;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  String? _selectedCropFilter;
  double _confidenceThreshold = 0.0;
  final List<String> _selectedCards = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _refreshHistory() {
    context.read<DetectionHistoryProvider>().loadDetectionHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<CropDetection> get _filteredHistory {
    final provider = context.watch<DetectionHistoryProvider>();

    return provider.getFilteredHistory(
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      cropFilter: _selectedCropFilter,
      confidenceThreshold: _confidenceThreshold,
      dateRange: _selectedDateRange,
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedCards.clear();
      }
    });
  }

  void _toggleCardSelection(String cardId) {
    setState(() {
      if (_selectedCards.contains(cardId)) {
        _selectedCards.remove(cardId);
      } else {
        _selectedCards.add(cardId);
      }
    });
  }

  void _deleteSelectedCards() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Selected'),
        content: Text(
            'Are you sure you want to delete ${_selectedCards.length} detection records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<DetectionHistoryProvider>();
              await provider.deleteMultipleDetections(_selectedCards);

              if (!mounted) return;

              setState(() {
                _selectedCards.clear();
                _isSelectionMode = false;
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected records deleted')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting detection history to CSV...')),
    );
  }

  void _shareMultiple() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Sharing ${_selectedCards.length} detection records...')),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All History'),
        content: Text(
            'Are you sure you want to delete all detection records? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<DetectionHistoryProvider>().clearAllHistory();
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('All detection history cleared')),
              );
            },
            child: Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetectionHistoryProvider>(
      builder: (context, provider, child) {
        final filteredHistory = _filteredHistory;

        return Scaffold(
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
            elevation: 2,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
            title: Text(
              _isSelectionMode
                  ? '${_selectedCards.length} Selected'
                  : 'Detection History',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              if (!_isSelectionMode) ...[
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isCalendarView = !_isCalendarView;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: _isCalendarView ? 'list' : 'calendar_today',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: CustomIconWidget(
                    iconName: 'more_vert',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'export':
                        _exportData();
                        break;
                      case 'refresh':
                        _refreshHistory();
                        break;
                      case 'clear_all':
                        _showClearAllDialog();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'download',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text('Export Data'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'refresh',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'refresh',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text('Refresh'),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                IconButton(
                  onPressed: _toggleSelectionMode,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
              ],
            ],
          ),
          body: Column(
            children: [
              // Statistics Summary
              StatisticsSummaryWidget(
                totalScans: provider.totalScans,
                mostIdentifiedCrop: provider.mostIdentifiedCrop,
                averageConfidence: provider.averageConfidence,
              ),

              // Search and Filter Section
              Container(
                padding: EdgeInsets.all(4.w),
                color: AppTheme.lightTheme.colorScheme.surface,
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by crop name or location...',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'search',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                icon: CustomIconWidget(
                                  iconName: 'clear',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Filter Options
                    FilterOptionsWidget(
                      selectedDateRange: _selectedDateRange,
                      selectedCropFilter: _selectedCropFilter,
                      confidenceThreshold: _confidenceThreshold,
                      onDateRangeChanged: (range) {
                        setState(() {
                          _selectedDateRange = range;
                        });
                      },
                      onCropFilterChanged: (filter) {
                        setState(() {
                          _selectedCropFilter = filter;
                        });
                      },
                      onConfidenceChanged: (threshold) {
                        setState(() {
                          _confidenceThreshold = threshold;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: _isCalendarView
                    ? CalendarViewWidget(
                        detectionHistory: filteredHistory
                            .map((detection) => {
                                  'id': detection.id,
                                  'cropName': detection.cropName,
                                  'cropType': _getCropType(detection.cropName),
                                  'imageUrl': detection.imageUrl,
                                  'confidence': detection.confidence,
                                  'timestamp': detection.detectedAt,
                                  'status': detection.status,
                                })
                            .toList(),
                      )
                    : _buildListView(filteredHistory, provider),
              ),
            ],
          ),

          // Floating Action Menu for Selection Mode
          floatingActionButton: _isSelectionMode && _selectedCards.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: "delete",
                      onPressed: _deleteSelectedCards,
                      backgroundColor: AppTheme.lightTheme.colorScheme.error,
                      child: CustomIconWidget(
                        iconName: 'delete',
                        color: AppTheme.lightTheme.colorScheme.onError,
                        size: 24,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    FloatingActionButton(
                      heroTag: "share",
                      onPressed: _shareMultiple,
                      backgroundColor:
                          AppTheme.lightTheme.colorScheme.secondary,
                      child: CustomIconWidget(
                        iconName: 'share',
                        color: AppTheme.lightTheme.colorScheme.onSecondary,
                        size: 24,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    FloatingActionButton(
                      heroTag: "export",
                      onPressed: _exportData,
                      backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
                      child: CustomIconWidget(
                        iconName: 'download',
                        color: AppTheme.lightTheme.colorScheme.onTertiary,
                        size: 24,
                      ),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildListView(
      List<CropDetection> filteredHistory, DetectionHistoryProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Loading detection history...',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'history',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              provider.detectionHistory.isEmpty
                  ? 'No Detection History'
                  : 'No Results Found',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              provider.detectionHistory.isEmpty
                  ? 'Start scanning crops to build your detection history'
                  : 'Try adjusting your search or filter criteria',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (provider.detectionHistory.isEmpty) ...[
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                icon: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 20,
                ),
                label: Text('Start Scanning'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshHistory();
      },
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(4.w),
        itemCount: filteredHistory.length,
        itemBuilder: (context, index) {
          final detection = filteredHistory[index];
          final isSelected = _selectedCards.contains(detection.id);

          // Convert CropDetection to Map for widget compatibility
          final detectionMap = {
            'id': detection.id,
            'cropName': detection.cropName,
            'cropType': _getCropType(detection.cropName),
            'imageUrl': detection.imageUrl,
            'confidence': detection.confidence,
            'timestamp': detection.detectedAt,
            'status': detection.status,
            'location': 'Farm Location',
            'diseaseDetected':
                detection.status.toLowerCase().contains('disease'),
            'pestDetected': detection.status.toLowerCase().contains('pest'),
          };

          return DetectionCardWidget(
            detection: detectionMap,
            isSelectionMode: _isSelectionMode,
            isSelected: isSelected,
            onTap: () {
              if (_isSelectionMode) {
                _toggleCardSelection(detection.id);
              } else {
                // Navigate to results with saved detection
                Navigator.pushNamed(
                  context,
                  '/crop-detection-results',
                  arguments: {
                    'imagePath': detection.imageUrl,
                    'detectedCrop': detection.cropName,
                    'confidence': detection.confidence,
                    'isFromHistory': true,
                  },
                );
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelectionMode();
                _toggleCardSelection(detection.id);
              }
            },
            onReidentify: () {
              Navigator.pushNamed(
                context,
                '/',
                arguments: {
                  'reidentify': true,
                  'imagePath': detection.imageUrl
                },
              );
            },
            onShare: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing ${detection.cropName} detection...'),
                ),
              );
            },
            onDelete: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Detection'),
                  content: Text(
                      'Are you sure you want to delete this detection record?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await provider.deleteDetection(detection.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Detection record deleted')),
                        );
                      },
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getCropType(String cropName) {
    // Simple mapping - you can expand this
    if (cropName.toLowerCase().contains('tomato')) return 'Fruit';
    if (cropName.toLowerCase().contains('pepper')) return 'Vegetable';
    if (cropName.toLowerCase().contains('corn') ||
        cropName.toLowerCase().contains('maize')) {
      return 'Grain';
    }
    return 'Crop';
  }
}
