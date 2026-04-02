import 'package:equatable/equatable.dart';
import 'package:onecharge/models/service_banner_model.dart';

abstract class ServiceBannerState extends Equatable {
  const ServiceBannerState();

  @override
  List<Object?> get props => [];
}

class ServiceBannerInitial extends ServiceBannerState {}

class ServiceBannerLoading extends ServiceBannerState {}

class ServiceBannerLoaded extends ServiceBannerState {
  final List<ServiceBanner> banners;

  const ServiceBannerLoaded(this.banners);

  @override
  List<Object?> get props => [banners];
}

class ServiceBannerError extends ServiceBannerState {
  final String message;

  const ServiceBannerError(this.message);

  @override
  List<Object?> get props => [message];
}
