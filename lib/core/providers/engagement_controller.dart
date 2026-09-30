import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/models/achievement.dart';
import 'package:Zentry/core/models/backend/user_stats_response.dart';
import 'package:Zentry/core/models/challenge.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/friends_api.dart';
import 'package:Zentry/core/providers/notifications_controller.dart';

/// Contadores de engagement del usuario autenticado (likes/comentarios/
/// guardados/compartidos dados, logros locales, retos semanales, monedas de
/// la tienda).
///
/// *** Aislamiento por usuario ***
/// Todo el estado persistente vive bajo claves con el `userId` del usuario
/// autenticado como namespace (`engagement.u<id>.<clave>`, ver [keyFor]).
/// Antes eran claves globales del dispositivo: si A y B usaban el mismo
/// teléfono, B heredaba los likes, logros y monedas de A. Ahora:
///  * [bindUser] con el id de B carga EXCLUSIVAMENTE las claves de B.
///  * [bindUser] con `null` (logout) limpia la memoria pero NO borra lo
///    persistido de A, que se recupera cuando A vuelve a iniciar sesión.
///  * Sin usuario vinculado, las acciones `register*` se ignoran.
///
/// *** Fuente de verdad ***
///  * Racha: la del backend (`StreakController`). Aquí ya no existe contador
///    local de racha; los logros `streak_*` y el reto semanal de racha se
///    alimentan con [syncBackendStreak].
///  * Publicaciones: `posts_count` de `GET /api/core/friends/stats`
///    prevalece (ver [refreshFromBackend]); el incremento local de
///    [registerPost] es sólo optimista hasta la siguiente sincronización.
///  * Likes/comentarios/guardados/compartidos DADOS, retos semanales, colores
///    comprados y monedas de la tienda: el backend no expone ningún endpoint
///    para ellos, así que siguen siendo locales (por usuario).
///
/// *** Respuestas en vuelo ***
/// [_generation] se incrementa en cada [bindUser]. Cualquier trabajo async
/// iniciado bajo una sesión (carga de preferencias, sincronización con el
/// backend) se descarta si la generación cambió mientras estaba en vuelo —
/// mismo principio que `StreakController`. Las mutaciones de `register*`
/// son síncronas sobre la instancia de [SharedPreferences] ya cargada, así
/// que no hay `await` entre leer el usuario vinculado y escribir.
class EngagementController extends ChangeNotifier {
  EngagementController({Future<UserStatsResponse> Function()? fetchStats})
    : _fetchStats = fetchStats ?? FriendsApi.instance.getStats;

  static const _likesGivenKey = 'likes_given';
  static const _savesGivenKey = 'saves_given';
  static const _sharesGivenKey = 'shares_given';
  static const _commentsGivenKey = 'comments_given';
  static const _postsPublishedKey = 'posts_published';
  static const _profileVisitsKey = 'profile_visits';
  static const _unlockedKey = 'unlocked_achievements';
  static const _zCoinsKey = 'zcoins';
  static const _ownedColorsKey = 'owned_colors';
  static const _weekKeyKey = 'week_key';
  static const _weeklyProgressKey = 'weekly_progress';
  static const _claimedChallengesKey = 'claimed_challenges';

  static const _dailyLikesKey = 'daily_likes';
  static const _dailySavesKey = 'daily_saves';
  static const _dailySharesKey = 'daily_shares';
  static const _dailyVisitsKey = 'daily_visits';
  static const _dailyCommentsKey = 'daily_comments';
  static const _dailyPostsKey = 'daily_posts';

  static const int postPublishReward = 8;

  /// Clave persistente de [base] para el usuario [userId].
  static String keyFor(int userId, String base) => 'engagement.u$userId.$base';

  final Future<UserStatsResponse> Function() _fetchStats;

  NotificationsController? notifications;

  int? _userId;
  SharedPreferences? _prefs;
  int _generation = 0;

  /// Usuario cuyo estado está cargado (o `null` sin sesión).
  int? get userId => _userId;

  int likesGiven = 0;
  int savesGiven = 0;
  int sharesGiven = 0;
  int commentsGiven = 0;
  int postsPublished = 0;
  int profileVisits = 0;
  int zCoins = 0;
  Set<String> unlockedAchievements = {};
  Set<String> ownedColors = {};
  Set<String> claimedChallenges = {};

  Map<String, int> _dailyLikes = {};
  Map<String, int> _dailySaves = {};
  Map<String, int> _dailyShares = {};
  Map<String, int> _dailyVisits = {};
  Map<String, int> _dailyComments = {};
  Map<String, int> _dailyPosts = {};
  Map<String, int> _weeklyProgress = {};

  List<int> get weeklyLikes => _lastNDays(_dailyLikes, 7);
  List<int> get weeklySaves => _lastNDays(_dailySaves, 7);
  List<int> get weeklyShares => _lastNDays(_dailyShares, 7);
  List<int> get weeklyVisits => _lastNDays(_dailyVisits, 7);
  List<int> get weeklyComments => _lastNDays(_dailyComments, 7);
  List<int> get weeklyPosts => _lastNDays(_dailyPosts, 7);

  int weeklyProgressFor(ChallengeMetric metric) =>
      _weeklyProgress[metric.name] ?? 0;

  bool isChallengeClaimed(String id) => claimedChallenges.contains(id);

  /// Vincula el controller al usuario [userId] (login / restauración de
  /// sesión) o lo desvincula con `null` (logout). Siempre limpia la memoria
  /// primero, así nunca queda visible el estado de otra cuenta.
  Future<void> bindUser(int? userId) async {
    final gen = ++_generation;
    final uid = (userId != null && userId > 0) ? userId : null;
    _userId = uid;
    _prefs = null;
    _clearMemory();
    notifyListeners();
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (gen != _generation) return;
    _prefs = prefs;
    _readFrom(prefs, uid);
    notifyListeners();

    await refreshFromBackend();
  }

  /// Sincroniza con el backend los contadores que sí tienen fuente de verdad
  /// server-side (hoy: `posts_count`). Se descarta si mientras tanto cambió
  /// la sesión o si la respuesta es de otra cuenta.
  Future<void> refreshFromBackend() async {
    final gen = _generation;
    final uid = _userId;
    if (uid == null) return;
    final UserStatsResponse stats;
    try {
      stats = await _fetchStats();
    } on ApiException {
      return; // sin red: se queda la caché local del usuario
    }
    final prefs = _prefs;
    if (gen != _generation || _userId != uid || prefs == null) return;
    if (stats.userId != null && stats.userId != uid) return;

    postsPublished = stats.postsCount;
    prefs.setInt(_k(_postsPublishedKey), postsPublished);
    _unlockMatching(AchievementMetric.posts, postsPublished, prefs);
    notifyListeners();
  }

  /// Aplica la racha REAL del backend a los logros `streak_*` y al reto
  /// semanal de racha. [userId] es el de la respuesta del backend: si no
  /// coincide con el usuario vinculado se ignora.
  void syncBackendStreak({
    required int userId,
    required int currentStreak,
    required int longestStreak,
  }) {
    final prefs = _prefs;
    if (prefs == null || userId != _userId) return;
    _unlockMatching(AchievementMetric.streak, longestStreak, prefs);
    final before = _weeklyProgress['streak'] ?? 0;
    _bumpWeeklyProgress('streak', prefs, setMax: currentStreak);
    if (_weeklyProgress['streak'] != before) notifyListeners();
  }

  void _clearMemory() {
    likesGiven = 0;
    savesGiven = 0;
    sharesGiven = 0;
    commentsGiven = 0;
    postsPublished = 0;
    profileVisits = 0;
    zCoins = 0;
    unlockedAchievements = {};
    ownedColors = {};
    claimedChallenges = {};
    _dailyLikes = {};
    _dailySaves = {};
    _dailyShares = {};
    _dailyVisits = {};
    _dailyComments = {};
    _dailyPosts = {};
    _weeklyProgress = {};
  }

  void _readFrom(SharedPreferences prefs, int uid) {
    String k(String base) => keyFor(uid, base);

    likesGiven = prefs.getInt(k(_likesGivenKey)) ?? 0;
    savesGiven = prefs.getInt(k(_savesGivenKey)) ?? 0;
    sharesGiven = prefs.getInt(k(_sharesGivenKey)) ?? 0;
    commentsGiven = prefs.getInt(k(_commentsGivenKey)) ?? 0;
    postsPublished = prefs.getInt(k(_postsPublishedKey)) ?? 0;
    profileVisits = prefs.getInt(k(_profileVisitsKey)) ?? 0;
    zCoins = prefs.getInt(k(_zCoinsKey)) ?? 0;
    unlockedAchievements = (prefs.getStringList(k(_unlockedKey)) ?? []).toSet();
    ownedColors = (prefs.getStringList(k(_ownedColorsKey)) ?? []).toSet();

    _dailyLikes = _decodeMap(prefs.getString(k(_dailyLikesKey)));
    _dailySaves = _decodeMap(prefs.getString(k(_dailySavesKey)));
    _dailyShares = _decodeMap(prefs.getString(k(_dailySharesKey)));
    _dailyVisits = _decodeMap(prefs.getString(k(_dailyVisitsKey)));
    _dailyComments = _decodeMap(prefs.getString(k(_dailyCommentsKey)));
    _dailyPosts = _decodeMap(prefs.getString(k(_dailyPostsKey)));

    final currentWeek = _weekKey(DateTime.now());
    if (prefs.getString(k(_weekKeyKey)) == currentWeek) {
      _weeklyProgress = _decodeMap(prefs.getString(k(_weeklyProgressKey)));
      claimedChallenges = (prefs.getStringList(k(_claimedChallengesKey)) ?? [])
          .toSet();
    } else {
      _weeklyProgress = {};
      claimedChallenges = {};
      prefs.setString(k(_weekKeyKey), currentWeek);
      prefs.setString(k(_weeklyProgressKey), jsonEncode(_weeklyProgress));
      prefs.setStringList(k(_claimedChallengesKey), []);
    }
  }

  /// Clave del usuario vinculado. Sólo se llama con [_prefs] no nulo, que
  /// implica [_userId] no nulo.
  String _k(String base) => keyFor(_userId!, base);

  /// Devuelve las preferencias si la acción debe aplicarse: hay usuario
  /// vinculado y, si el llamador indicó [forUserId] (capturado ANTES de su
  /// propio `await`), coincide con él.
  SharedPreferences? _prefsFor(int? forUserId) {
    final prefs = _prefs;
    if (prefs == null) return null;
    if (forUserId != null && forUserId != _userId) return null;
    return prefs;
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

    prefs.setString(_k(key), jsonEncode(daily));
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
    prefs.setString(_k(_weeklyProgressKey), jsonEncode(_weeklyProgress));
  }

  Future<void> registerLike({int? forUserId}) async {
    final prefs = _prefsFor(forUserId);
    if (prefs == null) return;
    likesGiven += 1;
    prefs.setInt(_k(_likesGivenKey), likesGiven);
    _bumpDaily(_dailyLikes, _dailyLikesKey, prefs);
    _bumpWeeklyProgress('likes', prefs);
    _unlockMatching(AchievementMetric.likes, likesGiven, prefs);
    notifyListeners();
  }

  Future<void> registerSave({int? forUserId}) async {
    final prefs = _prefsFor(forUserId);
    if (prefs == null) return;
    savesGiven += 1;
    prefs.setInt(_k(_savesGivenKey), savesGiven);
    _bumpDaily(_dailySaves, _dailySavesKey, prefs);
    _bumpWeeklyProgress('saves', prefs);
    _unlockMatching(AchievementMetric.saves, savesGiven, prefs);
    notifyListeners();
  }

  Future<void> registerShare({int? forUserId}) async {
    final prefs = _prefsFor(forUserId);
    if (prefs == null) return;
    sharesGiven += 1;
    prefs.setInt(_k(_sharesGivenKey), sharesGiven);
    _bumpDaily(_dailyShares, _dailySharesKey, prefs);
    _bumpWeeklyProgress('shares', prefs);
    _unlockMatching(AchievementMetric.shares, sharesGiven, prefs);
    notifyListeners();
  }

  Future<void> registerComment({int? forUserId}) async {
    final prefs = _prefsFor(forUserId);
    if (prefs == null) return;
    commentsGiven += 1;
    prefs.setInt(_k(_commentsGivenKey), commentsGiven);
    _bumpDaily(_dailyComments, _dailyCommentsKey, prefs);
    _bumpWeeklyProgress('comments', prefs);
    _unlockMatching(AchievementMetric.comments, commentsGiven, prefs);
    notifyListeners();
  }

  /// Incremento optimista: [refreshFromBackend] lo reemplaza por el
  /// `posts_count` real del backend.
  Future<void> registerPost({int? forUserId}) async {
    final prefs = _prefsFor(forUserId);
    if (prefs == null) return;
    postsPublished += 1;
    zCoins += postPublishReward;
    prefs.setInt(_k(_postsPublishedKey), postsPublished);
    prefs.setInt(_k(_zCoinsKey), zCoins);
    _bumpDaily(_dailyPosts, _dailyPostsKey, prefs);
    _bumpWeeklyProgress('posts', prefs);
    _unlockMatching(AchievementMetric.posts, postsPublished, prefs);
    notifyListeners();
  }

  Future<void> registerProfileVisit({int? forUserId}) async {
    final prefs = _prefsFor(forUserId);
    if (prefs == null) return;
    profileVisits += 1;
    prefs.setInt(_k(_profileVisitsKey), profileVisits);
    _bumpDaily(_dailyVisits, _dailyVisitsKey, prefs);
    notifyListeners();
  }

  Future<bool> claimChallenge(String id) async {
    final prefs = _prefs;
    if (prefs == null) return false;
    final def = kChallengeDefs.firstWhere((d) => d.id == id);
    final progress = weeklyProgressFor(def.metric);

    if (progress < def.threshold || claimedChallenges.contains(id)) {
      return false;
    }

    claimedChallenges.add(id);
    zCoins += def.reward;

    prefs.setStringList(_k(_claimedChallengesKey), claimedChallenges.toList());
    prefs.setInt(_k(_zCoinsKey), zCoins);

    notifications?.push(AppNotificationType.challenge, {
      'challengeId': id,
      'reward': def.reward,
    });

    notifyListeners();
    return true;
  }

  Future<bool> buyColor(String colorId, int price) async {
    final prefs = _prefs;
    if (prefs == null) return false;
    if (ownedColors.contains(colorId) || zCoins < price) return false;

    zCoins -= price;
    ownedColors.add(colorId);

    prefs.setInt(_k(_zCoinsKey), zCoins);
    prefs.setStringList(_k(_ownedColorsKey), ownedColors.toList());

    notifyListeners();
    return true;
  }

  Future<bool> spendZCoins(int amount) async {
    final prefs = _prefs;
    if (prefs == null) return false;
    if (zCoins < amount) return false;

    zCoins -= amount;
    prefs.setInt(_k(_zCoinsKey), zCoins);

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
      prefs.setStringList(_k(_unlockedKey), unlockedAchievements.toList());
      prefs.setInt(_k(_zCoinsKey), zCoins);
      notifyListeners();
    }
  }
}
