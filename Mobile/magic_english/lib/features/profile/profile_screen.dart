import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';
import 'package:magic_enlish/core/widgets/common/app_top_bar.dart';
import 'package:magic_enlish/core/widgets/profile/profile_card.dart';
import 'package:magic_enlish/core/widgets/common/section_header.dart';
import 'package:magic_enlish/core/widgets/profile/settings_section.dart';
import 'package:magic_enlish/features/profile/edit_profile_screen.dart';
import 'package:magic_enlish/features/profile/help_support_screen.dart';
import 'package:magic_enlish/features/profile/privacy_policy_screen.dart';
import 'package:magic_enlish/features/profile/terms_of_service_screen.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';
import 'package:provider/provider.dart';
import 'package:magic_enlish/providers/auth/auth_provider.dart';
import 'package:magic_enlish/providers/theme/theme_provider.dart';
import 'package:magic_enlish/features/auth/login_screen.dart';
import 'package:magic_enlish/providers/settings/settings_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Colors
  Color get primary => const Color(0xFF4A90E2);
  Color get primaryLight => const Color(0xFFF3F0FF);
  Color get cardLight => const Color(0xFFFFFFFF);
  Color get background => const Color(0xFFF4F6F9);
  Color get textPrimary => const Color(0xFF34495E);
  Color get textSecondary => const Color(0xFF7F8C8D);

  final List<String> _aiModels = [
    "Gemini 1.5 Pro",
    "Gemini 2.5 Flash-Lite",
    "GPT-4o",
    "Claude 3.5 Sonnet",
    "Llama 3",
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : background,
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Bar (use shared core component)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                ),
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
                  _buildAIModelTile(isDark, settingsProvider),
                  _settingsItem(
                    Icons.translate,
                    "Language",
                    "English",
                    isDark,
                    () {},
                  ),
                ],
              ),

              // General Section
              const SectionHeader(title: "General"),
              SettingsSection(
                items: [
                  _buildNotificationTile(isDark, settingsProvider),
                  _darkModeItem(context, isDark),
                ],
              ),

              // About Section
              const SectionHeader(title: "About"),
              SettingsSection(
                items: [
                  _aboutItem(
                    context,
                    Icons.help_outline,
                    "Help & Support",
                    isDark,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  _aboutItem(
                    context,
                    Icons.shield,
                    "Privacy Policy",
                    isDark,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  _aboutItem(
                    context,
                    Icons.gavel,
                    "Terms of Service",
                    isDark,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen(),
                        ),
                      );
                    },
                  ),
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
                    color: isDark ? const Color(0xFF1E1E1E) : cardLight,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(.2)
                            : Colors.black.withOpacity(.05),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 28,
                    ),
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

                      if (confirmed == true && mounted) {
                        await Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).logout();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        }
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

  Widget _buildAIModelTile(bool isDark, SettingsProvider provider) {
    final titleColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : textSecondary;

    return ListTile(
      leading: Icon(Icons.smart_toy, color: primary, size: 28),
      title: Text(
        "AI Model",
        style: GoogleFonts.lexend(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      trailing: DropdownButton<String>(
        value: _aiModels.contains(provider.aiModel)
            ? provider.aiModel
            : _aiModels.first,
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDark ? Colors.grey.shade400 : textPrimary,
        ),
        elevation: 16,
        style: GoogleFonts.lexend(fontSize: 13, color: subtitleColor),
        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        underline: Container(height: 0, color: Colors.transparent),
        onChanged: (String? newValue) {
          if (newValue != null) {
            provider.setAIModel(newValue);
          }
        },
        items: _aiModels.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: GoogleFonts.lexend(
                color: isDark ? Colors.white : textPrimary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationTile(bool isDark, SettingsProvider provider) {
    final titleColor = isDark ? Colors.white : const Color(0xFF333333);

    return ListTile(
      leading: Icon(Icons.notifications, color: primary, size: 28),
      title: Text(
        "Push Notifications",
        style: GoogleFonts.lexend(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      trailing: Switch(
        value: provider.pushNotificationsEnabled,
        onChanged: (bool value) {
          provider.setPushNotifications(value);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value
                    ? "Push notifications enabled"
                    : "Push notifications disabled",
                style: GoogleFonts.lexend(),
              ),
              backgroundColor: value ? Colors.green : Colors.grey,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        activeThumbColor: primary,
      ),
    );
  }

  Widget _settingsItem(
    IconData icon,
    String title,
    String value,
    bool isDark,
    VoidCallback onTap,
  ) {
    final titleColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : textSecondary;
    final arrowColor = isDark ? Colors.grey.shade400 : textPrimary;

    return ListTile(
      leading: Icon(icon, color: primary, size: 28),
      title: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.lexend(fontSize: 13, color: subtitleColor),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: arrowColor, size: 22),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _darkModeItem(BuildContext context, bool isDark) {
    final titleColor = isDark ? Colors.white : const Color(0xFF333333);

    return ListTile(
      leading: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: primary,
        size: 28,
      ),
      title: Text(
        "Dark Mode",
        style: GoogleFonts.lexend(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      trailing: Switch(
        value: isDark,
        onChanged: (v) {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        },
        activeThumbColor: primary,
        activeColor: primary.withOpacity(0.5),
      ),
    );
  }

  Widget _aboutItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isDark,
    VoidCallback onTap,
  ) {
    final titleColor = isDark ? Colors.white : const Color(0xFF333333);
    final arrowColor = isDark ? Colors.grey.shade400 : textPrimary;

    return ListTile(
      leading: Icon(icon, color: primary, size: 28),
      title: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: arrowColor, size: 22),
      onTap: onTap,
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
    if (avatarUrl.startsWith('https://')) {
      return avatarUrl;
    }

    // Otherwise, it's a filename - use BackendUtils to build URL
    return BackendUtils.getFullUrl('/storage/avatar/$avatarUrl');
  }
}
