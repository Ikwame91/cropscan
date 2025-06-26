import 'package:flutter/material.dart';
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
  bool _isLoading = false;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  String? _selectedCropFilter;
  double _confidenceThreshold = 0.0;
  final List<int> _selectedCards = [];

  late TabController _tabController;

  // Mock data for detection history
  final List<Map<String, dynamic>> _detectionHistory = [
    {
      "id": 1,
      "cropName": "Bell Pepper",
      "cropType": "Vegetable",
      "imageUrl":
          "https://images.pexels.com/photos/594137/pexels-photo-594137.jpeg?auto=compress&cs=tinysrgb&w=800",
      "confidence": 0.92,
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "location": "Field A - North Section",
      "weatherCondition": "Sunny, 28°C",
      "notes": "Healthy growth, ready for harvest in 2 weeks",
      "diseaseDetected": false,
      "pestDetected": false,
    },
    {
      "id": 2,
      "cropName": "Tomato",
      "cropType": "Fruit",
      "imageUrl":
          "https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg?auto=compress&cs=tinysrgb&w=800",
      "confidence": 0.87,
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
      "location": "Greenhouse B",
      "weatherCondition": "Cloudy, 24°C",
      "notes": "Some yellowing leaves detected, check irrigation",
      "diseaseDetected": true,
      "pestDetected": false,
    },
    {
      "id": 3,
      "cropName": "Maize",
      "cropType": "Grain",
      "imageUrl":
          "https://images.pexels.com/photos/547263/pexels-photo-547263.jpeg?auto=compress&cs=tinysrgb&w=800",
      "confidence": 0.95,
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
      "location": "Field C - East Section",
      "weatherCondition": "Partly Cloudy, 26°C",
      "notes": "Excellent growth, pest control recommended",
      "diseaseDetected": false,
      "pestDetected": true,
    },
    {
      "id": 4,
      "cropName": "Bell Pepper",
      "cropType": "Vegetable",
      "imageUrl":
          "https://images.pexels.com/photos/1327838/pexels-photo-1327838.jpeg?auto=compress&cs=tinysrgb&w=800",
      "confidence": 0.89,
      "timestamp": DateTime.now().subtract(Duration(days: 2)),
      "location": "Field A - South Section",
      "weatherCondition": "Rainy, 22°C",
      "notes": "Good condition, monitor for fungal issues",
      "diseaseDetected": false,
      "pestDetected": false,
    },
    {
      "id": 5,
      "cropName": "Tomato",
      "cropType": "Fruit",
      "imageUrl":
          "https://images.pexels.com/photos/1327838/pexels-photo-1327838.jpeg?auto=compress&cs=tinysrgb&w=800",
      "confidence": 0.91,
      "timestamp": DateTime.now().subtract(Duration(days: 3)),
      "location": "Greenhouse A",
      "weatherCondition": "Sunny, 27°C",
      "notes": "Optimal growth conditions, harvest in 1 week",
      "diseaseDetected": false,
      "pestDetected": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDetectionHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadDetectionHistory() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  List<Map<String, dynamic>> get _filteredHistory {
    List<Map<String, dynamic>> filtered = List.from(_detectionHistory);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final cropName = (item['cropName'] as String).toLowerCase();
        final location = (item['location'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return cropName.contains(query) || location.contains(query);
      }).toList();
    }

    // Apply crop type filter
    if (_selectedCropFilter != null && _selectedCropFilter!.isNotEmpty) {
      filtered = filtered
          .where((item) => item['cropType'] == _selectedCropFilter)
          .toList();
    }

    // Apply confidence threshold filter
    filtered = filtered
        .where((item) => (item['confidence'] as double) >= _confidenceThreshold)
        .toList();

    // Apply date range filter
    if (_selectedDateRange != null) {
      filtered = filtered.where((item) {
        final timestamp = item['timestamp'] as DateTime;
        return timestamp.isAfter(_selectedDateRange!.start) &&
            timestamp.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedCards.clear();
      }
    });
  }

  void _toggleCardSelection(int cardId) {
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
            onPressed: () {
              setState(() {
                _detectionHistory
                    .removeWhere((item) => _selectedCards.contains(item['id']));
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

  @override
  Widget build(BuildContext context) {
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
                    _loadDetectionHistory();
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
            totalScans: _detectionHistory.length,
            mostIdentifiedCrop: 'Bell Pepper',
            averageConfidence: 0.91,
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
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
                    detectionHistory: filteredHistory,
                  )
                : _buildListView(filteredHistory),
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
                  backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
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
  }

  Widget _buildListView(List<Map<String, dynamic>> filteredHistory) {
    if (_isLoading) {
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
              _detectionHistory.isEmpty
                  ? 'No Detection History'
                  : 'No Results Found',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _detectionHistory.isEmpty
                  ? 'Start scanning crops to build your detection history'
                  : 'Try adjusting your search or filter criteria',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (_detectionHistory.isEmpty) ...[
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/crop-scanner-camera');
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
        _loadDetectionHistory();
      },
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(4.w),
        itemCount: filteredHistory.length,
        itemBuilder: (context, index) {
          final detection = filteredHistory[index];
          final isSelected = _selectedCards.contains(detection['id']);

          return DetectionCardWidget(
            detection: detection,
            isSelectionMode: _isSelectionMode,
            isSelected: isSelected,
            onTap: () {
              if (_isSelectionMode) {
                _toggleCardSelection(detection['id']);
              } else {
                Navigator.pushNamed(
                  context,
                  '/crop-detection-results',
                  arguments: detection,
                );
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelectionMode();
                _toggleCardSelection(detection['id']);
              }
            },
            onReidentify: () {
              Navigator.pushNamed(
                context,
                '/crop-scanner-camera',
                arguments: {'reidentify': true, 'detection': detection},
              );
            },
            onShare: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Sharing ${detection['cropName']} detection...'),
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
                      onPressed: () {
                        setState(() {
                          _detectionHistory.removeWhere(
                              (item) => item['id'] == detection['id']);
                        });
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
}
