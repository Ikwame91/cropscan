import 'package:cropscan_pro/app/navigation_provider.dart';
import 'package:cropscan_pro/core/app_export.dart';
import 'package:cropscan_pro/core/ml/crop_classifier.dart';
import 'package:cropscan_pro/core/widgets/custom_error_widget.dart';
import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_provider.dart';
import 'package:cropscan_pro/features/guide/crop_care_provider.dart';
import 'package:cropscan_pro/features/history/detection_history_provider.dart';
import 'package:cropscan_pro/features/profile/user_profile_provider.dart';
import 'package:cropscan_pro/features/weather/weather_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder =
      (FlutterErrorDetails details) => CustomErrorWidget(errorDetails: details);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Small JSON asset; every screen that shows a diagnosis needs it.
  final knowledge = await DiseaseKnowledgeRepository.load();

  final history = DetectionHistoryProvider(knowledge);
  final followUps = FollowUpProvider();
  // A new scan of a crop closes its pending "rescan" reminders, and deleting
  // a scan removes its care plan.
  history
    ..addDetectionAddedListener(followUps.recordRescan)
    ..addDetectionsRemovedListener(followUps.removeForDetections);

  runApp(MultiProvider(
    providers: [
      Provider.value(value: knowledge),
      ChangeNotifierProvider(create: (_) => UserProfileProvider()),
      // Weather follows the region chosen in the profile.
      ChangeNotifierProxyProvider<UserProfileProvider, WeatherProvider>(
        create: (_) => WeatherProvider(),
        update: (_, profile, weather) =>
            weather!..onProfileRegion(profile.userProfile?.region),
      ),
      ChangeNotifierProvider.value(value: history),
      ChangeNotifierProvider.value(value: followUps),
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ChangeNotifierProvider(create: (_) => CropCareProvider()),
      ChangeNotifierProvider(create: (_) => CropClassifier()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'CropScan Pro',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        ),
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
      );
    });
  }
}
