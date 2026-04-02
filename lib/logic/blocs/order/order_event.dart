import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class FetchOrdersEvent extends OrderEvent {
  final int page;
  const FetchOrdersEvent({this.page = 1});

  @override
  List<Object> get props => [page];
}

class FetchOrderDetailEvent extends OrderEvent {
  final int orderId;
  const FetchOrderDetailEvent({required this.orderId});

  @override
  List<Object> get props => [orderId];
}
