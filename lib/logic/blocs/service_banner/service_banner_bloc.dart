import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/service_banner_repository.dart';
import 'package:onecharge/logic/blocs/service_banner/service_banner_event.dart';
import 'package:onecharge/logic/blocs/service_banner/service_banner_state.dart';

class ServiceBannerBloc extends Bloc<ServiceBannerEvent, ServiceBannerState> {
  final ServiceBannerRepository serviceBannerRepository;

  ServiceBannerBloc({required this.serviceBannerRepository})
      : super(ServiceBannerInitial()) {
    on<FetchServiceBanner>((event, emit) async {
      emit(ServiceBannerLoading());
      try {
        final banner = await serviceBannerRepository.getServiceBanner();
        emit(ServiceBannerLoaded(banner));
      } catch (e) {
        emit(ServiceBannerError(e.toString()));
      }
    });
  }
}
