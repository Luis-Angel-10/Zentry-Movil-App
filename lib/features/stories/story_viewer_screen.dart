import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/features/chat/chat_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _maxDuration = Duration(seconds: 30);

  late int _currentIndex;
  late final AnimationController _progressController;
  VideoPlayerController? _videoController;
  int _loadToken = 0;
  bool _videoReady = false;
  bool _muted = false;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _progressController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _goNext();
      });
    _loadStory(_currentIndex);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _videoController?.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _story => widget.stories[_currentIndex];

  bool get _isOwner {
    final me = context.read<AuthController>().currentUser?.displayName;
    return me != null && me == _story["user"];
  }

  Future<void> _confirmDeleteStory() async {
    final l10n = AppLocalizations.of(context)!;
    _pause();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF171725),
        title: Text(
          l10n.storyDeleteConfirmTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.storyDeleteConfirmMessage,
          style: TextStyle(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.commonDelete,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      _resume();
      return;
    }

    final storyId = _story["id"] as String?;
    if (storyId != null) {
      context.read<PostsController>().deleteStory(storyId);
    }
    if (mounted) Navigator.pop(context);
  }

  void _registerView(int index) {
    final story = widget.stories[index];
    final storyId = story["id"] as String?;
    final viewer = context.read<AuthController>().currentUser?.displayName;
    if (storyId == null || viewer == null) return;
    context.read<PostsController>().registerStoryView(storyId, viewer);
  }

  Future<void> _loadStory(int index) async {
    final token = ++_loadToken;

    _registerView(index);

    _progressController.stop();
    _progressController.reset();

    final oldVideoController = _videoController;
    _videoController = null;
    _videoReady = false;
    oldVideoController?.dispose();

    final videoFile = widget.stories[index]["videoFile"] as File?;

    if (videoFile == null) {
      _progressController.duration = _maxDuration;
      if (mounted) setState(() {});
      _progressController.forward(from: 0);
      return;
    }

    final controller = VideoPlayerController.file(videoFile);
    try {
      await controller.initialize();
    } catch (_) {
      if (token != _loadToken) return;
      _progressController.duration = _maxDuration;
      if (mounted) setState(() {});
      _progressController.forward(from: 0);
      return;
    }

    if (token != _loadToken || !mounted) {
      controller.dispose();
      return;
    }

    final videoDuration = controller.value.duration;
    final cappedDuration = videoDuration > _maxDuration
        ? _maxDuration
        : videoDuration;

    _videoController = controller;
    _videoReady = true;
    _progressController.duration = cappedDuration > Duration.zero
        ? cappedDuration
        : _maxDuration;
    controller.setLooping(false);
    controller.setVolume(_muted ? 0 : 1.0);
    controller.play();
    setState(() {});
    _progressController.forward(from: 0);
  }

  void _goNext() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      _loadStory(_currentIndex);
    } else {
      Navigator.pop(context);
    }
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _loadStory(_currentIndex);
    } else {
      _loadStory(_currentIndex);
    }
  }

  void _pause() {
    _progressController.stop();
    _videoController?.pause();
  }

  void _resume() {
    _progressController.forward();
    _videoController?.play();
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      _videoController?.setVolume(_muted ? 0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final File? imageFile = _story["imageFile"] as File?;
    final String content = _story["content"] as String? ?? '';
    final String user = _story["user"] as String? ?? '';
    final String time = _story["time"] as String? ?? '';
    final bool isVideo = _story["videoFile"] != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: isVideo
                  ? (_videoReady && _videoController != null
                        ? _CoverVideo(controller: _videoController!)
                        : const ColoredBox(color: Colors.black))
                  : imageFile != null
                  ? Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _StoryFallback(),
                    )
                  : const _StoryFallback(),
            ),

            if (isVideo && !_videoReady)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white70),
                ),
              ),

            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _goPrevious,
                      onLongPressStart: (_) => _pause(),
                      onLongPressEnd: (_) => _resume(),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _goNext,
                      onLongPressStart: (_) => _pause(),
                      onLongPressEnd: (_) => _resume(),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                children: List.generate(widget.stories.length, (i) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          double fraction;
                          if (i < _currentIndex) {
                            fraction = 1;
                          } else if (i > _currentIndex) {
                            fraction = 0;
                          } else {
                            fraction = _progressController.value;
                          }
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: fraction,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),

            Positioned(
              top: 18,
              left: 4,
              right: 4,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isOwner)
                    IconButton(
                      icon: Icon(
                        _story["highlighted"] == true
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        final storyId = _story["id"] as String?;
                        if (storyId == null) return;
                        context.read<PostsController>().toggleStoryHighlight(
                          storyId,
                        );
                        setState(() {});
                      },
                    ),
                  if (_isOwner)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                      onPressed: _confirmDeleteStory,
                    ),
                  if (isVideo)
                    IconButton(
                      icon: Icon(
                        _muted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: _toggleMute,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            if (content.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 32,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    content,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: SafeArea(
                top: false,
                child: _isOwner ? _viewersBar() : _replyBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewersBar() {
    final l10n = AppLocalizations.of(context)!;
    final storyId = _story["id"] as String?;
    final viewers = storyId == null
        ? const <String>[]
        : context.watch<PostsController>().storyViewers(storyId);

    return GestureDetector(
      onTap: () => _showViewers(viewers, l10n),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  l10n.storyViewersCount(viewers.length),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showViewers(List<String> viewers, AppLocalizations l10n) {
    _pause();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171725),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.storyViewersTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              if (viewers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l10n.storyViewersEmpty,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                )
              else
                ...viewers.map(
                  (name) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: Icon(Icons.person, color: Colors.white54),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).whenComplete(_resume);
  }

  Widget _replyBar() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _replyController,
              onTap: _pause,
              onSubmitted: (_) => _sendReply(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: l10n.storyReplyHint,
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: _sendReply,
        ),
      ],
    );
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    final user = _story["user"] as String? ?? '';
    final l10n = AppLocalizations.of(context)!;
    _replyController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          initialContactName: user,
          initialMessage: l10n.storyReplyMessagePrefix(text),
        ),
      ),
    );
  }
}

class _StoryFallback extends StatelessWidget {
  const _StoryFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
        ),
      ),
    );
  }
}

class _CoverVideo extends StatelessWidget {
  final VideoPlayerController controller;

  const _CoverVideo({required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = controller.value.size;
    if (size.width <= 0 || size.height <= 0) {
      return const ColoredBox(color: Colors.black);
    }

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
