import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onecharge/screen/home/chat_support_screen.dart';
import 'package:onecharge/screen/home/my_location_screen.dart';
import 'package:onecharge/screen/home/my_vehicle_screen.dart';
import 'package:onecharge/screen/home/profile_screen.dart';
import 'package:onecharge/screen/home/recent_bookings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Profile Section
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _imageFile != null
                          ? FileImage(File(_imageFile!.path))
                          : const NetworkImage(
                                  'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                                )
                                as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Saleh Al Sabah',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lufga',
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Individual',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Lufga',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Vehicle Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildVehicleCard(
                      'BMW i5',
                      'DUBAI01AS55',
                      'assets/home/profilecar.png',
                      const Color(0xFFF7F7F7),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildVehicleCard(
                      'BMW i7',
                      'DUBAI01AS55',
                      'assets/home/profilecar.png',
                      const Color(0xFFF7F7F7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Menu Items
            _buildMenuItem(
              Icons.person_outline,
              'Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              Icons.history,
              'Recent Bookings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecentBookingsScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              Icons.notifications_none_outlined,
              'Notification',
              trailing: Switch(
                value: true,
                onChanged: (val) {},
                activeColor: Colors.green,
              ),
            ),
            _buildMenuItem(
              Icons.directions_car_filled_outlined,
              'My Vehicle',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyVehicleScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              Icons.location_on_outlined,
              'Location',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyLocationScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(Icons.info_outline, 'Terms & Conditions'),
            _buildMenuItem(
              Icons.chat_bubble_outline,
              'Chat Support',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatSupportScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              Icons.logout,
              'Log out',
              showArrow: false,
              onTap: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to log out from\nthe application?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        color: Color(0xff636363),
                      ),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Lufga',
                          ),
                        ),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () {
                          // TODO: Implement actual logout
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: Color(0xffFF0000),
                            fontFamily: 'Lufga',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            _buildMenuItem(
              Icons.delete_outline,
              'Delete Account',
              showArrow: false,
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text(
                      'Are You Sure?',
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: const Text(
                      'You will permanently lose your account. This action cannot be undone',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontFamily: 'Lufga',
                        color: Color(0xff636363),
                      ),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Lufga',
                          ),
                        ),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () {
                          // TODO: Implement actual deletion
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Color(0xffFF0000),
                            fontFamily: 'Lufga',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(
    String title,
    String subtitle,
    String imagePath,
    Color bgColor,
  ) {
    return Container(
      height: 210,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(child: Image.asset(imagePath, fit: BoxFit.contain)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB8B9BD),
              fontFamily: 'Lufga',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    Widget? trailing,
    bool showArrow = true,
    Color textColor = Colors.black,
    Color iconColor = Colors.grey,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontFamily: 'Lufga',
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          trailing ??
          (showArrow
              ? const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                )
              : null),
      onTap: onTap,
    );
  }
}
