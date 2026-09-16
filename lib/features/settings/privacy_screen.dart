import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  final ScrollController scrollController = ScrollController();

  bool privateAccount = false;

  bool onlineStatus = true;

  bool lastSeen = true;

  bool searchable = true;

  bool twoFactor = false;

  String profileVisibility = "Público";

  String messagesFrom = "Todos";

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 700),
    );

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();

    scrollController.dispose();

    super.dispose();
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,

        title: Text(
          l10n.privacyScreenTitle,

          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.security)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,

        child: ListView(
          controller: scrollController,

          padding: const EdgeInsets.all(18),

          children: [
            FadeTransition(
              opacity: animationController,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    l10n.privacyHeading,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 28,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.privacySubtitle,

                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.lock,

                          accentColor,

                          "100%",

                          l10n.privacySecurityLabel,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.visibility,

                          Colors.blue,

                          profileVisibility,

                          l10n.privacyProfileLabel,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: const Color(0xff171725),

                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          l10n.privacyProfileLabel,

                          style: const TextStyle(
                            color: Colors.white,

                            fontWeight: FontWeight.bold,

                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 15),

                        DropdownButtonFormField<String>(
                          value: profileVisibility,

                          dropdownColor: const Color(0xff171725),

                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),

                          style: const TextStyle(color: Colors.white),

                          items: [
                            DropdownMenuItem(
                              value: "Público",

                              child: Text(l10n.privacyVisibilityPublic),
                            ),

                            DropdownMenuItem(
                              value: "Solo seguidores",

                              child: Text(l10n.privacyVisibilityFollowersOnly),
                            ),

                            DropdownMenuItem(
                              value: "Privado",

                              child: Text(l10n.privacyVisibilityPrivate),
                            ),
                          ],

                          onChanged: (value) {
                            setState(() {
                              profileVisibility = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        SwitchListTile(
                          value: privateAccount,

                          activeColor: accentColor,

                          onChanged: (value) {
                            setState(() {
                              privateAccount = value;
                            });
                          },

                          title: Text(
                            l10n.privacyPrivateAccountTitle,

                            style: const TextStyle(color: Colors.white),
                          ),

                          subtitle: Text(
                            l10n.privacyPrivateAccountSubtitle,

                            style: const TextStyle(color: Colors.white60),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: const Color(0xff171725),

                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          l10n.collabActiveNavMessages,

                          style: const TextStyle(
                            color: Colors.white,

                            fontWeight: FontWeight.bold,

                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 15),

                        DropdownButtonFormField<String>(
                          value: messagesFrom,

                          dropdownColor: const Color(0xff171725),

                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),

                          style: const TextStyle(color: Colors.white),

                          items: [
                            DropdownMenuItem(
                              value: "Todos",

                              child: Text(l10n.eventsFilterAll),
                            ),

                            DropdownMenuItem(
                              value: "Seguidores",

                              child: Text(l10n.privacyMessagesFromFollowers),
                            ),

                            DropdownMenuItem(
                              value: "Nadie",

                              child: Text(l10n.privacyMessagesFromNone),
                            ),
                          ],

                          onChanged: (value) {
                            setState(() {
                              messagesFrom = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: const Color(0xff171725),

                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          l10n.privacyActivityCardTitle,

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 18,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        SwitchListTile(
                          value: onlineStatus,

                          activeColor: Colors.green,

                          onChanged: (value) {
                            setState(() {
                              onlineStatus = value;
                            });
                          },

                          title: Text(
                            l10n.privacyShowOnlineStatusTitle,

                            style: const TextStyle(color: Colors.white),
                          ),

                          subtitle: Text(
                            l10n.privacyShowOnlineStatusSubtitle,

                            style: const TextStyle(color: Colors.white60),
                          ),
                        ),

                        SwitchListTile(
                          value: lastSeen,

                          activeColor: Colors.blue,

                          onChanged: (value) {
                            setState(() {
                              lastSeen = value;
                            });
                          },

                          title: Text(
                            l10n.privacyShowLastSeenTitle,

                            style: const TextStyle(color: Colors.white),
                          ),

                          subtitle: Text(
                            l10n.privacyShowLastSeenSubtitle,

                            style: const TextStyle(color: Colors.white60),
                          ),
                        ),

                        SwitchListTile(
                          value: searchable,

                          activeColor: Colors.orange,

                          onChanged: (value) {
                            setState(() {
                              searchable = value;
                            });
                          },

                          title: Text(
                            l10n.privacyShowInSearchTitle,

                            style: const TextStyle(color: Colors.white),
                          ),

                          subtitle: Text(
                            l10n.privacyShowInSearchSubtitle,

                            style: const TextStyle(color: Colors.white60),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: const Color(0xff171725),

                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          l10n.privacySecurityLabel,

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 18,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        SwitchListTile(
                          value: twoFactor,

                          activeColor: Colors.red,

                          onChanged: (value) {
                            setState(() {
                              twoFactor = value;
                            });
                          },

                          title: Text(
                            l10n.privacyTwoFactorTitle,

                            style: const TextStyle(color: Colors.white),
                          ),

                          subtitle: Text(
                            l10n.privacyTwoFactorSubtitle,

                            style: const TextStyle(color: Colors.white60),
                          ),
                        ),

                        const Divider(),

                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0x22F44336),

                            child: Icon(Icons.block, color: Colors.red),
                          ),

                          title: Text(
                            l10n.privacyBlockedUsersTitle,

                            style: const TextStyle(
                              color: Colors.white,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            l10n.privacyUsersCount(12),

                            style: const TextStyle(color: Colors.white60),
                          ),

                          trailing: const Icon(
                            Icons.chevron_right,

                            color: Colors.white54,
                          ),

                          onTap: () {},
                        ),

                        const Divider(),

                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0x22FF9800),

                            child: Icon(Icons.volume_off, color: Colors.orange),
                          ),

                          title: Text(
                            l10n.privacyMutedUsersTitle,

                            style: const TextStyle(
                              color: Colors.white,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            l10n.privacyUsersCount(4),

                            style: const TextStyle(color: Colors.white60),
                          ),

                          trailing: const Icon(
                            Icons.chevron_right,

                            color: Colors.white54,
                          ),

                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,

        elevation: 8,

        onPressed: () {
          scrollController.animateTo(
            0,

            duration: const Duration(milliseconds: 500),

            curve: Curves.easeOut,
          );
        },

        child: const Icon(Icons.keyboard_arrow_up),
      ),
    );
  }

  Widget _statCard(IconData icon, Color color, String value, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),

      decoration: BoxDecoration(
        color: const Color(0xff171725),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 10),

          Text(
            value,

            style: const TextStyle(
              color: Colors.white,

              fontWeight: FontWeight.bold,

              fontSize: 18,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,

            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _resetButton(AppLocalizations l10n) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.red,

        minimumSize: const Size(double.infinity, 52),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      onPressed: () {
        setState(() {
          privateAccount = false;

          onlineStatus = true;

          lastSeen = true;

          searchable = true;

          twoFactor = false;

          profileVisibility = "Público";

          messagesFrom = "Todos";
        });
      },

      icon: const Icon(Icons.restart_alt),

      label: Text(l10n.privacyResetSettingsButton),
    );
  }
}
