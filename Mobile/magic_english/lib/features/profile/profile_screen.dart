import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';
import 'package:magic_enlish/core/widgets/common/app_top_bar.dart';
import 'package:magic_enlish/core/widgets/profile/profile_card.dart';
import 'package:magic_enlish/core/widgets/common/section_header.dart';
import 'package:magic_enlish/core/widgets/profile/settings_section.dart';
import 'package:magic_enlish/features/profile/edit_profile_screen.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';
import 'package:provider/provider.dart';
import 'package:magic_enlish/providers/auth/auth_provider.dart';
import 'package:magic_enlish/features/auth/login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Colors
  Color get primary => const Color(0xFF4A90E2);
  Color get primaryLight => const Color(0xFFF3F0FF);
  Color get cardLight => const Color(0xFFFFFFFF);
  Color get background => const Color(0xFFF4F6F9);
  Color get textPrimary => const Color(0xFF34495E);
  Color get textSecondary => const Color(0xFF7F8C8D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Bar (use shared core component)
              Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: const AppTopBar(title: 'Profile'),
              ),

              // Profile Card (reusable)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    final user = auth.user;
                    return ProfileCard(
                      name: user?.name ?? 'Guest',
                      email: user?.email ?? '',
                      avatarUrl: _buildAvatarUrl(user?.avatarUrl),
                      // (user?.avatarUrl != null && user!.avatarUrl != null)
                      // ? dotenv.env['Backend_URL']! +'/storage/avatar/' +user.avatarUrl!: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCwjU4CsVdt2VEZUWSxL3Bn7cWu3vczpiZduN16hF5Tinakk5hqQY0APafoANhjTIWQt38yD1hmxuUZnRzF9SOQHQzDKapvXzD6W1wo4od6FEeyio-wAkRmRhBaf0fZGGNlIioVT-_Ec8SzErktYBEQ6QfN-2yhwqvc-qBhud5N7XXDPCj0Ogu9HpsXXsCXodL5l4BlK5N43TyexljZnqhyv3ZPMqTE1GpUCA6NT1j4XL48cGrdl58TipWQd-WuW-Wi_vhGXLwDg5A',
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Preferences Section
              const SectionHeader(title: "Preferences"),
              SettingsSection(
                items: [
                  _settingsItem(Icons.smart_toy, "AI Model", "Advanced"),
                  _settingsItem(Icons.translate, "Language", "English"),
                ],
              ),

              // General Section
              const SectionHeader(title: "General"),
              SettingsSection(
                items: [
                  _generalItem(
                    Icons.notifications,
                    "Push Notifications",
                    switchValue: true,
                  ),
                  _generalItem(
                    Icons.dark_mode,
                    "Dark Mode",
                    switchValue: false,
                  ),
                ],
              ),

              // About Section
              const SectionHeader(title: "About"),
              SettingsSection(
                items: [
                  _aboutItem(Icons.help_outline, "Help & Support"),
                  _aboutItem(Icons.shield, "Privacy Policy"),
                  _aboutItem(Icons.gavel, "Terms of Service"),
                ],
              ),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardLight,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red, size: 28),
                    title: Text(
                      "Logout",
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                            24,
                            20,
                            24,
                            24,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Warning Icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.logout_rounded,
                                  color: Colors.red.shade400,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Title
                              Text(
                                'Logout',
                                style: GoogleFonts.lexend(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Message
                              Text(
                                'Are you sure you want to logout from your account?',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: GoogleFonts.lexend(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade500,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Logout',
                                        style: GoogleFonts.lexend(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );

                      if (confirmed == true) {
                        await Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: primary, size: 28),
      title: Text(
        title,
        style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.lexend(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: textPrimary, size: 22),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _generalItem(
    IconData icon,
    String title, {
    required bool switchValue,
  }) {
    return ListTile(
      leading: Icon(icon, color: primary, size: 28),
      title: Text(
        title,
        style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: switchValue,
        onChanged: (v) {},
        activeThumbColor: primary,
      ),
    );
  }

  Widget _aboutItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: primary, size: 28),
      title: Text(
        title,
        style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, color: textPrimary, size: 22),
      onTap: () {},
    );
  }

  /// Build avatar URL - returns Cloudinary URL directly or builds backend URL for filenames
  String _buildAvatarUrl(String? avatarUrl) {
    const defaultAvatar =
        'https://ui-avatars.com/api/?name=User&background=4A90E2&color=fff&size=256';

    if (avatarUrl == null || avatarUrl.isEmpty) {
      return defaultAvatar;
    }

    // If already a full URL (Cloudinary or other), use it directly
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return avatarUrl;
    }

    // Otherwise, it's a filename - use BackendUtils to build URL
    return BackendUtils.getFullUrl('/storage/avatar/$avatarUrl');
  }
}
