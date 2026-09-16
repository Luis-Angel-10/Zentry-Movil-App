import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/models/community.dart';
import 'package:Zentry/core/models/creative_challenge.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/creative_challenge_controller.dart';
import 'package:Zentry/core/providers/follow_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/services/auth_repository.dart';

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

  static Future<List<AppUser>> suggestedCreators({
    required AppUser? user,
    required FollowController follow,
    required AuthRepository authRepository,
    int limit = 5,
  }) async {
    if (user == null) return const [];

    final all = await authRepository.allUsers(excludeId: user.id);
    final notFollowed = all
        .where((u) => !follow.isFollowing(user.id, u.id))
        .toList();

    int score(AppUser candidate) {
      var s = 0;
      if (candidate.discipline != null &&
          candidate.discipline == user.discipline) {
        s += 2;
      }
      if (candidate.discipline != null &&
          user.interests.contains(candidate.discipline)) {
        s += 1;
      }
      s += candidate.interests.where(user.interests.contains).length;
      return s;
    }

    notFollowed.sort((a, b) => score(b).compareTo(score(a)));

    return notFollowed.take(limit).toList();
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
