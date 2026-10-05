import 'dart:convert';

import 'package:cropscan_pro/features/weather/ghana_regions.dart';
import 'package:cropscan_pro/features/weather/weather_forecast.dart';
import 'package:http/http.dart' as http;

/// Fetches forecasts from Open-Meteo (https://open-meteo.com): free, no API
/// key, CC BY 4.0.
class WeatherService {
  static const Duration timeout = Duration(seconds: 10);

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  static Uri forecastUri(GhanaRegion region) => Uri.https(
        'api.open-meteo.com',
        '/v1/forecast',
        {
          'latitude': region.latitude.toString(),
          'longitude': region.longitude.toString(),
          'current': 'temperature_2m,relative_humidity_2m,precipitation,'
              'weather_code,wind_speed_10m',
          'hourly': 'temperature_2m,relative_humidity_2m,precipitation',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min,'
              'precipitation_sum,precipitation_probability_max',
          'forecast_days': '3',
          'timezone': 'auto',
        },
      );

  Future<WeatherForecast> fetch(GhanaRegion region, {DateTime? now}) async {
    final response = await _client.get(forecastUri(region)).timeout(timeout);
    if (response.statusCode != 200) {
      throw WeatherException('Weather service returned ${response.statusCode}');
    }
    return WeatherForecast.fromOpenMeteo(
      json.decode(response.body) as Map<String, dynamic>,
      place: region.capital,
      fetchedAt: now ?? DateTime.now(),
    );
  }
}

class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => message;
}
