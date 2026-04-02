import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onecharge/screen/wallet/widgets/add_money_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/wallet/wallet_bloc.dart';
import 'package:onecharge/logic/blocs/wallet/wallet_event.dart';
import 'package:onecharge/logic/blocs/wallet/wallet_state.dart';
import 'package:onecharge/models/wallet_model.dart';
import 'package:intl/intl.dart';
import 'package:onecharge/widgets/crypto_loading.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(FetchWalletDetailsEvent());
  }

  // ios or android custom loading
  bool isIos = Platform.isIOS;

  loading() {
    if (isIos) {
      return const Center(child: CupertinoActivityIndicator());
    } else {
      return const Center(child: CryptoLoading());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading && state is! WalletLoaded) {
            return loading();
          }

          String balance = "0.00";
          String currency = "AED";
          List<Transaction> transactions = [];

          if (state is WalletLoaded) {
            balance = state.data.wallet.balance.toStringAsFixed(2);
            currency = state.data.wallet.currency;
            transactions = state.data.transactions;
          } else if (state is WalletFailure) {
            return Center(child: Text('Error: ${state.error}'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<WalletBloc>().add(FetchWalletDetailsEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black,
                                size: 22,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$currency $balance',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: 'Lufga',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                context.read<WalletBloc>().add(
                                  FetchWalletDetailsEvent(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              'assets/home/BGgrednt.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          Column(
                            children: [
                              const Text(
                                'Total Balance',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontFamily: 'Lufga',
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$currency $balance',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lufga',
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const AddMoneyBottomSheet(
                                  onConfirm: _dummyOnConfirm,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 22,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Top Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Lufga',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                  Container(
                    color: Colors.grey.shade100,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF001F3F),
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ),
                  if (transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontFamily: 'Lufga',
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ...transactions.map(
                      (tx) => _buildTransactionItem(
                        title: tx.type == 'top_up'
                            ? 'Wallet Top-up'
                            : 'Transaction',
                        subtitle: _formatDate(tx.createdAt),
                        amount:
                            '${tx.status == 'pending' ? '-' : (tx.type == 'top_up' ? '+' : '-')}${tx.currency} ${tx.amount.toStringAsFixed(2)}',
                        isOutgoing:
                            tx.status == 'pending' || tx.type != 'top_up',
                        status: tx.status,
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static void _dummyOnConfirm(double amount, String method) {}

  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr).toLocal();
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required String amount,
    required bool isOutgoing,
    required String status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOutgoing
                  ? const Color(0xFFFFEAEA)
                  : const Color(0xFFF1F8E9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOutgoing ? Icons.arrow_outward : Icons.south_west,
              color: isOutgoing
                  ? const Color(0xFFFF5252)
                  : const Color(0xFF4CAF50),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lufga',
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (status == 'pending')
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF888888),
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lufga',
              color: status == 'pending'
                  ? Colors.red
                  : (isOutgoing ? Colors.black : const Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }
}
