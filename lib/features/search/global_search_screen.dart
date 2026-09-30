import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/models/community.dart';
import 'package:Zentry/core/models/zentry_category.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/profile_api.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/widgets/zentry_network_image.dart';
import 'package:Zentry/features/communities/community_detail_screen.dart';
import 'package:Zentry/features/explore/category_detail_screen.dart';
import 'package:Zentry/features/profile/public_profile_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final TabController _tabController;

  String _query = '';
  List<AppUser> _users = [];
  bool _loadingUsers = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Búsqueda REAL de usuarios (`GET /api/core/profiles/search?q=`, público).
  ///
  /// `ProfileResponse` no incluye el ID numérico del usuario (limitación del
  /// backend actual — ver reporte), así que los resultados de búsqueda se
  /// construyen con `id: 0` como centinela: `PublicProfileScreen` lo
  /// interpreta como "perfil real pero sin ID resuelto todavía" y deshabilita
  /// sólo el botón de Mensaje directo hasta que haya una relación (amistad)
  /// que sí traiga el ID. Seguir y enviar solicitud de amistad funcionan de
  /// inmediato porque ambos aceptan `username`.
  Future<void> _runSearch(String query) async {
    setState(() {
      _query = query;
      _loadingUsers = true;
    });

    final myUsername = context
        .read<AuthController>()
        .currentUser
        ?.username
        .toLowerCase();

    try {
      final profiles = await ProfileApi.instance.searchProfiles(query);
      if (!mounted) return;
      setState(() {
        _users = profiles
            .where((p) => p.username.toLowerCase() != myUsername)
            .map(
              (p) => AppUser(
                id: 0,
                fullName: (p.name?.isNotEmpty ?? false) ? p.name! : p.username,
                username: p.username,
                email: '',
                artistName: p.artisticName,
                discipline: p.discipline,
                bio: p.bio,
              ),
            )
            .toList();
        _loadingUsers = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() {
        _users = [];
        _loadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final posts = context.watch<PostsController>().posts;
    final communities = context.watch<CommunityController>().communities;

    final q = _query.trim().toLowerCase();
    final isHashtag = q.startsWith('#');
    final tag = isHashtag ? q.substring(1) : q;

    final matchingPosts = q.isEmpty
        ? <Map<String, dynamic>>[]
        : posts.where((p) {
            final content = (p["content"] as String? ?? '').toLowerCase();
            final user = (p["user"] as String? ?? '').toLowerCase();
            return content.contains(q) || user.contains(q);
          }).toList();

    final matchingProjects = q.isEmpty
        ? <Map<String, dynamic>>[]
        : posts.where((p) {
            final category = (p["category"] as String? ?? '');
            if (category != l10n.createTabProject &&
                category != l10n.createTabCollaboration) {
              return false;
            }
            final title = (p["title"] as String? ?? '').toLowerCase();
            final content = (p["content"] as String? ?? '').toLowerCase();
            return title.contains(q) || content.contains(q);
          }).toList();

    final matchingCommunities = q.isEmpty
        ? <Community>[]
        : communities.where((c) {
            if (isHashtag) {
              return c.hashtags.any((h) => h.toLowerCase().contains(tag));
            }
            return c.name.toLowerCase().contains(q) ||
                c.description.toLowerCase().contains(q) ||
                c.categoryName.toLowerCase().contains(q) ||
                (c.subcategoryName ?? '').toLowerCase().contains(q) ||
                c.hashtags.any((h) => h.toLowerCase().contains(q));
          }).toList();

    final matchingCategories = q.isEmpty || isHashtag
        ? <CategoryMatch>[]
        : searchZentryCategories(q);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _runSearch,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.searchScreenHint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: InputBorder.none,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade500,
          tabs: [
            Tab(text: l10n.searchTabAll),
            Tab(text: l10n.searchTabUsers),
            Tab(text: l10n.searchTabPosts),
            Tab(text: l10n.searchTabCommunities),
            Tab(text: l10n.searchTabProjects),
            Tab(text: l10n.searchTabCategories),
          ],
        ),
      ),
      body: q.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  l10n.searchEmptyHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _AllResultsTab(
                  users: _users,
                  posts: matchingPosts,
                  communities: matchingCommunities,
                  projects: matchingProjects,
                  categories: matchingCategories,
                  loadingUsers: _loadingUsers,
                ),
                _UsersTab(users: _users, loading: _loadingUsers),
                _PostsTab(posts: matchingPosts),
                _CommunitiesTab(communities: matchingCommunities),
                _PostsTab(posts: matchingProjects, isProjectsTab: true),
                _CategoriesTab(matches: matchingCategories),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}

Widget _userTile(BuildContext context, AppUser user) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.white10,
      backgroundImage: user.photoPath != null
          ? FileImage(File(user.photoPath!))
          : null,
      child: user.photoPath == null
          ? const Icon(Icons.person, color: Colors.white54)
          : null,
    ),
    title: Text(user.displayName, style: const TextStyle(color: Colors.white)),
    subtitle: Text(
      '@${user.username}',
      style: TextStyle(color: Colors.grey.shade500),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PublicProfileScreen(user: user)),
      );
    },
  );
}

Widget _postTile(BuildContext context, Map<String, dynamic> post) {
  final imageFile = post["imageFile"] as File?;
  final imageUrl = post["image"] as String?;

  return ListTile(
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 46,
        height: 46,
        child: imageFile != null
            ? Image.file(
                imageFile,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Colors.white10),
              )
            : imageUrl != null
            ? ZentryNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
            : const ColoredBox(
                color: Colors.white10,
                child: Icon(Icons.article_outlined, color: Colors.white38),
              ),
      ),
    ),
    title: Text(
      (post["title"] as String?)?.isNotEmpty == true
          ? post["title"] as String
          : (post["content"] as String? ?? ''),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Colors.white),
    ),
    subtitle: Text(
      '${post["user"]} · ${post["category"]}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.grey.shade500),
    ),
  );
}

Widget _communityTile(BuildContext context, Community community) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.white10,
      backgroundImage: community.iconPath != null
          ? FileImage(File(community.iconPath!))
          : null,
      child: community.iconPath == null
          ? const Icon(Icons.groups_rounded, color: Colors.white54)
          : null,
    ),
    title: Text(community.name, style: const TextStyle(color: Colors.white)),
    subtitle: Text(
      community.categoryName,
      style: TextStyle(color: Colors.grey.shade500),
    ),
    trailing: Icon(
      community.isPrivate ? Icons.lock_outline : Icons.public,
      color: Colors.grey.shade500,
      size: 18,
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityDetailScreen(identifier: community.id),
        ),
      );
    },
  );
}

Widget _categoryTile(BuildContext context, CategoryMatch match) {
  return ListTile(
    leading: Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: match.group.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(match.group.emoji, style: const TextStyle(fontSize: 18)),
    ),
    title: Text(match.subcategory, style: const TextStyle(color: Colors.white)),
    subtitle: Text(
      match.group.name,
      style: TextStyle(color: Colors.grey.shade500),
    ),
    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDetailScreen(
            group: match.group,
            initialSubcategory: match.subcategory,
          ),
        ),
      );
    },
  );
}

class _AllResultsTab extends StatelessWidget {
  final List<AppUser> users;
  final List<Map<String, dynamic>> posts;
  final List<Community> communities;
  final List<Map<String, dynamic>> projects;
  final List<CategoryMatch> categories;
  final bool loadingUsers;

  const _AllResultsTab({
    required this.users,
    required this.posts,
    required this.communities,
    required this.projects,
    required this.categories,
    required this.loadingUsers,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasAny =
        users.isNotEmpty ||
        posts.isNotEmpty ||
        communities.isNotEmpty ||
        projects.isNotEmpty ||
        categories.isNotEmpty;

    if (!hasAny && !loadingUsers) {
      return Center(
        child: Text(
          l10n.searchNoResults,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView(
      children: [
        if (users.isNotEmpty) ...[
          _SectionHeader(l10n.searchSectionUsers),
          for (final u in users.take(3)) _userTile(context, u),
        ],
        if (communities.isNotEmpty) ...[
          _SectionHeader(l10n.searchSectionCommunities),
          for (final c in communities.take(3)) _communityTile(context, c),
        ],
        if (posts.isNotEmpty) ...[
          _SectionHeader(l10n.searchSectionPosts),
          for (final p in posts.take(3)) _postTile(context, p),
        ],
        if (projects.isNotEmpty) ...[
          _SectionHeader(l10n.searchSectionProjects),
          for (final p in projects.take(3)) _postTile(context, p),
        ],
        if (categories.isNotEmpty) ...[
          _SectionHeader(l10n.searchSectionCategories),
          for (final m in categories.take(3)) _categoryTile(context, m),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

class _UsersTab extends StatelessWidget {
  final List<AppUser> users;
  final bool loading;

  const _UsersTab({required this.users, required this.loading});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (loading) return const Center(child: CircularProgressIndicator());
    if (users.isEmpty) {
      return Center(
        child: Text(
          l10n.searchNoResults,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }
    return ListView(children: [for (final u in users) _userTile(context, u)]);
  }
}

class _PostsTab extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final bool isProjectsTab;

  const _PostsTab({required this.posts, this.isProjectsTab = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (posts.isEmpty) {
      return Center(
        child: Text(
          l10n.searchNoResults,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }
    return ListView(children: [for (final p in posts) _postTile(context, p)]);
  }
}

class _CommunitiesTab extends StatelessWidget {
  final List<Community> communities;
  const _CommunitiesTab({required this.communities});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (communities.isEmpty) {
      return Center(
        child: Text(
          l10n.searchNoResults,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }
    return ListView(
      children: [for (final c in communities) _communityTile(context, c)],
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  final List<CategoryMatch> matches;
  const _CategoriesTab({required this.matches});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (matches.isEmpty) {
      return Center(
        child: Text(
          l10n.searchNoResults,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }
    return ListView(
      children: [for (final m in matches) _categoryTile(context, m)],
    );
  }
}
