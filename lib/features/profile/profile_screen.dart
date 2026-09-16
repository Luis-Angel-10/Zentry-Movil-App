import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:Zentry/core/models/achievement.dart';
import 'package:Zentry/core/models/avatar_frame.dart';
import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/models/portfolio_item.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/providers/follow_controller.dart';
import 'package:Zentry/core/providers/portfolio_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/providers/virtual_pet_controller.dart';
import 'package:Zentry/features/communities/community_detail_screen.dart';
import 'package:Zentry/features/profile/add_portfolio_item_screen.dart';
import 'package:Zentry/features/profile/edit_profile_screen.dart';
import 'package:Zentry/features/profile/pet_detail_screen.dart';
import 'package:Zentry/features/profile/qr_code_screen.dart';
import 'package:Zentry/features/stories/story_viewer_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

Future<void> _pickCoverPhoto(BuildContext context) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );
  if (image == null || !context.mounted) return;

  // Sube el banner al backend (multipart -> /uploads/profiles/**) y lo guarda
  // también en local para verlo al instante.
  final failure = await context.read<AuthController>().updateProfile(
    bannerPath: image.path,
    coverPhotoPath: image.path,
  );
  if (failure != null && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

String _portfolioStatusLabel(AppLocalizations l10n, PortfolioStatus status) {
  switch (status) {
    case PortfolioStatus.concept:
      return l10n.portfolioStatusConcept;
    case PortfolioStatus.inProgress:
      return l10n.portfolioStatusInProgress;
    case PortfolioStatus.completed:
      return l10n.portfolioStatusCompleted;
  }
}

void _showPortfolioItemDetail(
  BuildContext context,
  PortfolioItem item,
  AppLocalizations l10n,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF171725),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subcategoryName != null
                    ? '${item.categoryName} · ${item.subcategoryName}'
                    : item.categoryName,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Chip(
                label: Text(_portfolioStatusLabel(l10n, item.status)),
                backgroundColor: Colors.white10,
                labelStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  item.description,
                  style: TextStyle(color: Colors.grey.shade300, height: 1.4),
                ),
              ],
              if (item.tools.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: item.tools
                      .map(
                        (t) => Chip(
                          label: Text(t),
                          backgroundColor: Colors.white10,
                          labelStyle: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (item.collaborators.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  item.collaborators.join(', '),
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
              if ((item.externalLink ?? '').isNotEmpty) ...[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri.tryParse(item.externalLink!);
                    if (uri != null) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.portfolioOpenLinkButton),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthController>().refreshProfile();
      context.read<PostsController>().loadMyBackendPosts();
    });
  }

  /// Adapta un [PostResponse] real al formato de mapa que consumen los
  /// widgets de las pestañas del perfil (diseño sin cambios).
  Map<String, dynamic> _adaptBackendPost(PostResponse p) => {
    'id': p.id.toString(),
    'category': p.contentType ?? 'post',
    'image': p.imageUrlAbsolute,
    'imageFile': null,
    'content': p.content ?? '',
    'title': p.title,
  };

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final auth = context.watch<AuthController>();
    final currentUser = auth.currentUser;
    final backendProfile = auth.backendProfile;
    final follow = context.watch<FollowController>();
    final postsController = context.watch<PostsController>();

    // Pestaña "Publicaciones": feed real del backend (mis publicaciones).
    final backendMine = postsController.myBackendPosts
        .map(_adaptBackendPost)
        .toList();
    // Pestaña "Proyectos": proyectos/colaboraciones locales (aún sin backend).
    final localProjects = currentUser != null
        ? postsController
              .postsByUser(currentUser.displayName)
              .where(
                (p) =>
                    p["communityId"] == null &&
                    (p["category"] == l10n.createTabProject ||
                        p["category"] == l10n.createTabCollaboration),
              )
              .toList()
        : <Map<String, dynamic>>[];

    final myPosts = <Map<String, dynamic>>[...backendMine, ...localProjects];

    final postsCount = backendMine.length;

    // Imagen efectiva: foto local elegida por el usuario > URL del backend.
    final localCover = currentUser?.coverPhotoPath;
    final localAvatar = currentUser?.photoPath;
    final ImageProvider? coverProvider =
        (localCover != null && localCover.isNotEmpty)
        ? FileImage(File(localCover))
        : (backendProfile?.bannerUrlAbsolute != null
              ? NetworkImage(backendProfile!.bannerUrlAbsolute!)
              : null);
    final ImageProvider? avatarProvider =
        (localAvatar != null && localAvatar.isNotEmpty)
        ? FileImage(File(localAvatar))
        : (backendProfile?.avatarUrlAbsolute != null
              ? NetworkImage(backendProfile!.avatarUrlAbsolute!)
              : null);

    final followersCount =
        backendProfile?.followersCount ??
        (currentUser != null ? follow.followersCount(currentUser.id) : 0);
    final followingCount =
        backendProfile?.followingCount ??
        (currentUser != null ? follow.followingCount(currentUser.id) : 0);

    final highlights = currentUser != null
        ? context.watch<PostsController>().highlightedStoriesOf(
            currentUser.displayName,
          )
        : <Map<String, dynamic>>[];

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () => _pickCoverPhoto(context),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: coverProvider == null
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF2A1B4D),
                                      Color(0xFF120F1F),
                                    ],
                                  )
                                : null,
                            image: coverProvider != null
                                ? DecorationImage(
                                    image: coverProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        bottom: -38,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              gradient: LinearGradient(
                                colors: avatarFrameColors(
                                  currentUser?.avatarFrameId,
                                ),
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: Colors.white10,
                              backgroundImage: avatarProvider,
                              child: avatarProvider == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white54,
                                      size: 36,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 46),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                currentUser?.displayName ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            for (final id
                                in currentUser?.featuredBadgeIds ?? const [])
                              if (kAchievementDefs
                                  .where((d) => d.id == id)
                                  .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Icon(
                                    kAchievementDefs
                                        .firstWhere((d) => d.id == id)
                                        .icon,
                                    color: kAchievementDefs
                                        .firstWhere((d) => d.id == id)
                                        .color,
                                    size: 18,
                                  ),
                                ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '@${currentUser?.username ?? ''}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                            if ((backendProfile?.rank ?? '').isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  backendProfile!.rank!,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (backendProfile?.discipline?.isNotEmpty ?? false)
                              ? backendProfile!.discipline!
                              : currentUser?.discipline ??
                                    "Desarrollador Creativo",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        if ((backendProfile?.location ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 13,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 3),
                              Text(
                                backendProfile!.location!,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              if (backendProfile.createdAt != null) ...[
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Miembro desde '
                                  '${backendProfile.createdAt!.year}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          (backendProfile?.bio?.isNotEmpty ?? false)
                              ? backendProfile!.bio!
                              : (currentUser?.bio?.isNotEmpty ?? false)
                              ? currentUser!.bio!
                              : "Creando experiencias digitales, arte y tecnología 🚀",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        if (highlights.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 82,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: highlights.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (_, i) {
                                final story = highlights[i];
                                final imageFile = story["imageFile"] as File?;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StoryViewerScreen(
                                          stories: highlights,
                                          initialIndex: i,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: accentColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.white10,
                                          backgroundImage: imageFile != null
                                              ? FileImage(imageFile)
                                              : null,
                                          child: imageFile == null
                                              ? const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.profileHighlightsLabel,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStat('$postsCount', l10n.profilePostsLabel),
                              _buildStat(
                                '$followersCount',
                                l10n.profileFollowersLabel,
                              ),
                              _buildStat(
                                '$followingCount',
                                l10n.profileFollowingLabel,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfileScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B5CF6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  l10n.profileEditButton,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const QrCodeScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A1A24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  l10n.commonShare,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const _VirtualPetCard(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: accentColor,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: accentColor,
                  tabs: [
                    Tab(text: l10n.profileTabPosts),
                    Tab(text: l10n.profileTabProjects),
                    Tab(text: l10n.profileTabPortfolio),
                    Tab(text: l10n.profileTabCommunities),
                    Tab(text: l10n.profileTabAchievements),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _PostsGridTab(
                posts: myPosts,
                l10n: l10n,
                accentColor: accentColor,
              ),
              _ProjectsTab(posts: myPosts, l10n: l10n),
              _PortfolioTab(userId: currentUser?.id, l10n: l10n),
              _CommunitiesTab(userId: currentUser?.id, l10n: l10n),
              _AchievementsTab(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
      ],
    );
  }
}

class _ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _ProfileTabBarDelegate(this.tabBar);

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
  bool shouldRebuild(_ProfileTabBarDelegate oldDelegate) => true;
}

class _PostsGridTab extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final AppLocalizations l10n;
  final Color accentColor;

  const _PostsGridTab({
    required this.posts,
    required this.l10n,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final feedPosts = posts
        .where(
          (p) =>
              p["category"] != l10n.createTabProject &&
              p["category"] != l10n.createTabCollaboration,
        )
        .toList();

    if (feedPosts.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Text(
            l10n.profileNoPostsYet,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: feedPosts.length,
      itemBuilder: (context, index) {
        final post = feedPosts[index];
        final imageFile = post["imageFile"] as File?;
        final imageUrl = post["image"] as String?;
        return Container(
          color: Colors.white10,
          child: imageFile != null
              ? Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                )
              : imageUrl != null
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white24,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    post["content"] as String? ?? '',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
        );
      },
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final AppLocalizations l10n;

  const _ProjectsTab({required this.posts, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final projects = posts
        .where(
          (p) =>
              p["category"] == l10n.createTabProject ||
              p["category"] == l10n.createTabCollaboration,
        )
        .toList();

    if (projects.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Text(
            l10n.profileNoProjectsYet,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final p = projects[index];
        final progress = p["progress"] as double?;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (p["title"] as String?)?.isNotEmpty == true
                    ? p["title"] as String
                    : p["category"] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p["content"] as String? ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              if (progress != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PortfolioTab extends StatelessWidget {
  final int? userId;
  final AppLocalizations l10n;

  const _PortfolioTab({required this.userId, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final items = userId != null
        ? context.watch<PortfolioController>().itemsOf(userId!)
        : const <PortfolioItem>[];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPortfolioItemScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: Text(l10n.portfolioAddButton),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.work_outline,
                    color: Colors.grey.shade700,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.portfolioEmptyTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.portfolioEmptySubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => _showPortfolioItemDetail(context, item, l10n),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    image: item.imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(item.imagePath!)),
                            fit: BoxFit.cover,
                            opacity: 0.35,
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.categoryName,
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _CommunitiesTab extends StatelessWidget {
  final int? userId;
  final AppLocalizations l10n;

  const _CommunitiesTab({required this.userId, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final communities = userId != null
        ? context.watch<CommunityController>().myCommunities(userId!)
        : const [];

    if (communities.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Text(
            l10n.profileNoCommunitiesYet,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: communities.length,
      itemBuilder: (context, index) {
        final c = communities[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white10,
            backgroundImage: c.iconPath != null
                ? FileImage(File(c.iconPath!))
                : null,
            child: c.iconPath == null
                ? const Icon(Icons.groups_rounded, color: Colors.white54)
                : null,
          ),
          title: Text(c.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            c.categoryName,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommunityDetailScreen(communityId: c.id),
              ),
            );
          },
        );
      },
    );
  }
}

class _AchievementsTab extends StatelessWidget {
  final AppLocalizations l10n;

  const _AchievementsTab({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final unlocked = context.watch<EngagementController>().unlockedAchievements;
    final defs = kAchievementDefs
        .where((d) => unlocked.contains(d.id))
        .toList();

    if (defs.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Text(
            l10n.profileNoAchievementsYet,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: defs.length,
      itemBuilder: (context, index) {
        final def = defs[index];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(def.icon, color: def.color, size: 30),
              const SizedBox(height: 6),
              Text(
                '${def.points} pts',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VirtualPetCard extends StatefulWidget {
  const _VirtualPetCard();

  @override
  State<_VirtualPetCard> createState() => _VirtualPetCardState();
}

class _VirtualPetCardState extends State<_VirtualPetCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;
  late final Animation<double> _idleFloat;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _idleFloat = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pet = context.watch<VirtualPetController>().pet;

    if (pet == null) return const SizedBox.shrink();

    final color = moodColor(pet.mood);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PetDetailScreen()),
            );
          },
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.22), const Color(0xFF171725)],
              ),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _idleController,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _idleFloat.value),
                    child: child,
                  ),
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withOpacity(0.35),
                          color.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Text(
                      pet.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _miniTag(l10n.petLevelLabel(pet.level), color),
                          _miniTag(moodLabel(l10n, pet.mood), color),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
