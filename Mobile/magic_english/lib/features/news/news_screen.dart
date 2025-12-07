import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  static const primary = Color(0xFF3B82F6);
  static const bgLight = Color(0xFFF3F4F6);
  static const surface = Colors.white;
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
                _appBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Column(
                      children: [
                        _segment(),
                        _search(),
                        _category(),
                        _newsList(),
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

  // ================= STATUS =================
  Widget _statusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "1:09",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 14),
              SizedBox(width: 4),
              Icon(Icons.wifi, size: 14),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  // ================= APP BAR =================
  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () {},
          ),
          const Expanded(
            child: Text(
              "My Vocabulary",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
    );
  }

  // ================= SEGMENT =================
  Widget _segment() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "My Vocabulary",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "News",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SEARCH =================
  Widget _search() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search for articles",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= CATEGORY =================
  Widget _category() {
    final items = ["All", "News", "Sports", "Business", "Tech"];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (c, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: i == 0 ? primary : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(14),
            boxShadow: i == 0
                ? [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 8)]
                : [],
          ),
          child: Text(
            items[i],
            style: TextStyle(
              color: i == 0 ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }

  // ================= NEWS LIST =================
  Widget _newsList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          _NewsItem(
            title:
                "Malaysian coach accused of forcing teen sprinter to fake injury...",
            source: "VNExpress - 56 minutes ago",
            image:
                "https://lh3.googleusercontent.com/aida-public/AB6AXuA11slHQm3V1CQlUGvD9PR9-foyI4pnf2EPISy9FZcOyQsl4Fgv6jgNpc8Cc2ag8xGrb5JIFwu8cCLOOn_piDxTDOS0BFpx5689ljMRNGb2cSRSFusJzeR5TKxCK35GkmAmDvnwdH1F92NV4AXRueOkrNIcQn41gZRLJuTa8QEfvSLVXRq29u0ASJPR89M5hX7ys02i4lxotXVnElHN2bgTeh3K8b8X4jHJg42gBy7sVx6gb6R4JPYKHdjxibNeuRaUwvQ_0EC2QlJ9",
          ),
          _NewsItem(
            title: "How I lose my passion with a stable \$24,000 salary",
            source: "VNExpress - 1 hour ago",
            image:
                "https://lh3.googleusercontent.com/aida-public/AB6AXuDo-TbKd7DN1eFUCxA2BiafxtYZP7UCBQVjEhyL-2BtvajJPkv677not1o6SYUQqQaf5p-8ZXyVp2TnREd0P1fbGDjOIEzgO0MiWonso3ftLbJxUkz1Z3ppyVJj3qXmKO5PzXs5-7bEX8thyRFn9DvoAsW7ArP_MkixAqlbT0AiAy6R1DlC0peW_JoFkNoDLV6M3Kl5s4Ndpmu9P5ZZcamu3GRNojPa7CPaOEnFHYPhCs6U0JM6IGkvOwpDnQYqbynaHAIUmNO2U8pM",
          ),
        ],
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
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        decoration: const BoxDecoration(
          color: surface,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _NavItem(Icons.home, "Home"),
            _NavItem(Icons.school, "Vocab", active: true),
            _NavItem(Icons.spellcheck, "Grammar"),
            _NavItem(Icons.fitness_center, "Practice"),
            _NavItem(Icons.bar_chart, "Progress"),
            _NavItem(Icons.account_circle, "Profile"),
          ],
        ),
      ),
    );
  }
}

// ================= NEWS ITEM =================
class _NewsItem extends StatelessWidget {
  final String title;
  final String source;
  final String image;

  const _NewsItem({
    required this.title,
    required this.source,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  source,
                  style: const TextStyle(
                    fontSize: 12,
                    color: NewsScreen.textSub,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Text(
                      "Read more",
                      style: TextStyle(
                        color: NewsScreen.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: NewsScreen.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              image,
              width: 112,
              height: 112,
              fit: BoxFit.cover,
            ),
          ),
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
                width: 48,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: NewsScreen.primary),
              )
            : Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? NewsScreen.primary : Colors.grey,
          ),
        ),
      ],
    );
  }
}
