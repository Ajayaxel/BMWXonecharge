import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/logic/blocs/cart/cart_bloc.dart';
import 'package:onecharge/models/cart_model.dart';
import 'package:onecharge/screen/payment/payment_webview_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final CartData cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _buildingController = TextEditingController();
  final _notesController = TextEditingController();
  final _promoController = TextEditingController();

  String _selectedPaymentMethod = 'paymob';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _buildingController.dispose();
    _notesController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _onPlaceOrder() {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final checkoutData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'notes': _notesController.text,
      'promo_code': _promoController.text,
      'payment_method': _selectedPaymentMethod,
      'building': _buildingController.text,
    };

    context.read<CartBloc>().add(CheckoutEvent(checkoutData: checkoutData));
  }

  void _handleCheckoutSuccess(Map<String, dynamic> data) async {
    final paymentUrl = data['payment_url'];
    final intentionId = data['intention_id'];

    if (paymentUrl != null) {
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebViewScreen(
            paymentUrl: paymentUrl,
            intentionId: intentionId,
          ),
        ),
      );

      if (mounted) {
        if (success == true) {
          _showStatusDialog(
            isSuccess: true,
            message: 'Your order has been placed successfully!',
          );
        } else {
          _showStatusDialog(
            isSuccess: false,
            message: 'Payment was canceled or failed. Please try again.',
          );
        }
      }
    } else {
      // Wallet payment or no URL needed
      _showStatusDialog(
        isSuccess: true,
        message: 'Your order has been placed successfully!',
      );
    }
  }

  void _showStatusDialog({required bool isSuccess, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFF3EDF7), // Matching the lavender tint in screenshot
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error_outline,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? 'Success!' : 'Failed!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  fontFamily: 'Lufga',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontFamily: 'Lufga',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      if (isSuccess) {
                        Navigator.pop(context); // Go back to cart
                        Navigator.pop(context); // Go back to shop
                      }
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          _handleCheckoutSuccess(state.data);
        } else if (state is CartFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Checkout',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lufga',
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSectionHeader('Customer Info'),
                  _buildCustomerInfo(),
                  const SizedBox(height: 20),

                  _buildSectionHeader('Address'),
                  _buildAddressSection(),
                  const SizedBox(height: 20),

                  _buildSectionHeader('Notes'),
                  _buildNotesSection(),
                  const SizedBox(height: 20),

                  _buildSectionHeader('Promo Code'),
                  _buildPromoCodeSection(),
                  const SizedBox(height: 20),

                  _buildSectionHeader('Order Summary'),
                  _buildOrderSummary(widget.cart),
                  const SizedBox(height: 20),

                  _buildSectionHeader('Payment'),
                  _buildPaymentSection(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartLoading) {
                  return Container(
                    color: Colors.black12,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        bottomSheet: _buildBottomButton(context),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontFamily: 'Lufga',
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCustomerInfo() {
    return _buildCard(
      child: Column(
        children: [
          _buildTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
            controller: _nameController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Phone Number',
            hint: 'Enter phone number',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
            controller: _phoneController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Email Address',
            hint: 'Enter email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return _buildCard(
      child: Column(
        children: [
          _buildTextField(
            label: 'City',
            hint: 'Enter city',
            icon: Icons.location_city_outlined,
            controller: _cityController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Street Address',
            hint: 'Enter street address',
            icon: Icons.location_on_outlined,
            controller: _addressController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Building / Floor',
            hint: 'Building Name, Floor, Apt No',
            icon: Icons.home_work_outlined,
            controller: _buildingController,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildCard(
      child: _buildTextField(
        label: 'Additional Info',
        hint: 'Any special instructions for delivery...',
        icon: Icons.note_alt_outlined,
        maxLines: 3,
        controller: _notesController,
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return _buildCard(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promoController,
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                prefixIcon: const Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // Handle promo code application if needed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Promo code applied')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Apply',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartData cart) {
    return _buildCard(
      child: Column(
        children: [
          ...cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} x ${item.quantity}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${cart.currency} ${item.subtotal}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Items', style: TextStyle(color: Colors.grey)),
              Text(
                '${cart.totalCount}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Text(
                '${cart.currency} ${cart.totalPrice}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _buildCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = 'wallet'),
            child: _buildPaymentOption(
              'Wallet Balance',
              Icons.account_balance_wallet_outlined,
              isSelected: _selectedPaymentMethod == 'wallet',
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = 'paymob'),
            child: _buildPaymentOption(
              'Pay mob',
              Icons.payments_outlined,
              isSelected: _selectedPaymentMethod == 'paymob',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    IconData icon, {
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.black : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.grey,
                fontFamily: 'Lufga',
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: Colors.black, size: 20),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            fontFamily: 'Lufga',
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, fontFamily: 'Lufga'),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: Colors.grey),
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
      child: OneBtn(
        text: 'Place Order',
        onPressed: _onPlaceOrder,
      ),
    );
  }
}
