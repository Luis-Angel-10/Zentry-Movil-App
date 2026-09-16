import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/achievement.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/services/progress_pdf_service.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

class RanksScreen extends StatefulWidget {
  final int currentPoints;

  const RanksScreen({super.key, required this.currentPoints});

  @override
  State<RanksScreen> createState() => _RanksScreenState();
}

class _RanksScreenState extends State<RanksScreen>
    with TickerProviderStateMixin {
  bool _exporting = false;

  late final AnimationController _heroController;
  late final AnimationController _pulseController;
  late final Animation<double> _iconPulse;

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _iconPulse = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heroController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _rankLabel(AppLocalizations l10n, String id) {
    switch (id) {
      case 'bronze':
        return l10n.achievementsRankBronze;
      case 'silver':
        return l10n.achievementsRankSilver;
      case 'gold':
        return l10n.achievementsRankGold;
      case 'platinum':
        return l10n.achievementsRankPlatinum;
      case 'diamond':
        return l10n.achievementsRankDiamond;
      case 'master':
        return l10n.achievementsRankMaster;
    }
    return id;
  }

  String _rankPerk(AppLocalizations l10n, String id) {
    switch (id) {
      case 'bronze':
        return l10n.ranksPerkBronze;
      case 'silver':
        return l10n.ranksPerkSilver;
      case 'gold':
        return l10n.ranksPerkGold;
      case 'platinum':
        return l10n.ranksPerkPlatinum;
      case 'diamond':
        return l10n.ranksPerkDiamond;
      case 'master':
        return l10n.ranksPerkMaster;
    }
    return '';
  }

  String _achievementTitle(AppLocalizations l10n, String id) {
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
    return id;
  }

  Future<void> _exportPdf(
    AppLocalizations l10n,
    EngagementController engagement,
    int points,
  ) async {
    setState(() => _exporting = true);
    final userName =
        context.read<AuthController>().currentUser?.displayName ?? '';
    final rank = currentRank(points);
    final unlocked = kAchievementDefs
        .where((d) => engagement.unlockedAchievements.contains(d.id))
        .toList();

    try {
      await ProgressPdfService.exportAndOpen(
        userDisplayName: userName,
        points: points,
        streakCount: engagement.streakCount,
        bestStreak: engagement.bestStreak,
        unlockedAchievements: unlocked,
        titleFor: (id) => _achievementTitle(l10n, id),
        docTitle: l10n.pdfDocTitle,
        generatedOnLabel: l10n.pdfDocGeneratedOn(
          DateTime.now().toString().split('.').first,
        ),
        rankLabel: l10n.pdfDocRankLabel(_rankLabel(l10n, rank.id)),
        pointsLabel: l10n.pdfDocPointsLabel(points),
        achievementsTitle: l10n.pdfDocAchievementsTitle,
        noAchievementsLabel: l10n.pdfDocNoAchievements,
        streakLabel: l10n.pdfDocStreakLabel(
          engagement.streakCount,
          engagement.bestStreak,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.ranksExportPdfSuccess)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.ranksExportPdfError)));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final engagement = context.watch<EngagementController>();
    final myRank = currentRank(widget.currentPoints);
    final next = nextRank(widget.currentPoints);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ranksScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _heroCard(l10n, myRank, next),
          const SizedBox(height: 20),
          _tierStrip(l10n, myRank),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _exporting
                ? null
                : () => _exportPdf(l10n, engagement, widget.currentPoints),
            icon: _exporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(l10n.ranksExportPdfButton),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.ranksScreenSubtitle,
            style: TextStyle(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.ranksScreenCountLabel(kRankDefs.length),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          for (final rank in kRankDefs)
            _rankCard(l10n, rank, isCurrent: rank.id == myRank.id),
        ],
      ),
    );
  }

  Widget _heroCard(AppLocalizations l10n, RankDef myRank, RankDef? next) {
    final progress = next == null
        ? 1.0
        : ((widget.currentPoints - myRank.minPoints) /
                  (next.minPoints - myRank.minPoints))
              .clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        final angle = _heroController.value * 2 * pi;
        final begin = Alignment(cos(angle), sin(angle));
        final end = Alignment(-cos(angle), -sin(angle));

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [myRank.color.withOpacity(0.9), Colors.black87],
            ),
            boxShadow: [
              BoxShadow(
                color: myRank.color.withOpacity(0.45),
                blurRadius: 34,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _iconPulse,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.25),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(myRank.icon, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _rankLabel(l10n, myRank.id),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.pdfDocPointsLabel(widget.currentPoints),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _rankPerk(l10n, myRank.id),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.ranksNextRankTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.black38,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            next == null
                ? l10n.ranksMaxRankLabel
                : l10n.ranksPointsToNextLabel(
                    next.minPoints - widget.currentPoints,
                    _rankLabel(l10n, next.id),
                  ),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _tierStrip(AppLocalizations l10n, RankDef myRank) {
    return SizedBox(
      height: 96,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (var i = 0; i < kRankDefs.length; i++) ...[
              _tierNode(
                kRankDefs[i],
                label: _rankLabel(l10n, kRankDefs[i].id),
                isCurrent: kRankDefs[i].id == myRank.id,
                reached: widget.currentPoints >= kRankDefs[i].minPoints,
              ),
              if (i != kRankDefs.length - 1)
                Container(
                  width: 26,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: widget.currentPoints >= kRankDefs[i + 1].minPoints
                        ? kRankDefs[i + 1].color.withOpacity(0.7)
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tierNode(
    RankDef rank, {
    required String label,
    required bool isCurrent,
    required bool reached,
  }) {
    final color = reached ? rank.color : Colors.grey.shade700;
    final size = isCurrent ? 58.0 : 46.0;

    Widget node = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(reached ? 0.22 : 0.08),
        border: Border.all(color: color, width: isCurrent ? 3 : 1.5),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: rank.color.withOpacity(0.55),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        rank.icon,
        color: reached ? rank.color : Colors.grey.shade600,
        size: isCurrent ? 26 : 20,
      ),
    );

    if (isCurrent) {
      node = ScaleTransition(scale: _iconPulse, child: node);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          node,
          const SizedBox(height: 6),
          Opacity(
            opacity: reached ? 1 : 0.5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                color: reached ? Colors.white70 : Colors.grey.shade600,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankCard(
    AppLocalizations l10n,
    RankDef rank, {
    required bool isCurrent,
  }) {
    final reached = widget.currentPoints >= rank.minPoints;

    final card = Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: reached
              ? [Colors.grey.shade900, rank.color.withOpacity(0.25)]
              : [Colors.grey.shade900, Colors.grey.shade900],
        ),
        border: Border.all(
          color: isCurrent
              ? rank.color
              : rank.color.withOpacity(reached ? 0.35 : 0.15),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Opacity(
        opacity: reached ? 1 : 0.55,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rank.color.withOpacity(reached ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                rank.icon,
                color: reached ? rank.color : Colors.grey.shade500,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _rankLabel(l10n, rank.id),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.ranksMinPointsLabel(rank.minPoints),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _rankPerk(l10n, rank.id),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: rank.color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.ranksCurrentBadge,
                  style: TextStyle(
                    color: rank.color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (reached)
              Icon(Icons.check_circle, color: rank.color, size: 20),
          ],
        ),
      ),
    );

    if (!isCurrent) return card;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: rank.color.withOpacity(
                  0.25 + 0.2 * _pulseController.value,
                ),
                blurRadius: 16 + 8 * _pulseController.value,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
      child: card,
    );
  }
}
