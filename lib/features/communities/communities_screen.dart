import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/models/community.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/features/communities/community_detail_screen.dart';
import 'package:Zentry/features/communities/create_community_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Community> _search(List<Community> all, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return all.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.categoryName.toLowerCase().contains(q) ||
          (c.subcategoryName ?? '').toLowerCase().contains(q) ||
          c.hashtags.any((h) => h.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final communityController = context.watch<CommunityController>();
    final postsController = context.watch<PostsController>();
    final user = context.watch<AuthController>().currentUser;

    final all = communityController.communities;
    final mine = user != null
        ? communityController.myCommunities(user.id)
        : const <Community>[];
    final mineIds = mine.map((c) => c.id).toSet();
    final notJoined = all.where((c) => !mineIds.contains(c.id)).toList();

    final myCategories = mine.map((c) => c.categoryName).toSet();
    final recommended = notJoined
        .where((c) => myCategories.contains(c.categoryName))
        .toList();

    final popular = List<Community>.from(notJoined)
      ..sort(
        (a, b) => communityController
            .memberCount(b.id)
            .compareTo(communityController.memberCount(a.id)),
      );

    final newest = List<Community>.from(all)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final mostActive = List<Community>.from(all)
      ..sort(
        (a, b) => postsController
            .postsForCommunity(b.id)
            .length
            .compareTo(postsController.postsForCommunity(a.id).length),
      );

    final searchResults = _search(all, _query);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.communitiesScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: l10n.communitiesCreateButton,
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateCommunityScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            l10n.communitiesHeading,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.communitiesSubtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: l10n.communitiesSearchHint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => setState(() {
                        _searchController.clear();
                        _query = '';
                      }),
                    ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (_query.isNotEmpty)
            _searchResultsSection(l10n, accentColor, searchResults, user)
          else ...[
            if (mine.isNotEmpty)
              _section(
                context,
                title: l10n.communitiesSectionMine,
                communities: mine,
                accentColor: accentColor,
                user: user,
              )
            else
              _emptyMineHint(l10n),

            const SizedBox(height: 26),

            if (recommended.isNotEmpty)
              _section(
                context,
                title: l10n.communitiesSectionRecommended,
                communities: recommended.take(10).toList(),
                accentColor: accentColor,
                user: user,
              ),

            const SizedBox(height: 26),

            if (popular.isNotEmpty)
              _section(
                context,
                title: l10n.communitiesSectionPopular,
                communities: popular.take(10).toList(),
                accentColor: accentColor,
                user: user,
              ),

            const SizedBox(height: 26),

            if (newest.isNotEmpty)
              _section(
                context,
                title: l10n.communitiesSectionNew,
                communities: newest.take(10).toList(),
                accentColor: accentColor,
                user: user,
              ),

            const SizedBox(height: 26),

            if (mostActive.isNotEmpty &&
                postsController
                    .postsForCommunity(mostActive.first.id)
                    .isNotEmpty)
              _section(
                context,
                title: l10n.communitiesSectionActive,
                communities: mostActive
                    .where(
                      (c) => postsController.postsForCommunity(c.id).isNotEmpty,
                    )
                    .take(10)
                    .toList(),
                accentColor: accentColor,
                user: user,
              ),

            if (all.isEmpty) _emptyState(context, l10n, accentColor),
          ],
        ],
      ),
    );
  }

  Widget _emptyMineHint(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff171725),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.groups_outlined, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.communitiesNoneJoinedHint,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchResultsSection(
    AppLocalizations l10n,
    Color accentColor,
    List<Community> results,
    AppUser? user,
  ) {
    if (results.isEmpty) {
      return _emptyState(context, l10n, accentColor);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final community in results)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _CommunityCard(
              community: community,
              accentColor: accentColor,
              user: user,
              horizontal: true,
            ),
          ),
      ],
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Community> communities,
    required Color accentColor,
    required AppUser? user,
  }) {
    if (communities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: communities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 220,
              child: _CommunityCard(
                community: communities[i],
                accentColor: accentColor,
                user: user,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(
    BuildContext context,
    AppLocalizations l10n,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.groups_outlined, color: Colors.grey.shade700, size: 72),
            const SizedBox(height: 20),
            Text(
              l10n.communitiesEmptyTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.communitiesEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: accentColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateCommunityScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.communitiesCreateButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final Community community;
  final Color accentColor;
  final AppUser? user;
  final bool horizontal;

  const _CommunityCard({
    required this.community,
    required this.accentColor,
    required this.user,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final communityController = context.watch<CommunityController>();
    final postsController = context.watch<PostsController>();
    final currentUser = user;
    final memberCount = communityController.memberCount(community.id);
    final postCount = postsController.postsForCommunity(community.id).length;
    final role = currentUser != null
        ? communityController.roleOf(community.id, currentUser.id)
        : null;
    final isMember = role != null;
    final hasPendingRequest = currentUser != null
        ? communityController.hasPendingRequest(community.id, currentUser.id)
        : false;

    final cover = Container(
      height: horizontal ? 80 : 92,
      width: horizontal ? 80 : double.infinity,
      decoration: BoxDecoration(
        borderRadius: horizontal
            ? BorderRadius.circular(14)
            : const BorderRadius.vertical(top: Radius.circular(18)),
        gradient: community.coverPath == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A1B4D), Color(0xFF120F1F)],
              )
            : null,
        image: community.coverPath != null
            ? DecorationImage(
                image: FileImage(File(community.coverPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: accentColor.withOpacity(.25),
            backgroundImage: community.iconPath != null
                ? FileImage(File(community.iconPath!))
                : null,
            child: community.iconPath == null
                ? Icon(Icons.groups_rounded, color: accentColor, size: 16)
                : null,
          ),
        ),
      ),
    );

    final joinButton = SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: hasPendingRequest ? null : () => _handleTap(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isMember ? Colors.green : accentColor,
          disabledBackgroundColor: Colors.grey.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isMember
              ? l10n.communitiesMemberLabel
              : hasPendingRequest
              ? l10n.communitiesRequestPendingLabel
              : community.isPrivate
              ? l10n.communitiesRequestLabel
              : l10n.communitiesJoinLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    final info = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  community.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                community.isPrivate ? Icons.lock_outline : Icons.public,
                size: 13,
                color: Colors.grey.shade500,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            community.description,
            maxLines: horizontal ? 2 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11.5),
          ),
          const SizedBox(height: 6),
          Text(
            community.subcategoryName != null
                ? '${community.categoryName} · ${community.subcategoryName}'
                : community.categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: accentColor, fontSize: 10.5),
          ),
          if (community.hashtags.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              community.hashtags.take(3).map((t) => '#$t').join('  '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10.5),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.groups, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                '$memberCount',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.article_outlined,
                size: 13,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                '$postCount',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
              const Spacer(),
              joinButton,
            ],
          ),
        ],
      ),
    );

    final card = Container(
      decoration: BoxDecoration(
        color: const Color(0xff171725),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: horizontal
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18),
                  ),
                  child: cover,
                ),
                Expanded(child: info),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [cover, info],
            ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityDetailScreen(communityId: community.id),
          ),
        );
      },
      child: card,
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = user;
    if (currentUser == null) return;

    final communityController = context.read<CommunityController>();
    final role = communityController.roleOf(community.id, currentUser.id);

    if (role != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityDetailScreen(communityId: community.id),
        ),
      );
      return;
    }

    final joined = await communityController.joinOrRequest(
      community,
      currentUser,
    );
    if (!context.mounted) return;
    if (!joined) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.communityJoinRequestSentSnackbar)),
      );
    }
  }
}
