import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/features/profile/profile_screen.dart';
import 'package:Zentry/features/explore/explore_screen.dart';
import 'package:Zentry/features/chat/chat_screen.dart';
import 'package:Zentry/features/home/home_screen.dart';
import 'package:Zentry/features/create/create_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  bool showNavbar = true;

  final List<Widget> _screens = [
    const HomeScreen(),

    const ExploreScreen(),

    const CreateScreen(),

    const ChatScreen(),

    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final bool hideOnChat = currentIndex == 3;

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        setState(() {
          currentIndex = 0;
        });
      },
      child: Scaffold(
        extendBody: true,

        body: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (hideOnChat) {
              return true;
            }

            if (notification.direction == ScrollDirection.reverse) {
              if (showNavbar) {
                setState(() {
                  showNavbar = false;
                });
              }
            }

            if (notification.direction == ScrollDirection.forward) {
              if (!showNavbar) {
                setState(() {
                  showNavbar = true;
                });
              }
            }

            return true;
          },

          child: _screens[currentIndex],
        ),

        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 280),

          curve: Curves.easeInOut,

          height: hideOnChat
              ? 0
              : showNavbar
              ? 78
              : 0,

          child: Wrap(
            children: [
              NavigationBar(
                selectedIndex: currentIndex,

                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

                onDestinationSelected: (i) {
                  if (i == 4 && currentIndex != 4) {
                    context.read<EngagementController>().registerProfileVisit();
                  }

                  setState(() {
                    currentIndex = i;
                  });
                },

                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),

                    selectedIcon: const Icon(Icons.home),

                    label: l10n.homePageNavFeedLabel,
                  ),

                  NavigationDestination(
                    icon: const Icon(Icons.explore_outlined),

                    selectedIcon: const Icon(Icons.explore),

                    label: l10n.communitiesExploreButton,
                  ),

                  NavigationDestination(
                    icon: const Icon(Icons.add_box_outlined),

                    selectedIcon: const Icon(Icons.add_box),

                    label: l10n.createScreenTitle,
                  ),

                  NavigationDestination(
                    icon: const Icon(Icons.chat_bubble_outline),

                    selectedIcon: const Icon(Icons.chat_bubble),

                    label: l10n.homePageNavChatLabel,
                  ),

                  NavigationDestination(
                    icon: const Icon(Icons.person_outline),

                    selectedIcon: const Icon(Icons.person),

                    label: l10n.homePageNavProfileLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
