import 'package:equatable/equatable.dart';

abstract class ServiceBannerEvent extends Equatable {
  const ServiceBannerEvent();

  @override
  List<Object> get props => [];
}

class FetchServiceBanner extends ServiceBannerEvent {}
