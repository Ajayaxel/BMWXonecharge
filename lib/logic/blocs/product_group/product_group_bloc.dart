import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/product_group_repository.dart';
import 'product_group_event.dart';
import 'product_group_state.dart';

class ProductGroupBloc extends Bloc<ProductGroupEvent, ProductGroupState> {
  final ProductGroupRepository repository;

  ProductGroupBloc({required this.repository}) : super(ProductGroupInitial()) {
    on<FetchProductGroups>((event, emit) async {
      emit(ProductGroupLoading());
      try {
        final groups = await repository.getProductGroups();
        emit(ProductGroupLoaded(groups));
      } catch (e) {
        emit(ProductGroupError(e.toString()));
      }
    });
  }
}
