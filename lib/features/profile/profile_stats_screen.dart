import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/providers/follow_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

const List<String> _kDayLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

class ProfileStatsScreen extends StatelessWidget {
  const ProfileStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final engagement = context.watch<EngagementController>();
    final user = context.watch<AuthController>().currentUser;
    final postsController = context.watch<PostsController>();
    final follow = context.watch<FollowController>();

    final myPosts = user == null
        ? const <Map<String, dynamic>>[]
        : postsController.postsByUser(user.displayName);
    final totalReactions = myPosts.fold<int>(
      0,
      (sum, p) => sum + ((p["likes"] as int?) ?? 0),
    );
    final totalComments = myPosts.fold<int>(
      0,
      (sum, p) => sum + ((p["comments"] as List?)?.length ?? 0),
    );
    final followersCount = user == null ? 0 : follow.followersCount(user.id);

    Map<String, dynamic>? topPost;
    for (final p in myPosts) {
      final likes = (p["likes"] as int?) ?? 0;
      final topLikes = (topPost?["likes"] as int?) ?? -1;
      if (topPost == null || likes > topLikes) topPost = p;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileStatsScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.profileStatsContentTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  icon: Icons.grid_on_rounded,
                  color: Colors.tealAccent,
                  label: l10n.profileStatsTotalPosts,
                  value: myPosts.length,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryTile(
                  icon: Icons.favorite,
                  color: Colors.redAccent,
                  label: l10n.profileStatsTotalReactions,
                  value: totalReactions,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  icon: Icons.mode_comment_outlined,
                  color: Colors.blueAccent,
                  label: l10n.profileStatsTotalComments,
                  value: totalComments,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryTile(
                  icon: Icons.people_alt_outlined,
                  color: Colors.purpleAccent,
                  label: l10n.profileStatsTotalFollowers,
                  value: followersCount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.profileStatsViewsUnavailable,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.profileStatsTopContentTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (topPost == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF171725),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.profileStatsNoPostsYet,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            )
          else
            _topPostCard(topPost),
          const SizedBox(height: 24),
          _statSection(
            title: l10n.profileStatsWeeklyLikes,
            icon: Icons.favorite,
            color: Colors.redAccent,
            values: engagement.weeklyLikes,
            l10n: l10n,
          ),
          const SizedBox(height: 18),
          _statSection(
            title: l10n.profileStatsWeeklySaves,
            icon: Icons.bookmark,
            color: Colors.amber,
            values: engagement.weeklySaves,
            l10n: l10n,
          ),
          const SizedBox(height: 18),
          _statSection(
            title: l10n.profileStatsWeeklyShares,
            icon: Icons.share,
            color: Colors.blueAccent,
            values: engagement.weeklyShares,
            l10n: l10n,
          ),
          const SizedBox(height: 18),
          _statSection(
            title: l10n.profileStatsWeeklyVisits,
            icon: Icons.visibility,
            color: Colors.purpleAccent,
            values: engagement.weeklyVisits,
            l10n: l10n,
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required IconData icon,
    required Color color,
    required String label,
    required int value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171725),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _topPostCard(Map<String, dynamic> post) {
    final imageFile = post["imageFile"] as File?;
    final imageUrl = post["image"] as String?;
    final content = post["content"] as String? ?? '';
    final likes = (post["likes"] as int?) ?? 0;
    final comments = (post["comments"] as List?)?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171725),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: imageFile != null
                  ? Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.white10,
                        child: const Icon(Icons.image, color: Colors.white24),
                      ),
                    )
                  : imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: Colors.white10,
                      child: const Icon(Icons.notes, color: Colors.white24),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content.isEmpty ? '—' : content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$likes',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.mode_comment_outlined,
                    color: Colors.blueAccent.shade100,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$comments',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<int> values,
    required AppLocalizations l10n,
  }) {
    final total = values.fold<int>(0, (sum, v) => sum + v);
    final maxValue = values.fold<int>(1, (m, v) => v > m ? v : m);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171725),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                l10n.profileStatsTotalLabel(total),
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (i) {
                final ratio = values[i] / maxValue;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${values[i]}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          height: 50 * ratio.clamp(0.04, 1.0),
                          decoration: BoxDecoration(
                            color: values[i] == 0
                                ? Colors.white12
                                : color.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _kDayLetters[i % 7],
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
