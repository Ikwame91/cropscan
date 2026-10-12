import 'dart:convert';

import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:cropscan_pro/data/models/crop_care_tip.dart';
import 'package:cropscan_pro/data/models/farming_calendar_event.dart';
import 'package:cropscan_pro/features/history/detection_history_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Content for the Crop Guide tab.
///
/// - General tips and the seasonal calendar come from
///   `assets/data/farming_guide.json`.
/// - Disease tips and the disease library come from `crop_database.json`
///   (via [DiseaseKnowledgeRepository]), so they cover every disease the
///   model can detect.
/// - "Personalized" tips are picked from the diseases and crops in the
///   farmer's own scan history.
class CropCareProvider extends ChangeNotifier {
  static const String guideAsset = 'assets/data/farming_guide.json';
  static const String diseaseTipPrefix = 'db:';

  final DiseaseKnowledgeRepository _knowledge;
  final Future<String> Function() _loadGuide;
  final DateTime Function() _clock;

  List<CropCareTip> _generalTips = [];
  late final List<CropCareTip> _diseaseTips;
  List<FarmingCalendarEvent> _calendarEvents = [];
  bool _isLoading = false;
  String? _errorMessage;

  CropCareProvider(
    this._knowledge, {
    Future<String> Function()? loadGuide,
    DateTime Function()? clock,
    bool autoLoad = true,
  })  : _loadGuide = loadGuide ?? (() => rootBundle.loadString(guideAsset)),
        _clock = clock ?? DateTime.now {
    _diseaseTips = [
      for (final entry in _knowledge.diseases) diseaseTipFor(entry),
    ];
    if (autoLoad) refreshData();
  }

  List<CropCareTip> get allTips => [..._diseaseTips, ..._generalTips];
  List<FarmingCalendarEvent> get calendarEvents => _calendarEvents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> refreshData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final guide = json.decode(await _loadGuide()) as Map<String, dynamic>;
      _generalTips = [
        for (final t in guide['tips'] as List)
          CropCareTip.fromMap(Map<String, dynamic>.from(t as Map)),
      ];
      _calendarEvents = [
        for (final e in guide['calendar'] as List)
          FarmingCalendarEvent.fromMap(Map<String, dynamic>.from(e as Map)),
      ];
    } catch (e) {
      debugPrint('CropCareProvider: failed to load guide: $e');
      _errorMessage = 'Could not load the farming guide.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Turns a database entry into a tip card. The id carries the model label
  /// so the full guide can be opened from it.
  static CropCareTip diseaseTipFor(DiseaseEntry entry) {
    final info = entry.info;
    final severity = info.basicInfo.severity.toLowerCase();
    return CropCareTip(
      id: '$diseaseTipPrefix${entry.rawLabel}',
      title: info.displayName,
      description: info.prevention?.bestPractices.firstOrNull ?? info.summary,
      category: 'disease',
      cropTypes: [entry.crop.toLowerCase()],
      severity: severity.contains('severe') || severity.contains('high')
          ? 'high'
          : severity.contains('moderate')
              ? 'medium'
              : 'low',
      iconName: 'coronavirus',
      symptoms: info.symptoms?.earlyStage ?? const [],
      treatments: info.treatment?.immediateAction ?? const [],
      preventions: info.prevention?.bestPractices ?? const [],
    );
  }

  /// The model label behind a disease tip, or null for other tips.
  static String? rawLabelOf(CropCareTip tip) =>
      tip.id.startsWith(diseaseTipPrefix)
          ? tip.id.substring(diseaseTipPrefix.length)
          : null;

  List<CropCareTip> getTipsByCategory(String category) =>
      allTips.where((tip) => tip.category == category).toList();

  List<CropCareTip> searchTips(String query) {
    final q = query.toLowerCase();
    return allTips
        .where((tip) =>
            tip.title.toLowerCase().contains(q) ||
            tip.description.toLowerCase().contains(q) ||
            tip.symptoms.any((s) => s.toLowerCase().contains(q)) ||
            tip.cropTypes.any((c) => c.toLowerCase().contains(q)))
        .toList();
  }

  /// Up to [limit] tips: prevention for diseases found in recent scans
  /// first, then general tips for the crops the farmer grows (or for
  /// everyone, with no history).
  List<CropCareTip> getPersonalizedTips(
    DetectionHistoryProvider? history, {
    int limit = 6,
  }) {
    final tips = <CropCareTip>[];
    final crops = _cropsOf(history);

    for (final label in history?.recentDiseaseLabels() ?? const <String>[]) {
      if (tips.length >= 3) break;
      final entry = _knowledge.entryFor(label);
      if (entry != null && !entry.isHealthy) tips.add(diseaseTipFor(entry));
    }

    for (final tip in _generalTips) {
      if (tips.length >= limit) break;
      if (tip.isRelevantForCurrentMonth() &&
          (crops.isEmpty || crops.any(tip.isRelevantForCrop))) {
        tips.add(tip);
      }
    }
    return tips;
  }

  /// Calendar entries for this month and the farmer's crops. If this month
  /// has none, the next month that does — check [FarmingCalendarEvent.month].
  List<FarmingCalendarEvent> getRelevantActivities(
      DetectionHistoryProvider? history) {
    final crops = _cropsOf(history);
    bool relevant(FarmingCalendarEvent e) =>
        crops.isEmpty || crops.any(e.isRelevantForCrop);

    final month = _clock().month;
    for (var offset = 0; offset < 12; offset++) {
      final m = (month - 1 + offset) % 12 + 1;
      final events = _calendarEvents
          .where((e) => e.month == m && relevant(e))
          .toList()
        ..sort((a, b) =>
            _priorityScore(b.priority).compareTo(_priorityScore(a.priority)));
      if (events.isNotEmpty) return events;
    }
    return const [];
  }

  /// e.g. {"tomato", "bell pepper"}; empty with no history.
  static Set<String> _cropsOf(DetectionHistoryProvider? history) =>
      history?.scannedCrops.map((c) => c.toLowerCase()).toSet() ?? const {};

  static int _priorityScore(String priority) =>
      switch (priority.toLowerCase()) {
        'high' => 3,
        'medium' => 2,
        'low' => 1,
        _ => 0,
      };
}
