import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/form/auth_text_field.dart';
import 'package:magic_enlish/core/widgets/form/custom_password_field.dart';
import 'package:magic_enlish/core/widgets/form/auth_form_field.dart';
import 'package:magic_enlish/data/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  bool passVisible = false;
  bool confirmPassVisible = false;
  bool _isLoading = false;

  Color get primary => const Color(0xFF4A90E2);
  Color get inputBg => const Color(0xfff6f6f8);
  Color get borderLight => const Color(0xffd3cfe7);
  Color get placeholderLight => const Color(0xff594c9a);

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.register(
        nameCtrl.text.trim(),
        emailCtrl.text.trim(),
        passCtrl.text,
      );

      if (!mounted) return;

      if (response.error == null) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration successful! Please login.',
              style: GoogleFonts.lexend(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 100,
              left: 16,
              right: 16,
            ),
          ),
        );
        // Navigate back to login
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.error ?? 'Registration failed',
              style: GoogleFonts.lexend(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 100,
              left: 16,
              right: 16,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e', style: GoogleFonts.lexend()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 16,
            right: 16,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xfff6f6f8);
    final textPrimary = isDark ? Colors.white : const Color(0xff100d1b);
    final textSecondary = isDark
        ? Colors.grey.shade400
        : const Color(0xff100d1b).withOpacity(0.8);
    final inputBgColor = isDark
        ? const Color(0xFF2D2D2D)
        : const Color(0xfff6f6f8);
    final borderColor = isDark ? Colors.grey.shade700 : const Color(0xffd3cfe7);
    final placeholderColor = isDark
        ? Colors.grey.shade500
        : const Color(0xff594c9a);
    final iconColor = isDark ? Colors.white : const Color(0xff100d1b);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // TOP APP BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 60,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, size: 28, color: iconColor),
                  ),
                  Expanded(
                    child: Text(
                      "Magic English",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // cân bằng layout
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADLINE
                      Text(
                        "Create Your Account",
                        style: GoogleFonts.lexend(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Start your journey to mastering English today.",
                        style: GoogleFonts.lexend(
                          color: textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // NAME FIELD
                      AuthFormField(
                        label: "Full Name",
                        inputWidget: AuthTextField(
                          controller: nameCtrl,
                          hint: "Enter your full name",
                          icon: Icons.person_outline,
                          inputBg: inputBgColor,
                          borderLight: borderColor,
                          placeholderLight: placeholderColor,
                          primary: primary,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // EMAIL FIELD
                      AuthFormField(
                        label: "Email Address",
                        inputWidget: AuthTextField(
                          controller: emailCtrl,
                          hint: "Enter your email",
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          inputBg: inputBgColor,
                          borderLight: borderColor,
                          placeholderLight: placeholderColor,
                          primary: primary,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // PASSWORD FIELD
                      AuthFormField(
                        label: "Password",
                        inputWidget: CustomPasswordField(
                          controller: passCtrl,
                          hint: "Enter your password",
                          prefixIcon: Icons.lock_outline,
                          visible: passVisible,
                          onToggle: () => setState(() {
                            passVisible = !passVisible;
                          }),
                          inputBg: inputBgColor,
                          borderLight: borderColor,
                          placeholderLight: placeholderColor,
                          primary: primary,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // CONFIRM PASSWORD
                      AuthFormField(
                        label: "Confirm Password",
                        inputWidget: CustomPasswordField(
                          controller: confirmCtrl,
                          hint: "Confirm your password",
                          prefixIcon: Icons.lock_outline,
                          visible: confirmPassVisible,
                          onToggle: () => setState(() {
                            confirmPassVisible = !confirmPassVisible;
                          }),
                          inputBg: inputBgColor,
                          borderLight: borderColor,
                          placeholderLight: placeholderColor,
                          primary: primary,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != passCtrl.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 40),

                      // REGISTER BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleRegister,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Register",
                                  style: GoogleFonts.lexend(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // LOGIN LINK
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: placeholderColor,
                            ),
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    "Log In",
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
