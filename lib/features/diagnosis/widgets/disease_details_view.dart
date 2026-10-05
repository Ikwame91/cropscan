import 'package:cropscan_pro/core/app_export.dart';
import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:cropscan_pro/data/models/disease_info.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Renders every section of a [DiseaseInfo] as expandable cards.
///
/// Shared by the diagnosis results screen and the disease library so both
/// show the same database content.
class DiseaseDetailsView extends StatelessWidget {
  final DiseaseInfo info;

  /// Expand the treatment / care section by default.
  final bool expandFirstSection;

  const DiseaseDetailsView({
    super.key,
    required this.info,
    this.expandFirstSection = false,
  });

  @override
  Widget build(BuildContext context) {
    final basic = info.basicInfo;
    final symptoms = info.symptoms;
    final treatment = info.treatment;
    final prevention = info.prevention;
    final maintenance = info.maintenance;
    final monitoring = info.monitoring;
    final economic = info.economicImpact;
    final labor = info.laborImpact;
    final community = info.communityImpact;
    final farmSize = info.farmSizeImpact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (treatment != null)
          _Section(
            title: 'Treatment',
            icon: 'healing',
            color: AppTheme.getSuccessColor(true),
            initiallyExpanded: expandFirstSection,
            children: [
              _StepList('Do this now', treatment.immediateAction),
              if (treatment.organicSolutions.isNotEmpty)
                _SolutionList(
                  'Organic options',
                  [
                    for (final s in treatment.organicSolutions)
                      (s.method, s.application ?? s.timing ?? s.note),
                  ],
                ),
              if (treatment.chemicalSolutions.isNotEmpty)
                _SolutionList(
                  'Chemical options',
                  [
                    for (final s in treatment.chemicalSolutions)
                      (
                        s.activeIngredient,
                        [
                          if ((s.tradeNames ?? const []).isNotEmpty)
                            'Brands: ${s.tradeNames!.join(', ')}',
                          if (s.applicationRate != null) s.applicationRate!,
                          if (s.timing != null) s.timing!,
                          if (s.note != null) s.note!,
                        ].join('\n'),
                      ),
                  ],
                ),
              _BulletList('Field practices', treatment.culturalPractices),
            ],
          ),
        if (maintenance != null)
          _Section(
            title: 'Crop care',
            icon: 'agriculture',
            color: Colors.teal,
            initiallyExpanded: expandFirstSection && treatment == null,
            children: [
              if (maintenance.watering != null) ...[
                _InfoRow('Watering', maintenance.watering!.frequency),
                _InfoRow('Amount', maintenance.watering!.amount),
                _BulletList('Critical stages',
                    maintenance.watering!.criticalStages ?? const []),
              ],
              if (maintenance.fertilization != null) ...[
                _InfoRow('Nitrogen', maintenance.fertilization!.nitrogen),
                _InfoRow('Phosphorus', maintenance.fertilization!.phosphorus),
                _InfoRow('Potassium', maintenance.fertilization!.potassium),
                _BulletList(
                    'When to feed', maintenance.fertilization!.timing ?? const []),
              ],
            ],
          ),
        if (symptoms != null)
          _Section(
            title: 'Symptoms',
            icon: 'medical_services',
            color: AppTheme.getWarningColor(true),
            children: [
              _BulletList('Early stage', symptoms.earlyStage),
              _BulletList('Advanced stage', symptoms.advancedStage),
              _BulletList('Affected parts', symptoms.affectedParts),
              _InfoRow('Favourable weather', symptoms.weatherConditions),
            ],
          ),
        if (info.causes != null)
          _Section(
            title: 'Causes',
            icon: 'help_outline',
            color: Colors.brown,
            children: [
              _BulletList('Environment', info.causes!.environmental),
              _BulletList('Farming practices', info.causes!.cultural),
            ],
          ),
        if (prevention != null)
          _Section(
            title: 'Prevention',
            icon: 'shield',
            color: Colors.blue,
            children: [
              _BulletList('Best practices', prevention.bestPractices),
              _BulletList('Resistant varieties',
                  prevention.resistantVarieties ?? const []),
            ],
          ),
        if (monitoring != null &&
            (monitoring.inspectionFrequency != null ||
                monitoring.keyIndicators.isNotEmpty))
          _Section(
            title: 'Monitoring',
            icon: 'visibility',
            color: Colors.cyan.shade700,
            children: [
              _InfoRow('How often', monitoring.inspectionFrequency),
              _BulletList('Look for', monitoring.keyIndicators),
              _InfoRow('Act when', monitoring.actionThreshold),
            ],
          ),
        if (economic != null || farmSize != null || labor != null)
          _Section(
            title: 'Costs & effort',
            icon: 'attach_money',
            color: AppTheme.getSuccessColor(true),
            children: [
              _InfoRow('Yield loss', economic?.yieldLoss),
              _InfoRow('Yield potential', economic?.yieldPotential),
              _InfoRow('Quality impact', economic?.qualityImpact),
              _InfoRow('Treatment cost', economic?.treatmentCost),
              _InfoRow('Upkeep cost', economic?.maintenanceCost),
              _InfoRow('Critical period', economic?.criticalPeriod),
              _InfoRow('Small farm', farmSize?.smallFarm),
              _InfoRow('Medium farm', farmSize?.mediumFarm),
              _InfoRow('Hours needed', labor?.hoursRequired),
              _InfoRow('Skill level', labor?.skillLevel),
              _InfoRow('Timing', labor?.timingConstraints),
            ],
          ),
        if (community != null)
          _Section(
            title: 'Community',
            icon: 'group',
            color: Colors.indigo,
            children: [
              _InfoRow('Spread risk', community.spreadRisk),
              _InfoRow('Working together', community.collectiveAction),
            ],
          ),
        if ((info.localTipsGhana ?? '').isNotEmpty)
          _Section(
            title: 'Local tips for Ghana',
            icon: 'lightbulb',
            color: AppTheme.getAccentColor(true),
            children: [
              Text(info.localTipsGhana!,
                  style: AppTheme.lightTheme.textTheme.bodyMedium),
            ],
          ),
        if (basic.pathogen.isNotEmpty || basic.diseaseType.isNotEmpty)
          _Section(
            title: 'About',
            icon: 'info',
            color: AppTheme.lightTheme.colorScheme.primary,
            children: [
              _InfoRow('Crop', basic.cropType),
              _InfoRow('Type', basic.diseaseType),
              _InfoRow('Pathogen', basic.pathogen),
              _InfoRow('Severity', basic.severity),
            ],
          ),
      ],
    );
  }
}

/// Small coloured badge, e.g. for disease severity.
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadge({super.key, required this.text, required this.color});

  factory StatusBadge.forInfo(DiseaseInfo info) => StatusBadge(
        text: info.isHealthy ? 'Healthy' : info.basicInfo.condition,
        color: info.statusColor,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: AppTheme.lightTheme.textTheme.labelMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final bool initiallyExpanded;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightTheme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          padding: EdgeInsets.all(1.5.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(iconName: icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        childrenPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: 1.h, bottom: 0.5.h),
        child: Text(
          text,
          style: AppTheme.lightTheme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28.w,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(v, style: AppTheme.lightTheme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final String label;
  final List<String> items;
  const _BulletList(this.label, this.items);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        for (final item in items)
          Padding(
            padding: EdgeInsets.only(left: 1.w, bottom: 0.5.h),
            child: Text('•  $item',
                style: AppTheme.lightTheme.textTheme.bodyMedium),
          ),
      ],
    );
  }
}

/// Numbered steps; strips a leading "Step 1:" if the data already has one.
class _StepList extends StatelessWidget {
  final String label;
  final List<String> steps;
  const _StepList(this.label, this.steps);

  static final _stepPrefix = RegExp(r'^step\s*\d+\s*[:.)-]\s*', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 0.8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: AppTheme.getSuccessColor(true).withValues(alpha: 0.15),
                  child: Text('${i + 1}',
                      style: AppTheme.lightTheme.textTheme.labelSmall
                          ?.copyWith(color: AppTheme.successInk())),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(steps[i].replaceFirst(_stepPrefix, ''),
                      style: AppTheme.lightTheme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SolutionList extends StatelessWidget {
  final String label;
  final List<(String, String?)> solutions;
  const _SolutionList(this.label, this.solutions);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        for (final (name, detail) in solutions)
          Padding(
            padding: EdgeInsets.only(left: 1.w, bottom: 0.8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  $name',
                    style: AppTheme.lightTheme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
                if ((detail ?? '').isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(left: 3.5.w),
                    child: Text(detail!,
                        style: AppTheme.lightTheme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
