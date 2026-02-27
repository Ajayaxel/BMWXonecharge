import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/vehicle_repository.dart';
import 'package:stream_transform/stream_transform.dart';
import 'vehicle_model_event.dart';
import 'vehicle_model_state.dart';

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class VehicleModelBloc extends Bloc<VehicleModelEvent, VehicleModelState> {
  final VehicleRepository vehicleRepository;
  CancelToken? _cancelToken;
  DateTime? _lastFetchTime;
  static const int _pageSize = 20;

  VehicleModelBloc({required this.vehicleRepository})
    : super(const VehicleModelInitial()) {
    on<FetchVehicleModels>(
      _onFetchVehicleModels,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    on<LoadMoreVehicleModels>(_onLoadMoreVehicleModels);
  }

  Future<void> _onFetchVehicleModels(
    FetchVehicleModels event,
    Emitter<VehicleModelState> emit,
  ) async {
    // Smart refresh: prevent refetch if last fetch was less than 30 seconds ago
    if (!event.isRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) <
            const Duration(seconds: 30)) {
      return;
    }

    // State guard: ignore if already loading
    if (state is VehicleModelLoading && !event.isRefresh) return;

    // Cancel any previous request
    _cancelToken?.cancel('New request started');
    _cancelToken = CancelToken();

    // Emit Loading only during the very first fetch OR if explicitly refreshing
    // We use the count from the current state (if any) to help UI decide how many skeletons
    if (state is VehicleModelInitial || event.isRefresh) {
      emit(
        VehicleModelLoading(
          models: event.isRefresh ? state.models : [],
          totalCount:
              state.totalCount, // Use previous total_count for skeletons
          hasReachedMax: false,
          currentPage: 1,
        ),
      );
    }

    try {
      final result = await vehicleRepository.getModels(
        page: 1,
        limit: _pageSize,
        cancelToken: _cancelToken,
      );

      _lastFetchTime = DateTime.now();

      // Avoid emitting if the list hasn't changed (minimal optimization)
      if (state.models.length == result.models.length &&
          state.totalCount == result.totalCount &&
          !event.isRefresh) {
        // Just update state to Loaded if it was Loading
        emit(
          VehicleModelLoaded(
            models: result.models,
            totalCount: result.totalCount,
            hasReachedMax: result.models.length >= result.totalCount,
            currentPage: 1,
          ),
        );
        return;
      }

      emit(
        VehicleModelLoaded(
          models: result.models,
          totalCount: result.totalCount,
          hasReachedMax: result.models.length >= result.totalCount,
          currentPage: 1,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;
      emit(
        VehicleModelError(
          e.toString(),
          models: state.models,
          totalCount: state.totalCount,
          hasReachedMax: state.hasReachedMax,
          currentPage: state.currentPage,
        ),
      );
    } catch (e) {
      emit(
        VehicleModelError(
          e.toString(),
          models: state.models,
          totalCount: state.totalCount,
          hasReachedMax: state.hasReachedMax,
          currentPage: state.currentPage,
        ),
      );
    }
  }

  Future<void> _onLoadMoreVehicleModels(
    LoadMoreVehicleModels event,
    Emitter<VehicleModelState> emit,
  ) async {
    // Prevent multiple rapid API calls
    if (state is VehicleModelPaginationLoading ||
        state is VehicleModelLoading ||
        state.hasReachedMax) {
      return;
    }

    final nextPage = state.currentPage + 1;
    _cancelToken = CancelToken();

    emit(
      VehicleModelPaginationLoading(
        models: state.models,
        totalCount: state.totalCount,
        hasReachedMax: state.hasReachedMax,
        currentPage: state.currentPage,
      ),
    );

    try {
      final result = await vehicleRepository.getModels(
        page: nextPage,
        limit: _pageSize,
        cancelToken: _cancelToken,
      );

      if (state is! VehicleModelLoaded &&
          state is! VehicleModelPaginationLoading) {
        return;
      }

      final updatedModels = List.of(state.models)..addAll(result.models);

      emit(
        VehicleModelLoaded(
          models: updatedModels,
          totalCount: result.totalCount,
          hasReachedMax: updatedModels.length >= result.totalCount,
          currentPage: nextPage,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;
      emit(
        VehicleModelError(
          e.toString(),
          models: state.models,
          totalCount: state.totalCount,
          hasReachedMax: state.hasReachedMax,
          currentPage: state.currentPage,
        ),
      );
    } catch (e) {
      emit(
        VehicleModelError(
          e.toString(),
          models: state.models,
          totalCount: state.totalCount,
          hasReachedMax: state.hasReachedMax,
          currentPage: state.currentPage,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel('Bloc closed');
    return super.close();
  }
}
