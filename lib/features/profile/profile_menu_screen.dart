import 'dart:io';
import 'dart:ui';

import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/features/achievements/achievements_screen.dart';
import 'package:Zentry/features/profile/edit_profile_screen.dart';
import 'package:Zentry/features/profile/personalize_profile_screen.dart';
import 'package:Zentry/features/profile/qr_code_screen.dart';
import 'package:Zentry/features/profile/profile_stats_screen.dart';
import 'package:Zentry/features/challenges/challenges_screen.dart';
import 'package:Zentry/features/store/store_screen.dart';
import 'package:Zentry/features/likes/likes_screen.dart';
import 'package:Zentry/features/saved/saved_screen.dart';
import 'package:Zentry/features/settings/language_screen.dart';
import 'package:Zentry/features/settings/notifications_screen.dart';
import 'package:Zentry/features/settings/privacy_screen.dart';
import 'package:Zentry/features/settings/security_screen.dart';
import 'package:Zentry/features/settings/settings_screen.dart';
import 'package:Zentry/features/subscription/subscription_screen.dart';
import 'package:Zentry/features/support/support_screen.dart';
import 'package:Zentry/features/communities/communities_screen.dart';
import 'package:Zentry/features/events/events_screen.dart';
import 'package:Zentry/features/friends/friends_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, .15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EngagementController>().registerProfileVisit();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void goSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void goLikes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LikesScreen()),
    );
  }

  void goSaved() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedScreen()),
    );
  }

  void goSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  void goAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
    );
  }

  void goQrCode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrCodeScreen()),
    );
  }

  void goStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileStatsScreen()),
    );
  }

  void goChallenges() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChallengesScreen()),
    );
  }

  void goStore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StoreScreen()),
    );
  }

  Future<void> showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xff171725),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.profileMenuLogout,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            l10n.profileMenuLogoutConfirmMessage,
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
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthController>().logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(l10n.profileMenuLogoutConfirmAction),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = context.watch<ThemeController>().accentColor;
    final currentUser = context.watch<AuthController>().currentUser;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff161625), Color(0xff09090F)],
              ),
            ),
          ),

          Positioned(
            top: -80,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -90,
            bottom: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                      child: Row(
                        children: [
                          Text(
                            l10n.profileMenuHeaderTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.06),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Hero(
                              tag: "profile_avatar",
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: accentColor,
                                backgroundImage: currentUser?.photoPath != null
                                    ? FileImage(File(currentUser!.photoPath!))
                                    : null,
                                child: currentUser?.photoPath == null
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 34,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentUser?.displayName ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "@${currentUser?.username ?? ''}",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Text(
                                      "Premium Creator",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: goQrCode,
                              icon: const Icon(
                                Icons.qr_code_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 30,
                        ),
                        children: [
                          sectionTitle(l10n.profileMenuSectionAccount),
                          menuCard(
                            icon: Icons.edit_outlined,
                            title: l10n.profileMenuEditProfileItem,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                          menuCard(
                            icon: Icons.photo_camera_outlined,
                            title: l10n.profileMenuChangePhotoItem,
                            onTap: () {},
                          ),
                          menuCard(
                            icon: Icons.auto_awesome,
                            title: l10n.profileMenuPersonalizeItem,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PersonalizeProfileScreen(),
                                ),
                              );
                            },
                          ),
                          menuCard(
                            icon: Icons.public,
                            title: l10n.profileMenuViewPublicProfileItem,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileMenuScreen(),
                                ),
                              );
                            },
                          ),
                          menuCard(
                            icon: Icons.qr_code_2,
                            title: l10n.profileMenuQrCodeItem,
                            onTap: goQrCode,
                          ),

                          sectionTitle(l10n.profileMenuSectionActivity),
                          menuCard(
                            icon: Icons.favorite_border,
                            title: l10n.profileMenuLikesItem,
                            onTap: goLikes,
                            color: Colors.redAccent,
                          ),
                          menuCard(
                            icon: Icons.bookmark_border,
                            title: l10n.profileMenuSavedItem,
                            onTap: goSaved,
                            color: Colors.amber,
                          ),
                          menuCard(
                            icon: Icons.history,
                            title: l10n.profileMenuHistoryItem,
                            onTap: () {},
                          ),

                          sectionTitle(l10n.profileMenuSectionSocial),
                          menuCard(
                            icon: Icons.people_alt_outlined,
                            title: l10n.profileMenuFriendsItem,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FriendsScreen(),
                                ),
                              );
                            },
                          ),
                          menuCard(
                            icon: Icons.groups_outlined,
                            title: l10n.communitiesScreenTitle,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CommunitiesScreen(),
                                ),
                              );
                            },
                          ),
                          menuCard(
                            icon: Icons.event_outlined,
                            title: l10n.eventsScreenTitle,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EventsScreen(),
                                ),
                              );
                            },
                          ),

                          sectionTitle(l10n.profileMenuSectionZentry),
                          menuCard(
                            icon: Icons.workspace_premium_outlined,
                            title: l10n.profileMenuSubscriptionItem,
                            onTap: goSubscription,
                            color: Colors.amberAccent,
                          ),
                          menuCard(
                            icon: Icons.emoji_events_outlined,
                            title: l10n.collabActiveNavAchievements,
                            onTap: goAchievements,
                            color: Colors.orangeAccent,
                          ),
                          menuCard(
                            icon: Icons.flag_outlined,
                            title: l10n.profileMenuChallengesItem,
                            onTap: goChallenges,
                            color: Colors.blueAccent,
                          ),
                          menuCard(
                            icon: Icons.military_tech_outlined,
                            title: l10n.profileMenuBadgesItem,
                            onTap: () {},
                            color: Colors.cyanAccent,
                          ),
                          menuCard(
                            icon: Icons.monetization_on_outlined,
                            title: l10n.profileMenuZCoinsItem(
                              context.watch<EngagementController>().zCoins,
                            ),
                            onTap: goStore,
                            color: Colors.yellowAccent,
                          ),
                          menuCard(
                            icon: Icons.bar_chart_outlined,
                            title: l10n.profileMenuStatsItem,
                            onTap: goStats,
                          ),
                          menuCard(
                            icon: Icons.collections_bookmark_outlined,
                            title: l10n.profileMenuPortfolioItem,
                            onTap: () {},
                          ),

                          sectionTitle(l10n.profileMenuSectionSettings),
                          menuCard(
                            icon: Icons.palette_outlined,
                            title: l10n.profileMenuThemeItem,
                            onTap: goSettings,
                          ),
                          menuCard(
                            icon: Icons.language,
                            title: l10n.profileMenuLanguageItem,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LanguageScreen(),
                                ),
                              );
                            },
                          ),
                          menuCard(
                            icon: Icons.notifications_none_outlined,
                            title: l10n.profileMenuNotificationsItem,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              );
                            },
                          ),
                          menuCard(
                            icon: Icons.lock_outline,
                            title: l10n.profileMenuPrivacyItem,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyScreen(),
                                ),
                              );
                            },
                          ),
                          menuCard(
                            icon: Icons.security_outlined,
                            title: l10n.profileMenuSecurityItem,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SecurityScreen(),
                                ),
                              );
                            },
                          ),

                          sectionTitle(l10n.profileMenuSectionHelp),
                          menuCard(
                            icon: Icons.help_outline,
                            title: l10n.profileMenuHelpCenterItem,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SupportScreen(),
                                ),
                              );
                            },
                          ),
                          menuCard(
                            icon: Icons.report_problem_outlined,
                            title: l10n.profileMenuReportProblemItem,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SupportScreen(),
                                ),
                              );
                            },
                          ),
                          menuCard(
                            icon: Icons.info_outline,
                            title: l10n.profileMenuAboutItem,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SupportScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 25),

                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xffE53935), Color(0xffC62828)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: showLogoutDialog,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.logout_rounded,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.profileMenuLogout,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          Center(
                            child: Column(
                              children: [
                                Text(
                                  "Zentry Community",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Version 1.0.0",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget menuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(.05)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Divider(color: Colors.white.withOpacity(.05), height: 1),
    );
  }
}
