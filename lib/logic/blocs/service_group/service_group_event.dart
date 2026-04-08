import 'package:equatable/equatable.dart';

abstract class ServiceGroupEvent extends Equatable {
  const ServiceGroupEvent();

  @override
  List<Object?> get props => [];
}

class FetchServiceGroups extends ServiceGroupEvent {
  final bool forceRefresh;

  const FetchServiceGroups({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}
