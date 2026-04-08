import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/service_group_repository.dart';
import 'service_group_event.dart';
import 'service_group_state.dart';

class ServiceGroupBloc extends Bloc<ServiceGroupEvent, ServiceGroupState> {
  final ServiceGroupRepository serviceGroupRepository;

  ServiceGroupBloc({required this.serviceGroupRepository})
      : super(ServiceGroupInitial()) {
    on<FetchServiceGroups>(_onFetchServiceGroups);
  }

  Future<void> _onFetchServiceGroups(
    FetchServiceGroups event,
    Emitter<ServiceGroupState> emit,
  ) async {
    if (state is ServiceGroupLoaded && !event.forceRefresh) return;

    emit(ServiceGroupLoading());
    try {
      final serviceGroups = await serviceGroupRepository.getServiceGroups();
      emit(ServiceGroupLoaded(serviceGroups));
    } catch (e) {
      emit(ServiceGroupError(e.toString()));
    }
  }
}
