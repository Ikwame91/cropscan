import 'package:flutter/material.dart';
import '../models/crop_care_tip.dart';
import '../models/farming_calendar_event.dart';
import '../providers/detection_history_provider.dart';

class CropCareProvider extends ChangeNotifier {
  List<CropCareTip> _allTips = [];
  List<FarmingCalendarEvent> _calendarEvents = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CropCareTip> get allTips => _allTips;
  List<FarmingCalendarEvent> get calendarEvents => _calendarEvents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CropCareProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadCropCareTips(),
        _loadFarmingCalendar(),
      ]);
    } catch (e) {
      _errorMessage = 'Failed to load crop care data: $e';
      debugPrint('❌ CropCareProvider initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCropCareTips() async {
    // In a real app, this would load from assets/database
    // For now, we'll use hardcoded data
    _allTips = [
      // Disease Prevention Tips
      CropCareTip(
        id: 'prev_001',
        title: 'Proper Plant Spacing',
        description:
            'Maintain adequate spacing between plants for good air circulation',
        category: 'prevention',
        cropTypes: ['tomato', 'pepper', 'maize'],
        severity: 'high',
        iconName: 'grid_view',
        symptoms: ['Overcrowded plants', 'Poor air circulation'],
        treatments: [
          'Thin out overcrowded areas',
          'Transplant excess seedlings'
        ],
        preventions: [
          'Follow recommended spacing guidelines',
          'Plan garden layout before planting',
          'Use string lines for proper alignment'
        ],
        isSeasonal: false,
      ),

      CropCareTip(
        id: 'prev_002',
        title: 'Water Management',
        description: 'Water at soil level to prevent leaf diseases',
        category: 'prevention',
        cropTypes: ['tomato', 'pepper'],
        severity: 'high',
        iconName: 'water_drop',
        symptoms: ['Wet leaves', 'Fungal growth on foliage'],
        treatments: ['Switch to drip irrigation', 'Water early morning'],
        preventions: [
          'Use drip irrigation or soaker hoses',
          'Water early morning (6-8 AM)',
          'Avoid watering leaves directly',
          'Mulch around plants to retain moisture'
        ],
        isSeasonal: false,
      ),

      // Disease-Specific Tips
      CropCareTip(
        id: 'disease_001',
        title: 'Tomato Early Blight',
        description: 'Fungal disease causing dark spots with concentric rings',
        category: 'disease',
        cropTypes: ['tomato'],
        severity: 'medium',
        iconName: 'bug_report',
        symptoms: [
          'Dark spots with concentric rings on older leaves',
          'Yellow halos around spots',
          'Leaf drop starting from bottom',
          'Stem lesions near soil line'
        ],
        treatments: [
          'Remove affected leaves immediately',
          'Apply copper-based fungicide',
          'Improve air circulation',
          'Reduce overhead watering'
        ],
        preventions: [
          'Choose resistant varieties',
          'Rotate crops annually',
          'Mulch to prevent soil splash',
          'Water at soil level only'
        ],
        isSeasonal: true,
        relevantMonths: [6, 7, 8, 9], // Rainy season in Ghana
      ),

      CropCareTip(
        id: 'disease_002',
        title: 'Tomato Late Blight',
        description: 'Serious fungal disease that can destroy entire crops',
        category: 'disease',
        cropTypes: ['tomato'],
        severity: 'high',
        iconName: 'dangerous',
        symptoms: [
          'Water-soaked spots that turn brown quickly',
          'White fuzzy growth on leaf undersides',
          'Black lesions on stems',
          'Brown rot on fruits'
        ],
        treatments: [
          'Remove infected plants immediately',
          'Apply preventive fungicide to healthy plants',
          'Improve drainage',
          'Increase plant spacing'
        ],
        preventions: [
          'Plant certified disease-free seeds',
          'Ensure excellent drainage',
          'Avoid overhead irrigation',
          'Remove plant debris after harvest'
        ],
        isSeasonal: true,
        relevantMonths: [5, 6, 7, 8, 9],
      ),

      // Maize-specific tips
      CropCareTip(
        id: 'disease_003',
        title: 'Maize Leaf Spot',
        description: 'Common fungal diseases affecting maize leaves',
        category: 'disease',
        cropTypes: ['maize', 'corn'],
        severity: 'medium',
        iconName: 'eco',
        symptoms: [
          'Small round to oval spots on leaves',
          'Spots may have gray centers',
          'Yellowing around spots',
          'Premature leaf death'
        ],
        treatments: [
          'Apply appropriate fungicide',
          'Remove severely affected leaves',
          'Ensure proper nutrition',
          'Improve field drainage'
        ],
        preventions: [
          'Use resistant varieties',
          'Practice crop rotation',
          'Maintain proper plant nutrition',
          'Avoid working in wet fields'
        ],
        isSeasonal: true,
        relevantMonths: [6, 7, 8],
      ),

      // General Care Tips
      CropCareTip(
        id: 'care_001',
        title: 'Soil Health Management',
        description: 'Maintain healthy soil for disease-resistant crops',
        category: 'care',
        cropTypes: ['tomato', 'pepper', 'maize'],
        severity: 'medium',
        iconName: 'grass',
        symptoms: ['Poor plant growth', 'Nutrient deficiencies'],
        treatments: [
          'Add organic compost',
          'Test and adjust soil pH',
          'Apply balanced fertilizer'
        ],
        preventions: [
          'Regular soil testing',
          'Annual compost addition',
          'Cover cropping in off-season',
          'Avoid soil compaction'
        ],
        isSeasonal: false,
      ),

      CropCareTip(
        id: 'care_002',
        title: 'Pest Management',
        description: 'Integrated approach to managing crop pests',
        category: 'care',
        cropTypes: ['tomato', 'pepper', 'maize'],
        severity: 'medium',
        iconName: 'pest_control',
        symptoms: ['Visible insects', 'Leaf damage', 'Reduced yields'],
        treatments: [
          'Identify pest species correctly',
          'Use targeted treatments',
          'Encourage beneficial insects',
          'Apply organic pesticides when necessary'
        ],
        preventions: [
          'Regular crop monitoring',
          'Encourage biodiversity',
          'Use companion planting',
          'Maintain healthy soil'
        ],
        isSeasonal: false,
      ),
    ];

    debugPrint('✅ Loaded ${_allTips.length} crop care tips');
  }

  Future<void> _loadFarmingCalendar() async {
    _calendarEvents = [
      // January - Dry Season
      FarmingCalendarEvent(
        id: 'cal_001',
        title: 'Land Preparation',
        description: 'Prepare fields for the upcoming planting season',
        cropTypes: ['tomato', 'pepper', 'maize'],
        month: 1,
        category: 'preparation',
        priority: 'high',
        actionItems: [
          'Clear and prepare planting beds',
          'Test soil pH and nutrients',
          'Plan crop rotation schedule',
          'Prepare irrigation systems'
        ],
        region: 'all',
      ),

      FarmingCalendarEvent(
        id: 'cal_002',
        title: 'Dry Season Vegetables',
        description: 'Plant vegetables that can handle dry conditions',
        cropTypes: ['tomato', 'pepper'],
        month: 2,
        category: 'planting',
        priority: 'medium',
        actionItems: [
          'Start tomato seedlings in nurseries',
          'Prepare drip irrigation',
          'Plant near reliable water sources',
          'Use mulch to conserve moisture'
        ],
      ),

      // March - Pre-rainy season
      FarmingCalendarEvent(
        id: 'cal_003',
        title: 'Pre-Season Preparation',
        description: 'Get ready for the main planting season',
        cropTypes: ['maize', 'tomato', 'pepper'],
        month: 3,
        category: 'preparation',
        priority: 'high',
        actionItems: [
          'Purchase certified seeds',
          'Prepare seedbeds',
          'Check and repair tools',
          'Plan fertilizer application schedule'
        ],
      ),

      // April-May - Early rains
      FarmingCalendarEvent(
        id: 'cal_004',
        title: 'Early Season Planting',
        description: 'Begin planting with first rains',
        cropTypes: ['maize'],
        month: 4,
        category: 'planting',
        priority: 'high',
        actionItems: [
          'Plant early maize varieties',
          'Ensure proper seed depth',
          'Apply base fertilizer',
          'Monitor for pest emergence'
        ],
      ),

      FarmingCalendarEvent(
        id: 'cal_005',
        title: 'Transplanting Season',
        description: 'Transplant seedlings to main fields',
        cropTypes: ['tomato', 'pepper'],
        month: 5,
        category: 'planting',
        priority: 'high',
        actionItems: [
          'Transplant tomato seedlings',
          'Install support stakes',
          'Apply starter fertilizer',
          'Begin regular monitoring'
        ],
      ),

      // June-August - Main growing season
      FarmingCalendarEvent(
        id: 'cal_006',
        title: 'Peak Growing Season',
        description: 'Main crop care and management period',
        cropTypes: ['maize', 'tomato', 'pepper'],
        month: 6,
        category: 'care',
        priority: 'high',
        actionItems: [
          'Weekly disease monitoring',
          'Apply side-dress fertilizer to maize',
          'Weed control in all crops',
          'Monitor for fungal diseases'
        ],
      ),

      FarmingCalendarEvent(
        id: 'cal_007',
        title: 'Disease Prevention Focus',
        description: 'Critical period for disease management',
        cropTypes: ['tomato', 'pepper'],
        month: 7,
        category: 'prevention',
        priority: 'high',
        actionItems: [
          'Increase disease monitoring frequency',
          'Ensure good air circulation',
          'Apply preventive fungicide treatments',
          'Remove any infected plant material'
        ],
      ),

      // September-November - Harvest preparation
      FarmingCalendarEvent(
        id: 'cal_008',
        title: 'Harvest Preparation',
        description: 'Prepare for harvest season',
        cropTypes: ['maize', 'tomato'],
        month: 9,
        category: 'harvesting',
        priority: 'high',
        actionItems: [
          'Monitor crops for harvest readiness',
          'Prepare storage facilities',
          'Plan harvest schedule',
          'Prepare post-harvest handling equipment'
        ],
      ),

      // December - Post-harvest
      FarmingCalendarEvent(
        id: 'cal_009',
        title: 'Post-Harvest Activities',
        description: 'Complete harvest and prepare for next season',
        cropTypes: ['maize', 'tomato', 'pepper'],
        month: 12,
        category: 'harvesting',
        priority: 'medium',
        actionItems: [
          'Complete final harvests',
          'Clean and store seeds for next season',
          'Remove crop residues',
          'Plan next season crop rotation'
        ],
      ),
    ];

    debugPrint('✅ Loaded ${_calendarEvents.length} farming calendar events');
  }

  // Get tips based on user's scan history and current context
  List<CropCareTip> getPersonalizedTips(
      DetectionHistoryProvider? historyProvider) {
    if (historyProvider == null || historyProvider.detectionHistory.isEmpty) {
      // New user - return general tips and seasonal relevance
      return _getNewUserTips();
    } else {
      // Experienced user - return personalized tips
      return _getPersonalizedTipsForUser(historyProvider);
    }
  }

  List<CropCareTip> _getNewUserTips() {
    final currentMonth = DateTime.now().month;

    // Get seasonal tips + general prevention tips
    return _allTips
        .where((tip) {
          // Include prevention tips and seasonal tips relevant to current month
          if (tip.category == 'prevention') return true;
          if (tip.category == 'care') return true;
          if (tip.isSeasonal && tip.relevantMonths.contains(currentMonth))
            return true;
          return false;
        })
        .take(6)
        .toList();
  }

  List<CropCareTip> _getPersonalizedTipsForUser(
      DetectionHistoryProvider historyProvider) {
    final recentDetections = historyProvider.detectionHistory.take(10).toList();
    final detectedCrops =
        recentDetections.map((d) => d.cropName.toLowerCase()).toSet();

    // ✅ CLEANER: If you added the isDiseaseDetected getter
    final recentDiseases = recentDetections
        .where((d) => d.isDiseaseDetected)
        .map((d) => d.cropName.toLowerCase())
        .toSet();
    List<CropCareTip> personalizedTips = [];

    // 1. Disease-specific tips based on recent detections
    if (recentDiseases.isNotEmpty) {
      personalizedTips.addAll(_allTips
          .where((tip) =>
              tip.category == 'disease' &&
              recentDiseases.any((disease) => tip.isRelevantForCrop(disease)))
          .take(3));
    }

    // 2. Prevention tips for crops being grown
    personalizedTips.addAll(_allTips
        .where((tip) =>
            tip.category == 'prevention' &&
            detectedCrops.any((crop) => tip.isRelevantForCrop(crop)))
        .take(2));

    // 3. Seasonal tips
    personalizedTips.addAll(_allTips
        .where((tip) =>
            tip.isRelevantForCurrentMonth() && !personalizedTips.contains(tip))
        .take(2));

    // 4. General care tips if we need more
    if (personalizedTips.length < 5) {
      personalizedTips.addAll(_allTips
          .where((tip) =>
              tip.category == 'care' && !personalizedTips.contains(tip))
          .take(5 - personalizedTips.length));
    }

    return personalizedTips;
  }

  // Get current month's farming activities
  List<FarmingCalendarEvent> getCurrentMonthActivities() {
    final currentMonth = DateTime.now().month;
    return _calendarEvents
        .where((event) => event.month == currentMonth)
        .toList()
      ..sort((a, b) =>
          _priorityScore(b.priority).compareTo(_priorityScore(a.priority)));
  }

  // Get activities relevant to user's crops
  List<FarmingCalendarEvent> getRelevantActivities(
      DetectionHistoryProvider? historyProvider) {
    if (historyProvider == null || historyProvider.detectionHistory.isEmpty) {
      return getCurrentMonthActivities();
    }

    final userCrops = historyProvider.detectionHistory
        .map((d) => d.cropName.toLowerCase())
        .toSet();

    return getCurrentMonthActivities()
        .where((event) =>
            event.cropTypes.isEmpty ||
            userCrops.any((crop) => event.isRelevantForCrop(crop)))
        .toList();
  }

  int _priorityScore(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  // Get tips by category
  List<CropCareTip> getTipsByCategory(String category) {
    return _allTips.where((tip) => tip.category == category).toList();
  }

  // Search tips
  List<CropCareTip> searchTips(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _allTips
        .where((tip) =>
            tip.title.toLowerCase().contains(lowercaseQuery) ||
            tip.description.toLowerCase().contains(lowercaseQuery) ||
            tip.symptoms.any(
                (symptom) => symptom.toLowerCase().contains(lowercaseQuery)) ||
            tip.cropTypes
                .any((crop) => crop.toLowerCase().contains(lowercaseQuery)))
        .toList();
  }

  // Refresh data
  Future<void> refreshData() async {
    await _initializeData();
  }
}
