import 'package:cropscan_pro/data/models/disease_sections.dart';

/// Everything `crop_database.json` knows about one model label.
class DiseaseInfo {
  final BasicInfo basicInfo;
  final Symptoms? symptoms;
  final Causes? causes;
  final Treatment? treatment;
  final Prevention? prevention;
  final Maintenance? maintenance;
  final EconomicImpact? economicImpact;
  final FarmSizeImpact? farmSizeImpact;
  final LaborImpact? laborImpact;
  final CommunityImpact? communityImpact;
  final MonitoringInfo? monitoring;
  final String? localTipsGhana;

  DiseaseInfo({
    required this.basicInfo,
    this.symptoms,
    this.causes,
    this.treatment,
    this.prevention,
    this.maintenance,
    this.economicImpact,
    this.farmSizeImpact,
    this.laborImpact,
    this.communityImpact,
    this.monitoring,
    this.localTipsGhana,
  });

  factory DiseaseInfo.fromJson(Map<String, dynamic> json) {
    return DiseaseInfo(
      basicInfo: BasicInfo.fromJson(json['basic_info']),
      symptoms:
          json['symptoms'] != null ? Symptoms.fromJson(json['symptoms']) : null,
      causes: json['causes'] != null ? Causes.fromJson(json['causes']) : null,
      treatment: json['treatment'] != null
          ? Treatment.fromJson(json['treatment'])
          : null,
      prevention: json['prevention'] != null
          ? Prevention.fromJson(json['prevention'])
          : null,
      maintenance: json['maintenance'] != null
          ? Maintenance.fromJson(json['maintenance'])
          : null,
      economicImpact: json['economic_impact'] != null
          ? EconomicImpact.fromJson(json['economic_impact'])
          : null,
      farmSizeImpact: json['farm_size_impact'] != null
          ? FarmSizeImpact.fromJson(json['farm_size_impact'])
          : null,
      laborImpact: json['labor_impact'] != null
          ? LaborImpact.fromJson(json['labor_impact'])
          : null,
      communityImpact: json['community_impact'] != null
          ? CommunityImpact.fromJson(json['community_impact'])
          : null,
      monitoring: json['monitoring'] != null
          ? MonitoringInfo.fromJson(json['monitoring'])
          : null,
      localTipsGhana: json['local_tips_ghana'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'basic_info': basicInfo.toMap(),
      'symptoms': symptoms?.toMap(),
      'causes': causes?.toMap(),
      'treatment': treatment?.toMap(),
      'prevention': prevention?.toMap(),
      'maintenance': maintenance?.toMap(),
      'economic_impact': economicImpact?.toMap(),
      'farm_size_impact': farmSizeImpact?.toMap(),
      'labor_impact': laborImpact?.toMap(),
      'community_impact': communityImpact?.toMap(),
      'monitoring': monitoring?.toMap(),
      'local_tips_ghana': localTipsGhana,
    };
  }

  factory DiseaseInfo.fromMap(Map<String, dynamic> json) {
    return DiseaseInfo(
      basicInfo: BasicInfo.fromMap(json['basic_info']),
      symptoms:
          json['symptoms'] != null ? Symptoms.fromMap(json['symptoms']) : null,
      causes: json['causes'] != null ? Causes.fromMap(json['causes']) : null,
      treatment: json['treatment'] != null
          ? Treatment.fromMap(json['treatment'])
          : null,
      prevention: json['prevention'] != null
          ? Prevention.fromMap(json['prevention'])
          : null,
      maintenance: json['maintenance'] != null
          ? Maintenance.fromMap(json['maintenance'])
          : null,
      economicImpact: json['economic_impact'] != null
          ? EconomicImpact.fromMap(json['economic_impact'])
          : null,
      farmSizeImpact: json['farm_size_impact'] != null
          ? FarmSizeImpact.fromMap(json['farm_size_impact'])
          : null,
      laborImpact: json['labor_impact'] != null
          ? LaborImpact.fromMap(json['labor_impact'])
          : null,
      communityImpact: json['community_impact'] != null
          ? CommunityImpact.fromMap(json['community_impact'])
          : null,
      monitoring: json['monitoring'] != null
          ? MonitoringInfo.fromMap(json['monitoring'])
          : null,
      localTipsGhana: json['local_tips_ghana'],
    );
  }
}
