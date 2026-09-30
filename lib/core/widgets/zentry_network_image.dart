import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Imagen de red rectangular con caché de disco (feed, banners, thumbnails,
/// grids de posts). Reemplaza los usos sueltos de `Image.network` para
/// evitar re-descargar la misma imagen en cada scroll/rebuild.
///
/// Mantiene el mismo comportamiento visual que tenían los sitios migrados:
/// placeholder mientras carga, ícono de imagen rota si falla, y el `fit`
/// que cada uno ya usaba.
class ZentryNetworkImage extends StatelessWidget {
  const ZentryNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.backgroundColor = const Color(0x1AFFFFFF), // Colors.white10
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white24,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
      ),
    );
  }
}

/// Límites de proporción compartidos por imágenes y videos del feed (evita
/// duplicar los mismos números mágicos en dos sitios): una publicación muy
/// panorámica o un video/poster extremadamente vertical se recortan a estos
/// límites en vez de ocupar varias pantallas de scroll completo, tanto en
/// teléfono como en tablet (donde la tarjeta es mucho más ancha).
const double kZentryMediaMinAspectRatio = 0.66;
const double kZentryMediaMaxAspectRatio = 1.91;

/// Imagen de red que respeta su proporción REAL (cuadrada se ve cuadrada,
/// vertical se ve vertical, horizontal se ve horizontal) en vez de forzar un
/// recorte a un rectángulo fijo. Resuelve las dimensiones reales del archivo
/// (una sola vez, vía el `ImageStream` del proveedor ya cacheado por
/// `cached_network_image` — no dispara una descarga nueva) y arma un
/// `AspectRatio` con esa proporción, recortada dentro de [minAspectRatio]/
/// [maxAspectRatio] para que una imagen panorámica o un poster extremadamente
/// alto no ocupe varias pantallas de scroll. Como el contenedor adopta la
/// proporción real de la imagen, `BoxFit.cover` dentro de él no recorta nada
/// salvo en esos casos extremos ya limitados por el clamp.
class ZentryAspectRatioImage extends StatefulWidget {
  const ZentryAspectRatioImage({
    super.key,
    required this.imageUrl,
    this.minAspectRatio = kZentryMediaMinAspectRatio,
    this.maxAspectRatio = kZentryMediaMaxAspectRatio,
    this.borderRadius,
    this.onTap,
  });

  final String imageUrl;
  final double minAspectRatio;
  final double maxAspectRatio;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;

  @override
  State<ZentryAspectRatioImage> createState() => _ZentryAspectRatioImageState();
}

class _ZentryAspectRatioImageState extends State<ZentryAspectRatioImage> {
  double? _ratio;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  void _resolve() {
    final provider = CachedNetworkImageProvider(widget.imageUrl);
    final stream = provider.resolve(const ImageConfiguration());
    final listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (h <= 0) return;
        setState(() {
          _ratio = (w / h).clamp(widget.minAspectRatio, widget.maxAspectRatio);
        });
      },
      onError: (_, _) {
        if (!mounted) return;
        setState(() => _ratio = 1.0);
      },
    );
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  @override
  void didUpdateWidget(covariant ZentryAspectRatioImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      if (_stream != null && _listener != null) {
        _stream!.removeListener(_listener!);
      }
      _ratio = null;
      _resolve();
    }
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: AspectRatio(
        aspectRatio: _ratio ?? 1.0,
        child: ZentryNetworkImage(imageUrl: widget.imageUrl, fit: BoxFit.cover),
      ),
    );
    if (widget.onTap == null) return content;
    return GestureDetector(onTap: widget.onTap, child: content);
  }
}

/// Avatar circular que prioriza una ruta de archivo LOCAL recién elegida por
/// el usuario (picker, aún no subida) sobre la URL de red del backend, con
/// caché de disco para la URL — mismo patrón que ya usaban `profile_screen`/
/// `public_profile_screen` (FileImage local > NetworkImage backend), sólo
/// que ahora la parte de red pasa por caché.
class ZentryAvatar extends StatelessWidget {
  const ZentryAvatar({
    super.key,
    this.localFilePath,
    this.networkUrl,
    this.radius = 20,
    this.backgroundColor,
    this.icon = Icons.person,
    this.iconColor = Colors.white54,
  });

  final String? localFilePath;
  final String? networkUrl;
  final double radius;
  final Color? backgroundColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final hasLocal = localFilePath != null && localFilePath!.isNotEmpty;
    final hasNetwork =
        !hasLocal && networkUrl != null && networkUrl!.isNotEmpty;

    if (hasLocal) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.white10,
        backgroundImage: FileImage(File(localFilePath!)),
      );
    }

    if (hasNetwork) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.white10,
        backgroundImage: CachedNetworkImageProvider(networkUrl!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.white10,
      child: Icon(icon, color: iconColor, size: radius * 0.9),
    );
  }
}
