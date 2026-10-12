import 'package:cropscan_pro/app/navigation_provider.dart';
import 'package:cropscan_pro/core/app_export.dart';
import 'package:cropscan_pro/core/ml/classification_result.dart';
import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:cropscan_pro/data/models/crop_detection.dart';
import 'package:cropscan_pro/data/models/disease_info.dart';
import 'package:cropscan_pro/features/diagnosis/widgets/action_buttons_widget.dart';
import 'package:cropscan_pro/features/diagnosis/widgets/crop_image_widget.dart';
import 'package:cropscan_pro/features/diagnosis/widgets/detection_result_card_widget.dart';
import 'package:cropscan_pro/features/diagnosis/widgets/disease_details_view.dart';
import 'package:cropscan_pro/features/history/detection_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

/// Shows a saved scan: the diagnosis, alternatives, what to do now and the
/// full database entry.
class CropDetectionResults extends StatelessWidget {
  final String detectionId;
  final bool justScanned;

  const CropDetectionResults({
    super.key,
    required this.detectionId,
    this.justScanned = false,
  });

  @override
  Widget build(BuildContext context) {
    final detection = context.select<DetectionHistoryProvider, CropDetection?>(
      (p) => p.byId(detectionId),
    );
    if (detection == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This scan is no longer in history.')),
      );
    }

    final knowledge = context.read<DiseaseKnowledgeRepository>();
    final info = knowledge.lookup(detection.rawLabel);
    final theme = AppTheme.lightTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(detection.cropName,
            style: theme.appBarTheme.titleTextStyle,
            overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: () => _share(context, detection, info),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(bottom: 4.h),
          children: [
            CropImageWidget(imagePath: detection.imageUrl),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DetectionResultCardWidget(
                    cropName: detection.cropName,
                    confidence: detection.confidence,
                    timestamp: detection.detectedAt,
                    statusColor: info?.statusColor,
                    condition: detection.status,
                  ),
                  if (detection.isUncertain ||
                      detection.alternatives.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    _AlternativesCard(detection: detection),
                  ],
                  SizedBox(height: 2.h),
                  _NextStepCard(info: info, detection: detection),
                  SizedBox(height: 3.h),
                  if (info != null) ...[
                    Text('Full guide',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 1.5.h),
                    DiseaseDetailsView(info: info),
                  ] else
                    const _MissingInfoCard(),
                  SizedBox(height: 2.h),
                  ActionButtonsWidget(
                    onShareResults: () => _share(context, detection, info),
                    onScanAnother: () => context
                        .read<NavigationProvider>()
                        .returnToTab(context, AppTab.scan),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String shareText(CropDetection detection, DiseaseInfo? info) {
    final buffer = StringBuffer()
      ..writeln('CropScan diagnosis: ${detection.cropName}')
      ..writeln(
          'Confidence: ${(detection.confidence * 100).toStringAsFixed(0)}%'
          '${detection.isUncertain ? ' (uncertain)' : ''}')
      ..writeln(
          'Scanned: ${DateFormat('d MMM yyyy, HH:mm').format(detection.detectedAt)}');
    final steps = info?.treatment?.immediateAction ?? const <String>[];
    if (steps.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Recommended now:');
      for (final step in steps) {
        buffer.writeln('- $step');
      }
    }
    return buffer.toString().trim();
  }

  Future<void> _share(
    BuildContext context,
    CropDetection detection,
    DiseaseInfo? info,
  ) async {
    final text = shareText(detection, info);
    try {
      await Share.shareXFiles([XFile(detection.imageUrl)], text: text);
    } catch (_) {
      // The photo may be missing (e.g. deleted); share the text alone.
      await Share.share(text);
    }
  }
}

class _AlternativesCard extends StatelessWidget {
  final CropDetection detection;
  const _AlternativesCard({required this.detection});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final knowledge = context.read<DiseaseKnowledgeRepository>();
    final warning = AppTheme.getWarningColor(true);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: detection.isUncertain
            ? warning.withValues(alpha: 0.08)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: detection.isUncertain
              ? warning.withValues(alpha: 0.5)
              : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detection.isUncertain) ...[
            Row(
              children: [
                Icon(Icons.help_outline, color: warning),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text('The model is not sure about this one',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Compare the symptoms below with your plant, or rescan a single '
              'leaf in good light.',
              style: theme.textTheme.bodySmall,
            ),
            SizedBox(height: 1.h),
          ],
          if (detection.alternatives.isNotEmpty) ...[
            Text('Could also be',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            for (final LabelScore alt in detection.alternatives)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(knowledge.displayNameFor(alt.label)),
                subtitle: LinearProgressIndicator(
                  value: alt.confidence,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                trailing: Text('${(alt.confidence * 100).toStringAsFixed(0)}%'),
                onTap: knowledge.lookup(alt.label) == null
                    ? null
                    : () => Navigator.pushNamed(
                          context,
                          AppRoutes.diseaseDetail,
                          arguments: alt.label,
                        ),
              ),
          ],
        ],
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final DiseaseInfo? info;
  final CropDetection detection;
  const _NextStepCard({required this.info, required this.detection});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final color = info?.statusColor ?? theme.colorScheme.primary;
    final summary = info?.summary;
    final action = info?.firstAction ??
        'Remove affected leaves and consult your local extension officer.';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary != null) ...[
            Text(summary, style: theme.textTheme.bodyMedium),
            SizedBox(height: 1.5.h),
          ],
          Row(
            children: [
              Icon(
                detection.isHealthy ? Icons.check_circle : Icons.priority_high,
                color: color,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(detection.isHealthy ? 'Keep it healthy' : 'Do this first',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          SizedBox(height: 0.8.h),
          Text(action.replaceFirst(RegExp(r'^step\s*\d+\s*[:.)-]\s*', caseSensitive: false), ''),
              style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MissingInfoCard extends StatelessWidget {
  const _MissingInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Text(
          'Detailed guidance for this result is not in the offline database '
          'yet. Please consult your local agricultural extension officer.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
