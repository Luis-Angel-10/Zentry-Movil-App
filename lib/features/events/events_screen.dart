import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  final ScrollController scrollController = ScrollController();

  final TextEditingController searchController = TextEditingController();

  bool searching = false;

  int selectedFilter = 0;

  List<String> _buildFilters(AppLocalizations l10n) {
    return [
      l10n.eventsFilterAll,
      l10n.eventsFilterToday,
      l10n.eventsFilterWeek,
      l10n.eventsFilterMonth,
      l10n.eventsFilterOnline,
      l10n.eventsFilterInPerson,
    ];
  }

  final List<Map<String, dynamic>> events = [
    {
      "title": "Hackathon Flutter",

      "date": "25 Jul",

      "time": "18:00",

      "location": "Puebla",

      "mode": "Presencial",

      "attendees": "328",

      "status": "Disponible",

      "cover": null,

      "joined": false,

      "featured": true,
    },

    {
      "title": "Festival Indie",

      "date": "28 Jul",

      "time": "20:00",

      "location": "CDMX",

      "mode": "Presencial",

      "attendees": "1.2K",

      "status": "Pocos lugares",

      "cover": null,

      "joined": false,

      "featured": true,
    },

    {
      "title": "Curso Spring Boot",

      "date": "02 Ago",

      "time": "17:00",

      "location": "Online",

      "mode": "Online",

      "attendees": "680",

      "status": "Disponible",

      "cover": null,

      "joined": true,

      "featured": false,
    },

    {
      "title": "Concurso de Arte",

      "date": "05 Ago",

      "time": "16:00",

      "location": "Guadalajara",

      "mode": "Presencial",

      "attendees": "432",

      "status": "Completo",

      "cover": null,

      "joined": false,

      "featured": false,
    },

    {
      "title": "Game Jam",

      "date": "12 Ago",

      "time": "09:00",

      "location": "Online",

      "mode": "Online",

      "attendees": "954",

      "status": "Disponible",

      "cover": null,

      "joined": false,

      "featured": true,
    },
  ];

  late List<Map<String, dynamic>> filteredEvents;

  @override
  void initState() {
    super.initState();

    filteredEvents = List.from(events);

    animationController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 700),
    );

    animationController.forward();

    searchController.addListener(filterEvents);
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

    filterEvents();
  }

  void filterEvents() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredEvents = events.where((event) {
        bool matchesSearch =
            event["title"].toLowerCase().contains(query) ||
            event["location"].toLowerCase().contains(query);

        switch (selectedFilter) {
          case 1:
            return matchesSearch && event["date"] == "25 Jul";

          case 2:
            return matchesSearch;

          case 3:
            return matchesSearch;

          case 4:
            return matchesSearch && event["mode"] == "Online";

          case 5:
            return matchesSearch && event["mode"] == "Presencial";

          default:
            return matchesSearch;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filters = _buildFilters(l10n);
    final accentColor = context.watch<ThemeController>().accentColor;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,

        title: Text(
          l10n.eventsScreenTitle,

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

          IconButton(onPressed: () {}, icon: const Icon(Icons.event_available)),
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
                    l10n.eventsHeading,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 28,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.eventsSubtitle,

                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.event,

                          Colors.blue,

                          events.length.toString(),

                          l10n.eventsStatEventsLabel,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.local_fire_department,

                          Colors.orange,

                          events.where((e) => e["featured"]).length.toString(),

                          l10n.eventsStatFeaturedLabel,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.check_circle,

                          Colors.green,

                          events.where((e) => e["joined"]).length.toString(),

                          l10n.eventsRegisteredLabel,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.people,

                          Colors.purple,

                          "3.6K",

                          l10n.eventsStatAttendeesLabel,
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

                        hintText: l10n.eventsSearchHint,

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

                            backgroundColor: const Color(0xff171725),

                            selectedColor: accentColor,

                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade400,
                            ),

                            onSelected: (_) {
                              setState(() {
                                selectedFilter = index;

                                filterEvents();
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        l10n.eventsFeaturedSectionTitle,

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 18,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      TextButton(
                        onPressed: () {},

                        child: Text(l10n.eventsSeeAllButton),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  if (filteredEvents.isEmpty)
                    _emptyState(accentColor)
                  else
                    GridView.builder(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: filteredEvents.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,

                            crossAxisSpacing: 15,

                            mainAxisSpacing: 15,

                            childAspectRatio: .67,
                          ),

                      itemBuilder: (_, index) {
                        final event = filteredEvents[index];

                        Color statusColor = Colors.green;

                        if (event["status"] == "Pocos lugares") {
                          statusColor = Colors.orange;
                        }

                        if (event["status"] == "Completo") {
                          statusColor = Colors.red;
                        }

                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 250 + (index * 80)),

                          tween: Tween(begin: .90, end: 1),

                          curve: Curves.easeOutBack,

                          builder: (_, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },

                          child: GestureDetector(
                            onTap: () {},

                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff171725),

                                borderRadius: BorderRadius.circular(22),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.25),

                                    blurRadius: 15,

                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Expanded(
                                    flex: 6,

                                    child: Hero(
                                      tag: "event_$index",

                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(22),

                                          topRight: Radius.circular(22),
                                        ),

                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: event["cover"] != null
                                                  ? Image.asset(
                                                      event["cover"] as String,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                              colors: [
                                                                Colors
                                                                    .deepPurple
                                                                    .shade900,
                                                                Colors.black87,
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                      ),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.event_outlined,
                                                          color: Colors.white24,
                                                          size: 48,
                                                        ),
                                                      ),
                                                    ),
                                            ),

                                            if (event["featured"])
                                              Positioned(
                                                top: 10,

                                                left: 10,

                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,

                                                        vertical: 5,
                                                      ),

                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,

                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),

                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .local_fire_department,

                                                        color: Colors.white,

                                                        size: 14,
                                                      ),

                                                      const SizedBox(width: 4),

                                                      Text(
                                                        l10n.eventsFeaturedBadge,

                                                        style: const TextStyle(
                                                          color: Colors.white,

                                                          fontWeight:
                                                              FontWeight.bold,

                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                            Positioned(
                                              right: 10,

                                              top: 10,

                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,

                                                      vertical: 5,
                                                    ),

                                                decoration: BoxDecoration(
                                                  color: statusColor,

                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),

                                                child: Text(
                                                  event["status"],

                                                  style: const TextStyle(
                                                    color: Colors.white,

                                                    fontSize: 10,

                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    flex: 4,

                                    child: Padding(
                                      padding: const EdgeInsets.all(12),

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            event["title"],

                                            maxLines: 1,

                                            overflow: TextOverflow.ellipsis,

                                            style: const TextStyle(
                                              color: Colors.white,

                                              fontWeight: FontWeight.bold,

                                              fontSize: 16,
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,

                                                color: Colors.white70,

                                                size: 14,
                                              ),

                                              const SizedBox(width: 5),

                                              Text(
                                                event["date"],

                                                style: TextStyle(
                                                  color: Colors.grey.shade400,

                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 5),

                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,

                                                color: Colors.white70,

                                                size: 14,
                                              ),

                                              const SizedBox(width: 5),

                                              Text(
                                                event["time"],

                                                style: TextStyle(
                                                  color: Colors.grey.shade400,

                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 5),

                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,

                                                color: Colors.red,

                                                size: 14,
                                              ),

                                              const SizedBox(width: 5),

                                              Expanded(
                                                child: Text(
                                                  event["location"],

                                                  overflow:
                                                      TextOverflow.ellipsis,

                                                  style: TextStyle(
                                                    color: Colors.grey.shade400,

                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const Spacer(),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons.people,

                                                color: Colors.grey.shade500,

                                                size: 15,
                                              ),

                                              const SizedBox(width: 4),

                                              Text(
                                                event["attendees"],

                                                style: TextStyle(
                                                  color: Colors.grey.shade400,

                                                  fontSize: 11,
                                                ),
                                              ),

                                              const Spacer(),

                                              SizedBox(
                                                height: 30,

                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        event["joined"]
                                                        ? Colors.green
                                                        : accentColor,

                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                        ),

                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),

                                                  onPressed: () {
                                                    if (event["status"] !=
                                                        "Completo") {
                                                      setState(() {
                                                        event["joined"] =
                                                            !event["joined"];
                                                      });
                                                    }
                                                  },

                                                  child: Text(
                                                    event["joined"]
                                                        ? l10n.eventsRegisteredLabel
                                                        : l10n.eventsJoinButton,

                                                    style: const TextStyle(
                                                      color: Colors.white,

                                                      fontSize: 11,

                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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

  Widget _emptyState(Color accentColor) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),

      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_busy, color: Colors.grey.shade700, size: 72),

            const SizedBox(height: 20),

            Text(
              l10n.eventsEmptyTitle,

              style: const TextStyle(
                color: Colors.white,

                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              l10n.eventsEmptySubtitle,

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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.eventsEmptySnackbarMessage)),
                );
              },

              icon: const Icon(Icons.explore),

              label: Text(l10n.eventsEmptyActionButton),
            ),
          ],
        ),
      ),
    );
  }
}
