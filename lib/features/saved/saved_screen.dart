import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  final ScrollController scrollController = ScrollController();

  final TextEditingController searchController = TextEditingController();

  bool searching = false;

  List<Map<String, dynamic>> collections = [
    {
      "name": "Favoritos",

      "posts": 128,

      "icon": Icons.favorite,

      "color": Colors.red,

      "cover": "assets/inicio.png",
    },

    {
      "name": "Inspiración",

      "posts": 56,

      "icon": Icons.lightbulb,

      "color": Colors.orange,

      "cover": "assets/login.png",
    },

    {
      "name": "UI / UX",

      "posts": 34,

      "icon": Icons.design_services,

      "color": Colors.blue,

      "cover": "assets/inicio.png",
    },

    {
      "name": "Música",

      "posts": 22,

      "icon": Icons.music_note,

      "color": Colors.purple,

      "cover": "assets/login.png",
    },

    {
      "name": "Videojuegos",

      "posts": 41,

      "icon": Icons.sports_esports,

      "color": Colors.green,

      "cover": "assets/inicio.png",
    },

    {
      "name": "Literatura",

      "posts": 18,

      "icon": Icons.menu_book,

      "color": Colors.teal,

      "cover": "assets/login.png",
    },
  ];

  late List<Map<String, dynamic>> filteredCollections;

  @override
  void initState() {
    super.initState();

    filteredCollections = List.from(collections);

    animationController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 700),
    );

    animationController.forward();

    searchController.addListener(filterCollections);
  }

  @override
  void dispose() {
    animationController.dispose();

    searchController.dispose();

    scrollController.dispose();

    super.dispose();
  }

  void filterCollections() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredCollections = collections.where((collection) {
        return collection["name"].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));

    filterCollections();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final savedPosts = context
        .watch<PostsController>()
        .posts
        .where((p) => p["saved"] == true)
        .toList();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,

        title: Text(
          l10n.savedScreenTitle,

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

            icon: const Icon(Icons.add_box_outlined),
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
                    l10n.savedCollectionsHeading,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 28,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.savedCollectionsSubtitle,

                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    l10n.savedPostsSectionTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (savedPosts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xff171725),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        l10n.savedPostsEmptyHint,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: savedPosts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                      itemBuilder: (_, index) {
                        final post = savedPosts[index];
                        final imageFile = post["imageFile"] as File?;
                        final imageUrl = post["image"] as String?;
                        final isVideo = post["videoFile"] != null;

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (imageFile != null)
                                Image.file(
                                  imageFile,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF8B5CF6),
                                          Color(0xFFD946EF),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else if (imageUrl != null)
                                Image.network(imageUrl, fit: BoxFit.cover)
                              else
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF8B5CF6),
                                        Color(0xFFD946EF),
                                      ],
                                    ),
                                  ),
                                ),
                              if (isVideo)
                                const Positioned(
                                  right: 6,
                                  bottom: 6,
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.folder_copy,

                          Colors.blue,

                          collections.length.toString(),

                          l10n.savedCollectionsStatLabel,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.bookmark,

                          Colors.amber,

                          collections
                              .fold<int>(
                                0,
                                (total, item) => total + (item["posts"] as int),
                              )
                              .toString(),

                          l10n.savedScreenTitle,
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

                          Colors.red,

                          "128",

                          l10n.savedFavoritesStatLabel,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.storage,

                          Colors.green,

                          "2.8 GB",

                          l10n.savedStorageStatLabel,
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

                        hintText: l10n.savedSearchHint,

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

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,

                    height: 55,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: () {
                        showDialog(
                          context: context,

                          builder: (_) {
                            final controller = TextEditingController();

                            return AlertDialog(
                              backgroundColor: const Color(0xff171725),

                              title: Text(
                                l10n.savedNewCollectionLabel,

                                style: const TextStyle(color: Colors.white),
                              ),

                              content: TextField(
                                controller: controller,

                                style: const TextStyle(color: Colors.white),

                                decoration: InputDecoration(
                                  hintText: l10n.savedCollectionNameHint,
                                ),
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
                                    if (controller.text.trim().isNotEmpty) {
                                      setState(() {
                                        collections.add({
                                          "name": controller.text,

                                          "posts": 0,

                                          "icon": Icons.folder,

                                          "color": accentColor,

                                          "cover": "assets/inicio.png",
                                        });

                                        filterCollections();
                                      });
                                    }

                                    Navigator.pop(context);
                                  },

                                  child: Text(l10n.savedCreateButton),
                                ),
                              ],
                            );
                          },
                        );
                      },

                      icon: const Icon(Icons.add),

                      label: Text(l10n.savedNewCollectionLabel),
                    ),
                  ),

                  const SizedBox(height: 30),
                  if (filteredCollections.isEmpty)
                    _emptyState(l10n, accentColor)
                  else
                    GridView.builder(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: filteredCollections.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,

                            crossAxisSpacing: 16,

                            mainAxisSpacing: 16,

                            childAspectRatio: .82,
                          ),

                      itemBuilder: (_, index) {
                        final collection = filteredCollections[index];

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
                                    flex: 7,

                                    child: Hero(
                                      tag: "collection_$index",

                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(22),

                                          topRight: Radius.circular(22),
                                        ),

                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Image.asset(
                                                collection["cover"],

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
                                                                    Icons.edit,

                                                                    color: Colors
                                                                        .white,
                                                                  ),

                                                              title: Text(
                                                                l10n.savedRenameOption,

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
                                                              leading:
                                                                  const Icon(
                                                                    Icons
                                                                        .delete,

                                                                    color: Colors
                                                                        .red,
                                                                  ),

                                                              title: Text(
                                                                l10n.commonDelete,

                                                                style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),

                                                              onTap: () {
                                                                setState(() {
                                                                  collections
                                                                      .remove(
                                                                        collection,
                                                                      );

                                                                  filterCollections();
                                                                });

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
                                                          30,
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
                                                      horizontal: 12,

                                                      vertical: 6,
                                                    ),

                                                decoration: BoxDecoration(
                                                  color: collection["color"],

                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),

                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      collection["icon"],

                                                      color: Colors.white,

                                                      size: 15,
                                                    ),

                                                    const SizedBox(width: 5),

                                                    Text(
                                                      "${collection["posts"]}",

                                                      style: const TextStyle(
                                                        color: Colors.white,

                                                        fontWeight:
                                                            FontWeight.bold,

                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
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
                                            collection["name"],

                                            maxLines: 1,

                                            overflow: TextOverflow.ellipsis,

                                            style: const TextStyle(
                                              color: Colors.white,

                                              fontWeight: FontWeight.bold,

                                              fontSize: 16,
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          Text(
                                            l10n.savedPostsCountLabel(
                                              collection["posts"] as int,
                                            ),

                                            style: TextStyle(
                                              color: Colors.grey.shade400,

                                              fontSize: 13,
                                            ),
                                          ),

                                          const Spacer(),

                                          Row(
                                            children: [
                                              Icon(
                                                collection["icon"],

                                                color: collection["color"],

                                                size: 20,
                                              ),

                                              const Spacer(),

                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,

                                                      vertical: 5,
                                                    ),

                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(.06),

                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),

                                                child: Text(
                                                  l10n.savedOpenButton,

                                                  style: const TextStyle(
                                                    color: Colors.white,

                                                    fontWeight: FontWeight.w600,

                                                    fontSize: 11,
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

  Widget _emptyState(AppLocalizations l10n, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),

      child: Center(
        child: Column(
          children: [
            Icon(Icons.bookmark_border, color: Colors.grey.shade700, size: 70),

            const SizedBox(height: 20),

            Text(
              l10n.savedEmptyTitle,

              style: const TextStyle(
                color: Colors.white,

                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              l10n.savedEmptySubtitle,

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey.shade500),
            ),

            const SizedBox(height: 25),

            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: accentColor),

              onPressed: () {},

              icon: const Icon(Icons.add),

              label: Text(l10n.savedNewCollectionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
