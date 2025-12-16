import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isDark = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF111827) : const Color(0xFFF8F9FD);
    final surface = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textMain =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textSub =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
    final accent = const Color(0xFF6366F1);
    final primary = const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _statusBar(textMain),
            _header(textMain),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Start your journey to mastering English today.",
                      style: TextStyle(color: textSub, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    _inputField(
                      label: "Full Name",
                      hint: "Enter your full name",
                      icon: Icons.person_outline,
                      controller: fullNameController,
                      surface: surface,
                      accent: accent,
                      primary: primary,
                    ),
                    const SizedBox(height: 20),
                    _inputField(
                      label: "Email Address",
                      hint: "Enter your email",
                      icon: Icons.mail_outline,
                      controller: emailController,
                      surface: surface,
                      accent: accent,
                      primary: primary,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _passwordField(
                      label: "Password",
                      hint: "Enter your password",
                      controller: passwordController,
                      obscure: obscurePassword,
                      onToggle: () =>
                          setState(() => obscurePassword = !obscurePassword),
                      surface: surface,
                      accent: accent,
                      primary: primary,
                    ),
                    const SizedBox(height: 20),
                    _passwordField(
                      label: "Confirm Password",
                      hint: "Confirm your password",
                      controller: confirmController,
                      obscure: obscureConfirm,
                      onToggle: () =>
                          setState(() => obscureConfirm = !obscureConfirm),
                      surface: surface,
                      accent: accent,
                      primary: primary,
                    ),
                    const SizedBox(height: 28),
                    _registerButton(primary),
                    const SizedBox(height: 28),
                    _bottomText(textSub),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? Colors.white : Colors.grey.shade900,
        onPressed: () => setState(() => isDark = !isDark),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          color: isDark ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  // ================= STATUS BAR =================
  Widget _statusBar(Color textMain) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("11:31",
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: textMain)),
          Row(
            children: const [
              Icon(Icons.signal_cellular_alt, size: 16),
              SizedBox(width: 4),
              Icon(Icons.wifi, size: 16),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(Color textMain) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: textMain),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              "Magic English",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ================= INPUT =================
  Widget _inputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Color surface,
    required Color accent,
    required Color primary,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.indigo.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(icon, color: accent),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required Color surface,
    required Color accent,
    required Color primary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.indigo.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(Icons.lock_open, color: accent),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: accent,
                ),
                onPressed: onToggle,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= BUTTON =================
  Widget _registerButton(Color primary) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
        ),
        child: const Text(
          "Register",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // ================= BOTTOM =================
  Widget _bottomText(Color textSub) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: textSub),
          children: const [
            TextSpan(
              text: "Log In",
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
