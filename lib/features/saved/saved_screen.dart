import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/widgets/zentry_network_image.dart';
import 'package:Zentry/features/home/widgets/backend_feed.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

/// Publicaciones guardadas — datos REALES de
/// `GET /api/core/posts/saved/{username}`.
///
/// CORRECCIÓN: la versión anterior de esta pantalla era, en su mayoría, una
/// función de "colecciones/carpetas" (Favoritos, Inspiración, UI/UX...) con
/// contadores y tamaños de almacenamiento ("128", "2.8 GB") 100% inventados
/// — el backend no tiene ningún concepto de colección para guardados
/// (`Bookmark` es sólo `id/userId/postId`, confirmado por lectura del
/// backend). Se reemplazó por una cuadrícula real de posts guardados, igual
/// que Likes, sin simular una función que no existe.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final TextEditingController searchController = TextEditingController();
  bool searching = false;

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
    await context.read<PostsController>().loadSavedPosts(username);
  }

  List<PostResponse> _applySearch(List<PostResponse> posts) {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return posts;
    return posts.where((p) {
      final haystack =
          '${p.title ?? ''} ${p.content ?? ''} ${p.authorName ?? ''} ${p.authorUsername ?? ''}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<PostsController>();
    final filtered = _applySearch(controller.savedBackendPosts);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.savedScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => searching = !searching),
            icon: Icon(searching ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              l10n.savedScreenTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.savedPostsSectionTitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
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
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            if (controller.savedPostsLoading && !controller.savedPostsLoaded)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.savedPostsError != null &&
                controller.savedBackendPosts.isEmpty)
              _errorState(controller.savedPostsError!, l10n)
            else if (filtered.isEmpty)
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
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: .72,
                ),
                itemBuilder: (_, index) =>
                    _SavedPostCard(post: filtered[index]),
              ),
            const SizedBox(height: 30),
          ],
        ),
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
}

class _SavedPostCard extends StatelessWidget {
  const _SavedPostCard({required this.post});
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
                            Icons.bookmark_outline,
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
                        // Desguardar aquí actualiza la UI de inmediato
                        // (Sección 12): `toggleBookmarkBackend` quita este
                        // post de `savedBackendPosts` en cuanto el backend
                        // confirma, sin esperar a un refresh manual.
                        GestureDetector(
                          onTap: () => _unsave(context),
                          child: const Icon(
                            Icons.bookmark,
                            color: Colors.amber,
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

  Future<void> _unsave(BuildContext context) async {
    try {
      await context.read<PostsController>().toggleBookmarkBackend(post.id);
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
