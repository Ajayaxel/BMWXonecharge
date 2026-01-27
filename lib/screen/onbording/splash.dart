import 'package:flutter/material.dart';
import 'package:onecharge/core/storage/token_storage.dart';

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

  Future<void> _checkAuthStatus() async {
    // Add a small delay to ensure SharedPreferences is fully initialized
    await Future.delayed(const Duration(milliseconds: 300));

    print('🔍 [SplashScreen] Checking authentication status...');

    // Try reading token multiple times to ensure SharedPreferences is ready
    String? token;
    for (int i = 0; i < 3; i++) {
      token = await TokenStorage.readToken();
      if (token != null && token.isNotEmpty) {
        break;
      }
      if (i < 2) {
        print(
          '⚠️ [SplashScreen] Token not found, retrying... (attempt ${i + 1}/3)',
        );
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    print(
      '🔍 [SplashScreen] Token check result: ${token != null ? "Token found (length: ${token.length})" : "No token found"}',
    );

    if (!mounted) return;

    // If token exists, user is logged in - check vehicle setup
    if (token != null && token.isNotEmpty) {
      print('✅ [SplashScreen] Token exists, user is authenticated');

      // 1. Check for local vehicle data first (fastest)
      String? vehicleName = await VehicleStorage.getVehicleName();
      bool hasLocalVehicle = vehicleName != null && vehicleName.isNotEmpty;

      if (hasLocalVehicle) {
        print('🏠 [SplashScreen] Local vehicle found: $vehicleName');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return;
      }

      // 2. No local vehicle, check server for existing vehicles
      print('🔍 [SplashScreen] No local vehicle, checking server...');
      try {
        final apiClient = ApiClient();
        final vehicleRepo = VehicleRepository(apiClient: apiClient);
        final response = await vehicleRepo.getVehicles();

        if (response.vehicles.isNotEmpty) {
          final firstVehicle = response.vehicles.first;
          print(
            '🚗 [SplashScreen] Found ${response.vehicles.length} vehicles on server. Selecting ${firstVehicle.vehicleName}',
          );

          // Save the first vehicle found and navigate to Home
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
        print('❌ [SplashScreen] Error fetching vehicles from server: $e');
        // Fall through to VehicleSelection if server check fails
      }

      if (!mounted) return;
      print(
        '🚀 [SplashScreen] No vehicles found locally or on server, navigating to VehicleSelection',
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VehicleSelection()),
      );
      return;
    }

    // Call dummy function for testing
    await _dummyFunctionForTesting();

    // If no token, check onboarding status
    print('⚠️ [SplashScreen] No token found, checking onboarding status...');
    final isCompleted = await OnboardingService.isOnboardingCompleted();
    print('🔍 [SplashScreen] Onboarding completed: $isCompleted');

    if (!mounted) return;

    final destination = isCompleted
        ? const Testlogin()
        : const OnboardingScreen();
    print(
      '🚀 [SplashScreen] Navigating to: ${isCompleted ? "Testlogin" : "OnboardingScreen"}',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  /// Dummy function for testing purposes
  Future<void> _dummyFunctionForTesting() async {
    print('🧪 [SplashScreen] Running dummy function...');
    // Simulate some work or delay
    await Future.delayed(const Duration(milliseconds: 500));
    print('🧪 [SplashScreen] Dummy function completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset("assets/onbord/spalsh.png")),
    );
  }
}
