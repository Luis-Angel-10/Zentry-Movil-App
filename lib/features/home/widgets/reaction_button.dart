import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Zentry/l10n/generated/app_localizations.dart';

/// Una de las 6 reacciones de Zentry (Fase 10 del reporte de integración).
///
/// `labelKey` es un identificador interno (no texto mostrado): la etiqueta
/// real se resuelve vía [zentryReactionLabel] con el `AppLocalizations` del
/// `BuildContext` de cada `Tooltip`, porque esta lista es `const` y no puede
/// depender del idioma activo.
class ZentryReaction {
  const ZentryReaction(this.emoji, this.labelKey);
  final String emoji;
  final String labelKey;
}

const List<ZentryReaction> kZentryReactions = [
  ZentryReaction('👍', 'like'),
  ZentryReaction('❤️', 'love'),
  ZentryReaction('😂', 'haha'),
  ZentryReaction('😮', 'wow'),
  ZentryReaction('🔥', 'fire'),
  ZentryReaction('🎨', 'creative'),
];

String zentryReactionLabel(AppLocalizations l10n, String labelKey) {
  switch (labelKey) {
    case 'like':
      return l10n.reactionLike;
    case 'love':
      return l10n.reactionLove;
    case 'haha':
      return l10n.reactionHaha;
    case 'wow':
      return l10n.reactionWow;
    case 'fire':
      return l10n.reactionFire;
    case 'creative':
      return l10n.reactionCreative;
    default:
      return labelKey;
  }
}

const String kDefaultReactionEmoji = '❤️';

/// Botón de reacción de una publicación.
///
/// * Toque rápido -> alterna la reacción predeterminada (❤️ Me encanta),
///   igual que el corazón de siempre.
/// * Pulsación prolongada -> abre un selector flotante animado con las 6
///   reacciones de Zentry (entrada escalonada, rebote suave, haptics).
///
/// *** Límite real del backend (ver reporte final) ***
/// `PostLike`/`POST /api/core/posts/{id}/like` sólo guardan un like/unlike
/// booleano, sin tipo de reacción ni desglose por tipo. Por eso:
///   - elegir CUALQUIER reacción marca el post como "like" de verdad contra
///     el backend (el contador que se ve es siempre real);
///   - el emoji concreto mostrado en el botón es SOLO visual/local: no se
///     persiste por tipo, así que se pierde al recargar el post (por eso no
///     se reconstruye desde `PostResponse`, que no trae esa información).
class ReactionButton extends StatefulWidget {
  const ReactionButton({
    super.key,
    required this.likes,
    required this.initialLiked,
    this.onToggle,
    this.onLiked,
  });

  final int likes;
  final bool initialLiked;

  /// Se llama cuando el estado de like real (booleano) debe cambiar en el
  /// backend — igual contrato que el corazón anterior.
  final ValueChanged<bool>? onToggle;

  /// Se llama sólo al pasar de "sin reacción" a "con reacción" (para
  /// contadores de engagement locales), nunca al sólo cambiar el emoji.
  final VoidCallback? onLiked;

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton>
    with SingleTickerProviderStateMixin {
  late bool _liked = widget.initialLiked;
  String _emoji = kDefaultReactionEmoji;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  /// Pequeño "pop" en el propio botón al confirmar una selección del
  /// selector (además de la animación del selector en sí).
  late final AnimationController _popController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _pop = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 60),
  ]).animate(CurvedAnimation(parent: _popController, curve: Curves.easeOut));

  @override
  void dispose() {
    _removeOverlay();
    _popController.dispose();
    super.dispose();
  }

  void _playPop() {
    _popController.forward(from: 0);
  }

  void _toggleDefault() {
    HapticFeedback.lightImpact();
    final wasLiked = _liked;
    setState(() {
      _liked = !_liked;
      _emoji = kDefaultReactionEmoji;
    });
    if (_liked) _playPop();
    widget.onToggle?.call(_liked);
    if (!wasLiked) widget.onLiked?.call();
  }

  void _pick(String emoji) {
    _removeOverlay();
    if (_liked && emoji == _emoji) {
      // Elegir la reacción ya activa la quita (permite "quitarla").
      HapticFeedback.selectionClick();
      setState(() => _liked = false);
      widget.onToggle?.call(false);
      return;
    }
    HapticFeedback.mediumImpact();
    final wasLiked = _liked;
    setState(() {
      _liked = true;
      _emoji = emoji;
    });
    _playPop();
    if (!wasLiked) {
      widget.onToggle?.call(true);
      widget.onLiked?.call();
    }
    // Si ya estaba liked y sólo cambió el emoji mostrado, no hay nada que
    // reenviar: para el backend sigue siendo el mismo like booleano.
  }

  void _showPicker() {
    if (_overlayEntry != null) return;
    HapticFeedback.selectionClick();

    // Evita que el selector se salga por el borde derecho: si el botón está
    // en la mitad derecha de la pantalla, el selector se ancla hacia la
    // izquierda en vez de hacia la derecha.
    final box = context.findRenderObject() as RenderBox?;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonCenterX = box != null
        ? (box.localToGlobal(Offset.zero).dx + box.size.width / 2)
        : 0.0;
    final openTowardsRight = buttonCenterX < screenWidth / 2;

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _ReactionPickerOverlay(
        layerLink: _layerLink,
        openTowardsRight: openTowardsRight,
        onSelect: _pick,
        onDismiss: _removeOverlay,
      ),
    );
    _overlayEntry = entry;
    overlay.insert(entry);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDefault,
        onLongPress: _showPicker,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _pop,
          builder: (context, child) => Transform.scale(
            scale: _liked ? _pop.value.clamp(1.0, 1.35) : 1,
            child: child,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: _liked
                    ? Text(
                        _emoji,
                        key: ValueKey(_emoji),
                        style: const TextStyle(fontSize: 20),
                      )
                    : const Icon(
                        Icons.favorite_border,
                        key: ValueKey('empty'),
                        color: Colors.white70,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.likes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionPickerOverlay extends StatefulWidget {
  const _ReactionPickerOverlay({
    required this.layerLink,
    required this.openTowardsRight,
    required this.onSelect,
    required this.onDismiss,
  });

  final LayerLink layerLink;
  final bool openTowardsRight;
  final ValueChanged<String> onSelect;
  final VoidCallback onDismiss;

  @override
  State<_ReactionPickerOverlay> createState() => _ReactionPickerOverlayState();
}

class _ReactionPickerOverlayState extends State<_ReactionPickerOverlay>
    with SingleTickerProviderStateMixin {
  static const _entranceDuration = Duration(milliseconds: 260);
  static const _exitDuration = Duration(milliseconds: 140);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _entranceDuration,
    reverseDuration: _exitDuration,
  )..forward();

  bool _dismissing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Cierre suave: reproduce la animación en reversa (fade+scale hacia
  /// afuera) y sólo entonces quita el `OverlayEntry` — evita el "salto"
  /// abrupto que tenía cerrar de golpe.
  Future<void> _dismiss(VoidCallback afterSelect) async {
    if (_dismissing) return;
    _dismissing = true;
    afterSelect();
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final containerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );

    return Stack(
      children: [
        // Cierra el selector al tocar fuera (Fase 11).
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _dismiss(() {}),
          ),
        ),
        CompositedTransformFollower(
          link: widget.layerLink,
          targetAnchor: widget.openTowardsRight
              ? Alignment.topLeft
              : Alignment.topRight,
          followerAnchor: widget.openTowardsRight
              ? Alignment.bottomLeft
              : Alignment.bottomRight,
          offset: const Offset(0, -14),
          child: FadeTransition(
            opacity: containerFade,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF20202A),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(kZentryReactions.length, (i) {
                    // Entrada escalonada (stagger): cada emoji arranca un
                    // poco después del anterior, con un ligero rebote.
                    final start = i * 0.08;
                    final end = (start + 0.5).clamp(0.0, 1.0);
                    final itemAnim = CurvedAnimation(
                      parent: _controller,
                      curve: Interval(start, end, curve: Curves.easeOutBack),
                    );
                    return _ReactionOption(
                      reaction: kZentryReactions[i],
                      entrance: itemAnim,
                      onTap: () => _dismiss(
                        () => widget.onSelect(kZentryReactions[i].emoji),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReactionOption extends StatefulWidget {
  const _ReactionOption({
    required this.reaction,
    required this.entrance,
    required this.onTap,
  });

  final ZentryReaction reaction;
  final Animation<double> entrance;
  final VoidCallback onTap;

  @override
  State<_ReactionOption> createState() => _ReactionOptionState();
}

class _ReactionOptionState extends State<_ReactionOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: zentryReactionLabel(
        AppLocalizations.of(context)!,
        widget.reaction.labelKey,
      ),
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          setState(() => _pressed = true);
        },
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        // Área táctil >= 44x44 (Fase 11: "tamaño táctil adecuado").
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: ScaleTransition(
              scale: widget.entrance,
              child: FadeTransition(
                opacity: widget.entrance,
                child: AnimatedScale(
                  scale: _pressed ? 1.45 : 1,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  child: Text(
                    widget.reaction.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
