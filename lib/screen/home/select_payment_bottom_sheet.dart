import 'package:flutter/material.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/screen/home/success_bottom_sheet.dart';
import 'package:onecharge/screen/payment/payment_webview_screen.dart';
import 'package:onecharge/models/ticket_model.dart';

class SelectPaymentBottomSheet extends StatefulWidget {
  final PaymentBreakdown? paymentBreakdown;
  final String? paymentUrl;
  final String? intentionId;

  const SelectPaymentBottomSheet({
    super.key,
    this.paymentBreakdown,
    this.paymentUrl,
    this.intentionId,
  });

  @override
  State<SelectPaymentBottomSheet> createState() =>
      _SelectPaymentBottomSheetState();
}

class _SelectPaymentBottomSheetState extends State<SelectPaymentBottomSheet> {
  String _selectedMethod = "card";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Select Payment",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lufga',
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Debit/Credit Card Section
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "+Add Card",
                style: TextStyle(
                  color: Color(0xFF2196F3),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lufga',
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            "Online Payment",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lufga',
            ),
          ),
          // const SizedBox(height: 16),
          // _buildPaymentOption(
          //   id: "tabby",
          //   title: "Pay",
          //   logo: "assets/issue/tabby.png",
          // ),
          // const SizedBox(height: 16),
          // _buildPaymentOption(
          //   id: "tamara",
          //   title: "Pay",
          //   logo: "assets/issue/tamara.png",
          // ),
          if (widget.paymentUrl != null) ...[
            const SizedBox(height: 16),
            _buildPaymentOption(id: "paymob", title: "Paymob", logo: null),
          ],

          const SizedBox(height: 16),
          OneBtn(
            onPressed: () {
              // Handle Paymob payment
              if (_selectedMethod == "paymob" && widget.paymentUrl != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentWebViewScreen(
                      paymentUrl: widget.paymentUrl!,
                      intentionId: widget.intentionId,
                    ),
                  ),
                ).then((paymentSuccess) {
                  if (mounted) {
                    Navigator.pop(context); // Close SelectPaymentBottomSheet
                    if (paymentSuccess == true) {
                      // Show success screen
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const SuccessBottomSheet(),
                      );
                    }
                  }
                });
              } else {
                // Handle other payment methods (card, tabby, tamara, cash)
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const SuccessBottomSheet(),
                );
              }
            },
            text: "Make Payment",
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    bool isSecured = false,
    String? logo,
  }) {
    final isSelected = _selectedMethod == id;
    final isCard = id == "card";

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        height: isCard ? 90 : 70,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (logo != null) ...[
              Image.asset(
                logo,
                height: 32,
                width: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.payment, size: 32),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lufga',
              ),
            ),
            if (isSecured) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 10,
                      color: Color(0xFF2196F3),
                    ),
                    SizedBox(width: 2),
                    Text(
                      "Secured",
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
