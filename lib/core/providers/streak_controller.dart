import 'package:flutter/material.dart';

import 'package:Zentry/core/models/backend/streak_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/streak_api.dart';

/// Los 4 estados reales que la UI debe distinguir (ver doc-comment de
/// [StreakController.status]).
enum StreakStatus {
  /// El usuario todavía nunca realizó la actividad necesaria.
  neverStarted,

  /// Ya realizó actividad válida hoy.
  activeToday,

  /// Tenía racha ayer y todavía puede conservarla si actúa hoy.
  pendingToday,

  /// Se incumplió la regla temporal: la racha se reinició.
  lost,
}

/// Racha real del usuario (`GET /api/core/streaks/me`) — sobrevive cierre de
/// app, reinstalación y cambio de dispositivo porque vive en el backend
/// (antes era puramente local en `EngagementController`).
///
/// El backend sólo guarda `currentStreak`/`longestStreak`/`lastActivityDate`,
/// sin historial día a día. `weeklyActivity` se deriva de esos 3 campos: sólo
/// marca como activos los días que son parte comprobada de la racha vigente
/// (una racha de N días consecutivos que terminó en `lastActivityDate`
/// garantiza actividad en cada uno de esos N días) — nunca inventa datos.
class StreakController extends ChangeNotifier {
  final StreakApi _api = StreakApi.instance;

  StreakResponse? data;
  bool isLoading = false;

  int get currentStreak => data?.currentStreak ?? 0;
  int get longestStreak => data?.longestStreak ?? 0;
  bool get activeToday => data?.activeToday ?? false;
  DateTime? get lastActivityDate => data?.lastActivityDate;

  /// Estados reales de la racha (corrección: antes la UI sólo distinguía
  /// "activa hoy" vs "0", sin diferenciar "nunca empezada" de "vigente pero
  /// pendiente hoy" de "perdida"). El backend (`StreakService.getStreak`)
  /// YA resetea `currentStreak` a 0 en el momento de leer si
  /// `lastActivityDate` es más viejo que ayer — por eso "perdida" ya viene
  /// reflejada en `currentStreak == 0` sin que Flutter tenga que calcularla;
  /// sólo "nunca empezada" (para no confundirla con "perdida") y "pendiente
  /// hoy" (racha vigente, ayer sí hubo actividad, hoy todavía no) requieren
  /// derivarse aquí, comparando fechas en UTC como hace el backend
  /// (`LocalDate.now(ZoneOffset.UTC)`).
  StreakStatus get status {
    final last = lastActivityDate;
    if (last == null) return StreakStatus.neverStarted;
    if (activeToday) return StreakStatus.activeToday;
    final today = DateTime.now().toUtc();
    final todayDate = DateTime.utc(today.year, today.month, today.day);
    final lastDate = DateTime.utc(last.year, last.month, last.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));
    if (currentStreak > 0 && lastDate == yesterday) {
      return StreakStatus.pendingToday;
    }
    return StreakStatus.lost;
  }

  /// Misma fórmula que usaba `EngagementController.todayStreakReward`, pero
  /// aplicada sobre el `currentStreak` real del backend.
  int get todayReward =>
      currentStreak == 0 ? 0 : (10 + (currentStreak - 1) * 5).clamp(0, 50);

  /// Semana actual de lunes (índice 0) a domingo (índice 6), en el calendario
  /// LOCAL del dispositivo — coincide con las letras L..D de la UI.
  /// 1 = activo / 0 = inactivo.
  ///
  /// `lastActivityDate` es un día UTC (el backend usa
  /// `LocalDate.now(ZoneOffset.UTC)`), así que no se compara directamente con
  /// la fecha local: de noche en América, el día UTC ya es "mañana" y ningún
  /// círculo se encendía. Se calcula cuántos días UTC atrás fue cada día de la
  /// racha y se traslada ese desfase al calendario local.
  List<int> get weeklyActivity {
    final last = data?.lastActivityDate;
    final streak = currentStreak;
    final nowUtc = DateTime.now().toUtc();
    final todayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final now = DateTime.now();
    final todayLocal = DateTime(now.year, now.month, now.day);

    final activeLocalDays = <DateTime>{};
    if (last != null && streak > 0) {
      final lastUtc = DateTime.utc(last.year, last.month, last.day);
      final daysAgo = todayUtc.difference(lastUtc).inDays;
      for (var i = 0; i < streak; i++) {
        final d = todayLocal.subtract(Duration(days: daysAgo + i));
        activeLocalDays.add(DateTime(d.year, d.month, d.day));
      }
    }

    final monday = todayLocal.subtract(Duration(days: todayLocal.weekday - 1));
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return activeLocalDays.contains(DateTime(d.year, d.month, d.day)) ? 1 : 0;
    });
  }

  /// Limpia la racha del usuario que acaba de cerrar sesión — corrección:
  /// sin esto, al cambiar de cuenta SIN reiniciar la app, la UI podía seguir
  /// mostrando la racha del usuario anterior hasta que la petición para el
  /// nuevo usuario respondiera (o indefinidamente si esa petición fallaba,
  /// ver [load]). Se llama desde `AuthController.onSessionCleared`.
  void reset() {
    _generation++;
    data = null;
    isLoading = false;
    notifyListeners();
  }

  /// Se incrementa en cada [reset] y en cada [load]. Una respuesta sólo se
  /// aplica si nadie más empezó otra carga ni limpió la sesión mientras
  /// estaba en vuelo — corrección: si el usuario A cerraba sesión (o se
  /// cambiaba de cuenta) con un `GET /streaks/me` suyo todavía pendiente, esa
  /// respuesta llegaba DESPUÉS del [reset] y dejaba la racha de A visible
  /// para el usuario B en el mismo dispositivo.
  int _generation = 0;

  Future<void> load() async {
    final gen = ++_generation;
    isLoading = true;
    notifyListeners();
    try {
      final result = await _api.getMyStreak();
      if (gen != _generation) return;
      data = result;
    } on ApiException {
      // Sin sesión o sin red: se conserva el último valor conocido (si lo
      // hay) en vez de mostrar un 0 que podría ser falso. Es seguro porque
      // [reset] lo borra al cerrar sesión, así que sólo puede ser del
      // usuario actual.
    } finally {
      if (gen == _generation) {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
