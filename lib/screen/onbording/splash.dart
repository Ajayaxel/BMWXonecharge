import 'package:flutter/material.dart';

import 'package:onecharge/core/storage/token_storage.dart';
import 'package:onecharge/core/storage/secure_storage_service.dart';
import 'package:onecharge/core/storage/vehicle_storage.dart';
import 'package:onecharge/screen/home/home_screen.dart';
import 'package:onecharge/screen/onbording/onbording_screen.dart';
import 'package:onecharge/screen/vehicle/vehicle_selection.dart';
import 'package:onecharge/test/testlogin.dart';
import 'package:onecharge/utils/onboarding_service.dart';
import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/data/repositories/vehicle_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache the logo image to ensure it's ready when the native splash is removed
    precacheImage(const AssetImage("assets/onbord/spalsh.png"), context);
  }

  Future<void> _checkAuthStatus() async {
    // 1. Initial stabilization delay
    await Future.delayed(const Duration(milliseconds: 200));

    // Handle First Run after Reinstall
    final isFirstRun = await OnboardingService.isFirstRun();
    if (isFirstRun) {
      final secureStorage = SecureStorageService();
      await secureStorage.clearAll();
      await OnboardingService.markFirstRunComplete();
    }

    // Checking authentication status
    String? token;
    for (int i = 0; i < 3; i++) {
      token = await TokenStorage.readToken();
      if (token != null && token.isNotEmpty) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      String? vehicleName = await VehicleStorage.getVehicleName();
      if (vehicleName != null && vehicleName.isNotEmpty) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return;
      }

      try {
        final apiClient = ApiClient(SecureStorageService());
        final vehicleRepo = VehicleRepository(apiClient: apiClient);
        final response = await vehicleRepo.getVehicles();

        if (response.vehicles.isNotEmpty) {
          final firstVehicle = response.vehicles.first;
          await VehicleStorage.saveVehicleInfo(
            name: firstVehicle.vehicleName,
            number: firstVehicle.vehicleNumber,
            image: firstVehicle.vehicleImage,
            vehicleTypeId: firstVehicle.vehicleTypeId,
            brandId: firstVehicle.brandId,
            modelId: firstVehicle.modelId,
          );

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          return;
        }
      } catch (e) {
        // Log or handle error
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VehicleSelection()),
      );
      return;
    }

    // Default flow for unauthenticated users
    final isCompleted = await OnboardingService.isOnboardingCompleted();

    if (!mounted) return;

    final destination = isCompleted
        ? const Testlogin()
        : const OnboardingScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          "assets/onbord/spalsh.png",
          width: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
