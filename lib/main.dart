import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/data/repositories/brand_repository.dart';
import 'package:onecharge/logic/blocs/brand/brand_bloc.dart';
import 'package:onecharge/logic/blocs/brand/brand_event.dart';
import 'package:onecharge/screen/home/home_screen.dart';

import 'package:onecharge/data/repositories/vehicle_repository.dart';
import 'package:onecharge/logic/blocs/vehicle_model/vehicle_model_bloc.dart';
import 'package:onecharge/logic/blocs/vehicle_model/vehicle_model_event.dart';

import 'package:onecharge/data/repositories/issue_repository.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_event.dart';

import 'package:onecharge/data/repositories/chat_repository.dart';
import 'package:onecharge/logic/blocs/chat/chat_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final brandRepository = BrandRepository(apiClient: apiClient);
  final vehicleRepository = VehicleRepository(apiClient: apiClient);
  final issueRepository = IssueRepository(apiClient: apiClient);
  final chatRepository = ChatRepository(apiClient: apiClient);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BrandRepository>.value(value: brandRepository),
        RepositoryProvider<VehicleRepository>.value(value: vehicleRepository),
        RepositoryProvider<IssueRepository>.value(value: issueRepository),
        RepositoryProvider<ChatRepository>.value(value: chatRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BrandBloc>(
            create: (context) =>
                BrandBloc(brandRepository: brandRepository)..add(FetchBrands()),
          ),
          BlocProvider<VehicleModelBloc>(
            create: (context) =>
                VehicleModelBloc(vehicleRepository: vehicleRepository)
                  ..add(FetchVehicleModels()),
          ),
          BlocProvider<IssueCategoryBloc>(
            create: (context) =>
                IssueCategoryBloc(issueRepository: issueRepository)
                  ..add(FetchIssueCategories()),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(chatRepository: chatRepository),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

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
      home: const HomeScreen(),
    );
  }
}
