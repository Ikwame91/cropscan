class BasicInfo {
  final String displayName;
  final String cropType;

  final String condition;
  final String diseaseType;
  final String pathogen;
  final String severity;
  final String statusColor;

  BasicInfo({
    required this.displayName,
    required this.cropType,
    required this.condition,
    required this.diseaseType,
    required this.pathogen,
    required this.severity,
    required this.statusColor,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      displayName: json['display_name'] ?? '',
      cropType: json['crop_type'] ?? '',
      condition: json['condition'] ?? '',
      diseaseType: json['disease_type'] ?? '',
      pathogen: json['pathogen'] ?? '',
      severity: json['severity'] ?? '',
      statusColor: json['status_color'] ?? '#4CAF50',
    );
  }
}

class Symptoms {
  final List<String> earlyStage;
  final List<String> advancedStage;
  final List<String> affectedParts;
  final String weatherConditions;

  Symptoms({
    required this.earlyStage,
    required this.advancedStage,
    required this.affectedParts,
    required this.weatherConditions,
  });

  factory Symptoms.fromJson(Map<String, dynamic> json) {
    return Symptoms(
      earlyStage: List<String>.from(json['early_stage'] ?? []),
      advancedStage: List<String>.from(json['advanced_stage'] ?? []),
      affectedParts: List<String>.from(json['affected_parts'] ?? []),
      weatherConditions: json['weather_conditions'] ?? '',
    );
  }

  // Helper methods for backward compatibility
  String get early => earlyStage.join(', ');
  String get advanced => advancedStage.join(', ');
}

class Causes {
  final List<String> environmental;
  final List<String> cultural;

  Causes({
    required this.environmental,
    required this.cultural,
  });

  factory Causes.fromJson(Map<String, dynamic> json) {
    return Causes(
      environmental: List<String>.from(json['environmental'] ?? []),
      cultural: List<String>.from(json['cultural'] ?? []),
    );
  }

  // Helper methods for backward compatibility
  String get environmentalString => environmental.join(', ');
  String get culturalString => cultural.join(', ');
}

class Treatment {
  final List<String> immediateAction;
  final List<OrganicSolution> organicSolutions;
  final List<ChemicalSolution> chemicalSolutions;
  final List<String> culturalPractices;

  Treatment({
    required this.immediateAction,
    required this.organicSolutions,
    required this.chemicalSolutions,
    required this.culturalPractices,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      immediateAction: List<String>.from(json['immediate_action'] ?? []),
      organicSolutions: (json['organic_solutions'] as List?)
              ?.map((e) => OrganicSolution.fromJson(e))
              .toList() ??
          [],
      chemicalSolutions: (json['chemical_solutions'] as List?)
              ?.map((e) => ChemicalSolution.fromJson(e))
              .toList() ??
          [],
      culturalPractices: List<String>.from(json['cultural_practices'] ?? []),
    );
  }

  // Helper methods for backward compatibility
  String get chemical => chemicalSolutions.isNotEmpty
      ? chemicalSolutions.map((e) => e.activeIngredient).join(', ')
      : 'No chemical treatment specified';

  String get organic => organicSolutions.isNotEmpty
      ? organicSolutions.map((e) => e.method).join(', ')
      : 'No organic treatment specified';
}

class OrganicSolution {
  final String method;
  final String? activeIngredient;
  final String? application;
  final String? timing;
  final String? note;

  OrganicSolution({
    required this.method,
    this.activeIngredient,
    this.application,
    this.timing,
    this.note,
  });

  factory OrganicSolution.fromJson(Map<String, dynamic> json) {
    return OrganicSolution(
      method: json['method'] ?? '',
      activeIngredient: json['active_ingredient'],
      application: json['application'],
      timing: json['timing'],
      note: json['note'],
    );
  }
}

class ChemicalSolution {
  final String activeIngredient;
  final List<String>? tradeNames;
  final String? applicationRate;
  final String? timing;
  final String? note;

  ChemicalSolution({
    required this.activeIngredient,
    this.tradeNames,
    this.applicationRate,
    this.timing,
    this.note,
  });

  factory ChemicalSolution.fromJson(Map<String, dynamic> json) {
    return ChemicalSolution(
      activeIngredient: json['active_ingredient'] ?? '',
      tradeNames: json['trade_names'] != null
          ? List<String>.from(json['trade_names'])
          : null,
      applicationRate: json['application_rate'],
      timing: json['timing'],
      note: json['note'],
    );
  }
}

class Prevention {
  final List<String>? resistantVarieties;
  final List<String> bestPractices;

  Prevention({
    this.resistantVarieties,
    required this.bestPractices,
  });

  factory Prevention.fromJson(Map<String, dynamic> json) {
    return Prevention(
      resistantVarieties: json['resistant_varieties'] != null
          ? List<String>.from(json['resistant_varieties'])
          : null,
      bestPractices: List<String>.from(json['best_practices'] ?? []),
    );
  }

  // Helper methods for backward compatibility
  String get culturalPractices => bestPractices.join(', ');
  String get chemicalControl =>
      resistantVarieties?.join(', ') ?? 'Use resistant varieties';
}

class Maintenance {
  final WateringInfo? watering;
  final FertilizationInfo? fertilization;
  final MonitoringInfo? monitoring;

  Maintenance({
    this.watering,
    this.fertilization,
    this.monitoring,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      watering: json['watering'] != null
          ? WateringInfo.fromJson(json['watering'])
          : null,
      fertilization: json['fertilization'] != null
          ? FertilizationInfo.fromJson(json['fertilization'])
          : null,
      monitoring: json['monitoring'] != null
          ? MonitoringInfo.fromJson(json['monitoring'])
          : null,
    );
  }

  // Helper methods for backward compatibility
  String get irrigation => watering != null
      ? '${watering!.frequency} - ${watering!.amount}'
      : 'Regular watering as needed';
}

class WateringInfo {
  final String frequency;
  final String amount;
  final List<String>? criticalStages;

  WateringInfo({
    required this.frequency,
    required this.amount,
    this.criticalStages,
  });

  factory WateringInfo.fromJson(Map<String, dynamic> json) {
    return WateringInfo(
      frequency: json['frequency'] ?? '',
      amount: json['amount'] ?? '',
      criticalStages: json['critical_stages'] != null
          ? List<String>.from(json['critical_stages'])
          : null,
    );
  }
}

class FertilizationInfo {
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final List<String>? timing;

  FertilizationInfo({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    this.timing,
  });

  factory FertilizationInfo.fromJson(Map<String, dynamic> json) {
    return FertilizationInfo(
      nitrogen: json['nitrogen'] ?? '',
      phosphorus: json['phosphorus'] ?? '',
      potassium: json['potassium'] ?? '',
      timing: json['timing'] != null ? List<String>.from(json['timing']) : null,
    );
  }
}

class MonitoringInfo {
  final List<String>? growthStages;
  final List<String>? keyMetrics;

  MonitoringInfo({
    this.growthStages,
    this.keyMetrics,
  });

  factory MonitoringInfo.fromJson(Map<String, dynamic> json) {
    return MonitoringInfo(
      growthStages: json['growth_stages'] != null
          ? List<String>.from(json['growth_stages'])
          : null,
      keyMetrics: json['key_metrics'] != null
          ? List<String>.from(json['key_metrics'])
          : null,
    );
  }
}
