import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';
import 'appearance_screen.dart';
import 'language_screen.dart';
import 'notifications_screen.dart';
import 'privacy_screen.dart';
import 'security_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool emailNotifications = true;
  bool pushNotifications = true;
  bool privateAccount = false;
  bool darkMode = true;

  String selectedTheme = "Oscuro";
  String selectedLanguage = "Español";

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.commonSettings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _section(l10n.settingsScreenSectionAppearance),

          _card(
            icon: Icons.palette_outlined,
            title: l10n.settingsScreenThemeItem,
            subtitle: selectedTheme,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppearanceScreen()),
              );
            },
          ),

          _card(
            icon: Icons.language,
            title: l10n.settingsScreenLanguageItem,
            subtitle: selectedLanguage,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              );
            },
          ),

          const SizedBox(height: 25),

          _section(l10n.settingsScreenSectionNotifications),

          _card(
            icon: Icons.notifications_outlined,
            title: l10n.settingsScreenNotificationsItem,
            subtitle: l10n.settingsScreenNotificationsSubtitle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),

          const SizedBox(height: 25),

          _card(
            icon: Icons.lock_outline,
            title: l10n.settingsScreenPrivacyItem,
            subtitle: l10n.settingsScreenPrivacySubtitle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            },
          ),

          _switchCard(
            icon: Icons.fingerprint,
            title: l10n.settingsScreenBiometricAuthTitle,
            value: context.watch<AuthController>().biometricEnabled,
            onChanged: (v) async {
              final ok = await context
                  .read<AuthController>()
                  .setBiometricEnabled(v);
              if (!ok && mounted) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.settingsScreenBiometricUnavailable),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
              }
            },
          ),

          _card(
            icon: Icons.security_outlined,
            title: l10n.settingsScreenSecurityItem,
            subtitle: l10n.settingsScreenSecuritySubtitle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecurityScreen()),
              );
            },
          ),

          const SizedBox(height: 25),

          _section(l10n.settingsScreenSectionStorage),

          _card(
            icon: Icons.cleaning_services_outlined,
            title: l10n.settingsScreenClearCacheItem,
            subtitle: l10n.settingsScreenCacheUsedMb(248),
            onTap: () {
              _clearCacheDialog(l10n);
            },
          ),

          _card(
            icon: Icons.storage_outlined,
            title: l10n.settingsScreenManageStorageItem,
            subtitle: l10n.settingsScreenManageStorageSubtitle,
            onTap: () {},
          ),

          const SizedBox(height: 25),

          _section(l10n.settingsScreenSectionInfo),

          _card(
            icon: Icons.info_outline,
            title: l10n.settingsScreenAboutItem,
            subtitle: l10n.settingsScreenVersionLabel("1.0.0"),
            onTap: () {},
          ),

          _card(
            icon: Icons.description_outlined,
            title: l10n.settingsScreenTermsItem,
            subtitle: l10n.settingsScreenConsultLabel,
            onTap: () {},
          ),

          _card(
            icon: Icons.privacy_tip_outlined,
            title: l10n.settingsScreenPrivacyPolicyItem,
            subtitle: l10n.settingsScreenConsultLabel,
            onTap: () {},
          ),

          const SizedBox(height: 35),

          Center(
            child: Column(
              children: [
                Icon(Icons.auto_awesome, color: accentColor, size: 30),

                const SizedBox(height: 12),

                Text(
                  l10n.settingsScreenCommunityBrand,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  l10n.settingsScreenVersionLabel("1.0.0"),
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final accentColor = context.watch<ThemeController>().accentColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xff171725),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 28),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchCard({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final accentColor = context.watch<ThemeController>().accentColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff171725),
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          leading: Icon(icon, color: accentColor),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          trailing: Switch(
            value: value,
            activeColor: accentColor,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  void _themeDialog(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff171725),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),

              Text(
                l10n.settingsScreenSelectThemeDialogTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.white),
                title: Text(
                  l10n.settingsScreenThemeDarkOption,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    selectedTheme = "Oscuro";
                  });
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.light_mode, color: Colors.white),
                title: Text(
                  l10n.settingsScreenThemeLightOption,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    selectedTheme = "Claro";
                  });
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.phone_android, color: Colors.white),
                title: Text(
                  l10n.settingsScreenThemeSystemOption,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    selectedTheme = "Sistema";
                  });
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _languageDialog(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff171725),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),

              Text(
                l10n.settingsScreenLanguageItem,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                title: Text(
                  l10n.languageScreenSpanishNative,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    selectedLanguage = "Español";
                  });
                  Navigator.pop(context);
                },
              ),

              ListTile(
                title: Text(
                  l10n.settingsScreenLanguageEnglishOption,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    selectedLanguage = "English";
                  });
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _clearCacheDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff171725),
        title: Text(
          l10n.settingsScreenClearCacheItem,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.settingsScreenClearCacheDialogContent,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(l10n.commonCancel),
          ),

          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(l10n.commonAccept),
          ),
        ],
      ),
    );
  }
}
