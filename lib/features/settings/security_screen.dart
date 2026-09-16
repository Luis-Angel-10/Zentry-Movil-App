import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  final ScrollController _scrollController = ScrollController();

  bool twoFactor = false;
  bool passkeys = false;
  bool loginAlerts = true;
  bool securityEmails = true;

  final List<Map<String, dynamic>> devices = [
    {
      "name": "Galaxy S24 Ultra",
      "location": "Puebla, México",
      "current": true,
      "icon": Icons.smartphone,
    },
    {
      "name": "Huawei MateBook D16",
      "location": "Puebla, México",
      "current": false,
      "icon": Icons.laptop,
    },
    {
      "name": "Chrome - Windows",
      "location": "Ciudad de México",
      "current": false,
      "icon": Icons.computer,
    },
  ];

  final List<Map<String, dynamic>> activity = [
    {
      "title": "Inicio de sesión",
      "date": "Hoy · 10:42",
      "icon": Icons.login,
      "color": Colors.green,
    },
    {
      "title": "Cambio de contraseña",
      "date": "Hace 3 días",
      "icon": Icons.lock_reset,
      "color": Colors.orange,
    },
    {
      "title": "Nuevo dispositivo",
      "date": "Hace 1 semana",
      "icon": Icons.devices,
      "color": Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
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
          l10n.securityScreenTitle,

          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.shield_outlined)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,

        child: FadeTransition(
          opacity: _animationController,

          child: ListView(
            controller: _scrollController,

            padding: const EdgeInsets.all(18),

            children: [
              Text(
                l10n.securityHeading,

                style: const TextStyle(
                  color: Colors.white,

                  fontSize: 28,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                l10n.securitySubtitle,

                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      Icons.shield,

                      Colors.blue,

                      l10n.securityLevelHighValue,

                      l10n.securitySecurityLabel,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      Icons.devices,

                      Colors.green,

                      devices.length.toString(),

                      l10n.securityDevicesStatLabel,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      Icons.history,

                      Colors.orange,

                      activity.length.toString(),

                      l10n.securityActivityStatLabel,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      Icons.lock,

                      accentColor,

                      twoFactor
                          ? l10n.securityStatusActive
                          : l10n.securityStatusInactive,

                      l10n.securityTwoFaStatLabel,
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
                      l10n.securityAuthenticationCardTitle,

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: const CircleAvatar(
                        backgroundColor: Color(0x332196F3),

                        child: Icon(Icons.password, color: Colors.blue),
                      ),

                      title: Text(
                        l10n.securityChangePasswordTitle,

                        style: const TextStyle(color: Colors.white),
                      ),

                      subtitle: Text(
                        l10n.securityChangePasswordSubtitle,

                        style: const TextStyle(color: Colors.white60),
                      ),

                      trailing: const Icon(
                        Icons.chevron_right,

                        color: Colors.white54,
                      ),

                      onTap: () {},
                    ),

                    const Divider(),

                    SwitchListTile(
                      value: twoFactor,

                      activeColor: accentColor,

                      onChanged: (value) {
                        setState(() {
                          twoFactor = value;
                        });
                      },

                      title: Text(
                        l10n.securityTwoFactorTitle,

                        style: const TextStyle(color: Colors.white),
                      ),

                      subtitle: Text(
                        l10n.securityTwoFactorSubtitle,

                        style: const TextStyle(color: Colors.white60),
                      ),
                    ),

                    SwitchListTile(
                      value: passkeys,

                      activeColor: Colors.green,

                      onChanged: (value) {
                        setState(() {
                          passkeys = value;
                        });
                      },

                      title: Text(
                        l10n.securityPasskeysTitle,

                        style: const TextStyle(color: Colors.white),
                      ),

                      subtitle: Text(
                        l10n.securityPasskeysSubtitle,

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
                      l10n.securityTrustedDevicesCardTitle,

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),
                    ...devices.map((device) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,

                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(.15),

                          child: Icon(device["icon"], color: Colors.green),
                        ),

                        title: Text(
                          device["name"],

                          style: const TextStyle(
                            color: Colors.white,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          device["location"],

                          style: const TextStyle(color: Colors.white60),
                        ),

                        trailing: device["current"]
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,

                                  vertical: 5,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.green,

                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Text(
                                  l10n.securityCurrentDeviceBadge,

                                  style: const TextStyle(
                                    color: Colors.white,

                                    fontSize: 11,
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: () {},

                                icon: const Icon(
                                  Icons.logout,

                                  color: Colors.red,
                                ),
                              ),
                      );
                    }).toList(),
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
                      l10n.securityRecentActivityCardTitle,

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ...activity.map((item) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,

                        leading: CircleAvatar(
                          backgroundColor: (item["color"] as Color).withOpacity(
                            .15,
                          ),

                          child: Icon(item["icon"], color: item["color"]),
                        ),

                        title: Text(
                          item["title"],

                          style: const TextStyle(
                            color: Colors.white,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          item["date"],

                          style: const TextStyle(color: Colors.white60),
                        ),
                      );
                    }).toList(),
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
                      l10n.securityAlertsCardTitle,

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    SwitchListTile(
                      value: loginAlerts,

                      activeColor: Colors.red,

                      onChanged: (value) {
                        setState(() {
                          loginAlerts = value;
                        });
                      },

                      title: Text(
                        l10n.securityLoginAlertsTitle,

                        style: const TextStyle(color: Colors.white),
                      ),

                      subtitle: Text(
                        l10n.securityLoginAlertsSubtitle,

                        style: const TextStyle(color: Colors.white60),
                      ),
                    ),

                    SwitchListTile(
                      value: securityEmails,

                      activeColor: Colors.blue,

                      onChanged: (value) {
                        setState(() {
                          securityEmails = value;
                        });
                      },

                      title: Text(
                        l10n.securitySecurityEmailsTitle,

                        style: const TextStyle(color: Colors.white),
                      ),

                      subtitle: Text(
                        l10n.securitySecurityEmailsSubtitle,

                        style: const TextStyle(color: Colors.white60),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _logoutAllDevicesButton(l10n),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,

        elevation: 8,

        onPressed: () {
          _scrollController.animateTo(
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

  Widget _logoutAllDevicesButton(AppLocalizations l10n) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.red,

        minimumSize: const Size(double.infinity, 52),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      onPressed: () {
        showDialog(
          context: context,

          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xff171725),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: Text(
                l10n.securityLogoutDialogTitle,

                style: const TextStyle(color: Colors.white),
              ),

              content: Text(
                l10n.securityLogoutDialogContent,

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
                  },

                  child: Text(l10n.commonClose),
                ),
              ],
            );
          },
        );
      },

      icon: const Icon(Icons.logout),

      label: Text(l10n.securityLogoutAllButton),
    );
  }
}
