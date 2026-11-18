import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

class TapakLampungApp extends StatelessWidget {
  const TapakLampungApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      );
}
