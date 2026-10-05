import 'package:cropscan_pro/core/ml/crop_classifier.dart';
import 'package:cropscan_pro/features/guide/crop_care_provider.dart';
import 'package:cropscan_pro/features/history/detection_history_provider.dart';
import 'package:cropscan_pro/app/navigation_provider.dart';
import 'package:cropscan_pro/features/profile/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:cropscan_pro/core/widgets/custom_error_widget.dart';
import 'package:cropscan_pro/core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };
  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => UserProfileProvider(),
        lazy: true,
      ),
      ChangeNotifierProvider(
          create: (_) => DetectionHistoryProvider(), lazy: true),
      ChangeNotifierProvider(
        create: (_) => NavigationProvider(),
        lazy: true,
      ),
      ChangeNotifierProvider(
        create: (_) => CropCareProvider(),
        lazy: true,
      ),
      ChangeNotifierProvider(
        create: (_) => TfLiteModelServices(),
        lazy: true,
      ),
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
        title: 'cropscan_pro',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
      );
    });
  }
}
