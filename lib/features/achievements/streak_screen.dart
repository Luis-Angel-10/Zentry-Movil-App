import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/providers/engagement_controller.dart';
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
    final engagement = context.watch<EngagementController>();
    final active = engagement.isStreakActiveToday;
    final activity = engagement.weeklyStreakActivity;

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
              gradient: LinearGradient(
                colors: active
                    ? [Colors.deepOrange, Colors.amber]
                    : [Colors.grey.shade900, Colors.grey.shade800],
              ),
            ),
            child: Column(
              children: [
                ScaleTransition(
                  scale: active ? _pulse : const AlwaysStoppedAnimation(1.0),
                  child: Icon(
                    Icons.local_fire_department,
                    color: active ? Colors.white : Colors.white24,
                    size: 84,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.achievementsStreakDaysLabel(engagement.streakCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  active
                      ? l10n.streakScreenActiveToday
                      : l10n.streakScreenInactiveToday,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  Icons.emoji_events,
                  Colors.amber,
                  '${engagement.bestStreak}',
                  l10n.achievementsStreakBestLabel(engagement.bestStreak),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  Icons.bolt,
                  Colors.deepOrange,
                  '+${engagement.todayStreakReward}',
                  l10n.achievementsStreakRewardLabel(
                    engagement.todayStreakReward,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  Icons.stars,
                  Colors.purpleAccent,
                  '${engagement.streakPoints}',
                  l10n.achievementsStreakPointsTotalLabel(
                    engagement.streakPoints,
                  ),
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
