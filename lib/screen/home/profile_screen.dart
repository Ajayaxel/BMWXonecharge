import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/logic/blocs/profile/profile_bloc.dart';
import 'package:onecharge/logic/blocs/profile/profile_event.dart';
import 'package:onecharge/logic/blocs/profile/profile_state.dart';
import 'package:onecharge/utils/toast_utils.dart';
import 'package:onecharge/models/user_profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isUpdateLoading = false;

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current state if available.
    // This prevents empty fields if the profile is already loaded.
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _fillControllers(state.customer);
    }
  }

  void _fillControllers(Customer customer) {
    _fullNameController.text = customer.name;
    _emailController.text = customer.email;
    _phoneController.text = customer.phone;
  }

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

  void _updateProfile() {
    context.read<ProfileBloc>().add(
      UpdateProfile(
        name: _fullNameController.text,
        phone: _phoneController.text,
        profileImage: _imageFile != null ? File(_imageFile!.path) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdating) {
          _isUpdateLoading = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 15,
                  ),
                ),
              );
            },
          );
        } else if (state is ProfileUpdated) {
          if (_isUpdateLoading) {
            Navigator.of(context).pop();
            _isUpdateLoading = false;
          }
          // Clear local image file to show network image from response as confirmation
          setState(() {
            _imageFile = null;
          });
          // Update controllers with confirmed data
          _fillControllers(state.customer);
          ToastUtils.showToast(context, state.message);
        } else if (state is ProfileLoaded) {
          // Ensure controllers are populated if we navigated here after a fetch
          // and haven't typed anything yet (or if state just refreshed).
          // We check if controllers are empty to avoid overwriting user input,
          // OR if we strictly want to sync. Given ProfileUpdated handles the update case,
          // this is mostly for initial load latency.
          if (_fullNameController.text.isEmpty && _imageFile == null) {
            _fillControllers(state.customer);
          }
        } else if (state is ProfileError) {
          if (_isUpdateLoading) {
            Navigator.of(context).pop();
            _isUpdateLoading = false;
          }
          ToastUtils.showToast(context, state.message, isError: true);
        }
      },
      child: Scaffold(
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
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading && state is! ProfileUpdating) {
                return const Center(
                  child: CupertinoActivityIndicator(color: Colors.black),
                );
              }

              Customer? customer;
              bool isUpdating = false;

              if (state is ProfileLoaded) {
                customer = state.customer;
              } else if (state is ProfileUpdating) {
                customer = state.currentCustomer;
                isUpdating = true;
              } else if (state is ProfileUpdated) {
                customer = state.customer;
              } else if (state is ProfileError &&
                  _fullNameController.text.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ProfileBloc>().add(FetchProfile()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
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
                              onTap: isUpdating ? null : _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: _imageFile != null
                                          ? Image.file(
                                              File(_imageFile!.path),
                                              fit: BoxFit.cover,
                                            )
                                          : (customer?.profileImage != null
                                                ? Image.network(
                                                    customer!.profileImage!,
                                                    key: ValueKey(
                                                      customer!.profileImage,
                                                    ),
                                                    fit: BoxFit.cover,
                                                    loadingBuilder:
                                                        (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return const Center(
                                                            child:
                                                                CupertinoActivityIndicator(),
                                                          );
                                                        },
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Image.network(
                                                          'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                                                          fit: BoxFit.cover,
                                                        ),
                                                  )
                                                : Image.network(
                                                    'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                                                    fit: BoxFit.cover,
                                                  )),
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
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
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
                            onTap: isUpdating ? null : _pickImage,
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
                          _buildInputField(
                            'Full Name',
                            _fullNameController,
                            enabled: !isUpdating,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            'Email',
                            _emailController,
                            enabled: false,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            'Phone',
                            _phoneController,
                            enabled: !isUpdating,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Update Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: OneBtn(
                      onPressed: isUpdating ? () {} : _updateProfile,
                      text: 'Update',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: enabled ? Colors.white : Colors.grey[50],
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
            enabled: enabled,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lufga',
              color: enabled ? Colors.black : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
