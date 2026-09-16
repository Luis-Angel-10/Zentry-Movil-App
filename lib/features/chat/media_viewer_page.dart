import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:video_player/video_player.dart';

import 'package:Zentry/l10n/generated/app_localizations.dart';

class MediaViewerPage extends StatefulWidget {
  final List<File> files;
  final int initialIndex;
  final bool isVideo;

  final String Function(int index)? heroTagFor;

  const MediaViewerPage({
    super.key,
    required this.files,
    required this.initialIndex,
    required this.isVideo,
    this.heroTagFor,
  });

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late PageController pageController;

  int currentIndex = 0;
  double _dragOffset = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;

    pageController = PageController(initialPage: currentIndex);
  }

  String _tagFor(int index) =>
      widget.heroTagFor?.call(index) ?? 'media_viewer_$index';

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0, 320);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset > 110 || details.velocity.pixelsPerSecond.dy > 700) {
      Navigator.pop(context);
      return;
    }
    setState(() => _dragOffset = 0);
  }

  Future<void> _save(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      final result = await OpenFilex.open(widget.files[currentIndex].path);
      if (!mounted) return;
      final ok = result.type == ResultType.done;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              ok ? l10n.chatMediaSavedSuccess : l10n.chatMediaSaveError,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.chatMediaSaveError),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragOffset / 320).clamp(0.0, 1.0);
    final scale = 1 - progress * 0.14;
    final opacity = 1 - progress * 0.6;

    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(opacity.clamp(0.35, 1.0)),
        body: Stack(
          children: [
            Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Transform.scale(
                scale: scale,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: widget.files.length,
                  onPageChanged: (index) {
                    setState(() => currentIndex = index);
                  },
                  itemBuilder: (_, index) {
                    final file = widget.files[index];

                    if (widget.isVideo) {
                      return Center(
                        child: Hero(
                          tag: _tagFor(index),
                          child: FullScreenVideo(file: file),
                        ),
                      );
                    }

                    return Hero(
                      tag: _tagFor(index),
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 5,
                        child: Center(
                          child: Image.file(file, fit: BoxFit.contain),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Positioned(
              top: 45,
              right: 20,
              child: Text(
                "${currentIndex + 1}/${widget.files.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  color: Colors.black45,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: _saving ? null : () => _save(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.download_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.chatMediaSaveButton,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reproductor de video a pantalla completa. Componente reutilizable: acepta
/// un archivo local ([file], usado por el chat) o una URL de red
/// ([networkUrl], usado por publicaciones del feed con video). Incluye
/// aspect ratio correcto, play/pause, barra de progreso con scrubbing,
/// duración/posición, mute/unmute, indicador de buffering y manejo de error.
class FullScreenVideo extends StatefulWidget {
  final File? file;
  final String? networkUrl;
  final bool autoplay;

  const FullScreenVideo({
    super.key,
    this.file,
    this.networkUrl,
    this.autoplay = true,
  }) : assert(
         file != null || networkUrl != null,
         'Se requiere file o networkUrl',
       );

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  VideoPlayerController? controller;
  bool showControls = true;
  bool _error = false;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final c = widget.file != null
        ? VideoPlayerController.file(widget.file!)
        : VideoPlayerController.networkUrl(Uri.parse(widget.networkUrl!));
    controller = c;
    c.addListener(_onTick);
    try {
      await c.initialize();
      if (!mounted) return;
      if (widget.autoplay) c.play();
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = true);
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _toggleMute() {
    final c = controller;
    if (c == null) return;
    setState(() {
      _muted = !_muted;
      c.setVolume(_muted ? 0 : 1);
    });
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white54, size: 40),
            SizedBox(height: 10),
            Text(
              'No se pudo reproducir el video',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    final c = controller;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () => setState(() => showControls = !showControls),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c)),

          if (c.value.isBuffering)
            const CircularProgressIndicator(color: Colors.white70),

          if (showControls && !c.value.isBuffering)
            GestureDetector(
              onTap: () {
                c.value.isPlaying ? c.pause() : c.play();
                setState(() {});
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  c.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 45,
                ),
              ),
            ),

          if (showControls)
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                onPressed: _toggleMute,
                icon: Icon(
                  _muted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
              ),
            ),

          if (showControls)
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VideoProgressIndicator(
                    c,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    colors: const VideoProgressColors(
                      playedColor: Colors.white,
                      bufferedColor: Colors.white30,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmt(c.value.position),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _fmt(c.value.duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.removeListener(_onTick);
    controller?.dispose();
    super.dispose();
  }
}
