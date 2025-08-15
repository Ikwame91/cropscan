import 'package:cropscan_pro/models/crop_care_tip.dart';
import 'package:cropscan_pro/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PersonalizedTipsWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<CropCareTip> tips;
  final bool showViewAll;

  const PersonalizedTipsWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tips,
    this.showViewAll = false,
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
          _buildTipsList(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        if (showViewAll && tips.length > 3)
          TextButton.icon(
            onPressed: () => _showAllTips(context),
            icon: Icon(Icons.arrow_forward, size: 16),
            label: Text("View All"),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            ),
          ),
      ],
    );
  }

  Widget _buildTipsList(BuildContext context) {
    final displayTips = tips.take(3).toList();

    if (displayTips.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: displayTips.map((tip) => _buildTipCard(context, tip)).toList(),
    );
  }

  Widget _buildTipCard(BuildContext context, CropCareTip tip) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
          onTap: () => _showTipDetails(context, tip),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(tip.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(tip.category),
                        color: _getCategoryColor(tip.category),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.title,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (tip.cropTypes.isNotEmpty) ...[
                            SizedBox(height: 0.5.h),
                            Text(
                              "For: ${tip.cropTypes.join(', ')}",
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildSeverityBadge(tip.severity),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  tip.description,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tip.symptoms.isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          "Symptoms: ${tip.symptoms.first}${tip.symptoms.length > 1 ? '...' : ''}",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tap for details",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
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

  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8.sp,
          fontWeight: FontWeight.bold,
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
            Icons.eco,
            size: 12.w,
            color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 2.h),
          Text(
            "No tips available right now",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Scan some crops to get personalized recommendations!",
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'disease':
        return Colors.red;
      case 'prevention':
        return Colors.green;
      case 'care':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'disease':
        return Icons.bug_report;
      case 'prevention':
        return Icons.shield;
      case 'care':
        return Icons.eco;
      default:
        return Icons.help;
    }
  }

  void _showTipDetails(BuildContext context, CropCareTip tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TipDetailsBottomSheet(tip: tip),
    );
  }

  void _showAllTips(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AllTipsScreen(tips: tips, title: title),
      ),
    );
  }
}

class _TipDetailsBottomSheet extends StatelessWidget {
  final CropCareTip tip;

  const _TipDetailsBottomSheet({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
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
                  child: Text(
                    tip.title,
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                  Text(
                    tip.description,
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                  ),
                  if (tip.symptoms.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    _buildSection("Symptoms", tip.symptoms, Icons.visibility),
                  ],
                  if (tip.treatments.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    _buildSection("Treatments", tip.treatments, Icons.healing),
                  ],
                  if (tip.preventions.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    _buildSection("Prevention", tip.preventions, Icons.shield),
                  ],
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                size: 20, color: AppTheme.lightTheme.colorScheme.primary),
            SizedBox(width: 2.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 0.5.h, left: 6.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• ", style: TextStyle(fontSize: 14.sp)),
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
}

class _AllTipsScreen extends StatelessWidget {
  final List<CropCareTip> tips;
  final String title;

  const _AllTipsScreen({required this.tips, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          return PersonalizedTipsWidget(
            title: "",
            subtitle: "",
            tips: [tips[index]],
            showViewAll: false,
          );
        },
      ),
    );
  }
}
