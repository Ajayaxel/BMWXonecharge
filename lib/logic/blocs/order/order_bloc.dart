import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/product_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final ProductRepository productRepository;

  OrderBloc({required this.productRepository}) : super(const OrderState()) {
    on<FetchOrdersEvent>(_onFetchOrders);
    on<FetchOrderDetailEvent>(_onFetchOrderDetail);
  }

  Future<void> _onFetchOrders(FetchOrdersEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(isOrdersLoading: true, ordersError: null));
    try {
      final response = await productRepository.getOrders(page: event.page);
      emit(state.copyWith(
        isOrdersLoading: false,
        ordersData: response.data,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOrdersLoading: false,
        ordersError: e.toString(),
      ));
    }
  }

  Future<void> _onFetchOrderDetail(FetchOrderDetailEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(isDetailLoading: true, detailError: null));
    try {
      final response = await productRepository.getOrderDetail(event.orderId);
      emit(state.copyWith(
        isDetailLoading: false,
        orderDetail: response.data,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDetailLoading: false,
        detailError: e.toString(),
      ));
    }
  }
}
