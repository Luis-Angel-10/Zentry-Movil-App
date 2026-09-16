import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:Zentry/core/models/community.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/services/auth_repository.dart';
import 'package:Zentry/features/challenges/create_creative_challenge_screen.dart';
import 'package:Zentry/features/collaboration/collaboration_action_button.dart';
import 'package:Zentry/features/create/create_screen.dart';
import 'package:Zentry/features/profile/public_profile_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class CommunityDetailScreen extends StatelessWidget {
  final String communityId;

  const CommunityDetailScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    final communities = context.watch<CommunityController>().communities;
    final community = communities.where((c) => c.id == communityId).firstOrNull;

    if (community == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('...')),
      );
    }

    return _CommunityDetailBody(community: community);
  }
}

class _CommunityDetailBody extends StatefulWidget {
  final Community community;

  const _CommunityDetailBody({required this.community});

  @override
  State<_CommunityDetailBody> createState() => _CommunityDetailBodyState();
}

class _CommunityDetailBodyState extends State<_CommunityDetailBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final communityController = context.watch<CommunityController>();
    final user = context.watch<AuthController>().currentUser;
    final community = widget.community;

    final role = user != null
        ? communityController.roleOf(community.id, user.id)
        : null;
    final isMember = role != null;
    final isOwner = role == CommunityRole.owner;
    final isModerator = role == CommunityRole.moderator;
    final canManage = isOwner || isModerator;
    final memberCount = communityController.memberCount(community.id);
    final hasPendingRequest = user != null
        ? communityController.hasPendingRequest(community.id, user.id)
        : false;
    final canSeeRestrictedContent = !community.isPrivate || isMember;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _Header(
                community: community,
                memberCount: memberCount,
                accentColor: accentColor,
              ),
            ),
            SliverToBoxAdapter(
              child: _ActionsRow(
                community: community,
                role: role,
                hasPendingRequest: hasPendingRequest,
                accentColor: accentColor,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade500,
                  indicatorColor: accentColor,
                  tabs: [
                    Tab(text: l10n.communityDetailAboutTab),
                    Tab(text: l10n.communityDetailPostsTab),
                    Tab(text: l10n.communityDetailMembersTab),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _AboutTab(community: community, canManage: canManage),
            canSeeRestrictedContent
                ? _PostsTab(community: community, canPost: isMember)
                : _LockedTab(message: l10n.communityDetailPrivateLocked),
            canSeeRestrictedContent
                ? _MembersTab(
                    community: community,
                    canManage: canManage,
                    isOwner: isOwner,
                  )
                : _LockedTab(message: l10n.communityDetailPrivateLocked),
          ],
        ),
      ),
      floatingActionButton: isMember
          ? FloatingActionButton.extended(
              backgroundColor: accentColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateScreen(
                      communityId: community.id,
                      communityName: community.name,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.communityDetailCreatePostButton),
            )
          : null,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}

class _Header extends StatelessWidget {
  final Community community;
  final int memberCount;
  final Color accentColor;

  const _Header({
    required this.community,
    required this.memberCount,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
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
            ),
            Positioned(
              top: 8,
              left: 4,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              left: 18,
              bottom: -34,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: accentColor.withOpacity(.2),
                  backgroundImage: community.iconPath != null
                      ? FileImage(File(community.iconPath!))
                      : null,
                  child: community.iconPath == null
                      ? Icon(Icons.groups_rounded, color: accentColor, size: 30)
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 44),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      community.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    community.isPrivate ? Icons.lock_outline : Icons.public,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    community.isPrivate
                        ? l10n.communitiesPrivateBadge
                        : l10n.communitiesPublicBadge,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                community.description,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _pill(
                    icon: Icons.groups,
                    label: l10n.communityDetailMembersCount(memberCount),
                    accentColor: accentColor,
                  ),
                  _pill(
                    icon: Icons.category_outlined,
                    label: community.subcategoryName != null
                        ? '${community.categoryName} · ${community.subcategoryName}'
                        : community.categoryName,
                    accentColor: accentColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accentColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: accentColor, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final Community community;
  final CommunityRole? role;
  final bool hasPendingRequest;
  final Color accentColor;

  const _ActionsRow({
    required this.community,
    required this.role,
    required this.hasPendingRequest,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMember = role != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
      child: Row(
        children: [
          Expanded(
            child: isMember
                ? OutlinedButton.icon(
                    onPressed: role == CommunityRole.owner
                        ? () => _showOwnerCannotLeave(context, l10n)
                        : () => _leave(context),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(
                      role == CommunityRole.owner
                          ? l10n.communityDetailOwnerLabel
                          : l10n.communitiesMemberLabel,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentColor,
                      side: BorderSide(color: accentColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: hasPendingRequest ? null : () => _join(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      disabledBackgroundColor: accentColor.withOpacity(.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      hasPendingRequest
                          ? l10n.communityDetailPendingButton
                          : community.isPrivate
                          ? l10n.communityDetailRequestButton
                          : l10n.communityDetailJoinButton,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: const BorderSide(color: Colors.white24),
            ),
            child: const Icon(Icons.share_outlined, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Future<void> _join(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final user = context.read<AuthController>().currentUser;
    if (user == null) return;

    final joined = await context.read<CommunityController>().joinOrRequest(
      community,
      user,
    );

    if (!context.mounted) return;
    if (!joined) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.communityJoinRequestSentSnackbar)),
      );
    }
  }

  Future<void> _leave(BuildContext context) async {
    final user = context.read<AuthController>().currentUser;
    if (user == null) return;
    await context.read<CommunityController>().leaveCommunity(
      community.id,
      user.id,
    );
  }

  void _showOwnerCannotLeave(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.communityDetailOwnerCannotLeave)),
    );
  }
}

class _AboutTab extends StatelessWidget {
  final Community community;
  final bool canManage;

  const _AboutTab({required this.community, required this.canManage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final communityController = context.watch<CommunityController>();
    final owner = communityController
        .membersOf(community.id)
        .where((m) => m.role == CommunityRole.owner)
        .firstOrNull;
    final moderators = communityController
        .membersOf(community.id)
        .where((m) => m.role == CommunityRole.moderator)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          community.description,
          style: const TextStyle(color: Colors.white, height: 1.4),
        ),
        if (community.hashtags.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: community.hashtags
                .map(
                  (tag) => Chip(
                    label: Text('#$tag'),
                    backgroundColor: Theme.of(context).cardColor,
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          l10n.communityDetailRulesTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          community.rules.trim().isEmpty
              ? l10n.communityDetailNoRules
              : community.rules,
          style: TextStyle(color: Colors.grey.shade400, height: 1.4),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.communityDetailAdminsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        if (owner != null)
          _adminTile(owner.userName, l10n.communityDetailOwnerLabel),
        for (final mod in moderators)
          _adminTile(mod.userName, l10n.communityDetailModeratorLabel),
        if (canManage) ...[
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CreateCreativeChallengeScreen(communityId: community.id),
                ),
              );
            },
            icon: const Icon(Icons.emoji_events_outlined),
            label: Text(l10n.challengeCreateButton),
          ),
        ],
      ],
    );
  }

  Widget _adminTile(String name, String roleLabel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white10,
            child: Icon(Icons.person, color: Colors.white54, size: 18),
          ),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          Text(
            roleLabel,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PostsTab extends StatelessWidget {
  final Community community;
  final bool canPost;

  const _PostsTab({required this.community, required this.canPost});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allPosts = context.watch<PostsController>().posts;
    final communityPosts = allPosts
        .where((p) => p["communityId"] == community.id)
        .toList();

    if (communityPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            canPost
                ? l10n.communityDetailPostsEmpty
                : '${l10n.communityDetailPostsEmpty}\n${l10n.communityDetailJoinToPost}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: communityPosts.length,
      itemBuilder: (context, i) {
        final post = communityPosts[i];
        final realIndex = allPosts.indexOf(post);
        return _CommunityPostCard(post: post, postIndex: realIndex);
      },
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final int postIndex;

  const _CommunityPostCard({required this.post, required this.postIndex});

  @override
  Widget build(BuildContext context) {
    final imageFile = post["imageFile"] as File?;
    final videoFile = post["videoFile"] as File?;
    final content = post["content"] as String? ?? '';
    final user = post["user"] as String? ?? '';
    final time = post["time"] as String? ?? '';
    final likes = post["likes"] as int? ?? 0;
    final likedByMe = post["likedByMe"] == true;
    final comments = (post["comments"] as List?)?.length ?? 0;
    final isCollab = post["isPublicCollab"] != null;
    final postTitle = post["title"] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white10,
                child: Icon(Icons.person, color: Colors.white54, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(color: Colors.white)),
          ],
          if (imageFile != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 220,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ] else if (videoFile != null) ...[
            const SizedBox(height: 10),
            _CommunityVideoPreview(videoFile: videoFile),
          ],
          if (isCollab) ...[
            const SizedBox(height: 10),
            CollaborationActionButton(
              postId: post["id"] as String,
              postOwnerName: user,
              postTitle: (postTitle?.isNotEmpty ?? false)
                  ? postTitle!
                  : content,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  likedByMe ? Icons.favorite : Icons.favorite_border,
                  color: likedByMe ? Colors.pinkAccent : Colors.grey.shade400,
                ),
                onPressed: () {
                  final wasLiked = likedByMe;
                  context.read<PostsController>().toggleLike(postIndex);
                  if (!wasLiked) {
                    context.read<EngagementController>().registerLike();
                  }
                },
              ),
              Text('$likes', style: TextStyle(color: Colors.grey.shade400)),
              const SizedBox(width: 12),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.mode_comment_outlined,
                  color: Colors.grey.shade400,
                ),
                onPressed: () => _openCommentSheet(context),
              ),
              Text('$comments', style: TextStyle(color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }

  void _openCommentSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 18,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.homeCommentHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  final actorName =
                      context.read<AuthController>().currentUser?.displayName ??
                      'Tú';
                  context.read<PostsController>().addComment(
                    postIndex,
                    text,
                    actorName: actorName,
                  );
                  context.read<EngagementController>().registerComment();
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommunityVideoPreview extends StatefulWidget {
  final File videoFile;

  const _CommunityVideoPreview({required this.videoFile});

  @override
  State<_CommunityVideoPreview> createState() => _CommunityVideoPreviewState();
}

class _CommunityVideoPreviewState extends State<_CommunityVideoPreview> {
  VideoPlayerController? _controller;
  bool _playing = false;

  Future<void> _toggle() async {
    if (_controller == null) {
      final controller = VideoPlayerController.file(widget.videoFile);
      await controller.initialize();
      controller.setVolume(1.0);
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    }

    if (_playing) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }
    setState(() => _playing = !_playing);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return GestureDetector(
      onTap: _toggle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 220,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (controller != null && controller.value.isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                )
              else
                const ColoredBox(color: Colors.black26),
              if (!_playing)
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 54,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  final Community community;
  final bool canManage;
  final bool isOwner;

  const _MembersTab({
    required this.community,
    required this.canManage,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final communityController = context.watch<CommunityController>();
    final members = communityController.membersOf(community.id);
    final pending = canManage
        ? communityController.pendingRequestsFor(community.id)
        : const <CommunityJoinRequest>[];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        if (canManage) ...[
          Text(
            l10n.communityDetailRequestsTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (pending.isEmpty)
            Text(
              l10n.communityDetailRequestsEmpty,
              style: TextStyle(color: Colors.grey.shade500),
            )
          else
            for (final request in pending) _requestTile(context, l10n, request),
          const SizedBox(height: 22),
        ],
        Text(
          l10n.communityDetailMembersTab,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        for (final member in members) _memberTile(context, l10n, member),
      ],
    );
  }

  Widget _requestTile(
    BuildContext context,
    AppLocalizations l10n,
    CommunityJoinRequest request,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white10,
            child: Icon(Icons.person, color: Colors.white54, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              request.userName,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<CommunityController>().rejectRequest(request),
            child: Text(l10n.communityDetailReject),
          ),
          FilledButton(
            onPressed: () =>
                context.read<CommunityController>().approveRequest(request),
            child: Text(l10n.communityDetailApprove),
          ),
        ],
      ),
    );
  }

  Future<void> _openMemberProfile(
    BuildContext context,
    CommunityMember member,
  ) async {
    final user = await AuthRepository().findById(member.userId);
    if (user == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PublicProfileScreen(user: user)),
    );
  }

  Widget _memberTile(
    BuildContext context,
    AppLocalizations l10n,
    CommunityMember member,
  ) {
    final roleLabel = switch (member.role) {
      CommunityRole.owner => l10n.communityDetailOwnerLabel,
      CommunityRole.moderator => l10n.communityDetailModeratorLabel,
      CommunityRole.member => l10n.communityDetailMemberRoleLabel,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _openMemberProfile(context, member),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white10,
              backgroundImage: member.photoPath != null
                  ? FileImage(File(member.photoPath!))
                  : null,
              child: member.photoPath == null
                  ? const Icon(Icons.person, color: Colors.white54, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _openMemberProfile(context, member),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.userName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    roleLabel,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (canManage && member.role != CommunityRole.owner)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white54),
              color: Theme.of(context).cardColor,
              onSelected: (value) {
                final controller = context.read<CommunityController>();
                if (value == 'promote') {
                  controller.setRole(
                    community.id,
                    member.userId,
                    CommunityRole.moderator,
                  );
                } else if (value == 'demote') {
                  controller.setRole(
                    community.id,
                    member.userId,
                    CommunityRole.member,
                  );
                } else if (value == 'remove') {
                  controller.removeMember(community.id, member.userId);
                }
              },
              itemBuilder: (context) => [
                if (isOwner && member.role == CommunityRole.member)
                  PopupMenuItem(
                    value: 'promote',
                    child: Text(l10n.communityDetailPromote),
                  ),
                if (isOwner && member.role == CommunityRole.moderator)
                  PopupMenuItem(
                    value: 'demote',
                    child: Text(l10n.communityDetailDemote),
                  ),
                PopupMenuItem(
                  value: 'remove',
                  child: Text(l10n.communityDetailRemoveMember),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LockedTab extends StatelessWidget {
  final String message;

  const _LockedTab({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: Colors.grey.shade600, size: 48),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
