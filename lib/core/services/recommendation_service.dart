import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/models/backend/friend_user_response.dart';
import 'package:Zentry/core/models/community.dart';
import 'package:Zentry/core/models/creative_challenge.dart';
import 'package:Zentry/core/network/friends_api.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/creative_challenge_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';

class RecommendationService {
  const RecommendationService._();

  static List<Community> recommendedCommunities({
    required AppUser? user,
    required CommunityController communities,
    int limit = 5,
  }) {
    if (user == null) return const [];

    final mine = communities.myCommunities(user.id);
    final mineIds = mine.map((c) => c.id).toSet();
    final myCategories = {
      ...mine.map((c) => c.categoryName),
      ...user.interests,
    };

    final candidates = communities.communities
        .where((c) => !mineIds.contains(c.id))
        .toList();

    candidates.sort((a, b) {
      final aMatch = myCategories.contains(a.categoryName) ? 1 : 0;
      final bMatch = myCategories.contains(b.categoryName) ? 1 : 0;
      if (aMatch != bMatch) return bMatch - aMatch;
      return communities
          .memberCount(b.id)
          .compareTo(communities.memberCount(a.id));
    });

    return candidates.take(limit).toList();
  }

  /// Sugerencias de creadores REALES (`GET /api/core/friends/suggestions`).
  ///
  /// El backend ya excluye al usuario actual, amigos actuales y cualquier
  /// solicitud de amistad pendiente en cualquier dirección. NO existe un
  /// endpoint que además excluya a quien ya sigues (el grafo de "follow" es
  /// independiente del de amistad en este backend) — documentado como
  /// requisito pendiente en el reporte de esta fase, no se simula del lado
  /// de Flutter.
  static Future<List<FriendUserResponse>> suggestedCreators({int limit = 5}) {
    return FriendsApi.instance.getSuggestions(limit: limit);
  }

  static List<Map<String, dynamic>> recommendedPosts({
    required AppUser? user,
    required PostsController posts,
    int limit = 6,
  }) {
    final feedPosts = posts.posts
        .where((p) => p["communityId"] == null)
        .toList();

    final likedCategories = feedPosts
        .where((p) => p["likedByMe"] == true)
        .map((p) => p["category"] as String?)
        .whereType<String>()
        .toSet();

    final candidates = feedPosts
        .where((p) => user == null || p["user"] != user.displayName)
        .toList();

    if (likedCategories.isNotEmpty) {
      candidates.sort((a, b) {
        final aMatch = likedCategories.contains(a["category"]) ? 1 : 0;
        final bMatch = likedCategories.contains(b["category"]) ? 1 : 0;
        if (aMatch != bMatch) return bMatch - aMatch;
        return (b["likes"] as int? ?? 0).compareTo(a["likes"] as int? ?? 0);
      });
    } else {
      candidates.sort(
        (a, b) => (b["likes"] as int? ?? 0).compareTo(a["likes"] as int? ?? 0),
      );
    }

    return candidates.take(limit).toList();
  }

  static List<CreativeChallenge> recommendedChallenges({
    required AppUser? user,
    required CreativeChallengeController challenges,
    int limit = 5,
  }) {
    final active = challenges.active;
    if (user == null) return active.take(limit).toList();

    final myCategories = {
      if (user.discipline != null) user.discipline!,
      ...user.interests,
    };
    if (myCategories.isEmpty) return active.take(limit).toList();

    final matching = active
        .where((c) => myCategories.contains(c.categoryName))
        .toList();
    if (matching.isNotEmpty) return matching.take(limit).toList();

    return active.take(limit).toList();
  }
}
