import 'dart:math';
import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  // ===== COLORS =====
  static const primary = Color(0xFF6B4EFF);
  static const bgLight = Color(0xFFF3F4F6);
  static const cardLight = Colors.white;
  static const textMain = Color(0xFF1F2937);
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _originalText(),
                  const SizedBox(height: 12),
                  _scoreCard(),
                  const SizedBox(height: 12),
                  _summary(),
                  const SizedBox(height: 12),
                  _corrected(),
                  const SizedBox(height: 12),
                  _grammarCard(
                    wrong: "go",
                    correct: "went",
                    explanation:
                        "Động từ 'go' cần được chia ở thì quá khứ đơn vì có trạng từ chỉ thời gian 'yesterday'. Dạng quá khứ đơn của 'go' là 'went'.",
                    sentence:
                        "He go to the school yesterday but don't bringed his book",
                  ),
                  const SizedBox(height: 12),
                  _grammarCard(
                    wrong: "don't",
                    correct: "did not",
                    explanation:
                        "Khi phủ định động từ ở thì quá khứ đơn, ta dùng 'did not' + động từ nguyên mẫu.",
                    sentence:
                        "yesterday but don't bringed his book",
                  ),
                  const SizedBox(height: 12),
                  _grammarCard(
                    wrong: "bringed",
                    correct: "bring",
                    explanation:
                        "Sau 'did not', động từ chính phải ở dạng nguyên mẫu.",
                    sentence:
                        "but don't bringed his book",
                  ),
                  const SizedBox(height: 12),
                  _punctuationCard(),
                  const SizedBox(height: 80),
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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("10:47",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, size: 16),
              SizedBox(width: 4),
              Icon(Icons.wifi, size: 16),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 16),
            ],
          )
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const Text(
            "Grammar Checker",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.image_search, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  // ================= ORIGINAL TEXT =================
  Widget _originalText() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "ORIGINAL TEXT",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textSub,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "He go to the school yesterday but don't bringed his book",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SCORE =================
  Widget _scoreCard() {
    return _card(
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: _CircleScorePainter(score: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("40",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  Text("/ 100",
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Your Score",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Significant improvements needed.",
            style: TextStyle(color: textSub),
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summary() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Summary of Suggestions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Text(text,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ================= CORRECTED =================
  Widget _corrected() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F6EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.green,
                    child:
                        Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Corrected Version",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
              Icon(Icons.copy, color: Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "He went to the school yesterday but did not bring his book.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          )
        ],
      ),
    );
  }

  // ================= GRAMMAR CARD =================
  Widget _grammarCard({
    required String wrong,
    required String correct,
    required String explanation,
    required String sentence,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tt Grammar",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple)),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 18, color: textMain),
              children: [
                TextSpan(
                    text: sentence.replaceAll(wrong, ""),
                    style: const TextStyle()),
                TextSpan(
                  text: wrong,
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.purple,
                  ),
                ),
                TextSpan(
                  text: " $correct",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(explanation,
              style: const TextStyle(color: textSub, height: 1.5)),
        ],
      ),
    );
  }

  // ================= PUNCTUATION =================
  Widget _punctuationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Punctuation",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),
          SizedBox(height: 8),
          Text(
            "his book.",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),
          SizedBox(height: 8),
          Text(
            "Câu trần thuật cần kết thúc bằng dấu chấm (.).",
            style: TextStyle(color: textSub),
          ),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  // ================= BOTTOM NAV =================
  Widget _bottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 4,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: "Vocab"),
        BottomNavigationBarItem(
            icon: Icon(Icons.check_circle), label: "Grammar"),
        BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center), label: "Practice"),
        BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), label: "Progress"),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), label: "Profile"),
      ],
    );
  }
}

// ================= CIRCLE SCORE =================
class _CircleScorePainter extends CustomPainter {
  final int score;
  _CircleScorePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - stroke;

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;

    final fgPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweep = 2 * pi * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
