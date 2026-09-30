import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/widgets/zentry_network_image.dart';
import 'package:Zentry/features/home/widgets/backend_feed.dart'
    show BackendPostCard;
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

/// Detalle de una comunidad REAL del backend. Reemplaza a la versión local
/// (privacidad/moderadores/solicitudes de ingreso — conceptos que el
/// backend no tiene) — ver `CommunityController` para el detalle de qué se
/// conservó sin borrar.
///
/// [identifier] es el slug o el id numérico (`CommunityResponse.identifier`).
class CommunityDetailScreen extends StatefulWidget {
  const CommunityDetailScreen({super.key, required this.identifier});

  final String identifier;

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityController>().loadCommunityDetail(
        widget.identifier,
      );
      context.read<PostsController>().loadCommunityPosts(widget.identifier);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleJoin() async {
    final l10n = AppLocalizations.of(context)!;
    final community = context.read<CommunityController>().selectedCommunity;
    if (community == null) return;
    final error = await context.read<CommunityController>().toggleJoinBackend(
      community,
    );
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    // Mensaje de referencia disponible por si se necesita distinguir el caso
    // de "solicitud enviada" en un futuro modelo con aprobación de ingreso.
    assert(l10n.communityJoinRequestSentSnackbar.isNotEmpty);
  }

  Future<void> _openNewPostSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String? imagePath;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF17171F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.communityDetailNewPostButton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: l10n.communityDetailNewPostTitleRequired,
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF24242C),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    minLines: 2,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: l10n.communityDetailNewPostHint,
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF24242C),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (picked != null) {
                        setSheetState(() => imagePath = picked.path);
                      }
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      imagePath == null
                          ? l10n.communityDetailAddImageButton
                          : imagePath!.split(RegExp(r'[/\\]')).last,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.communityDetailNewPostTitleRequired,
                              ),
                            ),
                          );
                          return;
                        }
                        try {
                          await context
                              .read<PostsController>()
                              .createCommunityPostBackend(
                                widget.identifier,
                                title: title,
                                content: contentController.text.trim().isEmpty
                                    ? null
                                    : contentController.text.trim(),
                                imagePath: imagePath,
                              );
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop(true);
                          }
                        } on ApiException catch (e) {
                          if (sheetContext.mounted) {
                            ScaffoldMessenger.of(
                              sheetContext,
                            ).showSnackBar(SnackBar(content: Text(e.message)));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.communityDetailNewPostButton,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.communityDetailPostPublishedSnackbar),
            backgroundColor: Colors.green.shade600,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final controller = context.watch<CommunityController>();

    if (controller.selectedCommunityLoading &&
        controller.selectedCommunity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (controller.selectedCommunity == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.selectedCommunityError ??
                    l10n.communityDetailNotFound,
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context
                    .read<CommunityController>()
                    .loadCommunityDetail(widget.identifier),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      );
    }

    final community = controller.selectedCommunity!;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _Header(
                community: community.bannerUrlAbsolute,
                avatarUrl: community.avatarUrlAbsolute,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            community.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: _toggleJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: community.isJoined
                                  ? Colors.grey.shade800
                                  : accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              community.isJoined
                                  ? l10n.communityDetailLeaveButton
                                  : l10n.communitiesJoinLabel,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if ((community.categoria ?? '').isNotEmpty)
                      Text(
                        community.categoria!,
                        style: TextStyle(color: accentColor, fontSize: 13),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.groups,
                          size: 15,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.communityDetailMembersCount(
                            community.membersCount,
                          ),
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                    if ((community.ownerUsername ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.communityDetailCreatedByLabel(
                          community.ownerUsername!,
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade500,
                  indicatorColor: accentColor,
                  tabs: [
                    Tab(text: l10n.communityDetailAboutTab),
                    Tab(text: l10n.communityDetailPostsTab),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _AboutTab(
              descripcion: community.descripcion,
              rules: community.rules,
            ),
            _PostsTab(
              identifier: widget.identifier,
              onCreatePost: _openNewPostSheet,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.community, required this.avatarUrl});

  final String? community; // bannerUrl
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2A1B4D), Color(0xFF120F1F)],
            ),
          ),
          child: community != null
              ? ZentryNetworkImage(imageUrl: community!, fit: BoxFit.cover)
              : null,
        ),
        Positioned(
          left: 18,
          bottom: -30,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: ZentryAvatar(
              radius: 32,
              networkUrl: avatarUrl,
              icon: Icons.groups_rounded,
            ),
          ),
        ),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.descripcion, required this.rules});

  final String? descripcion;
  final List<String> rules;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 40),
      children: [
        if ((descripcion ?? '').isNotEmpty) ...[
          Text(
            descripcion!,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 24),
        ],
        if (rules.isNotEmpty) ...[
          Text(
            l10n.communityDetailRulesTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < rules.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rules[i],
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _PostsTab extends StatelessWidget {
  const _PostsTab({required this.identifier, required this.onCreatePost});

  final String identifier;
  final VoidCallback onCreatePost;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final postsController = context.watch<PostsController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onCreatePost,
        icon: const Icon(Icons.add),
        label: Text(l10n.communityDetailNewPostButton),
      ),
      body: _buildBody(context, l10n, postsController),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    PostsController postsController,
  ) {
    if (postsController.communityPostsLoading &&
        postsController.communityPosts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (postsController.communityPostsError != null &&
        postsController.communityPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              postsController.communityPostsError!,
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context
                  .read<PostsController>()
                  .loadCommunityPosts(identifier),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }

    final List<PostResponse> items = postsController.communityPosts;
    if (items.isEmpty) {
      return Center(
        child: Text(
          l10n.communityDetailNoPosts,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<PostsController>().loadCommunityPosts(identifier),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 90),
        itemCount: items.length,
        itemBuilder: (_, i) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: BackendPostCard(
              key: ValueKey('community_post_${items[i].id}'),
              post: items[i],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
