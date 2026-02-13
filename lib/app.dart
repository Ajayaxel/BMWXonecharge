import 'package:flutter/material.dart';
import 'package:onecharge/screen/onbording/splash.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneCharge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Lufga',
      ),
      home: const SplashScreen(),
    );    
  }
}













