/// Espejo de `UserStatsResponse` del backend (core/dtos/UserStatsResponse.java).
/// `GET /api/core/friends/stats`.
class UserStatsResponse {
  const UserStatsResponse({
    this.userId,
    this.username,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.friendsCount = 0,
    this.zentryCoins = 0,
    this.coinsToday = 0,
    this.reputationScore = 0,
    this.rank,
    this.rankMinScore = 0,
    this.nextRankScore,
  });

  final int? userId;
  final String? username;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final int friendsCount;
  final int zentryCoins;
  final int coinsToday;
  final int reputationScore;
  final String? rank;
  final int rankMinScore;
  final int? nextRankScore;

  factory UserStatsResponse.fromJson(Map<String, dynamic> json) {
    int i(dynamic v) => (v as num?)?.toInt() ?? 0;
    return UserStatsResponse(
      userId: (json['user_id'] as num?)?.toInt(),
      username: json['username'] as String?,
      postsCount: i(json['posts_count']),
      followersCount: i(json['followers_count']),
      followingCount: i(json['following_count']),
      friendsCount: i(json['friends_count']),
      zentryCoins: i(json['zentry_coins']),
      coinsToday: i(json['coins_today']),
      reputationScore: i(json['reputation_score']),
      rank: json['rank'] as String?,
      rankMinScore: i(json['rank_min_score']),
      nextRankScore: (json['next_rank_score'] as num?)?.toInt(),
    );
  }
}
