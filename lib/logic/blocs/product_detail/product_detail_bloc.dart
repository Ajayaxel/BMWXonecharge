import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/product_repository.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final ProductRepository productRepository;

  ProductDetailBloc({required this.productRepository}) : super(ProductDetailInitial()) {
    on<FetchProductDetailEvent>(_onFetchProductDetail);
  }

  Future<void> _onFetchProductDetail(
    FetchProductDetailEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());
    try {
      final response = await productRepository.getProductDetail(event.productId);
      if (response.success) {
        emit(ProductDetailLoaded(response.data));
      } else {
        emit(ProductDetailFailure('Failed to fetch product details'));
      }
    } catch (e) {
      emit(ProductDetailFailure(e.toString()));
    }
  }
}
