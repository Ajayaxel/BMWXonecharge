import 'package:flutter/material.dart';
import 'package:onecharge/screen/wallet/widgets/amount_chip.dart';
import 'package:onecharge/screen/wallet/widgets/payment_option_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/wallet/wallet_bloc.dart';
import 'package:onecharge/logic/blocs/wallet/wallet_event.dart';
import 'package:onecharge/logic/blocs/wallet/wallet_state.dart';
import 'package:onecharge/screen/payment/payment_webview_screen.dart';
import 'package:onecharge/screen/wallet/widgets/success_bottom_sheet.dart';
import 'package:onecharge/logic/blocs/profile/profile_bloc.dart';
import 'package:onecharge/logic/blocs/profile/profile_event.dart';

class AddMoneyBottomSheet extends StatefulWidget {
  final Function(double amount, String method) onConfirm;

  const AddMoneyBottomSheet({super.key, required this.onConfirm});

  @override
  State<AddMoneyBottomSheet> createState() => _AddMoneyBottomSheetState();
}

class _AddMoneyBottomSheetState extends State<AddMoneyBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final List<String> _quickAmounts = ['100', '500', '1000'];
  String? _selectedAmount;
  String? _selectedMethod = 'Pay mob';

  void _onQuickSelect(String amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount;
    });
  }

  void _navigateToPayment(BuildContext context, String checkoutUrl) async {
    // Close the current bottom sheet
    Navigator.pop(context);

    // Open WebView
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentWebViewScreen(
          paymentUrl: checkoutUrl,
        ),
      ),
    );

    if (result == true) {
      // Payment Success, show success sheet from WalletScreen context
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => SuccessBottomSheet(
            title: 'Top Up Successful',
            message: 'Your wallet has been credited successfully.',
            onDone: () {
              context.read<ProfileBloc>().add(FetchProfile());
              context.read<WalletBloc>().add(FetchWalletDetailsEvent());
            },
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Add Money',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'Lufga',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w600,
            ),
            onChanged: (value) {
              if (_quickAmounts.contains(value)) {
                setState(() => _selectedAmount = value);
              } else {
                setState(() => _selectedAmount = null);
              }
            },
            decoration: InputDecoration(
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: const Text(
                  'AED',
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              hintText: 'Enter amount',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _quickAmounts.map((amount) {
              return AmountChip(
                amount: amount,
                isSelected: _selectedAmount == amount,
                onTap: () => _onQuickSelect(amount),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          PaymentOptionTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Pay mob',
            isSelected: _selectedMethod == 'Pay mob',
            onTap: () => setState(() => _selectedMethod = 'PAY MOB'),
          ),

          const SizedBox(height: 24),
          BlocListener<WalletBloc, WalletState>(
            listener: (context, state) {
              if (state is WalletTopUpSuccess) {
                _navigateToPayment(context, state.data.checkoutUrl);
              } else if (state is WalletFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error), backgroundColor: Colors.red),
                );
              }
            },
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  final isLoading = state is WalletLoading;
                  return ElevatedButton(
                    onPressed: _amountController.text.isEmpty || isLoading
                        ? null
                        : () {
                            final amount = double.tryParse(_amountController.text) ?? 0;
                            context.read<WalletBloc>().add(TopUpWalletEvent(amount: amount));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Confirm Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Lufga',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
