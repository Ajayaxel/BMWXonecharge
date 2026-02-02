import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/logic/blocs/auth/auth_bloc.dart';
import 'package:onecharge/logic/blocs/auth/auth_event.dart';
import 'package:onecharge/logic/blocs/auth/auth_state.dart';
import 'package:onecharge/models/register_model.dart';
import 'package:onecharge/screen/login/user_info.dart';
import 'package:onecharge/screen/login/otp_verification_screen.dart';
import 'package:onecharge/test/testlogin.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';

class Testregister extends StatefulWidget {
  const Testregister({super.key});

  @override
  State<Testregister> createState() => _TestregisterState();
}

class _TestregisterState extends State<Testregister> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  OverlayEntry? _overlayEntry;
  String _selectedCountryCode = '+91';

  @override
  void dispose() {
    _overlayEntry?.remove();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final registerRequest = RegisterRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _selectedCountryCode + _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    context.read<AuthBloc>().add(RegisterRequested(registerRequest));
  }

  void _showTopError(String message) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    final overlay = Overlay.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding + 10,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Testlogin()),
            (route) => false,
          );
        } else if (state is AuthOtpRequired) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                email: state.email,
                isTestRegister: true,
              ),
            ),
          );
        } else if (state is AuthError) {
          _showTopError(state.message.replaceAll('Exception: ', ''));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        // Using resizeToAvoidBottomInset: true ensures the keyboard pushes the view up,
        // and CustomScrollView handles the scrolling.
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                          bottom: 20,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Center(
                              child: Image.asset(
                                'assets/login/logo.png',
                                fit: BoxFit.cover,
                                height: 30,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Start your journey with us.\nJoin today.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 30,
                          bottom: 30,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Create your account to proceed",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Name Field
                              TextFormField(
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                                decoration: _buildInputDecoration(
                                  'Enter your name',
                                  Icons.person_outline,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                decoration: _buildInputDecoration(
                                  'Enter your email',
                                  Icons.email_outlined,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Phone Field
                              IntlPhoneField(
                                controller: _phoneController,
                                initialCountryCode: 'AE',
                                pickerDialogStyle: PickerDialogStyle(
                                  backgroundColor: Colors.white,
                                ),
                                disableLengthCheck: true,
                                decoration: InputDecoration(
                                  hintText: "Enter your phone",
                                  hintStyle: const TextStyle(
                                    color: Color(0xffB8B9BD),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xffE4E4E4),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xffE4E4E4),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onCountryChanged: (country) {
                                  setState(() {
                                    _selectedCountryCode =
                                        '+${country.dialCode}';
                                  });
                                },
                                validator: (phone) {
                                  if (phone == null || phone.number.isEmpty) {
                                    return "Phone is required";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                decoration: _buildInputDecoration(
                                  'Enter your password',
                                  Icons.lock_outline,
                                  isPassword: true,
                                  obscureText: _obscurePassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Confirm Password Field
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleRegister(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                decoration: _buildInputDecoration(
                                  'Confirm your password',
                                  Icons.lock_outline,
                                  isPassword: true,
                                  obscureText: _obscureConfirmPassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Register Button
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return OneBtn(
                                    text: "Register",
                                    isLoading: state is AuthLoading,
                                    onPressed: _handleRegister,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // Login Link
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: RichText(
                                    text: const TextSpan(
                                      text: "Already have an account? ",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Login",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hintText,
    IconData icon, {
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xffB8B9BD)),
      prefixIcon: Icon(icon),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: onToggleVisibility,
            )
          : null,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xffE4E4E4)),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xffE4E4E4)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
