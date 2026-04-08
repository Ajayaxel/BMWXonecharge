import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/app.dart';
import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/core/services/push_notification_service.dart';
import 'package:onecharge/data/repositories/brand_repository.dart';
import 'package:onecharge/logic/blocs/brand/brand_bloc.dart';

import 'package:onecharge/data/repositories/vehicle_repository.dart';
import 'package:onecharge/logic/blocs/vehicle_model/vehicle_model_bloc.dart';

import 'package:onecharge/data/repositories/issue_repository.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_bloc.dart';

import 'package:onecharge/data/repositories/chat_repository.dart';
import 'package:onecharge/logic/blocs/chat/chat_bloc.dart';
import 'package:onecharge/features/ai_chat/data/repositories/ai_chat_repository.dart';
import 'package:onecharge/features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
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
import 'package:onecharge/data/repositories/company_code_repository.dart';
import 'package:onecharge/logic/blocs/company_code/company_code_bloc.dart';
import 'package:onecharge/data/repositories/service_banner_repository.dart';
import 'package:onecharge/logic/blocs/service_banner/service_banner_bloc.dart';
import 'package:onecharge/logic/blocs/service_banner/service_banner_event.dart';
import 'package:onecharge/data/repositories/wallet_repository.dart';
import 'package:onecharge/logic/blocs/wallet/wallet_bloc.dart';
import 'package:onecharge/data/repositories/product_repository.dart';
import 'package:onecharge/logic/blocs/product/product_bloc.dart';
import 'package:onecharge/logic/blocs/product/product_event.dart';
import 'package:onecharge/logic/blocs/product_detail/product_detail_bloc.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_bloc.dart';
import 'package:onecharge/logic/blocs/cart/cart_bloc.dart';
import 'package:onecharge/logic/blocs/order/order_bloc.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_bloc.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_event.dart';
import 'package:onecharge/data/repositories/service_group_repository.dart';
import 'package:onecharge/logic/blocs/service_group/service_group_bloc.dart';
import 'package:onecharge/logic/blocs/service_group/service_group_event.dart';
import 'package:onecharge/logic/blocs/combo_offer/data/repositories/combo_offer_repository.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_bloc.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_event.dart';
import 'package:onecharge/data/repositories/product_group_repository.dart';
import 'package:onecharge/logic/blocs/product_group/product_group_bloc.dart';
import 'package:onecharge/logic/blocs/product_group/product_group_event.dart';
import 'firebase_options.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final secureStorage = SecureStorageService();

  // Initialize Push Notifications (foreground + background)
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize(storage: secureStorage);

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
  final aiChatRepository = AiChatRepository();
  final chargingTypeRepository = ChargingTypeRepository(apiClient: apiClient);
  final profileRepository = ProfileRepository(apiClient: apiClient);
  final locationRepository = LocationRepository(apiClient: apiClient);
  final redeemCodeRepository = RedeemCodeRepository(apiClient: apiClient);
  final feedbackRepository = FeedbackRepository(apiClient: apiClient);
  final companyCodeRepository = CompanyCodeRepository(apiClient: apiClient);
  final serviceBannerRepository = ServiceBannerRepository(apiClient: apiClient);
  final walletRepository = WalletRepository(apiClient: apiClient);
  final productRepository = ProductRepository(apiClient: apiClient);
  final serviceGroupRepository = ServiceGroupRepository(apiClient: apiClient);
  final productGroupRepository = ProductGroupRepository(apiClient: apiClient);
  final comboOfferRepository = ComboOfferRepository(apiClient: apiClient);

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
        RepositoryProvider<CompanyCodeRepository>.value(
          value: companyCodeRepository,
        ),
        RepositoryProvider<ServiceBannerRepository>.value(
          value: serviceBannerRepository,
        ),
        RepositoryProvider<WalletRepository>.value(value: walletRepository),
        RepositoryProvider<ProductRepository>.value(value: productRepository),
        RepositoryProvider<ServiceGroupRepository>.value(value: serviceGroupRepository),
        RepositoryProvider<ProductGroupRepository>.value(value: productGroupRepository),
        RepositoryProvider<ComboOfferRepository>.value(value: comboOfferRepository),
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
          BlocProvider<AiChatBloc>(
            create: (context) => AiChatBloc(aiChatRepository: aiChatRepository),
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
            create: (context) => LocationBloc(
              repository: locationRepository,
              storage: secureStorage,
            ),
          ),
          BlocProvider<RedeemCodeBloc>(
            create: (context) =>
                RedeemCodeBloc(redeemCodeRepository: redeemCodeRepository),
          ),
          BlocProvider<FeedbackBloc>(
            create: (context) =>
                FeedbackBloc(feedbackRepository: feedbackRepository),
          ),
          BlocProvider<CompanyCodeBloc>(
            create: (context) =>
                CompanyCodeBloc(companyCodeRepository: companyCodeRepository),
          ),
          BlocProvider<ServiceBannerBloc>(
            create: (context) => ServiceBannerBloc(
              serviceBannerRepository: serviceBannerRepository,
            )..add(FetchServiceBanner()),
          ),
          BlocProvider<WalletBloc>(
            create: (context) =>
                WalletBloc(walletRepository: walletRepository),
          ),
          BlocProvider<ProductBloc>(
            create: (context) => ProductBloc(productRepository: productRepository)
              ..add(FetchProductsEvent()),
          ),
          BlocProvider<ProductDetailBloc>(
            create: (context) => ProductDetailBloc(productRepository: productRepository),
          ),
          BlocProvider<WishlistBloc>(
            create: (context) => WishlistBloc(productRepository: productRepository),
          ),
          BlocProvider<CartBloc>(
            create: (context) => CartBloc(productRepository: productRepository)
              ..add(FetchCartEvent()),
          ),
          BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(productRepository: productRepository),
          ),
          BlocProvider<ShopCategoryBloc>(
            create: (context) => ShopCategoryBloc(productRepository: productRepository)
              ..add(FetchShopCategories()),
          ),
          BlocProvider<ServiceGroupBloc>(
            create: (context) => ServiceGroupBloc(
              serviceGroupRepository: serviceGroupRepository,
            )..add(const FetchServiceGroups()),
          ),
          BlocProvider<ProductGroupBloc>(
            create: (context) => ProductGroupBloc(
              repository: productGroupRepository,
            )..add(FetchProductGroups()),
          ),
          BlocProvider<ComboOfferBloc>(
            create: (context) => ComboOfferBloc(
              repository: comboOfferRepository,
            )..add(FetchComboOffers()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
