import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onecharge/const/onebtn.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController(
    text: 'Saleh Al Sabah',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'example@gmail.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+971 524 2213 15',
  );

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
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // Profile Image Section
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                image: DecorationImage(
                                  image: _imageFile != null
                                      ? FileImage(File(_imageFile!.path))
                                      : const NetworkImage(
                                              'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                                            )
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 22,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: const Text(
                        'Tap change photo',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Lufga',
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Input Fields
                    _buildInputField('Full Name', _fullNameController),
                    const SizedBox(height: 20),
                    _buildInputField('Email', _emailController),
                    const SizedBox(height: 20),
                    _buildInputField('Phone', _phoneController),
                  ],
                ),
              ),
            ),
            // Update Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OneBtn(onPressed: () {}, text: 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              fontFamily: 'Lufga',
            ),
          ),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
