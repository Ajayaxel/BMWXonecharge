// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:onecharge/const/onebtn.dart';
// import 'dart:async';

// import 'package:onecharge/screen/login/user_info.dart';

// class PhoneLogin extends StatefulWidget {
//   const PhoneLogin({super.key});

//   @override
//   State<PhoneLogin> createState() => _PhoneLoginState();
// }

// class _PhoneLoginState extends State<PhoneLogin> {
//   bool _showOtpScreen = false;
//   final TextEditingController _phoneController = TextEditingController();
//   final List<TextEditingController> _otpControllers = List.generate(
//     6,
//     (index) => TextEditingController(),
//   );
//   final List<FocusNode> _otpFocusNodes = List.generate(
//     6,
//     (index) => FocusNode(),
//   );
//   Timer? _timer;
//   int _remainingSeconds = 30;
//   bool _isChecked = false;
//   OverlayEntry? _toastEntry;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     for (var controller in _otpControllers) {
//       controller.dispose();
//     }
//     for (var node in _otpFocusNodes) {
//       node.dispose();
//     }
//     _timer?.cancel();
//     _toastEntry?.remove();
//     super.dispose();
//   }

//   void _startTimer() {
//     _remainingSeconds = 30;
//     _timer?.cancel();
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_remainingSeconds > 0) {
//         setState(() {
//           _remainingSeconds--;
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   void _resendOtp() {
//     _startTimer();
//     // Add your OTP resend logic here
//   }

//   void _showToast(String message) {
//     _toastEntry?.remove();
//     _toastEntry = null;

//     final entry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: MediaQuery.of(context).padding.top + 20,
//         right: 20,
//         child: Material(
//           color: Colors.transparent,
//           child: TweenAnimationBuilder<double>(
//             tween: Tween(begin: 0.0, end: 1.0),
//             duration: const Duration(milliseconds: 300),
//             builder: (context, value, child) {
//               return Opacity(
//                 opacity: value,
//                 child: Transform.translate(
//                   offset: Offset(20 * (1 - value), 0),
//                   child: child,
//                 ),
//               );
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.9),
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.info_outline, color: Colors.white, size: 20),
//                   const SizedBox(width: 10),
//                   Text(
//                     message,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     _toastEntry = entry;
//     Overlay.of(context).insert(entry);

//     Future.delayed(const Duration(seconds: 3), () {
//       if (_toastEntry == entry) {
//         _toastEntry?.remove();
//         _toastEntry = null;
//       }
//     });
//   }

//   void _handleContinue() {
//     if (_phoneController.text.isEmpty) {
//       _showToast("Please enter mobile number");
//       return;
//     }

//     if (!_isChecked) {
//       _showToast("Please accept privacy policy and terms");
//       return;
//     }

//     if (_phoneController.text.isNotEmpty && _isChecked) {
//       setState(() {
//         _showOtpScreen = true;
//       });
//       _startTimer();
//       // Auto-focus the first OTP field after a short delay to allow the animation/transition
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted && _otpFocusNodes.isNotEmpty) {
//           _otpFocusNodes[0].requestFocus();
//         }
//       });
//     }
//   }

//   void _handleOtpContinue() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const UserInfo()),
//     );
//     // Verify OTP and proceed
//     String otp = _otpControllers.map((c) => c.text).join();
//     if (otp.length == 6) {
//       // Add your OTP verification logic here
//       print("OTP: $otp");
//     }
//   }

//   void _goBack() {
//     setState(() {
//       _showOtpScreen = false;
//       _timer?.cancel();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Set system UI colors to black to prevent white flash on refresh
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.black,
//         statusBarIconBrightness: Brightness.light,
//         systemNavigationBarColor: Colors.black,
//         systemNavigationBarIconBrightness: Brightness.light,
//       ),
//     );

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
//         final topPadding = MediaQuery.of(context).padding.top;
//         final isKeyboardVisible = keyboardHeight > 0;

//         return Scaffold(
//           backgroundColor: Colors.black,
//           resizeToAvoidBottomInset: false,
//           body: Container(
//             color: Colors.black,
//             child: Column(
//               children: [
//                 SizedBox(height: topPadding),
//                 // TOP SECTION - Black area
//                 if (!isKeyboardVisible)
//                   // Full top section when no keyboard
//                   Expanded(
//                     flex: 1,
//                     child: _showOtpScreen
//                         ? Stack(
//                             children: [
//                               Column(
//                                 children: [
//                                   const Spacer(flex: 3),
//                                   Center(
//                                     child: Image.asset(
//                                       'assets/login/logo.png',
//                                       fit: BoxFit.cover,
//                                       height: 30,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 20),
//                                   const Text(
//                                     "Electric vehicle charging\nstation for everyone.\nDiscover. Charge. Pay.",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   const Spacer(flex: 3),
//                                   Image.asset(
//                                     "assets/login/carimage.png",
//                                     fit: BoxFit.contain,
//                                     width: double.infinity,
//                                     alignment: Alignment.bottomCenter,
//                                   ),
//                                 ],
//                               ),
//                               Positioned(
//                                 top: 16,
//                                 left: 16,
//                                 child: GestureDetector(
//                                   onTap: _goBack,
//                                   child: Container(
//                                     width: 40,
//                                     height: 40,
//                                     decoration: const BoxDecoration(
//                                       color: Colors.white,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.arrow_back,
//                                       color: Colors.black,
//                                       size: 20,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 70),
//                               Center(
//                                 child: Image.asset(
//                                   'assets/login/logo.png',
//                                   fit: BoxFit.cover,
//                                   height: 30,
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                               const Text(
//                                 "Electric vehicle charging\nstation for everyone.\nDiscover. Charge. Pay.",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Expanded(
//                                 child: Image.asset(
//                                   "assets/login/carimage.png",
//                                   fit: BoxFit.contain,
//                                   width: double.infinity,
//                                   alignment: Alignment.bottomCenter,
//                                 ),
//                               ),
//                             ],
//                           ),
//                   )
//                 else
//                   // Small top section when keyboard is visible - use Expanded to push form down
//                   Expanded(
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 35),
//                         Center(
//                           child: Image.asset(
//                             'assets/login/logo.png',
//                             fit: BoxFit.cover,
//                             height: 30,
//                           ),
//                         ),
//                         const Spacer(), // This pushes the form to the bottom
//                       ],
//                     ),
//                   ),

//                 // FORM SECTION - White area
//                 if (_showOtpScreen)
//                   // OTP Form - Use Container (not Flexible) to let it take only needed space
//                   Container(
//                     width: double.infinity,
//                     decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                       ),
//                       color: Colors.white,
//                     ),
//                     child: SingleChildScrollView(
//                       physics: isKeyboardVisible
//                           ? const BouncingScrollPhysics()
//                           : const NeverScrollableScrollPhysics(),
//                       padding: EdgeInsets.only(
//                         left: 16,
//                         right: 16,
//                         top: 30,
//                         bottom: isKeyboardVisible ? keyboardHeight + 20 : 30,
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: _buildOtpContent(),
//                       ),
//                     ),
//                   )
//                 else
//                   // Phone Form - Now using Container like OTP screen to allow expansion with keyboard
//                   Container(
//                     width: double.infinity,
//                     decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                       ),
//                       color: Colors.white,
//                     ),
//                     child: SingleChildScrollView(
//                       physics: isKeyboardVisible
//                           ? const BouncingScrollPhysics()
//                           : const NeverScrollableScrollPhysics(),
//                       padding: EdgeInsets.only(
//                         left: 16,
//                         right: 16,
//                         top: 20,
//                         bottom: isKeyboardVisible ? keyboardHeight + 20 : 30,
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: _buildPhoneInputContent(),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<Widget> _buildPhoneInputContent() {
//     return [
//       Text(
//         "Login",
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//       ),
//       Text(
//         "Enter your mobile number to proceed",
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w400,
//           color: Colors.black54,
//         ),
//       ),
//       SizedBox(height: 24),
//       TextField(
//         controller: _phoneController,
//         keyboardType: TextInputType.phone,
//         onTapOutside: (event) {
//           FocusScope.of(context).unfocus();
//         },
//         decoration: InputDecoration(
//           hintText: 'Enter your mobile number',
//           hintStyle: TextStyle(color: Color(0xffB8B9BD)),
//           prefixIcon: Icon(Icons.phone),
//           border: OutlineInputBorder(
//             borderSide: BorderSide(color: Color(0xffE4E4E4)),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Color(0xffE4E4E4)),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black),
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       ),
//       SizedBox(height: 16),
//       Row(
//         children: [
//           Checkbox(
//             value: _isChecked,
//             onChanged: (value) {
//               setState(() {
//                 _isChecked = value ?? false;
//               });
//             },
//           ),
//           Flexible(
//             child: Text(
//               "I accept the Privacy Policy and Terms of Service",
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w400,
//                 color: Colors.black54,
//               ),
//             ),
//           ),
//         ],
//       ),
//       SizedBox(height: 16),
//       OneBtn(text: "Continue", onPressed: _handleContinue),
//       SizedBox(height: 24),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Divider(
//               color: Color(0xffDDDCE1),
//               thickness: 1,
//               endIndent: 16,
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               "OR",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Divider(color: Color(0xffDDDCE1), thickness: 1, indent: 16),
//           ),
//         ],
//       ),
//       SizedBox(height: 24),
//       Container(
//         height: 45,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Color(0xffF5F5F5),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.asset(
//               "assets/login/apple.png",
//               height: 24,
//               width: 24,
//               fit: BoxFit.cover,
//             ),
//             SizedBox(width: 10),
//             Text(
//               "Continue with Apple",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//       SizedBox(height: 16),
//       Container(
//         height: 45,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Color(0xffF5F5F5),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.asset(
//               "assets/login/google.png",
//               height: 24,
//               width: 24,
//               fit: BoxFit.cover,
//             ),
//             SizedBox(width: 10),
//             Text(
//               "Continue with Google",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ];
//   }

//   List<Widget> _buildOtpContent() {
//     String formattedTime = "0:${_remainingSeconds.toString().padLeft(2, '0')}";

//     return [
//       Text(
//         "Verify Details",
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//       ),
//       Text(
//         "OTP sent to ${_phoneController.text}",
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w400,
//           color: Colors.black54,
//         ),
//       ),
//       SizedBox(height: 32),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: List.generate(6, (index) {
//           return Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               border: Border.all(color: Color(0xffE4E4E4)),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: TextField(
//               // out side clieking the keybord will be exit
//               onTapOutside: (event) {
//                 _otpFocusNodes[index].unfocus();
//               },
//               controller: _otpControllers[index],
//               focusNode: _otpFocusNodes[index],
//               textAlign: TextAlign.center,
//               keyboardType: TextInputType.number,
//               maxLength: 1,
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//               decoration: InputDecoration(
//                 counterText: "",
//                 border: InputBorder.none,
//               ),
//               onChanged: (value) {
//                 if (value.isNotEmpty && index < 5) {
//                   _otpFocusNodes[index + 1].requestFocus();
//                 } else if (value.isEmpty && index > 0) {
//                   _otpFocusNodes[index - 1].requestFocus();
//                 }
//               },
//             ),
//           );
//         }),
//       ),
//       SizedBox(height: 24),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "Didn't receive the code? ",
//             style: TextStyle(fontSize: 14, color: Colors.black54),
//           ),
//           Text(
//             formattedTime + ". ",
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.black54,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           GestureDetector(
//             onTap: _remainingSeconds == 0 ? _resendOtp : null,
//             child: Text(
//               "Resend",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: _remainingSeconds == 0 ? Colors.black : Colors.black38,
//                 fontWeight: FontWeight.w500,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//           ),
//         ],
//       ),
//       SizedBox(height: 32),
//       OneBtn(text: "Continue", onPressed: _handleOtpContinue),
//     ];
//   }
// }

// class InputFileds extends StatelessWidget {
//   final String hintText;
//   final IconData icon;
//   const InputFileds({super.key, required this.hintText, required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       onTapOutside: (event) {
//         FocusScope.of(context).unfocus();
//       },
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: TextStyle(color: Color(0xffB8B9BD)),
//         prefixIcon: Icon(icon),
//         border: OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xffE4E4E4)),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xffE4E4E4)),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.black),
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
// }
