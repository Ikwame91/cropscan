import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class AnalyticsSummaryWidget extends StatelessWidget {
  final int totalScans;
  final double averageConfidence;
  final String mostScannedCrop;
  final String recentTrend;

  const AnalyticsSummaryWidget({
    super.key,
    required this.totalScans,
    required this.averageConfidence,
    required this.mostScannedCrop,
    required this.recentTrend,
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
          _buildStatsGrid(context),
          SizedBox(height: 2.h),
          _buildTrendCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.analytics,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Farming Analytics",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                "Insights from your scan history",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: "Total Scans",
            value: "$totalScans",
            icon: Icons.scanner,
            color: Colors.blue,
            subtitle: "Crops analyzed",
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatCard(
            context,
            title: "Avg Confidence",
            value: "${(averageConfidence * 100).toStringAsFixed(1)}%",
            icon: Icons.thumb_up,
            color: Colors.green,
            subtitle: "AI accuracy",
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 6.w,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getTrendIcon(recentTrend),
                color: _getTrendColor(recentTrend),
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Crop Health Trend",
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getTrendDescription(recentTrend),
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: _getTrendColor(recentTrend),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Icon(
                Icons.eco,
                size: 20,
                color:
                    AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.6),
              ),
              SizedBox(width: 2.w),
              Text(
                "Most scanned: ",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withOpacity(0.6),
                ),
              ),
              Text(
                mostScannedCrop.isNotEmpty ? mostScannedCrop : "N/A",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: _getTrendColor(recentTrend).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: _getTrendColor(recentTrend),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    _getTrendRecommendation(recentTrend),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getTrendColor(recentTrend),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return Icons.trending_up;
      case 'declining':
        return Icons.trending_down;
      case 'stable':
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return Colors.green;
      case 'declining':
        return Colors.red;
      case 'stable':
      default:
        return Colors.orange;
    }
  }

  String _getTrendDescription(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return "Your crops are getting healthier! ✨";
      case 'declining':
        return "Recent scans show more issues 🔍";
      case 'stable':
      default:
        return "Crop health is stable 📊";
    }
  }

  String _getTrendRecommendation(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return "Keep up the excellent farming practices! Continue current care routine.";
      case 'declining':
        return "Consider reviewing recent care practices and check for disease prevention measures.";
      case 'stable':
      default:
        return "Maintain current practices and continue regular monitoring.";
    }
  }
}
