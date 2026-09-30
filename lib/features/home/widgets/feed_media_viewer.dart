import 'package:flutter/material.dart';

import 'package:Zentry/core/widgets/zentry_network_image.dart';

/// Visor a pantalla completa para imágenes del feed (fondo oscuro, zoom con
/// pellizco, doble tap para zoom, pan cuando hay zoom, deslizar entre varias
/// imágenes del mismo post). Reutiliza [ZentryNetworkImage] para que la
/// imagen ya cacheada por `cached_network_image` no se vuelva a descargar al
/// abrir el visor.
class FeedImageViewer extends StatefulWidget {
  const FeedImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<FeedImageViewer> createState() => _FeedImageViewerState();
}

class _FeedImageViewerState extends State<FeedImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, index) {
              return _ZoomableImage(imageUrl: widget.imageUrls[index]);
            },
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              top: 45,
              right: 20,
              child: Text(
                '${_currentIndex + 1}/${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({required this.imageUrl});
  final String imageUrl;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;
  late final AnimationController _animController;
  Animation<Matrix4>? _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
        )..addListener(() {
          if (_zoomAnimation != null) {
            _transformController.value = _zoomAnimation!.value;
          }
        });
  }

  @override
  void dispose() {
    _animController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _onDoubleTapDown(TapDownDetails details) => _doubleTapDetails = details;

  void _onDoubleTap() {
    final isZoomedIn = _transformController.value != Matrix4.identity();
    final endMatrix = isZoomedIn
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -(_doubleTapDetails?.localPosition.dx ?? 0) * 1.8,
              -(_doubleTapDetails?.localPosition.dy ?? 0) * 1.8,
              0,
              1,
            )
            ..scaleByDouble(2.8, 2.8, 2.8, 1));
    _zoomAnimation = Matrix4Tween(
      begin: _transformController.value,
      end: endMatrix,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onDoubleTapDown: _onDoubleTapDown,
        onDoubleTap: _onDoubleTap,
        child: InteractiveViewer(
          transformationController: _transformController,
          minScale: 1,
          maxScale: 5,
          child: ZentryNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
