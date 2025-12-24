import 'dart:math';
import 'package:flutter/material.dart';

class GrammarResultScreen extends StatefulWidget {
  const GrammarResultScreen({super.key});

  @override
  State<GrammarResultScreen> createState() => _GrammarResultScreenState();
}

class _GrammarResultScreenState extends State<GrammarResultScreen> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final card = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textMain =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937);
    final textSub =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    const primary = Color(0xFF6B4EFF);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          _statusBar(textMain),
          _header(textMain),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _originalText(card, textMain),
                  const SizedBox(height: 12),
                  _scoreCard(card, textMain, textSub),
                  const SizedBox(height: 12),
                  _summary(card, textMain),
                  const SizedBox(height: 12),
                  _corrected(card),
                  const SizedBox(height: 12),
                  _grammarCard(
                    title: "Tt Grammar",
                    text:
                        "He go to the school yesterday but don't bringed his book",
                    wrong: "go",
                    correct: "went",
                    explain:
                        "Động từ 'go' cần chia ở thì quá khứ đơn vì có 'yesterday'.",
                    card: card,
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  _grammarCard(
                    title: "Tt Grammar",
                    text:
                        "yesterday but don't bringed his book",
                    wrong: "don't",
                    correct: "did not",
                    explain:
                        "Phủ định thì quá khứ dùng 'did not' + động từ nguyên mẫu.",
                    card: card,
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  _grammarCard(
                    title: "Tt Grammar",
                    text:
                        "but don't bringed his book",
                    wrong: "bringed",
                    correct: "bring",
                    explain:
                        "Sau 'did not', động từ phải ở dạng nguyên mẫu.",
                    card: card,
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  _punctuation(card, textMain, textSub),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? Colors.white : Colors.black,
        onPressed: () => setState(() => isDark = !isDark),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          color: isDark ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  // ================= STATUS =================
  Widget _statusBar(Color text) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("10:47",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Row(
            children: const [
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
  Widget _header(Color textMain) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            "Grammar Checker",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.image_search, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ================= ORIGINAL =================
  Widget _originalText(Color card, Color textMain) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ORIGINAL TEXT",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "He go to the school yesterday but don't bringed his book",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: textMain,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SCORE =================
  Widget _scoreCard(Color card, Color textMain, Color textSub) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _card(card),
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: _CircleScorePainter(0.4),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("40",
                        style:
                            TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                    Text("/ 100",
                        style:
                            TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text("Your Score",
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            "Significant improvements needed.",
            style: TextStyle(color: textSub),
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summary(Color card, Color textMain) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Summary of Suggestions",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _summaryRow(Icons.spellcheck, Colors.red, "0 Spelling Errors"),
          _summaryRow(Icons.text_fields, Colors.purple, "3 Grammar Errors"),
          _summaryRow(Icons.edit, Colors.blue, "1 Punctuation Mistake"),
          _summaryRow(Icons.lightbulb, Colors.orange, "0 Clarity Improvements"),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // ================= CORRECTED =================
  Widget _corrected(Color card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F6EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white),
              ),
              SizedBox(width: 8),
              Text("Corrected Version",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              Spacer(),
              Icon(Icons.copy, color: Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: _card(Colors.white),
            child: const Text(
              "He went to the school yesterday but did not bring his book.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ================= GRAMMAR CARD =================
  Widget _grammarCard({
    required String title,
    required String text,
    required String wrong,
    required String correct,
    required String explain,
    required Color card,
    required Color textMain,
    required Color textSub,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: _card(card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 18, color: textMain),
              children: [
                TextSpan(
                  text: text.replaceAll(wrong, ""),
                ),
                TextSpan(
                  text: wrong,
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.purple,
                  ),
                ),
                TextSpan(
                  text: " $correct ",
                  style: const TextStyle(
                    backgroundColor: Color(0xFFE6F6EB),
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(explain, style: TextStyle(color: textSub)),
        ],
      ),
    );
  }

  // ================= PUNCTUATION =================
  Widget _punctuation(Color card, Color textMain, Color textSub) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: _card(card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Punctuation",
              style: TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("his book.",
              style: TextStyle(
                  fontSize: 18,
                  color: textMain,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text("Câu trần thuật cần kết thúc bằng dấu chấm (.)",
              style: TextStyle(color: textSub)),
        ],
      ),
    );
  }

  // ================= BOTTOM NAV =================
  Widget _bottomNav() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(Icons.home, "Home"),
          _NavItem(Icons.school, "Vocab"),
          _NavItem(Icons.verified, "Grammar", active: true),
          _NavItem(Icons.fitness_center, "Practice"),
          _NavItem(Icons.bar_chart, "Progress"),
          _NavItem(Icons.account_circle, "Profile"),
        ],
      ),
    );
  }

  BoxDecoration _card(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4),
      ],
    );
  }
}

// ================= SCORE PAINTER =================
class _CircleScorePainter extends CustomPainter {
  final double percent;
  _CircleScorePainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final fgPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * percent,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon,
            color: active ? const Color(0xFF6B4EFF) : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? const Color(0xFF6B4EFF) : Colors.grey,
          ),
        ),
      ],
    );
  }
}
