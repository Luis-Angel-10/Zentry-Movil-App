import 'dart:io';

import 'package:Zentry/features/create/create_screen.dart';
import 'package:Zentry/features/home/widgets/backend_feed.dart';
import 'package:Zentry/features/profile/profile_menu_screen.dart';
import 'package:Zentry/features/achievements/achievements_screen.dart';
import 'package:Zentry/features/stories/story_viewer_screen.dart';
import 'package:Zentry/theme/theme_controller.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/providers/follow_controller.dart';
import 'package:Zentry/core/providers/notifications_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/features/notifications/notifications_screen.dart';
import 'package:Zentry/features/search/global_search_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<PostsController>();
      if (!controller.feedLoaded && !controller.feedLoading) {
        controller.refreshFeed();
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 600) {
      context.read<PostsController>().loadMoreFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = context.watch<ThemeController>().accentColor;
    final l10n = AppLocalizations.of(context)!;
    final engagement = context.watch<EngagementController>();
    final postsController = context.watch<PostsController>();
    final follow = context.watch<FollowController>();
    final myName = context.watch<AuthController>().currentUser?.displayName;
    final storyGroups = postsController.groupedVisibleStories(
      viewerName: myName ?? '',
      isFollowing: (authorId) {
        final me = context.read<AuthController>().currentUser;
        return me != null && follow.isFollowing(me.id, authorId);
      },
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<PostsController>().refreshFeed(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Zentry",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AchievementsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: engagement.isStreakActiveToday
                                    ? Colors.deepOrange.withOpacity(0.15)
                                    : Colors.white10,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    color: engagement.isStreakActiveToday
                                        ? Colors.deepOrange
                                        : Colors.white38,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.homeStreakChipLabel(
                                      engagement.streakCount,
                                    ),
                                    style: TextStyle(
                                      color: engagement.isStreakActiveToday
                                          ? Colors.deepOrange
                                          : Colors.white38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GlobalSearchScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.search),
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NotificationsScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.notifications_none),
                              ),
                              if (context
                                      .watch<NotificationsController>()
                                      .unreadCount >
                                  0)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileMenuScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                child: const Icon(
                                  Icons.person,
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
              ),

              // Historias (aún locales; no integradas en Fase 2).
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: storyGroups.length + 1,
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CreateScreen(initialPostType: 1),
                              ),
                            );
                          },
                          child: Container(
                            width: 78,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white10,
                                    border: Border.all(
                                      color: accentColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: accentColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.homeAddStoryLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final group = storyGroups[index - 1];
                      final File? storyImage =
                          group.latest["imageFile"] as File?;
                      final seen = group.allSeenBy(myName ?? '');

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoryViewerScreen(
                                stories: group.items,
                                initialIndex: group.firstUnseenIndexFor(
                                  myName ?? '',
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 78,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: seen
                                      ? null
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFF8B5CF6),
                                            Color(0xFFD946EF),
                                          ],
                                        ),
                                  border: seen
                                      ? Border.all(
                                          color: Colors.white24,
                                          width: 2.5,
                                        )
                                      : null,
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white10,
                                  backgroundImage: storyImage != null
                                      ? FileImage(storyImage) as ImageProvider
                                      : null,
                                  child: storyImage == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                group.user,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ─── Feed real (backend) ───────────────────────────────────
              ..._buildFeedSlivers(context, postsController, accentColor, l10n),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeedSlivers(
    BuildContext context,
    PostsController c,
    Color accentColor,
    AppLocalizations l10n,
  ) {
    // Estado: cargando por primera vez.
    if (c.feedLoading && c.backendPosts.isEmpty) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.only(top: 80),
            child: Align(
              alignment: Alignment.topCenter,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ];
    }

    // Estado: error sin datos previos.
    if (c.feedError != null && c.backendPosts.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 46, color: Colors.white38),
                const SizedBox(height: 14),
                Text(
                  c.feedError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => c.refreshFeed(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    // Estado: vacío.
    if (c.backendPosts.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.dynamic_feed, size: 46, color: Colors.white38),
                const SizedBox(height: 14),
                const Text(
                  'Todavía no hay publicaciones en el feed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => c.refreshFeed(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualizar'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    // Estado: lista con datos (+ indicador de paginación al final).
    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, index) => BackendPostCard(post: c.backendPosts[index]),
          childCount: c.backendPosts.length,
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 90, top: 4),
          child: Center(
            child: c.feedLoadingMore
                ? const SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : (!c.feedHasMore
                      ? Text(
                          '· fin del feed ·',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.3),
                            fontSize: 12,
                          ),
                        )
                      : const SizedBox.shrink()),
          ),
        ),
      ),
    ];
  }
}

class AnimatedLikeButton extends StatefulWidget {
  final int likes;
  final bool initialLiked;
  final VoidCallback? onLiked;
  final ValueChanged<bool>? onToggle;

  const AnimatedLikeButton({
    super.key,
    required this.likes,
    this.initialLiked = false,
    this.onLiked,
    this.onToggle,
  });

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton> {
  late bool liked = widget.initialLiked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final wasLiked = liked;
        setState(() {
          liked = !liked;
        });
        widget.onToggle?.call(liked);
        if (!wasLiked) {
          widget.onLiked?.call();
        }
      },
      child: AnimatedScale(
        scale: liked ? 1.2 : 1,
        duration: const Duration(milliseconds: 180),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(liked),
                color: liked ? Colors.pinkAccent : Colors.white70,
                size: 22,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "${widget.likes}",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final bool initialActive;
  final int badgeCount;

  const AnimatedActionButton({
    super.key,
    required this.icon,
    this.activeIcon,
    this.onTap,
    this.onToggle,
    this.initialActive = false,
    this.badgeCount = 0,
  });

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton> {
  bool pressed = false;
  late bool active = widget.initialActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          pressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          pressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },
      onTap: () {
        if (widget.activeIcon != null) {
          final wasActive = active;
          setState(() {
            active = !active;
          });
          widget.onToggle?.call(active);
          if (!wasActive) {
            widget.onTap?.call();
          }
        } else {
          widget.onTap?.call();
        }
      },
      child: AnimatedScale(
        scale: pressed ? 0.82 : 1,
        duration: const Duration(milliseconds: 120),
        child: Row(
          children: [
            Icon(
              active ? (widget.activeIcon ?? widget.icon) : widget.icon,
              color: active ? Colors.amber : Colors.white70,
              size: 23,
            ),
            if (widget.badgeCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '${widget.badgeCount}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
