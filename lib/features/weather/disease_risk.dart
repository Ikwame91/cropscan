import 'package:cropscan_pro/data/knowledge/crop_label.dart';
import 'package:cropscan_pro/features/weather/weather_forecast.dart';

enum RiskLevel { low, medium, high }

/// The weather a disease needs, taken from the `weather_conditions` text in
/// `crop_database.json`.
class DiseaseWeatherProfile {
  final String rawLabel;
  final double minTemp;
  final double maxTemp;

  /// Relative humidity at or above which leaves count as wet (rain also
  /// counts). Ignored for [dry] profiles.
  final double wetHumidity;

  /// Favoured by hot, dry weather (spider mites in the harmattan) rather
  /// than leaf wetness.
  final bool dry;

  const DiseaseWeatherProfile(
    this.rawLabel,
    this.minTemp,
    this.maxTemp, {
    this.wetHumidity = 90,
    this.dry = false,
  });
}

class DiseaseRisk {
  final String rawLabel;
  final RiskLevel level;

  /// Most favourable hours in a single day of the forecast.
  final int favourableHours;
  final DateTime day;

  const DiseaseRisk(this.rawLabel, this.level, this.favourableHours, this.day);

  String get crop => CropLabel.parse(rawLabel).crop;
}

/// Estimates which diseases the coming days' weather favours.
///
/// This is a rule of thumb for prompting farmers to scout and protect
/// crops, not a validated epidemiological model: about 10 hours of leaf
/// wetness at the right temperature is a common infection threshold for the
/// fungal and bacterial leaf diseases covered here.
class DiseaseRiskAssessor {
  static const int highWetHours = 10;
  static const int mediumWetHours = 6;
  static const int highDryHours = 6;
  static const int mediumDryHours = 3;
  static const double dryMaxHumidity = 50;
  static const double dryMinTemp = 30;
  static const double rainThresholdMm = 0.1;

  static const List<DiseaseWeatherProfile> profiles = [
    DiseaseWeatherProfile(
        'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot', 22, 30),
    DiseaseWeatherProfile('Corn_(maize)___Common_rust_', 16, 23),
    DiseaseWeatherProfile('Corn_(maize)___Northern_Leaf_Blight', 18, 27),
    DiseaseWeatherProfile('Pepper__bell___Bacterial_spot', 24, 30),
    DiseaseWeatherProfile('Tomato_Bacterial_spot', 24, 30),
    DiseaseWeatherProfile('Tomato_Early_blight', 24, 29),
    DiseaseWeatherProfile('Tomato_Late_blight', 18, 22),
    DiseaseWeatherProfile('Tomato_Leaf_Mold', 22, 24, wetHumidity: 85),
    DiseaseWeatherProfile('Tomato_Septoria_leaf_spot', 20, 30),
    DiseaseWeatherProfile('Tomato__Target_Spot', 25, 30),
    DiseaseWeatherProfile(
        'Tomato_Spider_mites_Two_spotted_spider_mite', dryMinTemp, 45,
        dry: true),
  ];

  /// Risks for the days covered by [hourly] from [now] on, highest first.
  /// When [crops] is given (e.g. {"Tomato"}), only those crops' diseases are
  /// assessed.
  static List<DiseaseRisk> assess(
    List<HourlyWeather> hourly, {
    required DateTime now,
    Set<String>? crops,
  }) {
    final from = DateTime(now.year, now.month, now.day, now.hour);
    final upcoming = hourly.where((h) => !h.time.isBefore(from)).toList();

    final risks = <DiseaseRisk>[];
    for (final profile in profiles) {
      if (crops != null &&
          crops.isNotEmpty &&
          !crops.contains(CropLabel.parse(profile.rawLabel).crop)) {
        continue;
      }

      final hoursByDay = <DateTime, int>{};
      for (final h in upcoming) {
        if (_favours(profile, h)) {
          final day = DateTime(h.time.year, h.time.month, h.time.day);
          hoursByDay[day] = (hoursByDay[day] ?? 0) + 1;
        }
      }
      if (hoursByDay.isEmpty) continue;

      final worst =
          hoursByDay.entries.reduce((a, b) => b.value > a.value ? b : a);
      final level = _level(profile, worst.value);
      if (level != RiskLevel.low) {
        risks.add(DiseaseRisk(profile.rawLabel, level, worst.value, worst.key));
      }
    }

    risks.sort((a, b) {
      final byLevel = b.level.index.compareTo(a.level.index);
      return byLevel != 0
          ? byLevel
          : b.favourableHours.compareTo(a.favourableHours);
    });
    return risks;
  }

  static bool _favours(DiseaseWeatherProfile p, HourlyWeather h) {
    final inRange = h.temperature >= p.minTemp && h.temperature <= p.maxTemp;
    if (!inRange) return false;
    if (p.dry) {
      return h.humidity < dryMaxHumidity && h.precipitation < rainThresholdMm;
    }
    return h.humidity >= p.wetHumidity || h.precipitation >= rainThresholdMm;
  }

  static RiskLevel _level(DiseaseWeatherProfile p, int hours) {
    final high = p.dry ? highDryHours : highWetHours;
    final medium = p.dry ? mediumDryHours : mediumWetHours;
    if (hours >= high) return RiskLevel.high;
    if (hours >= medium) return RiskLevel.medium;
    return RiskLevel.low;
  }
}
