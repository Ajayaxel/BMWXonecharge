import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:onecharge/logic/blocs/order/order_bloc.dart';
import 'package:onecharge/logic/blocs/order/order_event.dart';
import 'package:onecharge/logic/blocs/order/order_state.dart';
import 'package:onecharge/models/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(FetchOrderDetailEvent(orderId: widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state.isDetailLoading && state.orderDetail == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          } else if (state.detailError != null && state.orderDetail == null) {
            return Center(child: Text('Error: ${state.detailError}'));
          } else if (state.orderDetail != null) {
            final order = state.orderDetail!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderInfoCard(order),
                  const SizedBox(height: 24),
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => _buildItemCard(item)),
                  const SizedBox(height: 24),
                  _buildAddressSection(order),
                  const SizedBox(height: 24),
                  _buildSummarySection(order),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildOrderInfoCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order ID',
                style: TextStyle(color: Colors.grey, fontFamily: 'Lufga'),
              ),
              Text(
                order.orderNumber,
                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Lufga', fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Date',
                style: TextStyle(color: Colors.grey, fontFamily: 'Lufga'),
              ),
              Text(
                DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(order.placedAt)),
                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Lufga'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status',
                style: TextStyle(color: Colors.grey, fontFamily: 'Lufga'),
              ),
              _buildStatusBadge(order.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.product?.mainImage != null && item.product!.mainImage.isNotEmpty
                  ? Image.network(item.product!.mainImage, fit: BoxFit.cover)
                  : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Lufga',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Lufga'),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.lineTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: 'Lufga',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(OrderModel order) {
    if (order.shippingAddress == null) return const SizedBox();
    final addr = order.shippingAddress!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Address',
          style: TextStyle(fontFamily: 'Lufga', fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(addr.name, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Lufga')),
              const SizedBox(height: 4),
              Text(addr.phone, style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Lufga')),
              const SizedBox(height: 4),
              Text(
                '${addr.address}, ${addr.city}',
                style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Lufga'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(fontFamily: 'Lufga', fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _buildSummaryRow('Subtotal', order.totalAmount, order.currency),
        const SizedBox(height: 8),
        _buildSummaryRow('Shipping', 0.0, order.currency),
        const Divider(height: 24),
        _buildSummaryRow('Total', order.totalAmount, order.currency, isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, String currency, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
            fontFamily: 'Lufga',
          ),
        ),
        Text(
          '$currency ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.black,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            fontSize: isTotal ? 18 : 14,
            fontFamily: 'Lufga',
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: 'Lufga',
        ),
      ),
    );
  }
}
