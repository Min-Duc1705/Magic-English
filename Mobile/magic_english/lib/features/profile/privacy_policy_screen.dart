import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Color get primary => const Color(0xFF4A90E2);
  Color get background => const Color(0xFFF4F6F9);
  Color get cardColor => Colors.white;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF4F6F9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final bodyTextColor = isDark ? Colors.grey[300] : Colors.grey[700];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your Privacy Matters',
                    style: GoogleFonts.lexend(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: December 2024',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Policy Content
            _buildSection(
              'Introduction',
              'Magic English ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              'Information We Collect',
              '''We may collect information about you in various ways:

• Personal Data: Name, email address, phone number, and profile information you provide during registration.

• Usage Data: Information about how you use the app, including learning progress, time spent, and features accessed.

• Device Information: Device type, operating system, unique device identifiers, and mobile network information.

• Location Data: With your consent, we may collect location data to provide location-based features.''',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              'How We Use Your Information',
              '''We use the collected information to:

• Provide and maintain our services
• Personalize your learning experience
• Send you notifications and updates
• Analyze usage patterns to improve our app
• Respond to your requests and support inquiries
• Comply with legal obligations''',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              'Data Security',
              'We implement appropriate technical and organizational security measures to protect your personal information. However, no method of transmission over the Internet is 100% secure, and we cannot guarantee absolute security.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              'Third-Party Services',
              'Our app may contain links to third-party websites or services. We are not responsible for the privacy practices of these external sites. We encourage you to review their privacy policies.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              'Children\'s Privacy',
              'Our service is not directed to children under 13. We do not knowingly collect personal information from children under 13. If you become aware that a child has provided us with personal data, please contact us.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              'Your Rights',
              '''You have the right to:

• Access your personal data
• Correct inaccurate data
• Request deletion of your data
• Object to processing of your data
• Data portability
• Withdraw consent at any time''',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              'Contact Us',
              'If you have questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@magicenglish.com\nPhone: +84 123 456 789',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content,
    Color cardColor,
    Color textColor,
    Color? bodyTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: bodyTextColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
