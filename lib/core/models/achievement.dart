import 'package:flutter/material.dart';

enum AchievementMetric { likes, streak, posts, comments, saves, shares }

class AchievementDef {
  final String id;
  final AchievementMetric metric;
  final int threshold;
  final int points;
  final IconData icon;
  final Color color;

  const AchievementDef({
    required this.id,
    required this.metric,
    required this.threshold,
    required this.points,
    required this.icon,
    required this.color,
  });
}

const List<AchievementDef> kAchievementDefs = [
  AchievementDef(
    id: 'like_1',
    metric: AchievementMetric.likes,
    threshold: 1,
    points: 10,
    icon: Icons.favorite,
    color: Colors.pink,
  ),
  AchievementDef(
    id: 'like_5',
    metric: AchievementMetric.likes,
    threshold: 5,
    points: 25,
    icon: Icons.favorite,
    color: Colors.redAccent,
  ),
  AchievementDef(
    id: 'like_25',
    metric: AchievementMetric.likes,
    threshold: 25,
    points: 50,
    icon: Icons.local_fire_department,
    color: Colors.deepOrange,
  ),
  AchievementDef(
    id: 'like_100',
    metric: AchievementMetric.likes,
    threshold: 100,
    points: 100,
    icon: Icons.emoji_events,
    color: Colors.amber,
  ),
  AchievementDef(
    id: 'streak_3',
    metric: AchievementMetric.streak,
    threshold: 3,
    points: 15,
    icon: Icons.bolt,
    color: Colors.blueAccent,
  ),
  AchievementDef(
    id: 'streak_7',
    metric: AchievementMetric.streak,
    threshold: 7,
    points: 40,
    icon: Icons.calendar_month,
    color: Colors.purple,
  ),
  AchievementDef(
    id: 'streak_30',
    metric: AchievementMetric.streak,
    threshold: 30,
    points: 150,
    icon: Icons.workspace_premium,
    color: Colors.teal,
  ),
  AchievementDef(
    id: 'posts_1',
    metric: AchievementMetric.posts,
    threshold: 1,
    points: 10,
    icon: Icons.add_box,
    color: Colors.deepPurpleAccent,
  ),
  AchievementDef(
    id: 'posts_10',
    metric: AchievementMetric.posts,
    threshold: 10,
    points: 40,
    icon: Icons.dynamic_feed,
    color: Colors.deepPurple,
  ),
  AchievementDef(
    id: 'posts_50',
    metric: AchievementMetric.posts,
    threshold: 50,
    points: 120,
    icon: Icons.auto_awesome,
    color: Colors.indigoAccent,
  ),
  AchievementDef(
    id: 'comments_10',
    metric: AchievementMetric.comments,
    threshold: 10,
    points: 20,
    icon: Icons.mode_comment,
    color: Colors.blueAccent,
  ),
  AchievementDef(
    id: 'comments_50',
    metric: AchievementMetric.comments,
    threshold: 50,
    points: 60,
    icon: Icons.forum,
    color: Colors.lightBlue,
  ),
  AchievementDef(
    id: 'saves_10',
    metric: AchievementMetric.saves,
    threshold: 10,
    points: 20,
    icon: Icons.bookmark,
    color: Colors.amber,
  ),
  AchievementDef(
    id: 'shares_10',
    metric: AchievementMetric.shares,
    threshold: 10,
    points: 20,
    icon: Icons.share,
    color: Colors.tealAccent,
  ),
];

class RankDef {
  final String id;
  final int minPoints;
  final IconData icon;
  final Color color;

  const RankDef({
    required this.id,
    required this.minPoints,
    required this.icon,
    required this.color,
  });
}

const List<RankDef> kRankDefs = [
  RankDef(
    id: 'bronze',
    minPoints: 0,
    icon: Icons.shield,
    color: Color(0xFFCD7F32),
  ),
  RankDef(
    id: 'silver',
    minPoints: 50,
    icon: Icons.shield,
    color: Color(0xFFB0B0B0),
  ),
  RankDef(
    id: 'gold',
    minPoints: 150,
    icon: Icons.shield,
    color: Color(0xFFFFD700),
  ),
  RankDef(
    id: 'platinum',
    minPoints: 300,
    icon: Icons.military_tech,
    color: Color(0xFF66D9E8),
  ),
  RankDef(
    id: 'diamond',
    minPoints: 550,
    icon: Icons.diamond,
    color: Color(0xFF6EC6FF),
  ),
  RankDef(
    id: 'master',
    minPoints: 900,
    icon: Icons.workspace_premium,
    color: Color(0xFFEA80FC),
  ),
];

RankDef currentRank(int points) => kRankDefs.lastWhere(
  (r) => points >= r.minPoints,
  orElse: () => kRankDefs.first,
);

RankDef? nextRank(int points) {
  final current = currentRank(points);
  final index = kRankDefs.indexWhere((r) => r.id == current.id);
  if (index < 0 || index == kRankDefs.length - 1) return null;
  return kRankDefs[index + 1];
}
