import 'package:cropscan_pro/app/navigation_provider.dart';
import 'package:cropscan_pro/core/app_export.dart';
import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:cropscan_pro/features/history/detection_history_provider.dart';
import 'package:cropscan_pro/features/weather/disease_risk.dart';
import 'package:cropscan_pro/features/weather/weather_forecast.dart';
import 'package:cropscan_pro/features/weather/weather_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

/// Home-screen weather for the farmer's region, with a warning when the
/// coming days favour diseases of the crops they grow.
class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final forecast = weather.forecast;

    final Widget child;
    if (!weather.hasRegion) {
      child = _Message(
        icon: Icons.location_on_outlined,
        text: 'Set your region to see local weather and disease-risk alerts.',
        action: 'Choose region',
        onAction: () =>
            context.read<NavigationProvider>().navigateToTab(AppTab.profile),
      );
    } else if (forecast == null) {
      child = weather.isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          : _Message(
              icon: Icons.cloud_off,
              text: 'Weather needs an internet connection. It will appear '
                  'the next time you are online.',
              action: 'Try again',
              onAction: weather.refresh,
            );
    } else {
      child = _Forecast(forecast: forecast, weather: weather);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightTheme.dividerColor),
      ),
      child: child,
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final String action;
  final VoidCallback onAction;

  const _Message({
    required this.icon,
    required this.text,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: 3.w),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }
}

class _Forecast extends StatelessWidget {
  final WeatherForecast forecast;
  final WeatherProvider weather;

  const _Forecast({required this.forecast, required this.weather});

  String _updated(DateTime fetchedAt) {
    final age = DateTime.now().difference(fetchedAt);
    if (age.inMinutes < 2) return 'Updated just now';
    if (age.inMinutes < 60) return 'Updated ${age.inMinutes} min ago';
    if (age.inHours < 24) return 'Updated ${age.inHours} h ago';
    return 'Updated ${DateFormat('d MMM').format(fetchedAt)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final current = forecast.current;
    final scanned = context
        .select<DetectionHistoryProvider, Set<String>>((h) => h.scannedCrops);
    final risks = weather.risks(crops: scanned);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on,
                size: 16, color: theme.colorScheme.onSurfaceVariant),
            SizedBox(width: 1.w),
            Expanded(
              child: Text(
                '${forecast.place} · ${_updated(forecast.fetchedAt)}'
                '${weather.isOffline ? ' (offline)' : ''}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            if (weather.isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              InkWell(
                onTap: weather.refresh,
                child: Icon(Icons.refresh,
                    size: 20, color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: WeatherCode.iconName(current.weatherCode),
              color: theme.colorScheme.primary,
              size: 40,
            ),
            SizedBox(width: 3.w),
            Text('${current.temperature.round()}°C',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(WeatherCode.describe(current.weatherCode),
                      style: theme.textTheme.titleSmall),
                  Text(
                    'Humidity ${current.humidity.round()}% · '
                    'Wind ${current.windSpeed.round()} km/h',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            for (final day in forecast.daily.take(3))
              Expanded(child: _Day(day: day)),
          ],
        ),
        if (risks.isNotEmpty) ...[
          SizedBox(height: 1.5.h),
          _RiskBanner(risks: risks),
        ],
        SizedBox(height: 1.h),
        Text(
          'Weather data: Open-Meteo.com',
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _Day extends StatelessWidget {
  final DailyWeather day;
  const _Day({required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final today = DateUtils.isSameDay(day.date, DateTime.now());
    final rain = day.precipitationChance;
    return Column(
      children: [
        Text(today ? 'Today' : DateFormat('EEE').format(day.date),
            style: theme.textTheme.labelMedium),
        CustomIconWidget(
          iconName: WeatherCode.iconName(day.weatherCode),
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        Text(
          '${day.maxTemperature?.round() ?? '–'}° / '
          '${day.minTemperature?.round() ?? '–'}°',
          style: AppTheme.getDataTextStyle(isLight: true, fontSize: 12),
        ),
        if (rain != null)
          Text('${rain.round()}% rain', style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _RiskBanner extends StatelessWidget {
  final List<DiseaseRisk> risks;
  const _RiskBanner({required this.risks});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final knowledge = context.read<DiseaseKnowledgeRepository>();
    final high = risks.first.level == RiskLevel.high;
    final color =
        high ? theme.colorScheme.error : AppTheme.getWarningColor(true);
    final names = risks
        .take(3)
        .map((r) => knowledge.displayNameFor(r.rawLabel))
        .join(', ');

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.diseaseDetail,
        arguments: risks.first.rawLabel,
      ),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: color),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    high ? 'High disease risk' : 'Raised disease risk',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'The next few days favour $names. Scout your fields and '
                    'keep leaves dry where you can.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
