/// Weather for one location, parsed from an Open-Meteo forecast response.
class WeatherForecast {
  final String place;
  final DateTime fetchedAt;
  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  const WeatherForecast({
    required this.place,
    required this.fetchedAt,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  /// [json] is the API response; [place] and [fetchedAt] are ours.
  factory WeatherForecast.fromOpenMeteo(
    Map<String, dynamic> json, {
    required String place,
    required DateTime fetchedAt,
  }) {
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    List<T?> col<T>(Map<String, dynamic> m, String key) =>
        (m[key] as List? ?? const []).map((v) => v as T?).toList();
    double? d(num? v) => v?.toDouble();

    final hourTimes = col<String>(hourly, 'time');
    final hourTemp = col<num>(hourly, 'temperature_2m');
    final hourRh = col<num>(hourly, 'relative_humidity_2m');
    final hourRain = col<num>(hourly, 'precipitation');

    final dayTimes = col<String>(daily, 'time');
    final dayCode = col<num>(daily, 'weather_code');
    final dayMax = col<num>(daily, 'temperature_2m_max');
    final dayMin = col<num>(daily, 'temperature_2m_min');
    final dayRain = col<num>(daily, 'precipitation_sum');
    final dayRainChance = col<num>(daily, 'precipitation_probability_max');

    T? at<T>(List<T?> list, int i) => i < list.length ? list[i] : null;

    return WeatherForecast(
      place: place,
      fetchedAt: fetchedAt,
      current: CurrentWeather(
        time: DateTime.parse(current['time'] as String),
        temperature: (current['temperature_2m'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toDouble(),
        precipitation: d(current['precipitation'] as num?) ?? 0,
        windSpeed: d(current['wind_speed_10m'] as num?) ?? 0,
        weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      ),
      hourly: [
        for (var i = 0; i < hourTimes.length; i++)
          if (hourTimes[i] != null &&
              at(hourTemp, i) != null &&
              at(hourRh, i) != null)
            HourlyWeather(
              time: DateTime.parse(hourTimes[i]!),
              temperature: at(hourTemp, i)!.toDouble(),
              humidity: at(hourRh, i)!.toDouble(),
              precipitation: d(at(hourRain, i)) ?? 0,
            ),
      ],
      daily: [
        for (var i = 0; i < dayTimes.length; i++)
          if (dayTimes[i] != null)
            DailyWeather(
              date: DateTime.parse(dayTimes[i]!),
              weatherCode: at(dayCode, i)?.toInt() ?? 0,
              maxTemperature: d(at(dayMax, i)),
              minTemperature: d(at(dayMin, i)),
              precipitationSum: d(at(dayRain, i)),
              precipitationChance: d(at(dayRainChance, i)),
            ),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
        'place': place,
        'fetchedAt': fetchedAt.toIso8601String(),
        'current': current.toJson(),
        'hourly': hourly.map((h) => h.toJson()).toList(),
        'daily': daily.map((d) => d.toJson()).toList(),
      };

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      WeatherForecast(
        place: json['place'] as String,
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        current: CurrentWeather.fromJson(
            Map<String, dynamic>.from(json['current'] as Map)),
        hourly: [
          for (final h in json['hourly'] as List)
            HourlyWeather.fromJson(Map<String, dynamic>.from(h as Map)),
        ],
        daily: [
          for (final d in json['daily'] as List)
            DailyWeather.fromJson(Map<String, dynamic>.from(d as Map)),
        ],
      );
}

class CurrentWeather {
  final DateTime time;
  final double temperature;
  final double humidity;
  final double precipitation;
  final double windSpeed;
  final int weatherCode;

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCode,
  });

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'temperature': temperature,
        'humidity': humidity,
        'precipitation': precipitation,
        'windSpeed': windSpeed,
        'weatherCode': weatherCode,
      };

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
        time: DateTime.parse(json['time'] as String),
        temperature: (json['temperature'] as num).toDouble(),
        humidity: (json['humidity'] as num).toDouble(),
        precipitation: (json['precipitation'] as num).toDouble(),
        windSpeed: (json['windSpeed'] as num).toDouble(),
        weatherCode: json['weatherCode'] as int,
      );
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final double humidity;
  final double precipitation;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
  });

  Map<String, dynamic> toJson() => {
        't': time.toIso8601String(),
        'temp': temperature,
        'rh': humidity,
        'rain': precipitation,
      };

  factory HourlyWeather.fromJson(Map<String, dynamic> json) => HourlyWeather(
        time: DateTime.parse(json['t'] as String),
        temperature: (json['temp'] as num).toDouble(),
        humidity: (json['rh'] as num).toDouble(),
        precipitation: (json['rain'] as num).toDouble(),
      );
}

class DailyWeather {
  final DateTime date;
  final int weatherCode;
  final double? maxTemperature;
  final double? minTemperature;
  final double? precipitationSum;
  final double? precipitationChance;

  const DailyWeather({
    required this.date,
    required this.weatherCode,
    this.maxTemperature,
    this.minTemperature,
    this.precipitationSum,
    this.precipitationChance,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'code': weatherCode,
        'max': maxTemperature,
        'min': minTemperature,
        'rain': precipitationSum,
        'rainChance': precipitationChance,
      };

  factory DailyWeather.fromJson(Map<String, dynamic> json) => DailyWeather(
        date: DateTime.parse(json['date'] as String),
        weatherCode: json['code'] as int,
        maxTemperature: (json['max'] as num?)?.toDouble(),
        minTemperature: (json['min'] as num?)?.toDouble(),
        precipitationSum: (json['rain'] as num?)?.toDouble(),
        precipitationChance: (json['rainChance'] as num?)?.toDouble(),
      );
}

/// WMO weather interpretation codes, as used by Open-Meteo.
class WeatherCode {
  static String describe(int code) => switch (code) {
        0 => 'Clear sky',
        1 => 'Mainly clear',
        2 => 'Partly cloudy',
        3 => 'Overcast',
        45 || 48 => 'Fog',
        51 || 53 || 55 => 'Drizzle',
        56 || 57 => 'Freezing drizzle',
        61 => 'Light rain',
        63 => 'Rain',
        65 => 'Heavy rain',
        66 || 67 => 'Freezing rain',
        71 || 73 || 75 || 77 => 'Snow',
        80 => 'Light showers',
        81 => 'Showers',
        82 => 'Heavy showers',
        85 || 86 => 'Snow showers',
        95 => 'Thunderstorm',
        96 || 99 => 'Thunderstorm with hail',
        _ => 'Unknown',
      };

  /// A Material icon name for [CustomIconWidget].
  static String iconName(int code) => switch (code) {
        0 || 1 => 'wb_sunny',
        2 => 'wb_cloudy',
        3 || 45 || 48 => 'cloud',
        >= 51 && <= 67 || >= 80 && <= 82 => 'umbrella',
        >= 95 => 'thunderstorm',
        _ => 'cloud',
      };
}
