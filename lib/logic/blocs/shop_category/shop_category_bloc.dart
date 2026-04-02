import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/product_repository.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_event.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_state.dart';

class ShopCategoryBloc extends Bloc<ShopCategoryEvent, ShopCategoryState> {
  final ProductRepository productRepository;

  ShopCategoryBloc({required this.productRepository}) : super(ShopCategoryInitial()) {
    on<FetchShopCategories>((event, emit) async {
      emit(ShopCategoryLoading());
      try {
        final response = await productRepository.getCategories();
        emit(ShopCategoryLoaded(response.data));
      } catch (e) {
        emit(ShopCategoryFailure(e.toString()));
      }
    });
  }
}
