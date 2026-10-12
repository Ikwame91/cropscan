import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cropscan_pro/core/storage/json_file_store.dart';
import 'package:cropscan_pro/features/weather/disease_risk.dart';
import 'package:cropscan_pro/features/weather/ghana_regions.dart';
import 'package:cropscan_pro/features/weather/weather_forecast.dart';
import 'package:cropscan_pro/features/weather/weather_provider.dart';
import 'package:cropscan_pro/features/weather/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final fixture =
      File('test/fixtures/open_meteo_kumasi.json').readAsStringSync();
  final now = DateTime(2026, 10, 5, 14, 30);

  WeatherForecast parse() => WeatherForecast.fromOpenMeteo(
        json.decode(fixture) as Map<String, dynamic>,
        place: 'Kumasi',
        fetchedAt: now,
      );

  group('GhanaRegions', () {
    test('finds regions by profile name, loosely', () {
      expect(GhanaRegions.find('Ashanti Region')!.capital, 'Kumasi');
      expect(GhanaRegions.find('ashanti')!.capital, 'Kumasi');
      expect(GhanaRegions.find('Brong-Ahafo Region')!.capital, 'Sunyani');
      expect(GhanaRegions.find('Ghana'), isNull);
      expect(GhanaRegions.find(null), isNull);
      expect(GhanaRegions.all, hasLength(16));
    });
  });

  group('WeatherForecast', () {
    test('parses an Open-Meteo response, skipping null hours', () {
      final f = parse();
      expect(f.current.temperature, 28.4);
      expect(f.current.weatherCode, 2);
      expect(f.hourly, hasLength(71), reason: 'one hour had a null humidity');
      expect(f.daily.map((d) => d.precipitationChance), [20, 85, 60]);
    });

    test('round-trips through the cache format', () {
      final f = parse();
      final back = WeatherForecast.fromJson(
          json.decode(json.encode(f.toJson())) as Map<String, dynamic>);
      expect(back.hourly.length, f.hourly.length);
      expect(back.daily.last.maxTemperature, 28.3);
      expect(back.fetchedAt, now);
    });

    test('describes WMO codes', () {
      expect(WeatherCode.describe(63), 'Rain');
      expect(WeatherCode.iconName(95), 'thunderstorm');
    });
  });

  group('DiseaseRiskAssessor', () {
    List<HourlyWeather> hours(int count,
            {required double temp, required double rh, double rain = 0}) =>
        [
          for (var h = 0; h < count; h++)
            HourlyWeather(
              time: DateTime(2026, 10, 6, h),
              temperature: temp,
              humidity: rh,
              precipitation: rain,
            ),
        ];

    test('long wet spells at 24-29°C raise early blight to high', () {
      final risks = DiseaseRiskAssessor.assess(
        hours(12, temp: 26, rh: 95),
        now: now,
        crops: {'Tomato'},
      );
      final early =
          risks.firstWhere((r) => r.rawLabel == 'Tomato_Early_blight');
      expect(early.level, RiskLevel.high);
      expect(early.favourableHours, 12);
      expect(risks.any((r) => r.rawLabel == 'Tomato_Late_blight'), isFalse,
          reason: '26°C is too warm for late blight');
    });

    test('rain counts as leaf wetness even when humidity is lower', () {
      final risks = DiseaseRiskAssessor.assess(
        hours(7, temp: 20, rh: 60, rain: 1.2),
        now: now,
        crops: {'Tomato'},
      );
      expect(risks.firstWhere((r) => r.rawLabel == 'Tomato_Late_blight').level,
          RiskLevel.medium);
    });

    test('hot dry harmattan hours raise spider-mite risk', () {
      final risks = DiseaseRiskAssessor.assess(
        hours(8, temp: 34, rh: 30),
        now: now,
        crops: {'Tomato'},
      );
      expect(
          risks.single.rawLabel, 'Tomato_Spider_mites_Two_spotted_spider_mite');
      expect(risks.single.level, RiskLevel.high);
    });

    test('only assesses the crops asked for', () {
      final risks = DiseaseRiskAssessor.assess(
        hours(12, temp: 20, rh: 95),
        now: now,
        crops: {'Maize'},
      );
      expect(risks.every((r) => r.crop == 'Maize'), isTrue);
      expect(risks.map((r) => r.rawLabel),
          contains('Corn_(maize)___Common_rust_'));
    });

    test('ignores hours that have already passed', () {
      final past = [
        for (var h = 0; h < 12; h++)
          HourlyWeather(
              time: DateTime(2026, 10, 4, h),
              temperature: 26,
              humidity: 95,
              precipitation: 0),
      ];
      expect(DiseaseRiskAssessor.assess(past, now: now), isEmpty);
    });

    test('the Kumasi fixture flags maize leaf diseases on wet nights', () {
      final risks = DiseaseRiskAssessor.assess(parse().hourly,
          now: now, crops: {'Maize'});
      expect(risks.first.rawLabel,
          'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot');
      expect(risks.first.level, RiskLevel.high);
    });
  });

  group('WeatherProvider', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('weather'));
    tearDown(() => dir.deleteSync(recursive: true));

    WeatherProvider provider(http.Client client, {DateTime? at}) =>
        WeatherProvider(
          service: WeatherService(client: client),
          cache: JsonFileStore('w.json', directory: () async => dir),
          clock: () => at ?? now,
        );

    test('requests the region capital and caches the result', () async {
      Uri? requested;
      final online = MockClient((req) async {
        requested = req.url;
        return http.Response(fixture, 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      });
      final p = provider(online);
      await p.setRegion('Ashanti Region');
      expect(requested!.queryParameters['latitude'], '6.6885');
      expect(p.forecast!.place, 'Kumasi');
      expect(p.isOffline, isFalse);

      // Offline later: the saved forecast still shows.
      final offline =
          MockClient((_) async => throw const SocketException('no network'));
      final later = provider(offline, at: now.add(const Duration(hours: 5)));
      await later.setRegion('Ashanti Region');
      expect(later.forecast, isNotNull);
      expect(later.isOffline, isTrue);
    });

    test('does not refetch a fresh forecast', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return http.Response(fixture, 200);
      });
      final p = provider(client);
      await p.setRegion('Ashanti Region');
      await p.setRegion('Ashanti Region');
      expect(calls, 1);
    });

    test('fetches the new region if it changes mid-request', () async {
      final firstResponse = Completer<http.Response>();
      final firstRequested = Completer<void>();
      final requested = <String>[];
      final client = MockClient((req) {
        requested.add(req.url.queryParameters['latitude']!);
        if (requested.length == 1) firstRequested.complete();
        return requested.length == 1
            ? firstResponse.future
            : Future.value(http.Response(fixture, 200));
      });
      final p = provider(client);
      final first = p.setRegion('Ashanti Region');
      await firstRequested.future;
      // The region changes while the first request is still pending.
      await p.setRegion('Northern Region');
      firstResponse.complete(http.Response(fixture, 200));
      await first;

      expect(requested, ['6.6885', '9.4008']);
      expect(p.forecast!.place, 'Tamale');
      expect(p.isLoading, isFalse);
    });

    test('has no region until the profile sets a real one', () async {
      final p = provider(MockClient((_) async => http.Response('', 500)));
      await p.setRegion('Ghana');
      expect(p.hasRegion, isFalse);
      expect(p.forecast, isNull);
    });

    test('a cache for another region is not shown', () async {
      final p = provider(MockClient((_) async => http.Response(fixture, 200)));
      await p.setRegion('Ashanti Region');
      final other = provider(
          MockClient((_) async => throw const SocketException('offline')));
      await other.setRegion('Northern Region');
      expect(other.forecast, isNull);
    });
  });
}
