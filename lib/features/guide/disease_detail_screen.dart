import 'package:cropscan_pro/core/app_export.dart';
import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:cropscan_pro/features/diagnosis/widgets/disease_details_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

/// Full database entry for one disease/condition, opened from the disease
/// library or from a diagnosis' "could also be" list.
class DiseaseDetailScreen extends StatelessWidget {
  final String rawLabel;

  const DiseaseDetailScreen({super.key, required this.rawLabel});

  @override
  Widget build(BuildContext context) {
    final entry = context.read<DiseaseKnowledgeRepository>().entryFor(rawLabel);
    final theme = AppTheme.lightTheme;

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No information for this condition.')),
      );
    }

    final info = entry.info;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(info.displayName)),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          Row(
            children: [
              StatusBadge.forInfo(info),
              SizedBox(width: 2.w),
              if (info.basicInfo.severity.isNotEmpty)
                StatusBadge(
                  text: info.basicInfo.severity,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(info.summary, style: theme.textTheme.bodyLarge),
          SizedBox(height: 2.h),
          DiseaseDetailsView(info: info, expandFirstSection: true),
        ],
      ),
    );
  }
}
