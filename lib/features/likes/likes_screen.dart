import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/widgets/zentry_network_image.dart';
import 'package:Zentry/features/home/widgets/backend_feed.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

/// Publicaciones a las que el usuario dio like — datos REALES de
/// `GET /api/core/posts/liked/{username}` (corrección: antes esta pantalla
/// mostraba 6 tarjetas 100% inventadas — "Paisaje", "Logo Moderno", etc. —
/// sin relación alguna con el backend).
///
/// LIMITACIÓN documentada (ver reporte): el backend sólo tiene "like" real
/// para `Post` (con endpoint de listado); "Project"/"Story" también se
/// pueden dar like pero NO tienen un endpoint "mis X con like" — y no existe
/// ningún concepto de "Reel" en el backend. Por eso los filtros aquí sólo
/// son "Todos"/"Posts"/"Videos" (ambos reales, por `contentType`) — no se
/// ofrecen filtros de Reels/Historias/Proyectos que siempre estarían vacíos
/// por falta de endpoint, para no simular una función que no existe.
class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

enum _LikesFilter { all, posts, videos }

class _LikesScreenState extends State<LikesScreen> {
  final TextEditingController searchController = TextEditingController();
  _LikesFilter selectedFilter = _LikesFilter.all;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final username = context.read<AuthController>().currentUser?.username;
    if (username == null) return;
    await context.read<PostsController>().loadLikedPosts(username);
  }

  List<PostResponse> _applyFilters(List<PostResponse> posts) {
    final query = searchController.text.trim().toLowerCase();
    return posts.where((p) {
      final matchesFilter = switch (selectedFilter) {
        _LikesFilter.all => true,
        _LikesFilter.posts => p.contentType != 'video',
        _LikesFilter.videos => p.contentType == 'video',
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;
      final haystack =
          '${p.title ?? ''} ${p.content ?? ''} ${p.authorName ?? ''} ${p.authorUsername ?? ''}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final controller = context.watch<PostsController>();
    final filtered = _applyFilters(controller.likedBackendPosts);
    final videoCount = controller.likedBackendPosts
        .where((p) => p.contentType == 'video')
        .length;
    final postCount = controller.likedBackendPosts.length - videoCount;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.likesTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => isSearching = !isSearching),
            icon: Icon(isSearching ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(18),
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
                    controller.likedBackendPosts.length.toString(),
                    l10n.likesTitle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    Icons.article,
                    Colors.blue,
                    postCount.toString(),
                    l10n.likesFilterPosts,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    Icons.video_collection,
                    Colors.orange,
                    videoCount.toString(),
                    l10n.likesFilterReels,
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
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
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
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip(
                    l10n.likesFilterAll,
                    _LikesFilter.all,
                    accentColor,
                  ),
                  const SizedBox(width: 10),
                  _filterChip(
                    l10n.likesFilterPosts,
                    _LikesFilter.posts,
                    accentColor,
                  ),
                  const SizedBox(width: 10),
                  _filterChip(
                    l10n.likesFilterReels,
                    _LikesFilter.videos,
                    accentColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            if (controller.likedPostsLoading && !controller.likedPostsLoaded)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.likedPostsError != null &&
                controller.likedBackendPosts.isEmpty)
              _errorState(controller.likedPostsError!, l10n)
            else if (filtered.isEmpty)
              _emptyState(l10n)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: .72,
                ),
                itemBuilder: (_, index) =>
                    _LikedPostCard(post: filtered[index]),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, _LikesFilter value, Color accentColor) {
    final selected = selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      backgroundColor: const Color(0xff171725),
      selectedColor: accentColor,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.grey.shade400,
      ),
      onSelected: (_) => setState(() => selectedFilter = value),
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
        mainAxisSize: MainAxisSize.min,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String message, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.grey.shade700, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: Text(l10n.commonRetry)),
          ],
        ),
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

class _LikedPostCard extends StatelessWidget {
  const _LikedPostCard({required this.post});
  final PostResponse post;

  @override
  Widget build(BuildContext context) {
    final imageUrl = post.imageUrlAbsolute;
    final isVideo = post.contentType == 'video';

    return GestureDetector(
      onTap: () => _openPost(context),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff171725),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .30),
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
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      ZentryNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
                    else
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.favorite_outline,
                            color: Colors.white24,
                            size: 48,
                          ),
                        ),
                      ),
                    if (isVideo)
                      const Positioned(
                        right: 10,
                        bottom: 10,
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (post.title?.isNotEmpty ?? false)
                          ? post.title!
                          : (post.content ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => openAuthorProfile(context, post),
                      child: Text(
                        post.authorName ?? post.authorUsername ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red.shade400,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likesCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _unlike(context),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 18,
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
    );
  }

  Future<void> _unlike(BuildContext context) async {
    try {
      await context.read<PostsController>().toggleLikeBackend(post.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _openPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8),
            child: BackendPostCard(post: post),
          ),
        ),
      ),
    );
  }
}
