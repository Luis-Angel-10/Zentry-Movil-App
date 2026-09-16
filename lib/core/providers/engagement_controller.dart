import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/models/achievement.dart';
import 'package:Zentry/core/models/challenge.dart';
import 'package:Zentry/core/providers/notifications_controller.dart';

class EngagementController extends ChangeNotifier {
  static const _likesGivenKey = 'engagement_likes_given';
  static const _savesGivenKey = 'engagement_saves_given';
  static const _sharesGivenKey = 'engagement_shares_given';
  static const _commentsGivenKey = 'engagement_comments_given';
  static const _postsPublishedKey = 'engagement_posts_published';
  static const _profileVisitsKey = 'engagement_profile_visits';
  static const _streakCountKey = 'engagement_streak_count';
  static const _bestStreakKey = 'engagement_best_streak';
  static const _lastActiveDateKey = 'engagement_last_active_date';
  static const _unlockedKey = 'engagement_unlocked_achievements';
  static const _streakPointsKey = 'engagement_streak_points';
  static const _zCoinsKey = 'engagement_zcoins';
  static const _ownedColorsKey = 'engagement_owned_colors';
  static const _weekKeyKey = 'engagement_week_key';
  static const _weeklyProgressKey = 'engagement_weekly_progress';
  static const _claimedChallengesKey = 'engagement_claimed_challenges';

  static const _dailyLikesKey = 'engagement_daily_likes';
  static const _dailySavesKey = 'engagement_daily_saves';
  static const _dailySharesKey = 'engagement_daily_shares';
  static const _dailyVisitsKey = 'engagement_daily_visits';
  static const _dailyCommentsKey = 'engagement_daily_comments';
  static const _dailyPostsKey = 'engagement_daily_posts';
  static const _dailyStreakActiveKey = 'engagement_daily_streak_active';

  static const int postPublishReward = 8;

  NotificationsController? notifications;

  int likesGiven = 0;
  int savesGiven = 0;
  int sharesGiven = 0;
  int commentsGiven = 0;
  int postsPublished = 0;
  int profileVisits = 0;
  int streakCount = 0;
  int bestStreak = 0;
  int streakPoints = 0;
  int zCoins = 0;
  String? lastActiveDate;
  Set<String> unlockedAchievements = {};
  Set<String> ownedColors = {};
  Set<String> claimedChallenges = {};

  Map<String, int> _dailyLikes = {};
  Map<String, int> _dailySaves = {};
  Map<String, int> _dailyShares = {};
  Map<String, int> _dailyVisits = {};
  Map<String, int> _dailyComments = {};
  Map<String, int> _dailyPosts = {};
  Map<String, int> _dailyStreakActive = {};
  Map<String, int> _weeklyProgress = {};

  int get todayStreakReward =>
      streakCount == 0 ? 0 : (10 + (streakCount - 1) * 5).clamp(0, 50);

  bool get isStreakActiveToday => lastActiveDate == _dateKey(DateTime.now());

  List<int> get weeklyStreakActivity => _lastNDays(_dailyStreakActive, 7);

  List<int> get weeklyLikes => _lastNDays(_dailyLikes, 7);
  List<int> get weeklySaves => _lastNDays(_dailySaves, 7);
  List<int> get weeklyShares => _lastNDays(_dailyShares, 7);
  List<int> get weeklyVisits => _lastNDays(_dailyVisits, 7);
  List<int> get weeklyComments => _lastNDays(_dailyComments, 7);
  List<int> get weeklyPosts => _lastNDays(_dailyPosts, 7);

  int weeklyProgressFor(ChallengeMetric metric) =>
      _weeklyProgress[metric.name] ?? 0;

  bool isChallengeClaimed(String id) => claimedChallenges.contains(id);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    likesGiven = prefs.getInt(_likesGivenKey) ?? 0;
    savesGiven = prefs.getInt(_savesGivenKey) ?? 0;
    sharesGiven = prefs.getInt(_sharesGivenKey) ?? 0;
    commentsGiven = prefs.getInt(_commentsGivenKey) ?? 0;
    postsPublished = prefs.getInt(_postsPublishedKey) ?? 0;
    profileVisits = prefs.getInt(_profileVisitsKey) ?? 0;
    streakCount = prefs.getInt(_streakCountKey) ?? 0;
    bestStreak = prefs.getInt(_bestStreakKey) ?? 0;
    streakPoints = prefs.getInt(_streakPointsKey) ?? 0;
    zCoins = prefs.getInt(_zCoinsKey) ?? 0;
    lastActiveDate = prefs.getString(_lastActiveDateKey);
    unlockedAchievements = (prefs.getStringList(_unlockedKey) ?? []).toSet();
    ownedColors = (prefs.getStringList(_ownedColorsKey) ?? []).toSet();

    _dailyLikes = _decodeMap(prefs.getString(_dailyLikesKey));
    _dailySaves = _decodeMap(prefs.getString(_dailySavesKey));
    _dailyShares = _decodeMap(prefs.getString(_dailySharesKey));
    _dailyVisits = _decodeMap(prefs.getString(_dailyVisitsKey));
    _dailyComments = _decodeMap(prefs.getString(_dailyCommentsKey));
    _dailyPosts = _decodeMap(prefs.getString(_dailyPostsKey));
    _dailyStreakActive = _decodeMap(prefs.getString(_dailyStreakActiveKey));

    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final yesterdayKey = _dateKey(today.subtract(const Duration(days: 1)));

    if (lastActiveDate != null &&
        lastActiveDate != todayKey &&
        lastActiveDate != yesterdayKey) {
      streakCount = 0;
      prefs.setInt(_streakCountKey, 0);
    }

    final currentWeek = _weekKey(today);
    if (prefs.getString(_weekKeyKey) == currentWeek) {
      _weeklyProgress = _decodeMap(prefs.getString(_weeklyProgressKey));
      claimedChallenges = (prefs.getStringList(_claimedChallengesKey) ?? [])
          .toSet();
    } else {
      _weeklyProgress = {};
      claimedChallenges = {};
      prefs.setString(_weekKeyKey, currentWeek);
      prefs.setString(_weeklyProgressKey, jsonEncode(_weeklyProgress));
      prefs.setStringList(_claimedChallengesKey, []);
    }

    notifyListeners();
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _weekKey(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSince = date.difference(firstDayOfYear).inDays;
    final week = (daysSince / 7).floor();
    return '${date.year}-W$week';
  }

  Map<String, int> _decodeMap(String? raw) {
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  void _bumpDaily(Map<String, int> daily, String key, SharedPreferences prefs) {
    final todayKey = _dateKey(DateTime.now());
    daily[todayKey] = (daily[todayKey] ?? 0) + 1;

    final cutoff = DateTime.now().subtract(const Duration(days: 14));
    daily.removeWhere((dateKey, _) {
      final parts = dateKey.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return date.isBefore(cutoff);
    });

    prefs.setString(key, jsonEncode(daily));
  }

  List<int> _lastNDays(Map<String, int> daily, int n) {
    final today = DateTime.now();
    return List.generate(n, (i) {
      final date = today.subtract(Duration(days: n - 1 - i));
      return daily[_dateKey(date)] ?? 0;
    });
  }

  void _bumpWeeklyProgress(
    String metricKey,
    SharedPreferences prefs, {
    int? setMax,
  }) {
    if (setMax != null) {
      final current = _weeklyProgress[metricKey] ?? 0;
      _weeklyProgress[metricKey] = setMax > current ? setMax : current;
    } else {
      _weeklyProgress[metricKey] = (_weeklyProgress[metricKey] ?? 0) + 1;
    }
    prefs.setString(_weeklyProgressKey, jsonEncode(_weeklyProgress));
  }

  void _activateStreakIfNeeded(SharedPreferences prefs) {
    final today = DateTime.now();
    final todayKey = _dateKey(today);

    if (lastActiveDate == todayKey) return;

    if (lastActiveDate != null) {
      final yesterdayKey = _dateKey(today.subtract(const Duration(days: 1)));
      streakCount = lastActiveDate == yesterdayKey ? streakCount + 1 : 1;
    } else {
      streakCount = 1;
    }

    if (streakCount > bestStreak) {
      bestStreak = streakCount;
    }

    streakPoints += todayStreakReward;
    lastActiveDate = todayKey;

    _dailyStreakActive[todayKey] = 1;
    prefs.setString(_dailyStreakActiveKey, jsonEncode(_dailyStreakActive));

    prefs.setString(_lastActiveDateKey, todayKey);
    prefs.setInt(_streakCountKey, streakCount);
    prefs.setInt(_bestStreakKey, bestStreak);
    prefs.setInt(_streakPointsKey, streakPoints);

    _unlockMatching(AchievementMetric.streak, streakCount, prefs);
    _bumpWeeklyProgress('streak', prefs, setMax: streakCount);
  }

  Future<void> registerLike() async {
    likesGiven += 1;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_likesGivenKey, likesGiven);
    _bumpDaily(_dailyLikes, _dailyLikesKey, prefs);
    _bumpWeeklyProgress('likes', prefs);

    _unlockMatching(AchievementMetric.likes, likesGiven, prefs);
    _activateStreakIfNeeded(prefs);

    notifyListeners();
  }

  Future<void> registerSave() async {
    savesGiven += 1;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_savesGivenKey, savesGiven);
    _bumpDaily(_dailySaves, _dailySavesKey, prefs);
    _bumpWeeklyProgress('saves', prefs);

    _unlockMatching(AchievementMetric.saves, savesGiven, prefs);

    notifyListeners();
  }

  Future<void> registerShare() async {
    sharesGiven += 1;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_sharesGivenKey, sharesGiven);
    _bumpDaily(_dailyShares, _dailySharesKey, prefs);
    _bumpWeeklyProgress('shares', prefs);

    _unlockMatching(AchievementMetric.shares, sharesGiven, prefs);

    notifyListeners();
  }

  Future<void> registerComment() async {
    commentsGiven += 1;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_commentsGivenKey, commentsGiven);
    _bumpDaily(_dailyComments, _dailyCommentsKey, prefs);
    _bumpWeeklyProgress('comments', prefs);

    _unlockMatching(AchievementMetric.comments, commentsGiven, prefs);
    _activateStreakIfNeeded(prefs);

    notifyListeners();
  }

  Future<void> registerPost() async {
    postsPublished += 1;
    zCoins += postPublishReward;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_postsPublishedKey, postsPublished);
    prefs.setInt(_zCoinsKey, zCoins);
    _bumpDaily(_dailyPosts, _dailyPostsKey, prefs);
    _bumpWeeklyProgress('posts', prefs);

    _unlockMatching(AchievementMetric.posts, postsPublished, prefs);
    _activateStreakIfNeeded(prefs);

    notifyListeners();
  }

  Future<void> registerProfileVisit() async {
    profileVisits += 1;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_profileVisitsKey, profileVisits);
    _bumpDaily(_dailyVisits, _dailyVisitsKey, prefs);

    notifyListeners();
  }

  Future<bool> claimChallenge(String id) async {
    final def = kChallengeDefs.firstWhere((d) => d.id == id);
    final progress = weeklyProgressFor(def.metric);

    if (progress < def.threshold || claimedChallenges.contains(id)) {
      return false;
    }

    claimedChallenges.add(id);
    zCoins += def.reward;

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_claimedChallengesKey, claimedChallenges.toList());
    prefs.setInt(_zCoinsKey, zCoins);

    notifications?.push(AppNotificationType.challenge, {
      'challengeId': id,
      'reward': def.reward,
    });

    notifyListeners();
    return true;
  }

  Future<bool> buyColor(String colorId, int price) async {
    if (ownedColors.contains(colorId) || zCoins < price) return false;

    zCoins -= price;
    ownedColors.add(colorId);

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_zCoinsKey, zCoins);
    prefs.setStringList(_ownedColorsKey, ownedColors.toList());

    notifyListeners();
    return true;
  }

  Future<bool> spendZCoins(int amount) async {
    if (zCoins < amount) return false;

    zCoins -= amount;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_zCoinsKey, zCoins);

    notifyListeners();
    return true;
  }

  void _unlockMatching(
    AchievementMetric metric,
    int value,
    SharedPreferences prefs,
  ) {
    var changed = false;

    for (final def in kAchievementDefs) {
      if (def.metric != metric) continue;
      if (value < def.threshold) continue;
      if (unlockedAchievements.contains(def.id)) continue;

      unlockedAchievements.add(def.id);
      zCoins += def.points;
      changed = true;

      notifications?.push(AppNotificationType.achievement, {
        'achievementId': def.id,
        'points': def.points,
      });
    }

    if (changed) {
      prefs.setStringList(_unlockedKey, unlockedAchievements.toList());
      prefs.setInt(_zCoinsKey, zCoins);
    }
  }
}
