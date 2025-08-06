import 'package:cropscan_pro/presentation/crop_scanner_camera/widgets/crop_info.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/crop_image_widget.dart';

import './widgets/detection_result_card_widget.dart';

class CropDetectionResults extends StatefulWidget {
  final String imagePath;
  final String detectedCrop;
  final double confidence;
  final CropInfo cropInfo;

  const CropDetectionResults(
      {super.key,
      required this.imagePath,
      required this.detectedCrop,
      required this.cropInfo,
      required this.confidence});

  @override
  State<CropDetectionResults> createState() => _CropDetectionResultsState();
}

class _CropDetectionResultsState extends State<CropDetectionResults> {
  bool _isImageZoomed = false;

  @override
  void initState() {
    super.initState();
    // You can put any initial setup here, but the args are already available via widget.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 24,
          ),
        ),
        title: Text(
          widget.cropInfo.displayName, // ← USE CLEAN DISPLAY NAME
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: () => _showImageOptions(context),
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crop Image Section
              CropImageWidget(
                imageUrl: widget.imagePath,
                isFromFile: true,
                onImageTap: () => _toggleImageZoom(),
                onLongPress: () => _showImageContextMenu(context),
              ),

              SizedBox(height: 2.h),

              // Detection Result Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: DetectionResultCardWidget(
                  cropName: widget.cropInfo.displayName, // ← USE PROCESSED NAME
                  confidence: widget.confidence,
                  timestamp: DateTime.now(),
                  statusColor:
                      widget.cropInfo.statusColor, // ← ADD STATUS COLOR
                  condition: widget.cropInfo.condition, // ← ADD CONDITION
                ),
              ),
              SizedBox(height: 3.h),

              // Crop Information Section
              // CropInfoSectionWidget(
              //   cropInfo: cropInfo,
              // ),
              SizedBox(height: 3.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _buildCropInfoSection(),
              ),
              SizedBox(height: 3.h),
              // Action Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ActionButtonsWidget(
                  onSaveToFavorites: () => _saveToFavorites(),
                  onShareResults: () => _shareResults(context),
                  onScanAnother: () => _scanAnother(context),
                ),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'Crop Analysis',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),

        // Crop Type Card
        _buildInfoCard(
          title: 'Crop Type',
          content: widget.cropInfo.cropType,
          icon: 'eco',
          color: AppTheme.lightTheme.colorScheme.primary,
        ),

        SizedBox(height: 1.5.h),

        // Health Status Card
        _buildInfoCard(
          title: 'Health Status',
          content: widget.cropInfo.condition,
          icon: _getConditionIcon(widget.cropInfo.condition),
          color: widget.cropInfo.statusColor,
        ),

        SizedBox(height: 1.5.h),

        // Confidence Card
        _buildInfoCard(
          title: 'Detection Confidence',
          content: '${(widget.confidence * 100).toStringAsFixed(1)}%',
          icon: 'analytics',
          color: _getConfidenceColor(widget.confidence),
        ),

        SizedBox(height: 2.h),

        // Description Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Description',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                widget.cropInfo.description,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Recommended Action Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: widget.cropInfo.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.cropInfo.statusColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'lightbulb',
                    color: widget.cropInfo.statusColor,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Recommended Action',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.cropInfo.statusColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                widget.cropInfo.recommendedAction,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required String icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  content,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getConditionIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'healthy':
        return 'check_circle';
      case 'disease detected':
        return 'warning';
      case 'pest detected':
        return 'bug_report';
      case 'virus detected':
        return 'coronavirus';
      default:
        return 'help';
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _toggleImageZoom() {
    setState(() {
      _isImageZoomed = !_isImageZoomed;
    });
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.bottomSheetTheme.backgroundColor,
      shape: AppTheme.lightTheme.bottomSheetTheme.shape,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'save_alt',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Save to Gallery',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _saveToGallery();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'wallpaper',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Set as Wallpaper',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _setAsWallpaper();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'copy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Copy Image',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _copyImage();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showImageContextMenu(BuildContext context) {
    _showImageOptions(context);
  }

  void _saveToFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved to favorites successfully!',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
      ),
    );
  }

  void _shareResults(BuildContext context) {
    // Mock share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sharing detection results...',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
      ),
    );
  }

  void _scanAnother(BuildContext context) {
    Navigator.pop(context);
  }

  void _saveToGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Image saved to gallery',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
      ),
    );
  }

  void _setAsWallpaper() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Setting as wallpaper...',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
      ),
    );
  }

  void _copyImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Image copied to clipboard',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
      ),
    );
  }
}

class CropDetectionResultsArgs {
  final String imagePath;
  final String detectedCrop;
  final double confidence;
  final CropInfo cropInfo;

  CropDetectionResultsArgs({
    required this.imagePath,
    required this.detectedCrop,
    required this.confidence,
    required this.cropInfo,
  });
}
