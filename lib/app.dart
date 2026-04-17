import 'package:flutter/material.dart';
import 'package:onecharge/screen/onbording/splash.dart';

import 'package:onecharge/core/navigation/navigation_service.dart';
import 'package:onecharge/test.dart' hide Card;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'OneCharge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Lufga',
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Lufga',
        brightness: Brightness.light, // Keep light aesthetics as per design
      ),
      themeMode: ThemeMode.light, // Explicitly force light mode for now
      home: SplashScreen(),
    );
  }
}
