import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/providers/streak_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

const List<String> _kDayLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final streak = context.watch<StreakController>();
    final status = streak.status;
    final activity = streak.weeklyActivity;

    // 4 estados reales (corrección): antes sólo existían "encendida"/"apagada",
    // sin distinguir "nunca empezada" de "vigente pero pendiente hoy" de
    // "perdida" — ver StreakController.status.
    final bool isActive = status == StreakStatus.activeToday;
    final bool isPending = status == StreakStatus.pendingToday;
    final List<Color> gradient = switch (status) {
      StreakStatus.activeToday => [Colors.deepOrange, Colors.amber],
      StreakStatus.pendingToday => [
        Colors.deepOrange.shade900,
        Colors.orange.shade800,
      ],
      StreakStatus.neverStarted ||
      StreakStatus.lost => [Colors.grey.shade900, Colors.grey.shade800],
    };
    final String subtitle = switch (status) {
      StreakStatus.activeToday => l10n.streakScreenActiveToday,
      StreakStatus.pendingToday => l10n.streakScreenPendingToday(
        streak.currentStreak,
      ),
      StreakStatus.neverStarted ||
      StreakStatus.lost => l10n.streakScreenInactiveToday,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.streakScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(colors: gradient),
            ),
            child: Column(
              children: [
                ScaleTransition(
                  scale: isActive ? _pulse : const AlwaysStoppedAnimation(1.0),
                  child: Icon(
                    Icons.local_fire_department,
                    color: isActive
                        ? Colors.white
                        : isPending
                        ? Colors.white70
                        : Colors.white24,
                    size: 84,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.achievementsStreakDaysLabel(streak.currentStreak),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : isPending
                          ? Colors.white70
                          : Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Corrección racha: se quitó la 3ra tarjeta ("puntos de racha
          // acumulados"), que leía `EngagementController.streakPoints` — un
          // contador local en SharedPreferences que sólo avanzaba con
          // like/comentario/publicación (no con seguir, unirse a una
          // comunidad, etc.) y comparaba fechas con la hora LOCAL del
          // dispositivo, mientras el resto de esta pantalla ya usa la racha
          // REAL del backend (hora UTC, cuenta más tipos de actividad). Esa
          // mezcla es lo que hacía ver la racha "bugeada": los días de arriba
          // coincidían con el backend, pero este número no. El backend no
          // expone un total histórico de puntos de racha, así que en vez de
          // inventarlo se deja sólo lo que sí es real: récord y recompensa
          // de hoy.
          Row(
            children: [
              Expanded(
                child: _statCard(
                  Icons.emoji_events,
                  Colors.amber,
                  '${streak.longestStreak}',
                  l10n.achievementsStreakBestLabel(streak.longestStreak),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  Icons.bolt,
                  Colors.deepOrange,
                  '+${streak.todayReward}',
                  l10n.achievementsStreakRewardLabel(streak.todayReward),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF171725),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.streakScreenWeekTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final wasActive = activity[i] == 1;
                    return Column(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: wasActive
                                ? Colors.deepOrange
                                : Colors.white10,
                          ),
                          child: Icon(
                            Icons.local_fire_department,
                            color: wasActive ? Colors.white : Colors.white24,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _kDayLetters[i],
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF171725),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white54),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.streakScreenExplainer,
                    style: TextStyle(color: Colors.grey.shade400, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF171725),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
