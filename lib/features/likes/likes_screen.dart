import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  final ScrollController scrollController = ScrollController();

  final TextEditingController searchController = TextEditingController();

  int selectedFilter = 0;

  bool isSearching = false;

  List<String> filters = ["Todos", "Posts", "Reels", "Historias", "Proyectos"];

  List<String> _buildFilters(AppLocalizations l10n) {
    return [
      l10n.likesFilterAll,
      l10n.likesFilterPosts,
      l10n.likesFilterReels,
      l10n.likesFilterStories,
      l10n.likesFilterProjects,
    ];
  }

  final List<Map<String, dynamic>> posts = [
    {
      "title": "Paisaje",
      "creator": "Luis Martínez",
      "type": "Post",
      "likes": "1.2K",
      "image": "assets/inicio.png",
      "saved": false,
    },

    {
      "title": "Logo Moderno",
      "creator": "Jennifer",
      "type": "Proyecto",
      "likes": "856",
      "image": "assets/login.png",
      "saved": true,
    },

    {
      "title": "Sketch",
      "creator": "Daniel",
      "type": "Historia",
      "likes": "3.8K",
      "image": "assets/inicio.png",
      "saved": false,
    },

    {
      "title": "UI Mobile",
      "creator": "Joseph",
      "type": "Proyecto",
      "likes": "512",
      "image": "assets/login.png",
      "saved": true,
    },

    {
      "title": "Concept Art",
      "creator": "Andrea",
      "type": "Post",
      "likes": "7.4K",
      "image": "assets/inicio.png",
      "saved": false,
    },

    {
      "title": "Mountain",
      "creator": "Carlos",
      "type": "Reel",
      "likes": "920",
      "image": "assets/login.png",
      "saved": false,
    },
  ];

  late List<Map<String, dynamic>> filteredPosts;

  @override
  void initState() {
    super.initState();

    filteredPosts = List.from(posts);

    animationController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 700),
    );

    animationController.forward();

    searchController.addListener(filterPosts);
  }

  @override
  void dispose() {
    animationController.dispose();

    searchController.dispose();

    scrollController.dispose();

    super.dispose();
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));

    filterPosts();
  }

  void filterPosts() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredPosts = posts.where((post) {
        bool matchesSearch =
            post["title"].toLowerCase().contains(query) ||
            post["creator"].toLowerCase().contains(query);

        if (selectedFilter == 0) {
          return matchesSearch;
        }

        String type = filters[selectedFilter];

        if (type == "Posts") {
          return matchesSearch && post["type"] == "Post";
        }

        if (type == "Reels") {
          return matchesSearch && post["type"] == "Reel";
        }

        if (type == "Historias") {
          return matchesSearch && post["type"] == "Historia";
        }

        if (type == "Proyectos") {
          return matchesSearch && post["type"] == "Proyecto";
        }

        return matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    filters = _buildFilters(l10n);
    final accentColor = context.watch<ThemeController>().accentColor;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,

        title: Text(
          l10n.likesTitle,

          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
              });
            },

            icon: Icon(isSearching ? Icons.close : Icons.search),
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
                    l10n.likesHeading,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 26,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.likesSubtitle,

                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.favorite,

                          Colors.red,

                          filteredPosts.length.toString(),

                          l10n.likesTitle,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.article,

                          Colors.blue,

                          posts
                              .where((e) => e["type"] == "Post")
                              .length
                              .toString(),

                          l10n.likesFilterPosts,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.video_collection,

                          Colors.orange,

                          posts
                              .where((e) => e["type"] == "Reel")
                              .length
                              .toString(),

                          l10n.likesFilterReels,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.folder_copy,

                          Colors.green,

                          posts
                              .where((e) => e["type"] == "Proyecto")
                              .length
                              .toString(),

                          l10n.likesFilterProjects,
                        ),
                      ),
                    ],
                  ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),

                    height: isSearching ? 65 : 0,

                    margin: EdgeInsets.only(top: isSearching ? 25 : 0),

                    child: TextField(
                      controller: searchController,

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        filled: true,

                        fillColor: const Color(0xff171725),

                        hintText: l10n.likesSearchHint,

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

                                filterPosts();
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),
                  if (filteredPosts.isEmpty)
                    _emptyState(l10n)
                  else
                    GridView.builder(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: filteredPosts.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,

                            crossAxisSpacing: 15,

                            mainAxisSpacing: 15,

                            childAspectRatio: .72,
                          ),

                      itemBuilder: (_, index) {
                        final post = filteredPosts[index];

                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 250 + (index * 80)),

                          tween: Tween(begin: .85, end: 1),

                          curve: Curves.easeOutBack,

                          builder: (_, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },

                          child: GestureDetector(
                            onDoubleTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.likesRemovedSnackbar(post["title"]),
                                  ),
                                ),
                              );
                            },

                            onTap: () {},

                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff171725),

                                borderRadius: BorderRadius.circular(22),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.30),

                                    blurRadius: 15,

                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Expanded(
                                    flex: 7,

                                    child: Hero(
                                      tag: "post_$index",

                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(22),

                                          topRight: Radius.circular(22),
                                        ),

                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Image.asset(
                                                post["image"],

                                                fit: BoxFit.cover,
                                              ),
                                            ),

                                            Positioned(
                                              top: 10,

                                              right: 10,

                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(30),

                                                onTap: () {
                                                  showModalBottomSheet(
                                                    context: context,

                                                    backgroundColor:
                                                        const Color(0xff171725),

                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  25,
                                                                ),
                                                          ),
                                                    ),

                                                    builder: (_) {
                                                      return SafeArea(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,

                                                          children: [
                                                            const SizedBox(
                                                              height: 20,
                                                            ),

                                                            ListTile(
                                                              leading:
                                                                  const Icon(
                                                                    Icons.share,

                                                                    color: Colors
                                                                        .white,
                                                                  ),

                                                              title: Text(
                                                                l10n.commonShare,

                                                                style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),

                                                              onTap: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                            ),

                                                            ListTile(
                                                              leading: const Icon(
                                                                Icons
                                                                    .bookmark_add,

                                                                color: Colors
                                                                    .white,
                                                              ),

                                                              title: Text(
                                                                post["saved"]
                                                                    ? l10n.likesRemoveFromSaved
                                                                    : l10n.commonSave,

                                                                style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),

                                                              onTap: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                            ),

                                                            ListTile(
                                                              leading: const Icon(
                                                                Icons.favorite,

                                                                color:
                                                                    Colors.red,
                                                              ),

                                                              title: Text(
                                                                l10n.likesRemoveLike,

                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),

                                                              onTap: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                            ),

                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },

                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),

                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,

                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          25,
                                                        ),
                                                  ),

                                                  child: const Icon(
                                                    Icons.more_vert,

                                                    color: Colors.white,

                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 10,

                                              bottom: 10,

                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,

                                                      vertical: 5,
                                                    ),

                                                decoration: BoxDecoration(
                                                  color: accentColor,

                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),

                                                child: Text(
                                                  post["type"],

                                                  style: const TextStyle(
                                                    color: Colors.white,

                                                    fontSize: 11,

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
                                    flex: 3,

                                    child: Padding(
                                      padding: const EdgeInsets.all(12),

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            post["title"],

                                            maxLines: 1,

                                            overflow: TextOverflow.ellipsis,

                                            style: const TextStyle(
                                              color: Colors.white,

                                              fontWeight: FontWeight.bold,

                                              fontSize: 15,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            post["creator"],

                                            maxLines: 1,

                                            overflow: TextOverflow.ellipsis,

                                            style: TextStyle(
                                              color: Colors.grey.shade400,

                                              fontSize: 13,
                                            ),
                                          ),

                                          const Spacer(),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons.favorite,

                                                color: Colors.red.shade400,

                                                size: 18,
                                              ),

                                              const SizedBox(width: 5),

                                              Text(
                                                post["likes"],

                                                style: const TextStyle(
                                                  color: Colors.white,

                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const Spacer(),

                                              Icon(
                                                post["saved"]
                                                    ? Icons.bookmark
                                                    : Icons.bookmark_border,

                                                color: Colors.amber,

                                                size: 20,
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

          const SizedBox(height: 4),

          Text(
            title,

            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),

      child: Center(
        child: Column(
          children: [
            Icon(Icons.favorite_border, color: Colors.grey.shade700, size: 70),

            const SizedBox(height: 20),

            Text(
              l10n.likesEmptyTitle,

              style: const TextStyle(
                color: Colors.white,

                fontSize: 20,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              l10n.likesEmptySubtitle,

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
