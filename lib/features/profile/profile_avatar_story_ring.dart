import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/features/stories/story_viewer_screen.dart';

/// Envuelve el avatar de un perfil (propio o ajeno) para que, si ese usuario
/// tiene una Story ACTIVA, se indique visualmente (aro degradado, el mismo
/// que ya usa el Home para historias sin ver) y tocarlo abra
/// [StoryViewerScreen] con SUS historias reales. Si no tiene historia
/// activa, se conserva el comportamiento normal indicado en [onNoStory]
/// (editar perfil, o nada).
///
/// Usa `GET /api/core/stories/user/{userId}` (vía
/// `PostsController.loadUserActiveStories`), que el backend ya filtra por
/// "activa" real (`expiresAt > now && !isArchived`) — Flutter no inventa ni
/// asume nada sobre expiración.
class ProfileAvatarStoryRing extends StatefulWidget {
  const ProfileAvatarStoryRing({
    super.key,
    required this.userId,
    required this.displayName,
    required this.username,
    required this.child,
    this.avatarUrl,
    this.onNoStory,
    this.fallbackGradient,
  });

  final int userId;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final Widget child;
  final VoidCallback? onNoStory;

  /// Degradado a usar cuando NO hay historia activa (p. ej. el marco de
  /// logro/avatar que ya tenía la pantalla). Si es null, no se dibuja aro.
  final List<Color>? fallbackGradient;

  @override
  State<ProfileAvatarStoryRing> createState() => _ProfileAvatarStoryRingState();
}

class _ProfileAvatarStoryRingState extends State<ProfileAvatarStoryRing> {
  List<Map<String, dynamic>>? _stories;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProfileAvatarStoryRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _stories = null;
      _load();
    }
  }

  Future<void> _load() async {
    if (widget.userId <= 0) {
      setState(() => _stories = const []);
      return;
    }
    try {
      final viewerName =
          context.read<AuthController>().currentUser?.displayName ?? '';
      final stories = await context
          .read<PostsController>()
          .loadUserActiveStories(
            widget.userId,
            displayName: widget.displayName,
            username: widget.username,
            avatarUrl: widget.avatarUrl,
            viewerDisplayName: viewerName,
          );
      if (!mounted) return;
      setState(() => _stories = stories);
    } catch (_) {
      if (!mounted) return;
      setState(() => _stories = const []);
    }
  }

  void _handleTap() {
    final stories = _stories;
    if (stories != null && stories.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoryViewerScreen(stories: stories, initialIndex: 0),
        ),
      );
      return;
    }
    widget.onNoStory?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveStory = _stories?.isNotEmpty ?? false;
    final gradient = hasActiveStory
        ? const [Color(0xFF8B5CF6), Color(0xFFD946EF)]
        : widget.fallbackGradient;

    return GestureDetector(
      onTap: _handleTap,
      child: gradient == null
          ? widget.child
          : Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: gradient),
              ),
              child: widget.child,
            ),
    );
  }
}
