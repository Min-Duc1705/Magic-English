import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key});

  static const bgLight = Colors.white;
  static const bgDark = Color(0xFF121212);
  static const textSub = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _statusBar(),
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _coverImage(),
                    _content(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
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
          Text(
            "1:09",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 18),
              SizedBox(width: 6),
              Icon(Icons.wifi, size: 18),
              SizedBox(width: 6),
              RotatedBox(
                quarterTurns: 1,
                child: Icon(Icons.battery_full, size: 18),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Article",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ================= IMAGE =================
  Widget _coverImage() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Image.network(
        "https://lh3.googleusercontent.com/aida-public/AB6AXuADlCfyp4kebFIPLKnziNZfdjORHnoX4RygRCtNfOpKkoAoKEVQ3b7JS-u1oMki8p-M08K88kgJ9SjbIXEAEBa6QOPoPzB3CdQCSj8fCSHTbCVBu-UbUZxkh2pl3qg_k9jsSlhQdMZUMNwO0tKIoqAbK-K5WRftX9bvRG9SojYuBJsR21JFlqzTR1SjK87EJVHZUxibNB9DV-Btkccwa36sWMO8A1P2y0gUM7ZBNse_k5Rbemn2qRCA9UzLEBieN8FGJdQPXEiprCbi",
        fit: BoxFit.cover,
      ),
    );
  }

  // ================= CONTENT =================
  Widget _content() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Malaysian coach accused of forcing teen sprinter to fake injury to exit SEA Games",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),

          // META
          Row(
            children: const [
              Text("By ",
                  style: TextStyle(fontSize: 14, color: textSub)),
              Text(
                "VNExpress",
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Text("December 13, 2025",
                  style: TextStyle(fontSize: 12, color: textSub)),
              SizedBox(width: 8),
              Text("|", style: TextStyle(color: Colors.grey)),
              SizedBox(width: 8),
              Text("12:13 pm GMT+7",
                  style: TextStyle(fontSize: 12, color: textSub)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.schedule, size: 14, color: textSub),
              SizedBox(width: 6),
              Text("56 minutes ago",
                  style: TextStyle(fontSize: 12, color: textSub)),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // ARTICLE BODY
          _paragraph(
            "The family of 18-year-old sprinter ",
            bold:
                "Danish Irfan Tamrin",
            end:
                " has lodged a formal complaint with the Malaysia Athletics Federation (MAF), supported by WhatsApp evidence.",
          ),
          _paragraph(
              "They alleged that a national coach forced Danish to withdraw from the 4×100m relay squad, stripping him of a deserved spot and exposing flaws in the national selection process."),
          _paragraph(
              "According to the reports, the coach purportedly instructed the young athlete to feign an injury to facilitate a substitution, raising serious questions about integrity and fair play within the federation. The MAF has stated they will launch an immediate investigation into the matter."),
          _paragraph(
              "This incident has sparked a wider debate about the pressures placed on junior athletes and the transparency of coaching decisions at the highest levels of regional competition."),
        ],
      ),
    );
  }

  // ================= PARAGRAPH =================
  Widget _paragraph(String text,
      {String? bold, String? end}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 17,
            height: 1.6,
            color: Color(0xFF374151),
          ),
          children: [
            TextSpan(text: text),
            if (bold != null)
              TextSpan(
                text: bold,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            if (end != null) TextSpan(text: end),
          ],
        ),
      ),
    );
  }
}
