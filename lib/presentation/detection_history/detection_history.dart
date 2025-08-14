// ignore_for_file: use_build_context_synchronously

import 'package:cropscan_pro/models/crop_detection.dart';
import 'package:cropscan_pro/models/crop_detection_args.dart';
import 'package:cropscan_pro/models/crop_info.dart';
import 'package:cropscan_pro/presentation/detection_history/widgets/enhanced_detection.dart';
import 'package:cropscan_pro/presentation/detection_history/widgets/filter_options_widget.dart';
import 'package:cropscan_pro/presentation/detection_history/widgets/statistics_summary_widget.dart';
import 'package:cropscan_pro/providers/detection_history_provider.dart';
import 'package:cropscan_pro/theme/app_theme.dart';
import 'package:cropscan_pro/widgets/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class DetectionHistory extends StatefulWidget {
  const DetectionHistory({super.key});

  @override
  State<DetectionHistory> createState() => _DetectionHistoryState();
}

class _DetectionHistoryState extends State<DetectionHistory>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // View States
  String _viewMode = 'grid'; // 'grid', 'list', 'timeline'
  bool _isSelectionMode = false;
  String _searchQuery = '';
  String _sortBy = 'newest'; // 'newest', 'oldest', 'confidence', 'alphabetical'
  String _filterBy =
      'all'; // 'all', 'healthy', 'diseased', 'this_week', 'this_month'
  final Set<String> _selectedItems = {};

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetectionHistoryProvider>().loadDetectionHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<CropDetection> get _filteredAndSortedHistory {
    final provider = context.watch<DetectionHistoryProvider>();
    List<CropDetection> filtered = List.from(provider.detectionHistory);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((detection) {
        return detection.cropName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (detection.location
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            detection.status.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    switch (_filterBy) {
      case 'healthy':
        filtered = filtered
            .where((d) => d.status.toLowerCase().contains('healthy'))
            .toList();
        break;
      case 'diseased':
        filtered = filtered
            .where((d) => !d.status.toLowerCase().contains('healthy'))
            .toList();
        break;
      case 'this_week':
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        filtered =
            filtered.where((d) => d.detectedAt.isAfter(weekAgo)).toList();
        break;
      case 'this_month':
        final monthAgo = DateTime.now().subtract(const Duration(days: 30));
        filtered =
            filtered.where((d) => d.detectedAt.isAfter(monthAgo)).toList();
        break;
    }

    // Apply sorting
    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.detectedAt.compareTo(b.detectedAt));
        break;
      case 'confidence':
        filtered.sort((a, b) => b.confidence.compareTo(a.confidence));
        break;
      case 'alphabetical':
        filtered.sort((a, b) => a.cropName.compareTo(b.cropName));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetectionHistoryProvider>(
      builder: (context, provider, child) {
        final filteredHistory = _filteredAndSortedHistory;

        return Scaffold(
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Enhanced App Bar
                _buildSliverAppBar(provider),

                // Statistics Overview
                SliverToBoxAdapter(
                  child: StatisticsOverviewWidget(
                    totalScans: provider.totalScans,
                    healthyCount: provider.detectionHistory
                        .where(
                            (d) => d.status.toLowerCase().contains('healthy'))
                        .length,
                    diseasedCount: provider.detectionHistory
                        .where(
                            (d) => !d.status.toLowerCase().contains('healthy'))
                        .length,
                    averageConfidence: provider.averageConfidence,
                    mostCommonCrop: provider.mostIdentifiedCrop,
                  ),
                ),

                // Search and Filters
                SliverToBoxAdapter(
                  child: _buildSearchAndFilters(),
                ),

                // Content
                if (provider.isLoading)
                  _buildLoadingSliver()
                else if (filteredHistory.isEmpty)
                  _buildEmptyStateSliver(provider.detectionHistory.isEmpty)
                else
                  _buildContentSliver(filteredHistory),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(DetectionHistoryProvider provider) {
    return SliverAppBar(
      expandedHeight: 12.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      title: _isSelectionMode
          ? Text(
              '${_selectedItems.length} selected',
              style: GoogleFonts.poppins(
                textStyle: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      actions: [
        if (!_isSelectionMode) ...[
          // View Mode Toggle
          IconButton(
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == 'grid' ? 'list' : 'grid';
              });
            },
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: _viewMode == 'grid' ? 'view_list' : 'grid_view',
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // More Options
          PopupMenuButton<String>(
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'more_vert',
                color: Colors.white,
                size: 20,
              ),
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'select_all',
                child: _buildMenuItem(
                    'select_all', 'Select All', Icons.select_all),
              ),
              PopupMenuItem(
                value: 'export',
                child: _buildMenuItem('export', 'Export Data', Icons.download),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: _buildMenuItem('refresh', 'Refresh', Icons.refresh),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'clear_all',
                child: _buildMenuItem(
                    'clear_all', 'Clear All', Icons.delete_sweep,
                    color: Colors.red),
              ),
            ],
          ),
        ] else ...[
          // Selection Mode Actions
          IconButton(
            onPressed: () => _deleteSelected(),
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete, color: Colors.white, size: 20),
            ),
          ),
          IconButton(
            onPressed: () => _shareSelected(),
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.share, color: Colors.white, size: 20),
            ),
          ),
          IconButton(
            onPressed: () => _exitSelectionMode(),
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: !_isSelectionMode
            ? Text(
                'Detection History',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16.sp,
                  textStyle: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              )
            : null,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.lightTheme.colorScheme.primary,
                AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String value, String title, IconData icon,
      {Color? color}) {
    return Row(
      children: [
        Icon(icon,
            color: color ?? AppTheme.lightTheme.colorScheme.onSurface,
            size: 20),
        SizedBox(width: 3.w),
        Text(title, style: TextStyle(color: color)),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search crops, locations, or conditions...',
                hintStyle: GoogleFonts.poppins(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
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
                          setState(() => _searchQuery = '');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Filter Chips
          ModernFilterWidget(
            currentSortBy: _sortBy,
            currentFilterBy: _filterBy,
            onSortChanged: (sort) => setState(() => _sortBy = sort),
            onFilterChanged: (filter) => setState(() => _filterBy = filter),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSliver() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
              strokeWidth: 3,
            ),
            SizedBox(height: 2.h),
            Text(
              'Loading your crop history...',
              style: GoogleFonts.poppins(
                textStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateSliver(bool isCompletelyEmpty) {
    return SliverFillRemaining(
      child: Center(
        child: Container(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer
                      .withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: isCompletelyEmpty ? 'eco' : 'search_off',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 64,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                isCompletelyEmpty ? 'No Scans Yet' : 'No Results Found',
                style: GoogleFonts.poppins(
                  textStyle:
                      AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
                isCompletelyEmpty
                    ? 'Start scanning crops to build your\ndetection history and track progress'
                    : 'Try adjusting your search terms\nor filter options',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  textStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              if (isCompletelyEmpty) ...[
                SizedBox(height: 4.h),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/crop-scanner-camera'),
                  icon: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: Text(
                    'Start Scanning',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(height: 3.h),
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _filterBy = 'all';
                      _sortBy = 'newest';
                    });
                  },
                  icon: Icon(Icons.clear_all),
                  label: Text('Clear Filters'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSliver(List<CropDetection> filteredHistory) {
    if (_viewMode == 'grid') {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 3.w,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final detection = filteredHistory[index];
              return EnhancedDetectionCardWidget(
                detection: detection,
                isSelected: _selectedItems.contains(detection.id),
                isSelectionMode: _isSelectionMode,
                viewMode: 'grid',
                onTap: () => _handleCardTap(detection),
                onLongPress: () => _handleCardLongPress(detection),
              );
            },
            childCount: filteredHistory.length,
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final detection = filteredHistory[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: EnhancedDetectionCardWidget(
                  detection: detection,
                  isSelected: _selectedItems.contains(detection.id),
                  isSelectionMode: _isSelectionMode,
                  viewMode: 'list',
                  onTap: () => _handleCardTap(detection),
                  onLongPress: () => _handleCardLongPress(detection),
                ),
              );
            },
            childCount: filteredHistory.length,
          ),
        ),
      );
    }
  }

  // Event Handlers
  void _handleCardTap(CropDetection detection) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedItems.contains(detection.id)) {
          _selectedItems.remove(detection.id);
        } else {
          _selectedItems.add(detection.id);
        }
      });
    } else {
      _navigateToDetectionResults(detection);
    }
  }

  void _handleCardLongPress(CropDetection detection) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedItems.add(detection.id);
      });
    }
  }

  void _navigateToDetectionResults(CropDetection detection) {
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'select_all':
        setState(() {
          _isSelectionMode = true;
          _selectedItems.addAll(_filteredAndSortedHistory.map((d) => d.id));
        });
        break;
      case 'export':
        _exportData();
        break;
      case 'refresh':
        context.read<DetectionHistoryProvider>().loadDetectionHistory();
        break;
      case 'clear_all':
        _showClearAllDialog();
        break;
    }
  }

  void _deleteSelected() {
    if (_selectedItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Selected Items'),
        content: Text(
            'Are you sure you want to delete ${_selectedItems.length} detection records? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context
                  .read<DetectionHistoryProvider>()
                  .deleteMultipleDetections(_selectedItems.toList());
              _exitSelectionMode();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_selectedItems.length} items deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _shareSelected() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Sharing ${_selectedItems.length} detection records...')),
    );
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting detection history...')),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear All History'),
        content: Text(
            'Are you sure you want to delete all detection records? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<DetectionHistoryProvider>().clearAllHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All detection history cleared'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
