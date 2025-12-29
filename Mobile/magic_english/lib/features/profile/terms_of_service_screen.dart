import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Terms of Service',
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
                    Icons.gavel_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Terms of Service',
                    style: GoogleFonts.lexend(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Effective: December 2024',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Terms Content
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing or using Magic English, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our application.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              '2. Description of Service',
              'Magic English provides an English language learning platform with features including vocabulary lessons, grammar exercises, pronunciation practice, and AI-powered learning assistance.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              '3. User Accounts',
              '''• You must provide accurate and complete information when creating an account.
• You are responsible for maintaining the confidentiality of your account credentials.
• You must notify us immediately of any unauthorized access to your account.
• One person may not maintain more than one account.''',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              '4. User Conduct',
              '''You agree not to:
• Use the service for any unlawful purpose
• Attempt to gain unauthorized access to our systems
• Upload malicious content or viruses
• Harass, abuse, or harm other users
• Copy, modify, or distribute our content without permission
• Use automated systems to access the service''',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              '5. Intellectual Property',
              'All content, features, and functionality of Magic English, including but not limited to text, graphics, logos, icons, audio, video, and software, are the exclusive property of Magic English and are protected by copyright and other intellectual property laws.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              '6. Subscription and Payments',
              '''• Some features may require a subscription or payment.
• Prices are subject to change with notice.
• Subscriptions auto-renew unless cancelled before the renewal date.
• Refunds are processed according to our refund policy.''',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              '7. Disclaimer of Warranties',
              'The service is provided "as is" without warranties of any kind. We do not guarantee that the service will be uninterrupted, secure, or error-free.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              '8. Limitation of Liability',
              'To the maximum extent permitted by law, Magic English shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the service.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              '9. Termination',
              'We may terminate or suspend your account at any time for violations of these terms. Upon termination, your right to use the service will immediately cease.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              '10. Changes to Terms',
              'We reserve the right to modify these terms at any time. We will notify users of significant changes. Continued use of the service after changes constitutes acceptance of the modified terms.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              '11. Governing Law',
              'These terms shall be governed by and construed in accordance with the laws of Vietnam, without regard to conflict of law principles.',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            _buildSection(
              '12. Contact Information',
              'For questions about these Terms of Service, please contact us at:\n\nEmail: legal@magicenglish.com\nAddress: 123 Education Street, Ho Chi Minh City, Vietnam',
              cardColor,
              textColor,
              bodyTextColor,
            ),
            const SizedBox(height: 20),

            // Agreement Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using Magic English, you acknowledge that you have read and understood these Terms of Service.',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        color: bodyTextColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
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
