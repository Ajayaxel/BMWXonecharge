import 'package:flutter/material.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:lottie/lottie.dart';
import 'package:onecharge/screen/home/home_screen.dart';

class SuccessBottomSheet extends StatelessWidget {
  const SuccessBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        children: [
          // Animated Success Lottie
          Lottie.asset(
            'assets/issue/successfully.json',
            width: 128,
            height: 128,
            repeat: true,
          ),
          const SizedBox(height: 32),
          const Text(
            "Successful",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Your issue reported successful. our agent\nwill reach you ASAP",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lufga',
              color: Colors.black.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          OneBtn(
            onPressed: () {
              HomeScreenState.activeState?.startServiceFlow();
              HomeScreenState.activeState?.showToast("Payment Successful!");
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            text: "Done",
          ),
        ],
      ),
    );
  }
}
