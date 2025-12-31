import 'package:flutter/material.dart';
import 'package:magic_enlish/features/home/home_screen.dart';
import 'package:magic_enlish/features/auth/register_screen.dart';
import 'package:magic_enlish/data/services/auth_service.dart';
import 'package:magic_enlish/data/models/auth/ResponseLogin.dart';
import 'package:magic_enlish/core/theme/app_colors.dart';
import 'package:magic_enlish/core/theme/app_text_styles.dart';
import 'package:magic_enlish/core/widgets/common/app_logo.dart';
import 'package:magic_enlish/core/widgets/form/custom_text_field.dart';
import 'package:magic_enlish/core/widgets/common/custom_button.dart';
import 'package:magic_enlish/core/utils/snackbar_utils.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';
import 'package:provider/provider.dart';
import 'package:magic_enlish/providers/auth/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final authService = AuthService();
  bool isLoading = false;

  // Validation errors
  String? emailError;
  String? passwordError;

  bool _validateInputs() {
    bool isValid = true;

    setState(() {
      // Validate email
      if (emailCtrl.text.trim().isEmpty) {
        emailError = 'Please enter your email';
        isValid = false;
      } else if (!emailCtrl.text.contains('@') &&
          !emailCtrl.text.contains('.')) {
        emailError = 'Please enter a valid email';
        isValid = false;
      } else {
        emailError = null;
      }

      // Validate password
      if (passCtrl.text.isEmpty) {
        passwordError = 'Please enter your password';
        isValid = false;
      } else if (passCtrl.text.length < 6) {
        passwordError = 'Password must be at least 6 characters';
        isValid = false;
      } else {
        passwordError = null;
      }
    });

    return isValid;
  }

  Future<void> handleLogin() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await authService.login(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      if (result.statusCode == 200 && result.data != null) {
        ResponseLogin responseLogin = result.data!;
        if (mounted) {
          // Lưu thông tin user vào AuthProvider
          await Provider.of<AuthProvider>(
            context,
            listen: false,
          ).setUser(responseLogin);
          // DEBUG: show avatar value returned by backend
          debugPrint(
            'LOGIN: responseLogin.avatarUrl=${responseLogin.avatarUrl}',
          );

          SnackBarUtils.showSuccess(
            context,
            'Welcome back, ${responseLogin.name}!',
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          SnackBarUtils.showError(context, result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'An error occurred: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : AppColors.lightBg;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.textDark;
    final textSecondary = isDark ? Colors.grey.shade400 : AppColors.placeholder;
    final dividerColor = isDark ? Colors.grey.shade700 : AppColors.borderColor;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black26;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const AppLogo(),
                const SizedBox(height: 32),

                // LOGIN CARD BOX
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Welcome Back!",
                              style: AppTextStyles.screenTitle().copyWith(
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Log in to continue your journey.",
                              style: AppTextStyles.subtitle().copyWith(
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // EMAIL FIELD
                      CustomTextField(
                        controller: emailCtrl,
                        hint: "Enter your email",
                        label: "Email or Username",
                        keyboardType: TextInputType.emailAddress,
                        errorText: emailError,
                      ),

                      const SizedBox(height: 20),

                      // PASSWORD FIELD
                      Row(
                        children: [
                          Text(
                            "Password",
                            style: AppTextStyles.label().copyWith(
                              color: isDark ? Colors.grey.shade300 : null,
                            ),
                          ),
                          const Spacer(),
                          Text("Forgot Password?", style: AppTextStyles.link()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: passCtrl,
                        hint: "Enter your password",
                        isPassword: true,
                        errorText: passwordError,
                      ),

                      const SizedBox(height: 24),

                      // LOGIN BUTTON
                      CustomButton(
                        text: "Login",
                        onPressed: handleLogin,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 20),

                      // OR DIVIDER
                      Row(
                        children: [
                          Expanded(
                            child: Container(height: 1, color: dividerColor),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "or",
                              style: AppTextStyles.body().copyWith(
                                color: textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(height: 1, color: dividerColor),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // GOOGLE BUTTON
                      CustomButton(
                        text: "Continue with Google",
                        onPressed: () {
                          SnackBarUtils.showInfo(
                            context,
                            'Feature Coming Soon!',
                          );
                        },
                        isOutlined: true,
                        icon: Image.network(
                          BackendUtils.getImageUrl(
                            localPath: '/storage/google.png',
                            cloudinaryUrl:
                                'https://res.cloudinary.com/dekprzmna/image/upload/v1765509971/google_n7fual.png',
                          ),
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.g_mobiledata,
                                size: 28,
                                color: Colors.red,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // SIGN UP TEXT
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: AppTextStyles.body().copyWith(color: textSecondary),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text("Sign Up", style: AppTextStyles.link()),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
