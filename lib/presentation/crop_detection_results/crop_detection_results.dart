import 'dart:io';

import 'package:cropscan_pro/models/crop_info.dart';
import 'package:cropscan_pro/models/crop_models.dart';
import 'package:cropscan_pro/models/enhanced_crop_info.dart';
import 'package:cropscan_pro/providers/detection_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final EnhancedCropInfo? enhancedCropInfo;

  const CropDetectionResults(
      {super.key,
      required this.imagePath,
      required this.detectedCrop,
      required this.cropInfo,
      this.enhancedCropInfo,
      required this.confidence});

  @override
  State<CropDetectionResults> createState() => _CropDetectionResultsState();
}

class _CropDetectionResultsState extends State<CropDetectionResults> {
  bool _isImageZoomed = false;
  EnhancedCropInfo? _enhancedCropInfo;
  bool _isLoadingEnhancedInfo = true;

  @override
  void initState() {
    super.initState();
    if (widget.enhancedCropInfo != null) {
      debugPrint("Using passed enhancedCropInfo from history");
      _enhancedCropInfo = widget.enhancedCropInfo;
      _isLoadingEnhancedInfo = false;
      _saveToHistory();
    } else {
      debugPrint("Loading enhanced info for new scan");
      _loadAndSaveDetection();
    }
  }

  Future<void> _loadAndSaveDetection() async {
    try {
      // First, load the enhanced crop info.
      await _loadEnhancedCropInfo();

      if (_enhancedCropInfo != null) {
        await _saveToHistory();
      } else {
        // Handle the case where loading failed.
        debugPrint(
            "⚠️ Warning: Enhanced crop info could not be loaded, not saving to history.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load crop details, history not updated.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ An error occurred during loading or saving: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoadingEnhancedInfo = false;
      });
    }
  }

  Future<void> _saveToHistory() async {
    try {
      final historyProvider = context.read<DetectionHistoryProvider>();

      final imageFile = File(widget.imagePath);
      if (!await imageFile.exists()) {
        debugPrint(
            "⚠️ Warning: Image file does not exist when saving to history: ${widget.imagePath}");
        // Still save the detection but with a note about missing image
      }

      await historyProvider.addDetection(
        enhancedCropInfo: _enhancedCropInfo!,
        rawDetectedCrop: widget.detectedCrop,
        cropName: widget.cropInfo.displayName,
        confidence: widget.confidence,
        imagePath: widget.imagePath,
        status: widget.cropInfo.condition,
        location: 'Farm Location',
        notes: 'Detected via camera scan',
      );

      debugPrint("✅ Detection saved to history");
    } catch (e) {
      debugPrint("❌ Failed to save detection to history: $e");
      // Show user a subtle notification about the issue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Detection saved, but image may not be available in history'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadEnhancedCropInfo() async {
    try {
      // Initialize the enhanced crop database
      await EnhancedCropInfoService.loadDatabase();
      debugPrint("Looking for enhanced info with key: ${widget.detectedCrop}");
      _enhancedCropInfo =
          EnhancedCropInfoService.getCropInfo(widget.detectedCrop);

      debugPrint("Enhanced info loaded: ${_enhancedCropInfo != null}");
    } catch (e) {
      debugPrint("Error loading enhanced crop info: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEnhancedInfo = false;
        });
      }
    }
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
                child: _buildEnhancedCropInfoSection(),
              ),
              SizedBox(height: 3.h),
              // Action Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ActionButtonsWidget(
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

  Widget _buildEnhancedCropInfoSection() {
    if (_isLoadingEnhancedInfo) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }
    // If enhanced info is available, show detailed information
    if (_enhancedCropInfo != null) {
      return _buildDetailedCropInfo(_enhancedCropInfo!);
    }

    // Fallback to basic info

    return _buildCropInfoSection();
  }

  Widget _buildDetailedCropInfo(EnhancedCropInfo enhancedInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'Detailed Crop Analysis',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),

        // Basic Information Card
        _buildExpandableInfoCard(
          title: 'Basic Information',
          icon: 'info',
          color: AppTheme.lightTheme.colorScheme.primary,
          children: [
            _buildInfoRow('Crop Type', enhancedInfo.basicInfo.cropType),
            _buildInfoRow('Condition', enhancedInfo.basicInfo.condition),
            if (enhancedInfo.basicInfo.diseaseType.isNotEmpty)
              _buildInfoRow('Disease Type', enhancedInfo.basicInfo.diseaseType),
            if (enhancedInfo.basicInfo.pathogen.isNotEmpty)
              _buildInfoRow('Pathogen', enhancedInfo.basicInfo.pathogen),
            if (enhancedInfo.basicInfo.severity.isNotEmpty)
              _buildInfoRow('Severity', enhancedInfo.basicInfo.severity),
          ],
        ),
        SizedBox(height: 1.5.h),

        // Symptoms (if available)
        if (enhancedInfo.symptoms != null)
          _buildExpandableInfoCard(
            title: 'Symptoms',
            icon: 'medical_services',
            color: Colors.orange,
            children: [
              _buildListInfoRow(
                  'Early Stage', enhancedInfo.symptoms!.earlyStage),
              _buildListInfoRow(
                  'Advanced Stage', enhancedInfo.symptoms!.advancedStage),
              _buildListInfoRow(
                  'Affected Parts', enhancedInfo.symptoms!.affectedParts),
              _buildInfoRow('Weather Conditions',
                  enhancedInfo.symptoms!.weatherConditions),
            ],
          ),
        if (enhancedInfo.treatment != null)
          _buildExpandableInfoCard(
            title: 'Treatment Options',
            icon: 'healing',
            color: Colors.green,
            children: [
              _buildListInfoRow(
                  'Immediate Actions', enhancedInfo.treatment!.immediateAction),
              if (enhancedInfo.treatment!.organicSolutions.isNotEmpty)
                _buildOrganicSolutionsRow(
                    enhancedInfo.treatment!.organicSolutions),
              if (enhancedInfo.treatment!.chemicalSolutions.isNotEmpty)
                _buildChemicalSolutionsRow(
                    enhancedInfo.treatment!.chemicalSolutions),
            ],
          ),

        SizedBox(height: 1.5.h),

        // Treatment (if available)
        if (enhancedInfo.treatment != null)
          _buildExpandableInfoCard(
            title: 'Treatment Options',
            icon: 'healing',
            color: Colors.green,
            children: [
              _buildInfoRow(
                  'Chemical Treatment', enhancedInfo.treatment!.chemical),
              _buildInfoRow(
                  'Organic Treatment', enhancedInfo.treatment!.organic),
            ],
          ),

        SizedBox(height: 1.5.h),

        // Prevention (if available)
        if (enhancedInfo.prevention != null)
          _buildExpandableInfoCard(
            title: 'Prevention Methods',
            icon: 'shield',
            color: Colors.blue,
            children: [
              _buildInfoRow('Cultural Practices',
                  enhancedInfo.prevention!.culturalPractices),
              _buildInfoRow(
                  'Chemical Control', enhancedInfo.prevention!.chemicalControl),
            ],
          ),

        SizedBox(height: 1.5.h),

        // Maintenance (if available)
        if (enhancedInfo.maintenance != null)
          _buildExpandableInfoCard(
            title: 'Crop Maintenance',
            icon: 'agriculture',
            color: Colors.teal,
            children: [
              _buildInfoRow('Irrigation', enhancedInfo.maintenance!.irrigation),
              if (enhancedInfo.maintenance!.fertilization != null)
                _buildInfoRow(
                    'Fertilization',
                    'N: ${enhancedInfo.maintenance!.fertilization!.nitrogen}, '
                        'P: ${enhancedInfo.maintenance!.fertilization!.phosphorus}, '
                        'K: ${enhancedInfo.maintenance!.fertilization!.potassium}'),
              if (enhancedInfo.maintenance!.monitoring != null)
                _buildListInfoRow('Key Metrics',
                    enhancedInfo.maintenance!.monitoring!.keyMetrics ?? []),
            ],
          ),
        SizedBox(height: 1.5.h),
        // Economic Impact (if available)
        if (enhancedInfo.economicImpact != null)
          _buildExpandableInfoCard(
            title: 'Economic Impact',
            icon: 'attach_money',
            color: Colors.green,
            children: [
              if (enhancedInfo.economicImpact!.yieldLoss != null)
                _buildInfoRow(
                    'Yield Loss', enhancedInfo.economicImpact!.yieldLoss!),
              if (enhancedInfo.economicImpact!.qualityImpact != null)
                _buildInfoRow('Quality Impact',
                    enhancedInfo.economicImpact!.qualityImpact!),
              if (enhancedInfo.economicImpact!.treatmentCost != null)
                _buildInfoRow('Treatment Cost',
                    enhancedInfo.economicImpact!.treatmentCost!),
              if (enhancedInfo.economicImpact!.criticalPeriod != null)
                _buildInfoRow('Critical Period',
                    enhancedInfo.economicImpact!.criticalPeriod!),
            ],
          ),

        SizedBox(height: 1.5.h),
        if (enhancedInfo.laborImpact != null)
          _buildExpandableInfoCard(
            title: 'Labor Requirements',
            icon: 'people',
            color: Colors.purple,
            children: [
              if (enhancedInfo.laborImpact!.hoursRequired != null)
                _buildInfoRow(
                    'Hours Required', enhancedInfo.laborImpact!.hoursRequired!),
              if (enhancedInfo.laborImpact!.skillLevel != null)
                _buildInfoRow(
                    'Skill Level', enhancedInfo.laborImpact!.skillLevel!),
              if (enhancedInfo.laborImpact!.timingConstraints != null)
                _buildInfoRow('Timing Constraints',
                    enhancedInfo.laborImpact!.timingConstraints!),
            ],
          ),
        SizedBox(height: 1.5.h),
        if (enhancedInfo.communityImpact != null)
          _buildExpandableInfoCard(
            title: 'Community Considerations',
            icon: 'group',
            color: Colors.indigo,
            children: [
              if (enhancedInfo.communityImpact!.spreadRisk != null)
                _buildInfoRow(
                    'Spread Risk', enhancedInfo.communityImpact!.spreadRisk!),
              if (enhancedInfo.communityImpact!.collectiveAction != null)
                _buildInfoRow('Collective Action',
                    enhancedInfo.communityImpact!.collectiveAction!),
            ],
          ),

        SizedBox(height: 1.5.h),

        if (enhancedInfo.localTipsGhana != null &&
            enhancedInfo.localTipsGhana!.isNotEmpty)
          _buildExpandableInfoCard(
            title: 'Local Tips for Ghana',
            icon: 'lightbulb',
            color: Colors.amber,
            children: [
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Text(
                    enhancedInfo.localTipsGhana!,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),

        SizedBox(height: 1.5.h),
      ],
    );
  }

  Widget _buildOrganicSolutionsRow(List<OrganicSolution> solutions) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Organic Solutions:',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          ...solutions
              .map((solution) => Padding(
                    padding: EdgeInsets.only(left: 2.w, bottom: 0.5.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${solution.method}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (solution.application != null)
                          Text(
                            '  Application: ${solution.application}',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildChemicalSolutionsRow(List<ChemicalSolution> solutions) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chemical Solutions:',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          ...solutions.map((solution) => Padding(
                padding: EdgeInsets.only(left: 2.w, bottom: 0.5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ${solution.activeIngredient}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (solution.tradeNames != null &&
                        solution.tradeNames!.isNotEmpty)
                      Text(
                        '  Trade names: ${solution.tradeNames!.join(', ')}',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildListInfoRow(String label, List<String> values) {
    if (values.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          ...values.map((value) => Padding(
                padding: EdgeInsets.only(left: 2.w, bottom: 0.5.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: AppTheme.lightTheme.textTheme.bodyMedium),
                    Expanded(
                      child: Text(
                        value,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildExpandableInfoCard({
    required String title,
    required String icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(1.5.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
        ],
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
