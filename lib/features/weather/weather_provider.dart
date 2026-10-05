import 'package:cropscan_pro/core/storage/json_file_store.dart';
import 'package:cropscan_pro/features/weather/disease_risk.dart';
import 'package:cropscan_pro/features/weather/ghana_regions.dart';
import 'package:cropscan_pro/features/weather/weather_forecast.dart';
import 'package:cropscan_pro/features/weather/weather_service.dart';
import 'package:flutter/foundation.dart';

/// Weather for the farmer's region. Shows the last saved forecast at once,
/// refreshes it when older than [maxAge], and keeps showing it offline.
class WeatherProvider extends ChangeNotifier {
  static const Duration maxAge = Duration(hours: 3);

  final WeatherService _service;
  final JsonFileStore _cache;
  final DateTime Function() _clock;

  GhanaRegion? _region;
  WeatherForecast? _forecast;
  bool _isLoading = false;
  bool _lastRefreshFailed = false;
  bool _cacheLoaded = false;

  WeatherProvider({
    WeatherService? service,
    JsonFileStore? cache,
    DateTime Function()? clock,
  })  : _service = service ?? WeatherService(),
        _cache = cache ?? JsonFileStore('weather_cache.json'),
        _clock = clock ?? DateTime.now;

  GhanaRegion? get region => _region;
  WeatherForecast? get forecast => _forecast;
  bool get isLoading => _isLoading;

  /// True when the latest refresh failed (usually no connection) and any
  /// forecast shown is the saved one.
  bool get isOffline => _lastRefreshFailed;
  bool get hasRegion => _region != null;

  bool get isStale =>
      _forecast == null || _clock().difference(_forecast!.fetchedAt) > maxAge;

  /// Diseases the next days' weather favours, for [crops] if given.
  List<DiseaseRisk> risks({Set<String>? crops}) => _forecast == null
      ? const []
      : DiseaseRiskAssessor.assess(_forecast!.hourly,
          now: _clock(), crops: crops);

  /// For ChangeNotifierProxyProvider.update, which runs during build: defers
  /// the work so listeners aren't notified mid-build.
  void onProfileRegion(String? regionName) {
    final unchanged = GhanaRegions.find(regionName)?.name == _region?.name;
    if (unchanged && _cacheLoaded && !isStale) return;
    Future.microtask(() => setRegion(regionName));
  }

  /// Fetches if the region changed or the forecast is stale.
  Future<void> setRegion(String? regionName) async {
    final region = GhanaRegions.find(regionName);
    if (region?.name == _region?.name && _cacheLoaded) {
      if (isStale && !_isLoading) await refresh();
      return;
    }
    _region = region;
    _forecast = null;
    _lastRefreshFailed = false;
    notifyListeners();
    if (region == null) return;

    await _loadCache(region);
    if (isStale) await refresh();
  }

  Future<void> _loadCache(GhanaRegion region) async {
    try {
      final data = await _cache.read() as Map<String, dynamic>?;
      if (data != null && data['region'] == region.name) {
        _forecast = WeatherForecast.fromJson(
            Map<String, dynamic>.from(data['forecast'] as Map));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('WeatherProvider: ignoring unreadable cache: $e');
    } finally {
      _cacheLoaded = true;
    }
  }

  Future<void> refresh() async {
    final region = _region;
    if (region == null || _isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final forecast = await _service.fetch(region, now: _clock());
      if (region.name != _region?.name) return; // region changed meanwhile
      _forecast = forecast;
      _lastRefreshFailed = false;
      await _cache
          .write({'region': region.name, 'forecast': forecast.toJson()});
    } catch (e) {
      debugPrint('WeatherProvider: refresh failed: $e');
      _lastRefreshFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
