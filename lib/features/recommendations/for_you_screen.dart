import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/creative_challenge_controller.dart';
import 'package:Zentry/core/providers/follow_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/services/auth_repository.dart';
import 'package:Zentry/core/services/recommendation_service.dart';
import 'package:Zentry/features/challenges/creative_challenge_detail_screen.dart';
import 'package:Zentry/features/communities/community_detail_screen.dart';
import 'package:Zentry/features/profile/public_profile_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  final _authRepository = AuthRepository();
  List<AppUser> _suggestedCreators = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCreators());
  }

  bool _loadingCreators = true;

  Future<void> _loadCreators() async {
    final user = context.read<AuthController>().currentUser;
    final follow = context.read<FollowController>();
    final creators = await RecommendationService.suggestedCreators(
      user: user,
      follow: follow,
      authRepository: _authRepository,
    );
    if (mounted) {
      setState(() {
        _suggestedCreators = creators;
        _loadingCreators = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final user = context.watch<AuthController>().currentUser;

    final communities = RecommendationService.recommendedCommunities(
      user: user,
      communities: context.watch<CommunityController>(),
    );
    final posts = RecommendationService.recommendedPosts(
      user: user,
      posts: context.watch<PostsController>(),
    );
    final challenges = RecommendationService.recommendedChallenges(
      user: user,
      challenges: context.watch<CreativeChallengeController>(),
    );

    final nothingToShow =
        !_loadingCreators &&
        _suggestedCreators.isEmpty &&
        communities.isEmpty &&
        challenges.isEmpty &&
        posts.isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.forYouScreenTitle)),
      body: RefreshIndicator(
        onRefresh: _loadCreators,
        color: accentColor,
        child: nothingToShow
            ? ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                  Icon(
                    Icons.auto_awesome_outlined,
                    color: Colors.grey.shade700,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      l10n.forYouEmptyTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      l10n.forYouEmptySubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_suggestedCreators.isNotEmpty) ...[
                    _sectionTitle(
                      icon: Icons.person_search_rounded,
                      color: Colors.tealAccent,
                      title: l10n.forYouCreatorsTitle,
                    ),
                    SizedBox(
                      height: 128,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _suggestedCreators.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final creator = _suggestedCreators[i];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PublicProfileScreen(user: creator),
                                ),
                              );
                            },
                            child: Container(
                              width: 96,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF171725),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: accentColor.withOpacity(
                                      .2,
                                    ),
                                    backgroundImage: creator.photoPath != null
                                        ? FileImage(File(creator.photoPath!))
                                        : null,
                                    child: creator.photoPath == null
                                        ? Icon(Icons.person, color: accentColor)
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    creator.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                  if (communities.isNotEmpty) ...[
                    _sectionTitle(
                      icon: Icons.groups_rounded,
                      color: Colors.deepPurpleAccent,
                      title: l10n.forYouCommunitiesTitle,
                    ),
                    for (final c in communities)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CommunityDetailScreen(communityId: c.id),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF171725),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white10,
                                backgroundImage: c.iconPath != null
                                    ? FileImage(File(c.iconPath!))
                                    : null,
                                child: c.iconPath == null
                                    ? const Icon(
                                        Icons.groups_rounded,
                                        color: Colors.white54,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.categoryName,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white38,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                  if (challenges.isNotEmpty) ...[
                    _sectionTitle(
                      icon: Icons.emoji_events_outlined,
                      color: Colors.amber,
                      title: l10n.forYouChallengesTitle,
                    ),
                    for (final c in challenges)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreativeChallengeDetailScreen(
                                challengeId: c.id,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF171725),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.emoji_events_outlined,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.categoryName,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white38,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                  if (posts.isNotEmpty) ...[
                    _sectionTitle(
                      icon: Icons.dynamic_feed_rounded,
                      color: Colors.pinkAccent,
                      title: l10n.forYouContentTitle,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final imageFile = post["imageFile"] as File?;
                        final imageUrl = post["image"] as String?;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: Colors.white10,
                            child: imageFile != null
                                ? Image.file(
                                    imageFile,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  )
                                : imageUrl != null
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Text(
                                      post["content"] as String? ?? '',
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
