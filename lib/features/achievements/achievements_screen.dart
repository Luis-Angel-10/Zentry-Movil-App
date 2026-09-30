import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/achievement.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/providers/streak_controller.dart';
import 'package:Zentry/features/achievements/ranks_screen.dart';
import 'package:Zentry/features/achievements/streak_screen.dart';
import 'package:Zentry/features/challenges/challenges_screen.dart';
import 'package:Zentry/features/store/store_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

enum _AchievementFilter { all, unlocked, locked }

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  _AchievementFilter _filter = _AchievementFilter.all;

  late final AnimationController _entranceController;
  late final Animation<double> _streakFade;
  late final Animation<double> _streakScale;

  late final AnimationController _pulseController;
  late final Animation<double> _flamePulse;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _streakFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.7, curve: Curves.easeOut),
    );

    _streakScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 1, curve: Curves.easeOutBack),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _flamePulse = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _titleFor(AppLocalizations l10n, String id) {
    switch (id) {
      case 'like_1':
        return l10n.achievementsLike1Title;
      case 'like_5':
        return l10n.achievementsLike5Title;
      case 'like_25':
        return l10n.achievementsLike25Title;
      case 'like_100':
        return l10n.achievementsLike100Title;
      case 'streak_3':
        return l10n.achievementsStreak3Title;
      case 'streak_7':
        return l10n.achievementsStreak7Title;
      case 'streak_30':
        return l10n.achievementsStreak30Title;
      case 'posts_1':
        return l10n.achievementsPosts1Title;
      case 'posts_10':
        return l10n.achievementsPosts10Title;
      case 'posts_50':
        return l10n.achievementsPosts50Title;
      case 'comments_10':
        return l10n.achievementsComments10Title;
      case 'comments_50':
        return l10n.achievementsComments50Title;
      case 'saves_10':
        return l10n.achievementsSaves10Title;
      case 'shares_10':
        return l10n.achievementsShares10Title;
    }
    throw ArgumentError('Unknown achievement id: $id');
  }

  String _descFor(AppLocalizations l10n, String id) {
    switch (id) {
      case 'like_1':
        return l10n.achievementsLike1Desc;
      case 'like_5':
        return l10n.achievementsLike5Desc;
      case 'like_25':
        return l10n.achievementsLike25Desc;
      case 'like_100':
        return l10n.achievementsLike100Desc;
      case 'streak_3':
        return l10n.achievementsStreak3Desc;
      case 'streak_7':
        return l10n.achievementsStreak7Desc;
      case 'streak_30':
        return l10n.achievementsStreak30Desc;
      case 'posts_1':
        return l10n.achievementsPosts1Desc;
      case 'posts_10':
        return l10n.achievementsPosts10Desc;
      case 'posts_50':
        return l10n.achievementsPosts50Desc;
      case 'comments_10':
        return l10n.achievementsComments10Desc;
      case 'comments_50':
        return l10n.achievementsComments50Desc;
      case 'saves_10':
        return l10n.achievementsSaves10Desc;
      case 'shares_10':
        return l10n.achievementsShares10Desc;
    }
    throw ArgumentError('Unknown achievement id: $id');
  }

  String _rarityFor(AppLocalizations l10n, String id) {
    switch (id) {
      case 'like_1':
      case 'like_5':
      case 'streak_3':
      case 'posts_1':
      case 'saves_10':
      case 'shares_10':
        return l10n.achievementsRarityCommon;
      case 'like_25':
      case 'streak_7':
      case 'posts_10':
      case 'comments_10':
        return l10n.achievementsRarityRare;
      case 'like_100':
      case 'posts_50':
      case 'comments_50':
        return l10n.achievementsRarityEpic;
      case 'streak_30':
        return l10n.achievementsRarityLegendary;
    }
    throw ArgumentError('Unknown achievement id: $id');
  }

  String _rankFor(AppLocalizations l10n, int points) {
    return _rankLabel(l10n, currentRank(points).id);
  }

  String _rankLabel(AppLocalizations l10n, String id) {
    switch (id) {
      case 'master':
        return l10n.achievementsRankMaster;
      case 'diamond':
        return l10n.achievementsRankDiamond;
      case 'platinum':
        return l10n.achievementsRankPlatinum;
      case 'gold':
        return l10n.achievementsRankGold;
      case 'silver':
        return l10n.achievementsRankSilver;
      default:
        return l10n.achievementsRankBronze;
    }
  }

  /// Corrección racha: los logros de tipo `streak` (streak_3/7/30) ya NO se
  /// evalúan contra `EngagementController.streakCount` (contador local en
  /// SharedPreferences, que sólo avanza cuando se llama a `registerLike`/
  /// `registerComment`/`registerPost` y compara fechas con la hora LOCAL del
  /// dispositivo) sino contra la racha REAL del backend
  /// (`StreakController`, `GET /api/core/streaks/me`), que es la misma que
  /// se muestra en la tarjeta de racha de esta pantalla. Antes ambas fuentes
  /// podían divergir (p. ej. seguir a alguien o unirse a una comunidad cuenta
  /// como actividad para el backend pero no para el contador local) y el
  /// usuario veía "🔥 12 días" arriba mientras el logro "Racha de 7 días"
  /// seguía bloqueado o con progreso equivocado debajo — el reporte de
  /// "bugeado" de la racha.
  ///
  /// Se usa `longestStreak` (récord histórico, monótono) para decidir si el
  /// logro está desbloqueado — igual que `likesGiven`/`postsPublished`, que
  /// tampoco bajan nunca — y `currentStreak` (racha vigente) para la barra
  /// de progreso hacia el siguiente umbral mientras sigue bloqueado.
  bool _isUnlocked(
    AchievementDef def,
    EngagementController engagement,
    StreakController streak,
  ) {
    if (def.metric == AchievementMetric.streak) {
      return streak.longestStreak >= def.threshold;
    }
    return engagement.unlockedAchievements.contains(def.id);
  }

  int _valueFor(
    EngagementController engagement,
    StreakController streak,
    AchievementMetric metric,
  ) {
    switch (metric) {
      case AchievementMetric.likes:
        return engagement.likesGiven;
      case AchievementMetric.streak:
        return streak.currentStreak;
      case AchievementMetric.posts:
        return engagement.postsPublished;
      case AchievementMetric.comments:
        return engagement.commentsGiven;
      case AchievementMetric.saves:
        return engagement.savesGiven;
      case AchievementMetric.shares:
        return engagement.sharesGiven;
    }
  }

  IconData _categoryIcon(AchievementMetric metric) {
    switch (metric) {
      case AchievementMetric.likes:
        return Icons.favorite;
      case AchievementMetric.streak:
        return Icons.local_fire_department;
      case AchievementMetric.posts:
        return Icons.dynamic_feed;
      case AchievementMetric.comments:
        return Icons.mode_comment;
      case AchievementMetric.saves:
        return Icons.bookmark;
      case AchievementMetric.shares:
        return Icons.share;
    }
  }

  String _categoryLabel(AppLocalizations l10n, AchievementMetric metric) {
    switch (metric) {
      case AchievementMetric.likes:
        return l10n.achievementsCategoryLikes;
      case AchievementMetric.streak:
        return l10n.achievementsCategoryStreak;
      case AchievementMetric.posts:
        return l10n.achievementsCategoryPosts;
      case AchievementMetric.comments:
        return l10n.achievementsCategoryComments;
      case AchievementMetric.saves:
        return l10n.achievementsCategorySaves;
      case AchievementMetric.shares:
        return l10n.achievementsCategoryShares;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final engagement = context.watch<EngagementController>();
    final streak = context.watch<StreakController>();

    final unlockedDefs = kAchievementDefs.where(
      (def) => _isUnlocked(def, engagement, streak),
    );
    // Corrección racha: ya no se suma `engagement.streakPoints` (bolsa local
    // de puntos acumulados, desconectada de la racha real del backend y con
    // su propia regla de fechas en hora local) — los puntos de racha ahora
    // sólo cuentan cuando el logro streak_3/7/30 realmente se desbloquea con
    // el récord real (ver `_isUnlocked`), igual que cualquier otro logro.
    final points = unlockedDefs.fold<int>(0, (sum, def) => sum + def.points);
    final unlockedCount = kAchievementDefs
        .where((def) => _isUnlocked(def, engagement, streak))
        .length;
    final totalCount = kAchievementDefs.length;
    final overallProgress = totalCount == 0 ? 0.0 : unlockedCount / totalCount;

    final filtered = kAchievementDefs.where((def) {
      final isUnlocked = _isUnlocked(def, engagement, streak);
      switch (_filter) {
        case _AchievementFilter.all:
          return true;
        case _AchievementFilter.unlocked:
          return isUnlocked;
        case _AchievementFilter.locked:
          return !isUnlocked;
      }
    }).toList();

    final cardWidgets = <Widget>[];
    AchievementMetric? lastMetric;
    var cardIndex = 0;
    for (final def in filtered) {
      if (def.metric != lastMetric) {
        lastMetric = def.metric;
        cardWidgets.add(_categoryHeader(l10n, def.metric));
      }
      cardWidgets.add(
        _achievementCard(
          index: cardIndex++,
          l10n: l10n,
          title: _titleFor(l10n, def.id),
          desc: _descFor(l10n, def.id),
          rarity: _rarityFor(l10n, def.id),
          unlocked: _isUnlocked(def, engagement, streak),
          progressValue: _valueFor(engagement, streak, def.metric),
          threshold: def.threshold,
          progress: _valueFor(engagement, streak, def.metric) / def.threshold,
          color: def.color,
          icon: def.icon,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievementsScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _progressHero(
              context,
              l10n,
              unlockedCount,
              totalCount,
              overallProgress,
              points,
            ),

            const SizedBox(height: 14),

            _quickLinksRow(context, l10n, engagement),

            const SizedBox(height: 20),

            _streakCard(context, l10n, engagement, streak),

            const SizedBox(height: 20),

            _filterChips(l10n),

            const SizedBox(height: 16),

            if (cardWidgets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  l10n.achievementsEmptyFilterLabel,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              )
            else
              ...cardWidgets,
          ],
        ),
      ),
    );
  }

  Widget _filterChips(AppLocalizations l10n) {
    final options = [
      (_AchievementFilter.all, l10n.achievementsFilterAll),
      (_AchievementFilter.unlocked, l10n.achievementsFilterUnlocked),
      (_AchievementFilter.locked, l10n.achievementsFilterLocked),
    ];

    return Row(
      children: [
        for (final option in options) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filter = option.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _filter == option.$1
                      ? Colors.purpleAccent.withOpacity(0.22)
                      : Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _filter == option.$1
                        ? Colors.purpleAccent
                        : Colors.white12,
                  ),
                ),
                child: Text(
                  option.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _filter == option.$1
                        ? Colors.purpleAccent
                        : Colors.grey.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          ),
          if (option.$1 != _AchievementFilter.locked) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _categoryHeader(AppLocalizations l10n, AchievementMetric metric) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        children: [
          Icon(_categoryIcon(metric), color: Colors.grey.shade500, size: 16),
          const SizedBox(width: 8),
          Text(
            _categoryLabel(l10n, metric),
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressHero(
    BuildContext context,
    AppLocalizations l10n,
    int unlockedCount,
    int totalCount,
    double overallProgress,
    int points,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.grey.shade800],
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 136,
            height: 136,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: overallProgress),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => SizedBox(
                    width: 136,
                    height: 136,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 11,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.purpleAccent,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(overallProgress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.achievementsProgressStat,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _statCardContent(
                  Icons.emoji_events,
                  '$unlockedCount/$totalCount',
                  l10n.achievementsUnlockedStat,
                  Colors.amber,
                  false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCardContent(
                  Icons.star,
                  '$points',
                  l10n.achievementsPointsStat,
                  Colors.purpleAccent,
                  false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  Icons.workspace_premium,
                  _rankFor(l10n, points),
                  l10n.achievementsRankStat,
                  Colors.orangeAccent,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RanksScreen(currentPoints: points),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String value,
    String label,
    Color color,
    VoidCallback? onTap,
  ) {
    final card = _statCardContent(icon, value, label, color, onTap != null);

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: card,
      ),
    );
  }

  Widget _statCardContent(
    IconData icon,
    String value,
    String label,
    Color color,
    bool tappable,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.grey.shade800],
        ),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 11.5),
                ),
              ],
            ),
          ),
          if (tappable)
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  Widget _quickLinksRow(
    BuildContext context,
    AppLocalizations l10n,
    EngagementController engagement,
  ) {
    return Row(
      children: [
        Expanded(
          child: _quickLinkChip(
            context,
            icon: Icons.local_fire_department,
            label: l10n.achievementsStreakSectionTitle,
            color: Colors.deepOrange,
            page: const StreakScreen(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickLinkChip(
            context,
            icon: Icons.flag,
            label: l10n.challengesScreenTitle,
            color: Colors.blueAccent,
            page: const ChallengesScreen(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickLinkChip(
            context,
            icon: Icons.storefront,
            label: l10n.storeScreenTitle,
            color: Colors.amber,
            page: const StoreScreen(),
          ),
        ),
      ],
    );
  }

  Widget _quickLinkChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Widget page,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _streakCard(
    BuildContext context,
    AppLocalizations l10n,
    EngagementController engagement,
    StreakController streak,
  ) {
    return FadeTransition(
      opacity: _streakFade,
      child: ScaleTransition(
        scale: _streakScale,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StreakScreen()),
              );
            },
            child: Ink(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Colors.deepOrange, Colors.amber],
                ),
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _flamePulse,
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.achievementsStreakSectionTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.achievementsStreakDaysLabel(
                            streak.currentStreak,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.achievementsStreakSubtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.achievementsStreakBestLabel(streak.longestStreak),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.achievementsStreakRewardLabel(
                            streak.todayReward,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _achievementCard({
    required int index,
    required AppLocalizations l10n,
    required String title,
    required String desc,
    required String rarity,
    required Color color,
    required IconData icon,
    bool unlocked = false,
    double progress = 0,
    int progressValue = 0,
    int threshold = 1,
  }) {
    final locked = !unlocked && progress <= 0;
    final effectiveColor = locked ? Colors.grey : color;

    final start = (0.05 * index).clamp(0.0, 0.6);
    final animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(
        start,
        (start + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade900,
                        effectiveColor.withOpacity(0.2),
                      ],
                    ),
                    border: Border.all(color: effectiveColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: effectiveColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: effectiveColor),
                              ),
                              if (unlocked)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                )
                              else if (locked)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade700,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lock,
                                      color: Colors.white70,
                                      size: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  desc,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              rarity,
                              style: TextStyle(color: color, fontSize: 12),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      if (!unlocked) ...[
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[800],
                          color: effectiveColor,
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${progressValue.clamp(0, threshold)}/$threshold',
                            style: TextStyle(
                              color: effectiveColor,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],

                      if (unlocked)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.achievementsUnlockedBadge,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                ),
                if (unlocked)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: animation,
                        builder: (_, __) {
                          final t = animation.value;
                          return Align(
                            alignment: Alignment(-3 + 6 * t, -1),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Container(
                                width: 36,
                                height: 300,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0),
                                      Colors.white.withOpacity(0.16),
                                      Colors.white.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
