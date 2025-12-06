import 'package:flutter/material.dart';

class AddWordScreen extends StatelessWidget {
  const AddWordScreen({super.key});

  // ===== COLORS =====
  static const primary = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF2563EB);
  static const bgLight = Color(0xFFF8F9FB);
  static const surface = Colors.white;
  static const textMain = Color(0xFF111827);
  static const textSub = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Column(
        children: [
          _statusBar(),
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _wordInput(),
                  const SizedBox(height: 24),
                  _wordDetailCard(),
                  const SizedBox(height: 32),
                  _addButton(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ================= STATUS BAR =================
  Widget _statusBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: bgLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "9:03",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              Icon(Icons.wifi, size: 18),
              SizedBox(width: 6),
              Icon(Icons.battery_full, size: 18),
            ],
          )
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const Text(
            "Add new word",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ================= INPUT =================
  Widget _wordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter an English word",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textMain,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            TextField(
              controller: TextEditingController(text: "software"),
              decoration: InputDecoration(
                hintText: "Type a word...",
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.mic, color: Colors.green),
                onPressed: () {},
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "Our AI will automatically find the meaning, pronunciation, and examples for you.",
          style: TextStyle(fontSize: 12, color: textSub, height: 1.5),
        ),
      ],
    );
  }

  // ================= WORD DETAIL =================
  Widget _wordDetailCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "software",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "/ˈsɒf.twɛər/",
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                        color: textSub),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: primary),
                onPressed: () {},
              ),
            ],
          ),
          const Divider(height: 32),
          const Text(
            "MEANING",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSub,
                letterSpacing: 1),
          ),
          const SizedBox(height: 6),
          const Text(
            "Phần mềm máy tính; Thành phần phi vật lý",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _infoBlock("Type", "noun"),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Level",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textSub),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary,
                    ),
                    child: const Text(
                      "B1",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "EXAMPLE",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSub,
                letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          _example("This new computer comes with the latest software."),
          _example("You need to update your software for better security."),
        ],
      ),
    );
  }

  Widget _infoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textSub),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _example(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("”",
              style: TextStyle(fontSize: 22, color: primary)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ADD BUTTON =================
  Widget _addButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        onPressed: () {},
        child: const Text(
          "Add Word",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ================= BOTTOM NAV =================
  Widget _bottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(Icons.home, "Home"),
          _NavItem(Icons.school, "Vocab", active: true),
          _NavItem(Icons.spellcheck, "Grammar"),
          _NavItem(Icons.fitness_center, "Practice"),
          _NavItem(Icons.bar_chart, "Progress"),
          _NavItem(Icons.account_circle, "Profile"),
        ],
      ),
    );
  }
}

// ================= NAV ITEM =================
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem(this.icon, this.label, {this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        active
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  color: AddWordScreen.primary.withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: AddWordScreen.primary),
              )
            : Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 10,
              color: active ? AddWordScreen.primary : Colors.grey,
              fontWeight:
                  active ? FontWeight.bold : FontWeight.w500),
        ),
      ],
    );
  }
}
