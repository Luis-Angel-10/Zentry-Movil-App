import 'dart:async';

/// Serializa la INICIALIZACIÓN de decoders de video en toda la app (feed,
/// fullscreen, stories).
///
/// EVIDENCIA REAL capturada por ADB/logcat en un Huawei MatePad SLG-W09
/// (Kirin T92C, Android 12) mientras se investigaba por qué los mismos
/// videos que funcionan en un teléfono Android fallan en esta tablet:
///
///   - Dos posts con video en el feed (uno H.264 Constrained Baseline
///     1280x840, otro H.264 High Profile 576x768 — perfiles y resoluciones
///     completamente distintos) llamaron a `VideoPlayerController
///     .initialize()` con ~17 ms de diferencia entre sí.
///   - AMBOS decoders (`OMX.hisi.video.decoder.avc`, el decoder AVC por
///     hardware de este SoC) fallaron de forma IDÉNTICA:
///     `DecoderInitializationException` causada por un
///     `IllegalStateException` dentro de `MediaCodec.native_stop`.
///   - El log de `CodecTracker` (servicio propio de Huawei) muestra que el
///     segundo decoder empezó su secuencia CONFIGURING/STARTING mientras el
///     primero SEGUÍA en STARTING (todavía no liberado) — es decir, hubo dos
///     sesiones de decodificación de video solapadas al mismo tiempo.
///
/// Como el fallo ocurre igual sin importar el perfil/resolución del video,
/// la causa real no es de códec: este SoC (gama tablet, no el mismo que un
/// teléfono) sólo soporta de forma fiable UNA sesión de decodificación de
/// video de cada vez. En un teléfono con un decoder más capaz, dos videos
/// inicializándose casi a la vez simplemente funcionan — por eso "los mismos
/// videos se reproducen bien en un teléfono pero fallan en esta tablet".
///
/// La mitigación real (no una suposición): jamás iniciar dos decoders al
/// mismo tiempo. Este coordinador encola las llamadas a `initialize()` de
/// CUALQUIER reproductor de video de la app (feed, fullscreen, stories) para
/// que se ejecuten una detrás de otra, nunca solapadas.
class ZentryVideoDecoderCoordinator {
  ZentryVideoDecoderCoordinator._();
  static final ZentryVideoDecoderCoordinator instance =
      ZentryVideoDecoderCoordinator._();

  Future<void> _chain = Future.value();

  /// Encola [task] (normalmente `controller.initialize()`): espera a que
  /// cualquier inicialización de OTRO video en curso termine (con éxito o
  /// error) antes de empezar la propia. No limita cuántos
  /// `VideoPlayerController` existen en memoria — sólo garantiza que nunca
  /// se le pida al sistema operativo abrir dos decoders al mismo tiempo.
  Future<T> runExclusive<T>(Future<T> Function() task) {
    final previous = _chain;
    final gate = Completer<void>();
    _chain = gate.future;
    return previous.then((_) async {
      try {
        return await task();
      } finally {
        gate.complete();
      }
    });
  }
}
