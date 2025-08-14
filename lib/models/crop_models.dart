import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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

  BasicInfo copyWith({
    String? displayName,
    String? cropType,
    String? condition,
    String? diseaseType,
    String? pathogen,
    String? severity,
    String? statusColor,
  }) {
    return BasicInfo(
      displayName: displayName ?? this.displayName,
      cropType: cropType ?? this.cropType,
      condition: condition ?? this.condition,
      diseaseType: diseaseType ?? this.diseaseType,
      pathogen: pathogen ?? this.pathogen,
      severity: severity ?? this.severity,
      statusColor: statusColor ?? this.statusColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'cropType': cropType,
      'condition': condition,
      'diseaseType': diseaseType,
      'pathogen': pathogen,
      'severity': severity,
      'statusColor': statusColor,
    };
  }

  factory BasicInfo.fromMap(Map<String, dynamic> map) {
    return BasicInfo(
      displayName: map['displayName'] ?? '',
      cropType: map['cropType'] ?? '',
      condition: map['condition'] ?? '',
      diseaseType: map['diseaseType'] ?? '',
      pathogen: map['pathogen'] ?? '',
      severity: map['severity'] ?? '',
      statusColor: map['statusColor'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BasicInfo.fromJsonString(String source) =>
      BasicInfo.fromMap(json.decode(source));
  @override
  String toString() {
    return 'BasicInfo(displayName: $displayName, cropType: $cropType, condition: $condition, diseaseType: $diseaseType, pathogen: $pathogen, severity: $severity, statusColor: $statusColor)';
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

  Symptoms copyWith({
    List<String>? earlyStage,
    List<String>? advancedStage,
    List<String>? affectedParts,
    String? weatherConditions,
  }) {
    return Symptoms(
      earlyStage: earlyStage ?? this.earlyStage,
      advancedStage: advancedStage ?? this.advancedStage,
      affectedParts: affectedParts ?? this.affectedParts,
      weatherConditions: weatherConditions ?? this.weatherConditions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'earlyStage': earlyStage,
      'advancedStage': advancedStage,
      'affectedParts': affectedParts,
      'weatherConditions': weatherConditions,
    };
  }

  factory Symptoms.fromMap(Map<String, dynamic> map) {
    return Symptoms(
      earlyStage: List<String>.from(map['earlyStage']),
      advancedStage: List<String>.from(map['advancedStage']),
      affectedParts: List<String>.from(map['affectedParts']),
      weatherConditions: map['weatherConditions'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Symptoms(earlyStage: $earlyStage, advancedStage: $advancedStage, affectedParts: $affectedParts, weatherConditions: $weatherConditions)';
  }
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

  Causes copyWith({
    List<String>? environmental,
    List<String>? cultural,
  }) {
    return Causes(
      environmental: environmental ?? this.environmental,
      cultural: cultural ?? this.cultural,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'environmental': environmental,
      'cultural': cultural,
    };
  }

  factory Causes.fromMap(Map<String, dynamic> map) {
    return Causes(
      environmental: List<String>.from(map['environmental']),
      cultural: List<String>.from(map['cultural']),
    );
  }

  String toJson() => json.encode(toMap());
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

  Treatment copyWith({
    List<String>? immediateAction,
    List<OrganicSolution>? organicSolutions,
    List<ChemicalSolution>? chemicalSolutions,
    List<String>? culturalPractices,
  }) {
    return Treatment(
      immediateAction: immediateAction ?? this.immediateAction,
      organicSolutions: organicSolutions ?? this.organicSolutions,
      chemicalSolutions: chemicalSolutions ?? this.chemicalSolutions,
      culturalPractices: culturalPractices ?? this.culturalPractices,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'immediateAction': immediateAction,
      'organicSolutions': organicSolutions.map((x) => x.toMap()).toList(),
      'chemicalSolutions': chemicalSolutions.map((x) => x.toMap()).toList(),
      'culturalPractices': culturalPractices,
    };
  }

  factory Treatment.fromMap(Map<String, dynamic> map) {
    return Treatment(
      immediateAction: List<String>.from(map['immediateAction']),
      organicSolutions: List<OrganicSolution>.from(
          map['organicSolutions']?.map((x) => OrganicSolution.fromMap(x))),
      chemicalSolutions: List<ChemicalSolution>.from(
          map['chemicalSolutions']?.map((x) => ChemicalSolution.fromMap(x))),
      culturalPractices: List<String>.from(map['culturalPractices']),
    );
  }

  String toJson() => json.encode(toMap());
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

  OrganicSolution copyWith({
    String? method,
    ValueGetter<String?>? activeIngredient,
    ValueGetter<String?>? application,
    ValueGetter<String?>? timing,
    ValueGetter<String?>? note,
  }) {
    return OrganicSolution(
      method: method ?? this.method,
      activeIngredient:
          activeIngredient != null ? activeIngredient() : this.activeIngredient,
      application: application != null ? application() : this.application,
      timing: timing != null ? timing() : this.timing,
      note: note != null ? note() : this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'activeIngredient': activeIngredient,
      'application': application,
      'timing': timing,
      'note': note,
    };
  }

  factory OrganicSolution.fromMap(Map<String, dynamic> map) {
    return OrganicSolution(
      method: map['method'] ?? '',
      activeIngredient: map['activeIngredient'],
      application: map['application'],
      timing: map['timing'],
      note: map['note'],
    );
  }

  String toJson() => json.encode(toMap());
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

  ChemicalSolution copyWith({
    String? activeIngredient,
    ValueGetter<List<String>?>? tradeNames,
    ValueGetter<String?>? applicationRate,
    ValueGetter<String?>? timing,
    ValueGetter<String?>? note,
  }) {
    return ChemicalSolution(
      activeIngredient: activeIngredient ?? this.activeIngredient,
      tradeNames: tradeNames != null ? tradeNames() : this.tradeNames,
      applicationRate:
          applicationRate != null ? applicationRate() : this.applicationRate,
      timing: timing != null ? timing() : this.timing,
      note: note != null ? note() : this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activeIngredient': activeIngredient,
      'tradeNames': tradeNames,
      'applicationRate': applicationRate,
      'timing': timing,
      'note': note,
    };
  }

  factory ChemicalSolution.fromMap(Map<String, dynamic> map) {
    return ChemicalSolution(
      activeIngredient: map['activeIngredient'] ?? '',
      tradeNames: List<String>.from(map['tradeNames']),
      applicationRate: map['applicationRate'],
      timing: map['timing'],
      note: map['note'],
    );
  }

  String toJson() => json.encode(toMap());
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

  Prevention copyWith({
    ValueGetter<List<String>?>? resistantVarieties,
    List<String>? bestPractices,
  }) {
    return Prevention(
      resistantVarieties: resistantVarieties != null
          ? resistantVarieties()
          : this.resistantVarieties,
      bestPractices: bestPractices ?? this.bestPractices,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resistantVarieties': resistantVarieties,
      'bestPractices': bestPractices,
    };
  }

  factory Prevention.fromMap(Map<String, dynamic> map) {
    return Prevention(
      resistantVarieties: List<String>.from(map['resistantVarieties']),
      bestPractices: List<String>.from(map['bestPractices']),
    );
  }

  String toJson() => json.encode(toMap());
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

  WateringInfo copyWith({
    String? frequency,
    String? amount,
    ValueGetter<List<String>?>? criticalStages,
  }) {
    return WateringInfo(
      frequency: frequency ?? this.frequency,
      amount: amount ?? this.amount,
      criticalStages:
          criticalStages != null ? criticalStages() : this.criticalStages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency,
      'amount': amount,
      'criticalStages': criticalStages,
    };
  }

  factory WateringInfo.fromMap(Map<String, dynamic> map) {
    return WateringInfo(
      frequency: map['frequency'] ?? '',
      amount: map['amount'] ?? '',
      criticalStages: List<String>.from(map['criticalStages']),
    );
  }

  String toJson() => json.encode(toMap());
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

  FertilizationInfo copyWith({
    String? nitrogen,
    String? phosphorus,
    String? potassium,
    ValueGetter<List<String>?>? timing,
  }) {
    return FertilizationInfo(
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      timing: timing != null ? timing() : this.timing,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'timing': timing,
    };
  }

  factory FertilizationInfo.fromMap(Map<String, dynamic> map) {
    return FertilizationInfo(
      nitrogen: map['nitrogen'] ?? '',
      phosphorus: map['phosphorus'] ?? '',
      potassium: map['potassium'] ?? '',
      timing: List<String>.from(map['timing']),
    );
  }

  String toJson() => json.encode(toMap());
}

class EconomicImpact {
  final String? yieldLoss;
  final String? qualityImpact;
  final String? treatmentCost;
  final String? criticalPeriod;

  EconomicImpact({
    this.yieldLoss,
    this.qualityImpact,
    this.treatmentCost,
    this.criticalPeriod,
  });

  factory EconomicImpact.fromJson(Map<String, dynamic> json) {
    return EconomicImpact(
      yieldLoss: json['yield_loss'],
      qualityImpact: json['quality_impact'],
      treatmentCost: json['treatment_cost'],
      criticalPeriod: json['critical_period'],
    );
  }

  EconomicImpact copyWith({
    ValueGetter<String?>? yieldLoss,
    ValueGetter<String?>? qualityImpact,
    ValueGetter<String?>? treatmentCost,
    ValueGetter<String?>? criticalPeriod,
  }) {
    return EconomicImpact(
      yieldLoss: yieldLoss != null ? yieldLoss() : this.yieldLoss,
      qualityImpact:
          qualityImpact != null ? qualityImpact() : this.qualityImpact,
      treatmentCost:
          treatmentCost != null ? treatmentCost() : this.treatmentCost,
      criticalPeriod:
          criticalPeriod != null ? criticalPeriod() : this.criticalPeriod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'yieldLoss': yieldLoss,
      'qualityImpact': qualityImpact,
      'treatmentCost': treatmentCost,
      'criticalPeriod': criticalPeriod,
    };
  }

  factory EconomicImpact.fromMap(Map<String, dynamic> map) {
    return EconomicImpact(
      yieldLoss: map['yieldLoss'],
      qualityImpact: map['qualityImpact'],
      treatmentCost: map['treatmentCost'],
      criticalPeriod: map['criticalPeriod'],
    );
  }

  String toJson() => json.encode(toMap());
}

class FarmSizeImpact {
  final String? smallFarm;
  final String? mediumFarm;

  FarmSizeImpact({
    this.smallFarm,
    this.mediumFarm,
  });

  factory FarmSizeImpact.fromJson(Map<String, dynamic> json) {
    return FarmSizeImpact(
      smallFarm: json['small_farm'],
      mediumFarm: json['medium_farm'],
    );
  }

  FarmSizeImpact copyWith({
    ValueGetter<String?>? smallFarm,
    ValueGetter<String?>? mediumFarm,
  }) {
    return FarmSizeImpact(
      smallFarm: smallFarm != null ? smallFarm() : this.smallFarm,
      mediumFarm: mediumFarm != null ? mediumFarm() : this.mediumFarm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'smallFarm': smallFarm,
      'mediumFarm': mediumFarm,
    };
  }

  factory FarmSizeImpact.fromMap(Map<String, dynamic> map) {
    return FarmSizeImpact(
      smallFarm: map['smallFarm'],
      mediumFarm: map['mediumFarm'],
    );
  }

  String toJson() => json.encode(toMap());
}

class LaborImpact {
  final String? hoursRequired;
  final String? skillLevel;
  final String? timingConstraints;

  LaborImpact({
    this.hoursRequired,
    this.skillLevel,
    this.timingConstraints,
  });

  factory LaborImpact.fromJson(Map<String, dynamic> json) {
    return LaborImpact(
      hoursRequired: json['hours_required'],
      skillLevel: json['skill_level'],
      timingConstraints: json['timing_constraints'],
    );
  }

  LaborImpact copyWith({
    ValueGetter<String?>? hoursRequired,
    ValueGetter<String?>? skillLevel,
    ValueGetter<String?>? timingConstraints,
  }) {
    return LaborImpact(
      hoursRequired:
          hoursRequired != null ? hoursRequired() : this.hoursRequired,
      skillLevel: skillLevel != null ? skillLevel() : this.skillLevel,
      timingConstraints: timingConstraints != null
          ? timingConstraints()
          : this.timingConstraints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hoursRequired': hoursRequired,
      'skillLevel': skillLevel,
      'timingConstraints': timingConstraints,
    };
  }

  factory LaborImpact.fromMap(Map<String, dynamic> map) {
    return LaborImpact(
      hoursRequired: map['hoursRequired'],
      skillLevel: map['skillLevel'],
      timingConstraints: map['timingConstraints'],
    );
  }

  String toJson() => json.encode(toMap());
}

class CommunityImpact {
  final String? spreadRisk;
  final String? collectiveAction;

  CommunityImpact({
    this.spreadRisk,
    this.collectiveAction,
  });

  factory CommunityImpact.fromJson(Map<String, dynamic> json) {
    return CommunityImpact(
      spreadRisk: json['spread_risk'],
      collectiveAction: json['collective_action'],
    );
  }

  CommunityImpact copyWith({
    ValueGetter<String?>? spreadRisk,
    ValueGetter<String?>? collectiveAction,
  }) {
    return CommunityImpact(
      spreadRisk: spreadRisk != null ? spreadRisk() : this.spreadRisk,
      collectiveAction:
          collectiveAction != null ? collectiveAction() : this.collectiveAction,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'spreadRisk': spreadRisk,
      'collectiveAction': collectiveAction,
    };
  }

  factory CommunityImpact.fromMap(Map<String, dynamic> map) {
    return CommunityImpact(
      spreadRisk: map['spreadRisk'],
      collectiveAction: map['collectiveAction'],
    );
  }

  String toJson() => json.encode(toMap());
}

class LocalResourcesGhana {
  final String? extensionServices;
  final String? farmerGroups;
  final String? phoneSupport;

  LocalResourcesGhana({
    this.extensionServices,
    this.farmerGroups,
    this.phoneSupport,
  });

  factory LocalResourcesGhana.fromJson(Map<String, dynamic> json) {
    return LocalResourcesGhana(
      extensionServices: json['extension_services'],
      farmerGroups: json['farmer_groups'],
      phoneSupport: json['phone_support'],
    );
  }

  LocalResourcesGhana copyWith({
    ValueGetter<String?>? extensionServices,
    ValueGetter<String?>? farmerGroups,
    ValueGetter<String?>? phoneSupport,
  }) {
    return LocalResourcesGhana(
      extensionServices: extensionServices != null
          ? extensionServices()
          : this.extensionServices,
      farmerGroups: farmerGroups != null ? farmerGroups() : this.farmerGroups,
      phoneSupport: phoneSupport != null ? phoneSupport() : this.phoneSupport,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'extensionServices': extensionServices,
      'farmerGroups': farmerGroups,
      'phoneSupport': phoneSupport,
    };
  }

  factory LocalResourcesGhana.fromMap(Map<String, dynamic> map) {
    return LocalResourcesGhana(
      extensionServices: map['extensionServices'],
      farmerGroups: map['farmerGroups'],
      phoneSupport: map['phoneSupport'],
    );
  }

  String toJson() => json.encode(toMap());
}

// Update your existing Maintenance class to include missing fertilization property
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

  // Add this missing property that your UI tries to access
  String get fertilizationString => fertilization != null
      ? 'N: ${fertilization!.nitrogen}, P: ${fertilization!.phosphorus}, K: ${fertilization!.potassium}'
      : 'Standard fertilization as needed';

  Maintenance copyWith({
    ValueGetter<WateringInfo?>? watering,
    ValueGetter<FertilizationInfo?>? fertilization,
    ValueGetter<MonitoringInfo?>? monitoring,
  }) {
    return Maintenance(
      watering: watering != null ? watering() : this.watering,
      fertilization:
          fertilization != null ? fertilization() : this.fertilization,
      monitoring: monitoring != null ? monitoring() : this.monitoring,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'watering': watering?.toMap(),
      'fertilization': fertilization?.toMap(),
      'monitoring': monitoring?.toMap(),
    };
  }

  factory Maintenance.fromMap(Map<String, dynamic> map) {
    return Maintenance(
      watering: map['watering'] != null
          ? WateringInfo.fromMap(map['watering'])
          : null,
      fertilization: map['fertilization'] != null
          ? FertilizationInfo.fromMap(map['fertilization'])
          : null,
      monitoring: map['monitoring'] != null
          ? MonitoringInfo.fromMap(map['monitoring'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());
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

  MonitoringInfo copyWith({
    ValueGetter<List<String>?>? growthStages,
    ValueGetter<List<String>?>? keyMetrics,
  }) {
    return MonitoringInfo(
      growthStages: growthStages != null ? growthStages() : this.growthStages,
      keyMetrics: keyMetrics != null ? keyMetrics() : this.keyMetrics,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'growthStages': growthStages,
      'keyMetrics': keyMetrics,
    };
  }

  factory MonitoringInfo.fromMap(Map<String, dynamic> map) {
    return MonitoringInfo(
      growthStages: List<String>.from(map['growthStages']),
      keyMetrics: List<String>.from(map['keyMetrics']),
    );
  }
}
