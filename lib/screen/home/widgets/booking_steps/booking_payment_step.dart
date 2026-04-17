import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:onecharge/logic/blocs/company_code/company_code_bloc.dart';
import 'package:onecharge/logic/blocs/company_code/company_code_event.dart';
import 'package:onecharge/logic/blocs/company_code/company_code_state.dart';
import 'package:onecharge/logic/blocs/redeem_code/redeem_code_bloc.dart';
import 'package:onecharge/logic/blocs/redeem_code/redeem_code_event.dart';
import 'package:onecharge/logic/blocs/redeem_code/redeem_code_state.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_state.dart';
import '../../../../const/onebtn.dart';

class BookingPaymentStep extends StatefulWidget {
  final TextEditingController redeemCodeController;
  final String? appliedRedeemCode;
  final ValueNotifier<String> selectedPaymentMethodNotifier;
  final TextEditingController companyCodeController;
  final VoidCallback onSubmit;
  final VoidCallback onInstantBooking;
  final VoidCallback onBack;
  final Function(String) showToast;
  final String Function(String) formatErrorMessage;

  // Added for Summary
  final String vehicleName;
  final String vehiclePlate;
  final String vehicleImage;
  final String address;
  final String serviceCategory;
  final String? chargeUnit;
  final DateTime? selectedDateTime;

  const BookingPaymentStep({
    super.key,
    required this.redeemCodeController,
    this.appliedRedeemCode,
    required this.selectedPaymentMethodNotifier,
    required this.companyCodeController,
    required this.onSubmit,
    required this.onInstantBooking,
    required this.onBack,
    required this.showToast,
    required this.formatErrorMessage,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.vehicleImage,
    required this.address,
    required this.serviceCategory,
    this.chargeUnit,
    this.selectedDateTime,
  });

  @override
  State<BookingPaymentStep> createState() => _BookingPaymentStepState();
}

class _BookingPaymentStepState extends State<BookingPaymentStep> {
  String? _loadingButton;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildBookingSummary(),
        const SizedBox(height: 24),
        _buildRedeemCodeSection(context),
        const SizedBox(height: 24),
        const Text(
          "Payment Method",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lufga',
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodOptionsList(),
        const SizedBox(height: 40),
        BlocBuilder<TicketBloc, TicketState>(
          builder: (context, state) {
            final bool isTicketLoading = state is TicketLoading;
            if (!isTicketLoading) {
              _loadingButton = null;
            }

            return Column(
              children: [
                OneBtn(
                  onPressed: isTicketLoading
                      ? null
                      : () {
                          setState(() => _loadingButton = 'submit');
                          widget.onSubmit();
                        },
                  text: "Submit Service",
                  isLoading: isTicketLoading && _loadingButton == 'submit',
                ),
                const SizedBox(height: 12),
                OneBtn(
                  onPressed: isTicketLoading
                      ? null
                      : () {
                          setState(() => _loadingButton = 'instant');
                          widget.onInstantBooking();
                        },
                  text: "Instant Booking",
                  isLoading: isTicketLoading && _loadingButton == 'instant',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: Colors.black,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: widget.onBack,
            child: Text(
              "Back to Slot",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontFamily: 'Lufga',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.vehicleImage.isNotEmpty
                    ? Image.network(
                        widget.vehicleImage,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.directions_car,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.directions_car, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vehicleName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lufga',
                      ),
                    ),
                    Text(
                      widget.vehiclePlate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Selected",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lufga',
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildSummaryItem(
            icon: Icons.location_on_rounded,
            iconColor: Colors.red.shade400,
            title: "Location",
            value: widget.address,
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.settings_rounded,
            iconColor: Colors.orange.shade400,
            title: "Service",
            value:
                "${widget.serviceCategory}${widget.chargeUnit != null ? " (${widget.chargeUnit})" : ""}",
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.calendar_today_rounded,
            iconColor: Colors.green.shade400,
            title: "Slot",
            value: widget.selectedDateTime != null
                ? "${DateFormat('MMM dd, yyyy').format(widget.selectedDateTime!)} | ${DateFormat('hh:mm a').format(widget.selectedDateTime!)}"
                : "Instant (Today)",
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Lufga',
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lufga',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRedeemCodeSection(BuildContext context) {
    return BlocConsumer<RedeemCodeBloc, RedeemCodeState>(
      listener: (context, state) {
        if (state is RedeemCodeSuccess) {
          widget.showToast(state.response.message);
        } else if (state is RedeemCodeFailure) {
          widget.showToast(state.message);
        }
      },
      builder: (context, state) {
        final bool isApplied = state is RedeemCodeSuccess;
        final bool isLoading = state is RedeemCodeLoading;
        final bool canApply = widget.redeemCodeController.text.trim().isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Apply Redeem Code",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lufga',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isApplied
                      ? Colors.green
                      : (state is RedeemCodeFailure
                            ? Colors.red
                            : Colors.grey.shade200),
                  width: isApplied || state is RedeemCodeFailure ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.redeemCodeController,
                      enabled: !isApplied && !isLoading,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: "Enter code here",
                        hintStyle: TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontFamily: 'Lufga',
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (val) {
                        if (state is RedeemCodeFailure) {
                          context.read<RedeemCodeBloc>().add(ResetRedeemCode());
                        }
                      },
                    ),
                  ),
                  if (isApplied)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<RedeemCodeBloc>().add(
                                  ResetRedeemCode(),
                                );
                                widget.redeemCodeController.clear();
                              },
                        child: const Text(
                          "Remove",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lufga',
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OneBtn(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (widget.redeemCodeController.text.trim().isEmpty) {
                                  widget.showToast("Please enter a redeem code");
                                  return;
                                }
                                FocusScope.of(context).unfocus();
                                context.read<RedeemCodeBloc>().add(
                                  ValidateRedeemCode(
                                    widget.redeemCodeController.text.trim(),
                                  ),
                                );
                              },
                        text: "Apply",
                        isLoading: isLoading,
                        width: 100,
                        height: 40,
                      ),
                    ),
                ],
              ),
            ),
            if (isApplied)
              const Padding(
                padding: EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "Code applied successfully!",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodOptionsList() {
    return ValueListenableBuilder<String>(
      valueListenable: widget.selectedPaymentMethodNotifier,
      builder: (context, method, child) {
        return Column(
          children: [
            _buildPaymentOptionItem(
              title: "Pay By Company",
              subtitle: "Billing will be handled by your company",
              value: "company",
              isSelected: method == "company",
              icon: Icons.business_rounded,
            ),
            if (method == "company")
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildCompanyCodeInputFieldSection(context),
              ),
            const SizedBox(height: 12),
            _buildPaymentOptionItem(
              title: "Pay Online",
              subtitle: "Credit/Debit card or Apple Pay",
              value: "online",
              isSelected: method == "online",
              icon: Icons.credit_card_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentOptionItem({
    required String title,
    required String subtitle,
    required String value,
    required bool isSelected,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => widget.selectedPaymentMethodNotifier.value = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lufga',
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade600,
                      fontFamily: 'Lufga',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
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

  Widget _buildCompanyCodeInputFieldSection(BuildContext context) {
    return BlocConsumer<CompanyCodeBloc, CompanyCodeState>(
      listener: (context, state) {
        if (state is CompanyCodeSuccess) {
          widget.showToast(state.response.message);
        } else if (state is CompanyCodeFailure) {
          widget.showToast(widget.formatErrorMessage(state.error));
        }
      },
      builder: (context, state) {
        final bool isApplied = state is CompanyCodeSuccess;
        final bool isLoading = state is CompanyCodeLoading;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isApplied
                  ? Colors.green
                  : (state is CompanyCodeFailure
                        ? Colors.red
                        : Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.companyCodeController,
                  enabled: !isApplied && !isLoading,
                  decoration: const InputDecoration(
                    hintText: "Enter company code",
                    hintStyle: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 14,
                      color: Color(0xFFBDBDBD),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (val) {
                    if (state is CompanyCodeFailure) {
                      context.read<CompanyCodeBloc>().add(ResetCompanyCode());
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OneBtn(
                  onPressed: isApplied || isLoading
                      ? null
                      : () {
                          if (widget.companyCodeController.text.trim().isEmpty) {
                            widget.showToast("Please enter a company code");
                            return;
                          }
                          context.read<CompanyCodeBloc>().add(
                            ValidateCompanyCode(
                              widget.companyCodeController.text.trim(),
                            ),
                          );
                        },
                  text: isApplied ? "Applied" : "Apply",
                  isLoading: isLoading,
                  width: 100,
                  height: 38,
                  backgroundColor: isApplied ? Colors.green : Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
