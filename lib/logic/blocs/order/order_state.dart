import 'package:equatable/equatable.dart';
import 'package:onecharge/models/order_model.dart';

class OrderState extends Equatable {
  final OrderPaginationData? ordersData;
  final OrderModel? orderDetail;
  final bool isOrdersLoading;
  final bool isDetailLoading;
  final String? ordersError;
  final String? detailError;

  const OrderState({
    this.ordersData,
    this.orderDetail,
    this.isOrdersLoading = false,
    this.isDetailLoading = false,
    this.ordersError,
    this.detailError,
  });

  OrderState copyWith({
    OrderPaginationData? ordersData,
    OrderModel? orderDetail,
    bool? isOrdersLoading,
    bool? isDetailLoading,
    String? ordersError,
    String? detailError,
  }) {
    return OrderState(
      ordersData: ordersData ?? this.ordersData,
      orderDetail: orderDetail ?? this.orderDetail,
      isOrdersLoading: isOrdersLoading ?? this.isOrdersLoading,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      ordersError: ordersError ?? this.ordersError,
      detailError: detailError ?? this.detailError,
    );
  }

  @override
  List<Object?> get props => [
        ordersData,
        orderDetail,
        isOrdersLoading,
        isDetailLoading,
        ordersError,
        detailError,
      ];
}
