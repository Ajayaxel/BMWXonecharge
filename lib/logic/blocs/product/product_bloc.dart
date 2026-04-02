import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
  }

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final response = await productRepository.getProducts(page: event.page);
      if (response.success) {
        emit(ProductLoaded(data: response.data));
      } else {
        emit(ProductFailure(error: 'Failed to fetch products'));
      }
    } catch (e) {
      emit(ProductFailure(error: e.toString()));
    }
  }
}
