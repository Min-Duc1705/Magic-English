import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isDark = false;
  bool obscurePassword = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputBg = isDark ? const Color(0xFF334155) : const Color(0xFFF5F3FF);
    final inputBorder =
        isDark ? const Color(0xFF475569) : const Color(0xFFC7D2FE);
    final textMain = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statusBar(textMain),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _logo(),
                    const SizedBox(height: 24),
                    _loginCard(
                      card: card,
                      inputBg: inputBg,
                      inputBorder: inputBorder,
                      textMain: textMain,
                    ),
                  ],
                ),
              ),
            ),
            _bottomText(),
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

  // ============= STATUS BAR =================
  Widget _statusBar(Color textMain) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
              RotatedBox(
                quarterTurns: 1,
                child: Icon(Icons.battery_full, size: 16),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ================= LOGO =================
  Widget _logo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(Icons.menu_book,
              size: 48, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text(
          "Magic English",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ================= CARD =================
  Widget _loginCard({
    required Color card,
    required Color inputBg,
    required Color inputBorder,
    required Color textMain,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            "Welcome Back!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Login in to continue your journey",
            style: TextStyle(
              color: Color(0xFF4F46E5),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          _input(
            label: "Email or Username",
            controller: emailController,
            bg: inputBg,
            border: inputBorder,
          ),
          const SizedBox(height: 20),
          _passwordInput(
            bg: inputBg,
            border: inputBorder,
          ),
          const SizedBox(height: 24),
          _loginButton(),
          const SizedBox(height: 24),
          _divider(),
          const SizedBox(height: 16),
          _googleButton(inputBg, inputBorder),
        ],
      ),
    );
  }

  // ================= INPUT =================
  Widget _input({
    required String label,
    required TextEditingController controller,
    required Color bg,
    required Color border,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter your email",
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordInput({
    required Color bg,
    required Color border,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Password",
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(
              "Forgot Password?",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F46E5)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: "Enter your password",
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => obscurePassword = !obscurePassword),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= BUTTONS =================
  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
        ),
        child: const Text(
          "Login",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _googleButton(Color bg, Color border) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: border),
        ),
        icon: Image.network(
          "https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png",
          height: 20,
        ),
        label: const Text(
          "Continue with Google",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text("or"),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  // ================= BOTTOM =================
  Widget _bottomText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: const [
          Text.rich(
            TextSpan(
              text: "Don't have an account? ",
              children: [
                TextSpan(
                  text: "Sign Up",
                  style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
