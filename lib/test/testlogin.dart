import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:onecharge/features/auth/presentation/bloc/auth_event.dart';
import 'package:onecharge/features/auth/presentation/bloc/auth_state.dart';
import 'package:onecharge/screen/vehicle/vehicle_selection.dart';
import 'package:onecharge/test/testregister.dart';
import 'package:onecharge/screen/login/otp_verification_screen.dart';
import 'package:onecharge/test/forgot_password_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class Testlogin extends StatefulWidget {
  const Testlogin({super.key});

  @override
  State<Testlogin> createState() => _TestloginState();
}

class _TestloginState extends State<Testlogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isChecked = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showTopError('Could not launch $url');
    }
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isChecked) {
      _showTopError("Please accept privacy policy and terms");
      return;
    }

    context.read<AuthBloc>().add(
      LoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
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
        if (state is Authenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const VehicleSelection()),
            (route) => false,
          );
        } else if (state is AuthOtpRequired) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationScreen(email: state.email),
              ),
            );
          }
        } else if (state is AuthFailure) {
          _showTopError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final topPadding = MediaQuery.of(context).padding.top;
            final isKeyboardVisible = keyboardHeight > 0;
            final screenHeight = constraints.maxHeight;

            // Adjust flex ratios based on screen height to ensure form fits
            // Large screens (e.g. iPhone Pro Max): 3:2 (Header:Form)
            // Small/Medium screens or when keyboard is visible: Shifts priority to form
            int headerFlex = isKeyboardVisible
                ? 1
                : (screenHeight < 700 ? 5 : 3);
            int formFlex = isKeyboardVisible ? 4 : (screenHeight < 700 ? 7 : 2);

            return Column(
              children: [
                // TOP SECTION - Black area
                Expanded(
                  flex: headerFlex,
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: Column(
                      children: [
                        SizedBox(height: topPadding),
                        const Spacer(flex: 2),
                        Center(
                          child: Image.asset(
                            'assets/login/logo.png',
                            fit: BoxFit.contain,
                            height: isKeyboardVisible ? 24 : 30,
                          ),
                        ),
                        if (!isKeyboardVisible) ...[
                          const Spacer(flex: 3),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Electric vehicle charging\nstation for everyone.\nDiscover. Charge. Pay.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const Spacer(flex: 2),
                          Expanded(
                            flex: 12,
                            child: Image.asset(
                              "assets/login/carimage.png",
                              fit: BoxFit.contain,
                              width: double.infinity,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ] else
                          const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),

                // BOTTOM SECTION - White form
                Expanded(
                  flex: formFlex,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  10,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(flex: 1),
                                      const Text(
                                        "Enter your email and password to proceed",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const Spacer(flex: 3),
                                      // Email Field
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        onTapOutside: (event) {
                                          FocusScope.of(context).unfocus();
                                        },
                                        style: const TextStyle(fontSize: 14),
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
                                          hintText: 'Enter your email',
                                          icon: Icons.email_outlined,
                                        ),
                                      ),
                                      const Spacer(flex: 4),
                                      // Password Field
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _handleLogin(),
                                        onTapOutside: (event) {
                                          FocusScope.of(context).unfocus();
                                        },
                                        style: const TextStyle(fontSize: 14),
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
                                          hintText: 'Enter your password',
                                          icon: Icons.lock_outline,
                                          isPassword: true,
                                        ),
                                      ),
                                      const Spacer(flex: 4),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const ForgotPasswordScreen(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Forgot Password?",
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(flex: 3),
                                      // Privacy Policy Checkbox
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: Checkbox(
                                              checkColor: Colors.white,
                                              activeColor: Colors.black,
                                              value: _isChecked,
                                              onChanged: (value) {
                                                setState(() {
                                                  _isChecked = value ?? false;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: RichText(
                                              text: TextSpan(
                                                text: "I accept the ",
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black54,
                                                  fontFamily: 'Lufga',
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "Privacy Policy",
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                    recognizer: TapGestureRecognizer()
                                                      ..onTap = () => _launchUrl(
                                                        'https://onecharge.io/privacy-policy',
                                                      ),
                                                  ),
                                                  const TextSpan(text: " and "),
                                                  TextSpan(
                                                    text: "Terms of Service",
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                    recognizer: TapGestureRecognizer()
                                                      ..onTap = () => _launchUrl(
                                                        'https://onecharge.io/terms-conditions',
                                                      ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(flex: 4),
                                      // Login Button
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          return OneBtn(
                                            text: "Login",
                                            isLoading: state is AuthLoading,
                                            onPressed: _handleLogin,
                                          );
                                        },
                                      ),
                                      const Spacer(flex: 3),
                                      Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const Testregister(),
                                              ),
                                            );
                                          },
                                          child: RichText(
                                            text: const TextSpan(
                                              text: "Don't have an account? ",
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: "Register",
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
                                      const Spacer(flex: 2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xffB8B9BD), fontSize: 14),
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
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
