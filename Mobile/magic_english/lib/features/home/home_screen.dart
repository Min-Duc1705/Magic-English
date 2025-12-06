import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const primary = Color(0xFF4F46E5);
  static const bgLight = Color(0xFFF3F4F6);
  static const cardLight = Colors.white;
  static const textMain = Color(0xFF111827);
  static const textSub = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _statusBar(),
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                    child: Column(
                      children: [
                        _statGrid(),
                        const SizedBox(height: 20),
                        _featureCard(
                          icon: Icons.translate,
                          title: "Magic Vocab",
                          desc: "Build and review your personal dictionary.",
                          buttons: Row(
                            children: [
                              _primaryBtn("Add New Word"),
                              const SizedBox(width: 12),
                              _outlineBtn("Review Words"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _featureCard(
                          icon: Icons.spellcheck,
                          title: "Grammar & Style",
                          desc: "Refine your writing with AI.",
                          buttons: _primaryBtn("Check Text"),
                        ),
                        const SizedBox(height: 16),
                        _featureCard(
                          icon: Icons.monitoring,
                          title: "Progress Dashboard",
                          desc: "Track your learning journey.",
                          buttons: _primaryBtn("View Progress"),
                        ),
                        const SizedBox(height: 20),
                        _recentWords(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _bottomNav(),
          ],
        ),
      ),
    );
  }

  // ================= STATUS BAR =================
  Widget _statusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("11:31",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 14),
              SizedBox(width: 4),
              Icon(Icons.wifi, size: 14),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 14),
            ],
          )
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Transform.rotate(
            angle: -0.2,
            child: const Icon(Icons.menu_book,
                size: 40, color: primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Hello, Minh Đức!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ================= GRID =================
  Widget _statGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _statCard(
          icon: Icons.local_fire_department,
          color: Colors.orange,
          title: "Learning",
          sub: "Streak",
          value: "0 Days",
        ),
        _statCard(
          icon: Icons.import_contacts,
          color: Colors.blue,
          title: "Vocabulary",
          sub: "Today",
          value: "0 Words",
        ),
        _statCard(
          icon: Icons.psychology,
          color: Colors.green,
          title: "Grammar Check",
          sub: "Today",
          value: "0 times",
        ),
        _statCard(
          icon: Icons.star,
          color: Colors.red,
          title: "Grammar Score",
          sub: "Avg Today",
          value: "0 / 100",
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color color,
    required String title,
    required String sub,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(sub,
                      style: const TextStyle(
                          fontSize: 10, color: textSub)),
                ],
              )
            ],
          ),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ================= FEATURE CARD =================
  Widget _featureCard({
    required IconData icon,
    required String title,
    required String desc,
    required Widget buttons,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _card(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primary, size: 26),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(color: textSub)),
          const SizedBox(height: 16),
          buttons,
        ],
      ),
    );
  }

  // ================= RECENT =================
  Widget _recentWords() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Recently Add Words",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
            "No words added yet",
            style: TextStyle(
                fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ================= BUTTONS =================
  Widget _primaryBtn(String text) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
        ),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _outlineBtn(String text) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFC7D2FE), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: primary)),
      ),
    );
  }

  // ================= BOTTOM NAV =================
  Widget _bottomNav() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 16),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _NavItem(Icons.home, "Home", active: true),
            _NavItem(Icons.school, "Vocab"),
            _NavItem(Icons.spellcheck, "Grammar"),
            _NavItem(Icons.fitness_center, "Practice"),
            _NavItem(Icons.bar_chart, "Progress"),
            _NavItem(Icons.person, "Profile"),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  BoxDecoration _card({double radius = 20}) {
    return BoxDecoration(
      color: cardLight,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 20,
          offset: Offset(0, 8),
        )
      ],
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
        if (active)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: DashboardScreen.primary),
          )
        else
          Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color:
                active ? DashboardScreen.primary : Colors.grey,
          ),
        )
      ],
    );
  }
}
