import 'package:flutter/material.dart';

enum ChallengeMetric { likes, saves, shares, posts, comments, streak }

class ChallengeDef {
  final String id;
  final ChallengeMetric metric;
  final int threshold;
  final int reward;
  final IconData icon;
  final Color color;

  const ChallengeDef({
    required this.id,
    required this.metric,
    required this.threshold,
    required this.reward,
    required this.icon,
    required this.color,
  });
}

const List<ChallengeDef> kChallengeDefs = [
  ChallengeDef(
    id: 'weekly_likes_15',
    metric: ChallengeMetric.likes,
    threshold: 15,
    reward: 30,
    icon: Icons.favorite,
    color: Colors.redAccent,
  ),
  ChallengeDef(
    id: 'weekly_posts_3',
    metric: ChallengeMetric.posts,
    threshold: 3,
    reward: 60,
    icon: Icons.add_box,
    color: Colors.deepPurpleAccent,
  ),
  ChallengeDef(
    id: 'weekly_comments_5',
    metric: ChallengeMetric.comments,
    threshold: 5,
    reward: 25,
    icon: Icons.mode_comment,
    color: Colors.blueAccent,
  ),
  ChallengeDef(
    id: 'weekly_shares_5',
    metric: ChallengeMetric.shares,
    threshold: 5,
    reward: 25,
    icon: Icons.share,
    color: Colors.teal,
  ),
  ChallengeDef(
    id: 'weekly_saves_5',
    metric: ChallengeMetric.saves,
    threshold: 5,
    reward: 20,
    icon: Icons.bookmark,
    color: Colors.amber,
  ),
  ChallengeDef(
    id: 'weekly_streak_5',
    metric: ChallengeMetric.streak,
    threshold: 5,
    reward: 50,
    icon: Icons.local_fire_department,
    color: Colors.deepOrange,
  ),
  ChallengeDef(
    id: 'weekly_likes_30',
    metric: ChallengeMetric.likes,
    threshold: 30,
    reward: 55,
    icon: Icons.favorite,
    color: Colors.pinkAccent,
  ),
  ChallengeDef(
    id: 'weekly_posts_5',
    metric: ChallengeMetric.posts,
    threshold: 5,
    reward: 90,
    icon: Icons.auto_awesome,
    color: Colors.indigoAccent,
  ),
  ChallengeDef(
    id: 'weekly_comments_15',
    metric: ChallengeMetric.comments,
    threshold: 15,
    reward: 45,
    icon: Icons.forum,
    color: Colors.lightBlue,
  ),
];
