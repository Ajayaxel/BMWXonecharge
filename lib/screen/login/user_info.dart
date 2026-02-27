// import 'package:flutter/material.dart';
// import 'package:onecharge/const/onebtn.dart';
// import 'package:onecharge/screen/vehicle/vehicle_selection.dart';

// class UserInfo extends StatefulWidget {
//   const UserInfo({super.key});

//   @override
//   State<UserInfo> createState() => _UserInfoState();
// }

// class _UserInfoState extends State<UserInfo> {
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _uniqueCodeController = TextEditingController();

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _uniqueCodeController.dispose();
//     super.dispose();
//   }

//   void _onContinue() {
//     FocusScope.of(context).unfocus();
//     // Handle continue action
//     final fullName = _fullNameController.text;
//     final email = _emailController.text;
//     final uniqueCode = _uniqueCodeController.text;

//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => VehicleSelection()),
//     );
//     print('Full Name: $fullName');
//     print('Email: $email');
//     print('Unique Code: $uniqueCode');

//     // You can add your API call here
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         resizeToAvoidBottomInset: true, // Pushes UI up when keyboard is open
//         body: Column(
//           children: [
//             // Top Section - Black area with back button
//             Container(
//               height: 120,
//               width: double.infinity,
//               padding: const EdgeInsets.only(left: 16, top: 50),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: GestureDetector(
//                   onTap: () => Navigator.of(context).pop(),
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.black,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // Bottom Section - White container for form
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     topRight: Radius.circular(30),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           children: [
//                             const SizedBox(height: 10),
//                             // Title
//                             const Text(
//                               "Please tell us a bit more about yourself",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w500,
//                                 letterSpacing: -0.5,
//                               ),
//                             ),

//                             const SizedBox(height: 40),

//                             // Full Name Field
//                             _buildTextField(
//                               controller: _fullNameController,
//                               hint: "Full Name",
//                               keyboardType: TextInputType.name,
//                             ),

//                             const SizedBox(height: 16),

//                             // Email Field
//                             _buildTextField(
//                               controller: _emailController,
//                               hint: "Enter Email",
//                               keyboardType: TextInputType.emailAddress,
//                             ),

//                             const SizedBox(height: 16),

//                             // Unique Code Field (Optional)
//                             _buildTextField(
//                               controller: _uniqueCodeController,
//                               hint: "Enter your unique code here (Optional)",
//                               keyboardType: TextInputType.text,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Pin button to bottom of white area
//                     Padding(
//                       padding: const EdgeInsets.only(
//                         left: 24,
//                         right: 24,
//                         bottom: 40,
//                         top: 10,
//                       ),
//                       child: OneBtn(text: "Continue", onPressed: _onContinue),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     required TextInputType keyboardType,
//   }) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade500),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.black, width: 1.5),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 18,
//         ),
//       ),
//       onChanged: (_) => setState(() {}),
//     );
//   }
// }
