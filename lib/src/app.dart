import 'package:flutter/material.dart';
import 'package:hackathon/src/core/routes.dart';

class HackathonApp extends StatelessWidget {
  const HackathonApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.home,
      onGenerateRoute: Routes.onGenerateRoute,
      navigatorKey: Routes.navigatorKey,
    );
  }
}
