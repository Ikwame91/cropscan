import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/crop_image_widget.dart';
import './widgets/crop_info_section_widget.dart';
import './widgets/detection_result_card_widget.dart';

class CropDetectionResults extends StatefulWidget {
  const CropDetectionResults({super.key});

  @override
  State<CropDetectionResults> createState() => _CropDetectionResultsState();
}

class _CropDetectionResultsState extends State<CropDetectionResults> {
  // Mock detection result data
  final Map<String, dynamic> detectionResult = {
    "cropName": "Bell Pepper",
    "confidence": 87.5,
    "timestamp": DateTime.now().subtract(Duration(minutes: 2)),
    "imageUrl":
        "https://images.pexels.com/photos/594137/pexels-photo-594137.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "cropInfo": {
      "scientificName": "Capsicum annuum",
      "family": "Solanaceae",
      "growingTips": [
        "Plant in well-draining soil with pH 6.0-6.8",
        "Provide 6-8 hours of direct sunlight daily",
        "Water consistently but avoid waterlogging",
        "Space plants 18-24 inches apart",
        "Support with stakes as plants grow"
      ],
      "seasonalRecommendations": [
        "Spring: Start seeds indoors 8-10 weeks before last frost",
        "Summer: Transplant outdoors after soil warms to 60°F",
        "Fall: Harvest before first frost, around 70-80 days",
        "Winter: Store harvested peppers in cool, dry place"
      ],
      "diseaseWarnings": [
        "Bacterial spot: Yellow spots with dark centers on leaves",
        "Anthracnose: Dark, sunken spots on fruits",
        "Powdery mildew: White powdery coating on leaves",
        "Blossom end rot: Dark, sunken areas on fruit bottom"
      ],
      "pestAlerts": [
        "Aphids: Small green insects on leaves and stems",
        "Hornworms: Large green caterpillars eating leaves",
        "Flea beetles: Small jumping beetles creating holes",
        "Spider mites: Tiny pests causing stippled leaves"
      ]
    }
  };

  bool _isImageZoomed = false;

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
          'Detection Results',
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
                imageUrl: detectionResult["imageUrl"] as String,
                onImageTap: () => _toggleImageZoom(),
                onLongPress: () => _showImageContextMenu(context),
              ),

              SizedBox(height: 2.h),

              // Detection Result Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: DetectionResultCardWidget(
                  cropName: detectionResult["cropName"] as String,
                  confidence: detectionResult["confidence"] as double,
                  timestamp: detectionResult["timestamp"] as DateTime,
                ),
              ),

              SizedBox(height: 3.h),

              // Crop Information Section
              CropInfoSectionWidget(
                cropInfo: detectionResult["cropInfo"] as Map<String, dynamic>,
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
    Navigator.pushNamed(context, '/crop-scanner-camera');
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
