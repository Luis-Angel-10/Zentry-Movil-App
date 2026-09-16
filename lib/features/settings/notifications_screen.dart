import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  final ScrollController scrollController = ScrollController();

  final TextEditingController searchController = TextEditingController();

  bool searching = false;

  int selectedFilter = 0;

  final List<String> filters = [
    "Todas",

    "Likes",

    "Comentarios",

    "Seguidores",

    "Mensajes",

    "Sistema",
  ];

  final List<Map<String, dynamic>> notifications = [
    {
      "user": "Jennifer",

      "message": "Le gustó tu publicación.",

      "time": "Hace 5 min",

      "type": "Likes",

      "icon": Icons.favorite,

      "color": Colors.red,

      "avatar": "assets/login.png",

      "read": false,
    },

    {
      "user": "Daniel",

      "message": "Comentó tu historia.",

      "time": "Hace 20 min",

      "type": "Comentarios",

      "icon": Icons.chat_bubble,

      "color": Colors.blue,

      "avatar": "assets/inicio.png",

      "read": false,
    },

    {
      "user": "Andrea",

      "message": "Comenzó a seguirte.",

      "time": "Hace 1 h",

      "type": "Seguidores",

      "icon": Icons.person_add,

      "color": Colors.green,

      "avatar": "assets/login.png",

      "read": true,
    },

    {
      "user": "Sistema",

      "message": "Has obtenido una nueva insignia.",

      "time": "Ayer",

      "type": "Sistema",

      "icon": Icons.emoji_events,

      "color": Colors.amber,

      "avatar": "assets/inicio.png",

      "read": false,
    },

    {
      "user": "Eventos",

      "message": "Nuevo evento disponible.",

      "time": "Ayer",

      "type": "Sistema",

      "icon": Icons.event,

      "color": null,

      "avatar": "assets/login.png",

      "read": true,
    },
  ];

  late List<Map<String, dynamic>> filteredNotifications;

  @override
  void initState() {
    super.initState();

    filteredNotifications = List.from(notifications);

    animationController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 700),
    );

    animationController.forward();

    searchController.addListener(filterNotifications);
  }

  @override
  void dispose() {
    animationController.dispose();

    scrollController.dispose();

    searchController.dispose();

    super.dispose();
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));

    filterNotifications();
  }

  void filterNotifications() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredNotifications = notifications.where((notification) {
        bool matchesSearch =
            notification["user"].toLowerCase().contains(query) ||
            notification["message"].toLowerCase().contains(query);

        if (selectedFilter == 0) {
          return matchesSearch;
        }

        return matchesSearch && notification["type"] == filters[selectedFilter];
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,

        title: Text(
          l10n.notificationsScreenTitle,

          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                searching = !searching;
              });
            },

            icon: Icon(searching ? Icons.close : Icons.search),
          ),

          IconButton(
            onPressed: () {},

            icon: const Icon(Icons.notifications_active),
          ),
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
                    l10n.notificationsHeading,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 28,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.notificationsSubtitle,

                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.notifications,

                          accentColor,

                          notifications.length.toString(),

                          l10n.notificationsStatTotalLabel,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.mark_email_unread,

                          Colors.red,

                          notifications
                              .where((e) => !e["read"])
                              .length
                              .toString(),

                          l10n.notificationsUnreadLabel,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.favorite,

                          Colors.pink,

                          notifications
                              .where((e) => e["type"] == "Likes")
                              .length
                              .toString(),

                          l10n.notificationsLikesStatLabel,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.chat,

                          Colors.blue,

                          notifications
                              .where((e) => e["type"] == "Comentarios")
                              .length
                              .toString(),

                          l10n.notificationsCommentsStatLabel,
                        ),
                      ),
                    ],
                  ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),

                    height: searching ? 65 : 0,

                    margin: EdgeInsets.only(top: searching ? 25 : 0),

                    child: TextField(
                      controller: searchController,

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        filled: true,

                        fillColor: const Color(0xff171725),

                        hintText: l10n.notificationsSearchHint,

                        hintStyle: TextStyle(color: Colors.grey.shade500),

                        prefixIcon: const Icon(
                          Icons.search,

                          color: Colors.white70,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 42,

                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,

                      itemCount: filters.length,

                      itemBuilder: (_, index) {
                        bool selected = selectedFilter == index;

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),

                          child: ChoiceChip(
                            label: Text(filters[index]),

                            selected: selected,

                            selectedColor: accentColor,

                            backgroundColor: const Color(0xff171725),

                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade400,
                            ),

                            onSelected: (_) {
                              setState(() {
                                selectedFilter = index;

                                filterNotifications();
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    l10n.notificationsRecentActivityTitle,

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 18,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),
                  if (filteredNotifications.isEmpty)
                    _emptyState(l10n, accentColor)
                  else
                    ListView.separated(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: filteredNotifications.length,

                      separatorBuilder: (_, __) => const SizedBox(height: 14),

                      itemBuilder: (_, index) {
                        final notification = filteredNotifications[index];

                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 250 + (index * 60)),

                          tween: Tween(begin: .95, end: 1),

                          curve: Curves.easeOutBack,

                          builder: (_, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },

                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),

                            onTap: () {
                              setState(() {
                                notification["read"] = true;
                              });
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),

                              padding: const EdgeInsets.all(16),

                              decoration: BoxDecoration(
                                color: notification["read"]
                                    ? const Color(0xff171725)
                                    : const Color(0xff202038),

                                borderRadius: BorderRadius.circular(22),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.20),

                                    blurRadius: 12,

                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,

                                        backgroundImage: AssetImage(
                                          notification["avatar"],
                                        ),
                                      ),

                                      Positioned(
                                        right: -2,

                                        bottom: -2,

                                        child: Container(
                                          width: 24,

                                          height: 24,

                                          decoration: BoxDecoration(
                                            color:
                                                notification["color"]
                                                    as Color? ??
                                                accentColor,

                                            shape: BoxShape.circle,

                                            border: Border.all(
                                              color: const Color(0xff171725),

                                              width: 2,
                                            ),
                                          ),

                                          child: Icon(
                                            notification["icon"],

                                            color: Colors.white,

                                            size: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 15),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notification["user"],

                                                style: const TextStyle(
                                                  color: Colors.white,

                                                  fontWeight: FontWeight.bold,

                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),

                                            Text(
                                              notification["time"],

                                              style: TextStyle(
                                                color: Colors.grey.shade500,

                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 6),

                                        Text(
                                          notification["message"],

                                          style: TextStyle(
                                            color: Colors.grey.shade300,

                                            fontSize: 13,
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        Row(
                                          children: [
                                            if (!notification["read"])
                                              Container(
                                                width: 10,

                                                height: 10,

                                                decoration: const BoxDecoration(
                                                  color: Colors.blue,

                                                  shape: BoxShape.circle,
                                                ),
                                              ),

                                            if (!notification["read"])
                                              const SizedBox(width: 8),

                                            Text(
                                              notification["read"]
                                                  ? l10n.notificationsReadLabel
                                                  : l10n.notificationsUnreadLabel,

                                              style: TextStyle(
                                                color: notification["read"]
                                                    ? Colors.green
                                                    : Colors.blue,

                                                fontWeight: FontWeight.bold,

                                                fontSize: 12,
                                              ),
                                            ),

                                            const Spacer(),

                                            IconButton(
                                              splashRadius: 20,

                                              onPressed: () {
                                                setState(() {
                                                  notification["read"] = true;
                                                });
                                              },

                                              icon: const Icon(
                                                Icons.done_all,

                                                color: Colors.green,

                                                size: 20,
                                              ),
                                            ),

                                            IconButton(
                                              splashRadius: 20,

                                              onPressed: () {
                                                setState(() {
                                                  notifications.remove(
                                                    notification,
                                                  );

                                                  filterNotifications();
                                                });
                                              },

                                              icon: const Icon(
                                                Icons.delete_outline,

                                                color: Colors.red,

                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _emptyState(AppLocalizations l10n, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),

      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.notifications_off_outlined,

              color: Colors.grey.shade700,

              size: 72,
            ),

            const SizedBox(height: 20),

            Text(
              l10n.notificationsEmptyTitle,

              style: const TextStyle(
                color: Colors.white,

                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              l10n.notificationsEmptySubtitle,

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),

            const SizedBox(height: 25),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              onPressed: () {
                searchController.clear();

                filterNotifications();
              },

              icon: const Icon(Icons.refresh),

              label: Text(l10n.notificationsEmptyActionButton),
            ),
          ],
        ),
      ),
    );
  }
}
