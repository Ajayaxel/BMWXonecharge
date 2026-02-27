import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/app.dart';
import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/data/repositories/brand_repository.dart';
import 'package:onecharge/logic/blocs/brand/brand_bloc.dart';

import 'package:onecharge/data/repositories/vehicle_repository.dart';
import 'package:onecharge/logic/blocs/vehicle_model/vehicle_model_bloc.dart';

import 'package:onecharge/data/repositories/issue_repository.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_bloc.dart';

import 'package:onecharge/data/repositories/chat_repository.dart';
import 'package:onecharge/logic/blocs/chat/chat_bloc.dart';
import 'package:onecharge/data/repositories/charging_type_repository.dart';
import 'package:onecharge/logic/blocs/charging_type/charging_type_bloc.dart';
import 'package:onecharge/logic/blocs/add_vehicle/add_vehicle_bloc.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_bloc.dart';
import 'package:onecharge/logic/blocs/delete_vehicle/delete_vehicle_bloc.dart';
import 'package:onecharge/data/repositories/profile_repository.dart';
import 'package:onecharge/logic/blocs/profile/profile_bloc.dart';
import 'package:onecharge/data/repositories/location_repository.dart';
import 'package:onecharge/logic/blocs/location/location_bloc.dart';
import 'package:onecharge/data/repositories/redeem_code_repository.dart';
import 'package:onecharge/logic/blocs/redeem_code/redeem_code_bloc.dart';
import 'package:onecharge/data/repositories/feedback_repository.dart';
import 'package:onecharge/logic/blocs/feedback/feedback_bloc.dart';

// New Architecture Imports
import 'package:onecharge/core/storage/secure_storage_service.dart';
import 'package:onecharge/core/network/dio_client.dart';
import 'package:onecharge/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:onecharge/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:onecharge/features/auth/domain/usecases/login_usecase.dart';
import 'package:onecharge/features/auth/domain/usecases/logout_usecase.dart';
import 'package:onecharge/features/auth/domain/usecases/register_usecase.dart';
import 'package:onecharge/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:onecharge/features/auth/presentation/bloc/auth_bloc.dart'
    as new_auth;
import 'package:onecharge/features/auth/presentation/bloc/auth_event.dart'
    as auth_event;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final secureStorage = SecureStorageService();
  final dioClient = DioClient(secureStorage);
  final apiClient = ApiClient(secureStorage);

  // Auth dependenciesjay
  final authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    storage: secureStorage,
  );
  final loginUseCase = LoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final verifyOtpUseCase = VerifyOtpUseCase(authRepository);

  final brandRepository = BrandRepository(apiClient: apiClient);
  final vehicleRepository = VehicleRepository(apiClient: apiClient);
  final issueRepository = IssueRepository(apiClient: apiClient);
  final chatRepository = ChatRepository(apiClient: apiClient);
  final chargingTypeRepository = ChargingTypeRepository(apiClient: apiClient);
  final profileRepository = ProfileRepository(apiClient: apiClient);
  final locationRepository = LocationRepository(apiClient: apiClient);
  final redeemCodeRepository = RedeemCodeRepository(apiClient: apiClient);
  final feedbackRepository = FeedbackRepository(apiClient: apiClient);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BrandRepository>.value(value: brandRepository),
        RepositoryProvider<VehicleRepository>.value(value: vehicleRepository),
        RepositoryProvider<IssueRepository>.value(value: issueRepository),
        RepositoryProvider<ChatRepository>.value(value: chatRepository),
        RepositoryProvider<ChargingTypeRepository>.value(
          value: chargingTypeRepository,
        ),
        RepositoryProvider<AuthRepositoryImpl>.value(value: authRepository),
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
        RepositoryProvider<LocationRepository>.value(value: locationRepository),
        RepositoryProvider<RedeemCodeRepository>.value(
          value: redeemCodeRepository,
        ),
        RepositoryProvider<FeedbackRepository>.value(value: feedbackRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BrandBloc>(
            create: (context) => BrandBloc(brandRepository: brandRepository),
          ),
          BlocProvider<VehicleModelBloc>(
            create: (context) =>
                VehicleModelBloc(vehicleRepository: vehicleRepository),
          ),
          BlocProvider<IssueCategoryBloc>(
            create: (context) =>
                IssueCategoryBloc(issueRepository: issueRepository),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(chatRepository: chatRepository),
          ),
          BlocProvider<ChargingTypeBloc>(
            create: (context) => ChargingTypeBloc(
              chargingTypeRepository: chargingTypeRepository,
            ),
          ),
          BlocProvider<new_auth.AuthBloc>(
            create: (context) => new_auth.AuthBloc(
              loginUseCase: loginUseCase,
              logoutUseCase: logoutUseCase,
              registerUseCase: registerUseCase,
              verifyOtpUseCase: verifyOtpUseCase,
              repository: authRepository,
            )..add(auth_event.AuthCheckRequested()),
          ),
          BlocProvider<AddVehicleBloc>(
            create: (context) =>
                AddVehicleBloc(vehicleRepository: vehicleRepository),
          ),
          BlocProvider<VehicleListBloc>(
            create: (context) =>
                VehicleListBloc(vehicleRepository: vehicleRepository),
          ),
          BlocProvider<TicketBloc>(
            create: (context) => TicketBloc(issueRepository: issueRepository),
          ),
          BlocProvider<DeleteVehicleBloc>(
            create: (context) =>
                DeleteVehicleBloc(vehicleRepository: vehicleRepository),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) =>
                ProfileBloc(profileRepository: profileRepository),
          ),
          BlocProvider<LocationBloc>(
            create: (context) => LocationBloc(repository: locationRepository),
          ),
          BlocProvider<RedeemCodeBloc>(
            create: (context) =>
                RedeemCodeBloc(redeemCodeRepository: redeemCodeRepository),
          ),
          BlocProvider<FeedbackBloc>(
            create: (context) =>
                FeedbackBloc(feedbackRepository: feedbackRepository),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
