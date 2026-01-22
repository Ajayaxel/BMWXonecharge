import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/brand_repository.dart';
import 'brand_event.dart';
import 'brand_state.dart';

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  final BrandRepository brandRepository;

  BrandBloc({required this.brandRepository}) : super(BrandInitial()) {
    on<FetchBrands>((event, emit) async {
      emit(BrandLoading());
      try {
        final brands = await brandRepository.getBrands();
        emit(BrandLoaded(brands));
      } catch (e) {
        emit(BrandError(e.toString()));
      }
    });
  }
}
