import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/app_export.dart';
import '../../../../providers/crop_care_provider.dart';
import '../../../../models/crop_care_tip.dart';

class DiseaseLibraryWidget extends StatelessWidget {
  final List<String> userCrops;

  const DiseaseLibraryWidget({
    super.key,
    required this.userCrops,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(height: 2.h),
          _buildDiseaseGrid(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_book,
                color: Colors.red,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Disease Library",
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "Learn about common crop diseases",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () => _showFullLibrary(context),
          icon: Icon(Icons.library_books, size: 16),
          label: Text("View All"),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseGrid(BuildContext context) {
    return Consumer<CropCareProvider>(
      builder: (context, cropCareProvider, child) {
        final diseaseTips = cropCareProvider.getTipsByCategory('disease');
        final relevantDiseases = _getRelevantDiseases(diseaseTips);

        if (relevantDiseases.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
          ),
          itemCount: relevantDiseases.length.clamp(0, 4), // Show max 4 in grid
          itemBuilder: (context, index) =>
              _buildDiseaseCard(context, relevantDiseases[index]),
        );
      },
    );
  }

  Widget _buildDiseaseCard(BuildContext context, CropCareTip diseaseTip) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDiseaseColor(diseaseTip.severity).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDiseaseDetails(context, diseaseTip),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Disease icon and severity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: _getDiseaseColor(diseaseTip.severity)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getCropEmoji(diseaseTip.cropTypes.isNotEmpty
                            ? diseaseTip.cropTypes.first
                            : ''),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 1.5.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getDiseaseColor(diseaseTip.severity)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getDiseaseColor(diseaseTip.severity)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        diseaseTip.severity.toUpperCase(),
                        style: TextStyle(
                          color: _getDiseaseColor(diseaseTip.severity),
                          fontSize: 7.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Disease name
                Text(
                  diseaseTip.title,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 1.h),

                // Crop types
                if (diseaseTip.cropTypes.isNotEmpty) ...[
                  Text(
                    "Affects: ${diseaseTip.cropTypes.join(', ')}",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                ],

                // Quick symptoms
                if (diseaseTip.symptoms.isNotEmpty) ...[
                  Text(
                    "Symptoms:",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    diseaseTip.symptoms.first,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                Spacer(),

                // Tap to learn more
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Learn more",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.menu_book,
            size: 12.w,
            color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 2.h),
          Text(
            "Disease Library Loading...",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Common crop diseases will appear here",
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<CropCareTip> _getRelevantDiseases(List<CropCareTip> allDiseases) {
    if (userCrops.isEmpty) {
      return allDiseases.take(4).toList();
    }

    // Filter diseases relevant to user's crops
    final relevantDiseases = allDiseases.where((disease) {
      return userCrops.any((crop) => disease.isRelevantForCrop(crop));
    }).toList();

    // If we have relevant diseases, return them, otherwise return general ones
    return relevantDiseases.isNotEmpty
        ? relevantDiseases.take(4).toList()
        : allDiseases.take(4).toList();
  }

  Color _getDiseaseColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow[700] ?? Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  String _getCropEmoji(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'tomato':
        return '🍅';
      case 'maize':
      case 'corn':
        return '🌽';
      case 'pepper':
      case 'bell pepper':
        return '🌶️';
      default:
        return '🌿';
    }
  }

  void _showDiseaseDetails(BuildContext context, CropCareTip diseaseTip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DiseaseDetailsBottomSheet(diseaseTip: diseaseTip),
    );
  }

  void _showFullLibrary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullDiseaseLibraryScreen(userCrops: userCrops),
      ),
    );
  }
}

class _DiseaseDetailsBottomSheet extends StatelessWidget {
  final CropCareTip diseaseTip;

  const _DiseaseDetailsBottomSheet({required this.diseaseTip});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(vertical: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diseaseTip.title,
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (diseaseTip.cropTypes.isNotEmpty) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          "Affects: ${diseaseTip.cropTypes.join(', ')}",
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),

          Divider(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    diseaseTip.description,
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                  ),

                  if (diseaseTip.symptoms.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    _buildDetailSection("Symptoms to Look For",
                        diseaseTip.symptoms, Icons.visibility, Colors.orange),
                  ],

                  if (diseaseTip.treatments.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    _buildDetailSection("Treatment Options",
                        diseaseTip.treatments, Icons.healing, Colors.blue),
                  ],

                  if (diseaseTip.preventions.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    _buildDetailSection("Prevention Methods",
                        diseaseTip.preventions, Icons.shield, Colors.green),
                  ],

                  SizedBox(height: 3.h),

                  // Severity warning
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: _getDiseaseColor(diseaseTip.severity)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getDiseaseColor(diseaseTip.severity)
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: _getDiseaseColor(diseaseTip.severity),
                          size: 24,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${diseaseTip.severity.toUpperCase()} SEVERITY",
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getDiseaseColor(diseaseTip.severity),
                                ),
                              ),
                              Text(
                                _getSeverityDescription(diseaseTip.severity),
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: _getDiseaseColor(diseaseTip.severity),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
      String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(width: 2.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 1.h, left: 6.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 0.8.h, right: 2.w),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Color _getDiseaseColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow[700] ?? Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  String _getSeverityDescription(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return "Immediate action required. Can destroy entire crops quickly.";
      case 'medium':
        return "Moderate risk. Monitor closely and treat as needed.";
      case 'low':
        return "Low risk. Follow prevention measures and monitor.";
      default:
        return "Monitor and follow recommended practices.";
    }
  }
}

class _FullDiseaseLibraryScreen extends StatelessWidget {
  final List<String> userCrops;

  const _FullDiseaseLibraryScreen({required this.userCrops});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Disease Library"),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      ),
      body: Consumer<CropCareProvider>(
        builder: (context, cropCareProvider, child) {
          final allDiseases = cropCareProvider.getTipsByCategory('disease');

          return ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: allDiseases.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: DiseaseLibraryWidget(
                    userCrops: [allDiseases[index].cropTypes.first]),
              );
            },
          );
        },
      ),
    );
  }
}
