import 'package:Zentry/core/models/mock_creator.dart';
import 'package:Zentry/core/models/zentry_category.dart';
import 'package:Zentry/features/achievements/achievements_screen.dart';
import 'package:Zentry/features/communities/communities_screen.dart';
import 'package:Zentry/features/explore/category_detail_screen.dart';
import 'package:Zentry/features/recommendations/for_you_screen.dart';
import 'package:Zentry/features/profile/creator_detail_screen.dart';
import 'package:Zentry/features/subscription/subscription_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openGroup(CategoryGroup group, {String? initialSubcategory}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(
          group: group,
          initialSubcategory: initialSubcategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final matches = searchZentryCategories(_query);
    final creatorMatches = searchMockCreators(_query);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zentry',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMenuItem(
                      context,
                      l10n.communitiesScreenTitle,
                      icon: Icons.groups_rounded,
                      highlightColor: Colors.tealAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CommunitiesScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),

                    _buildMenuItem(
                      context,
                      l10n.forYouScreenTitle,
                      icon: Icons.auto_awesome,
                      highlightColor: Colors.pinkAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForYouScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),

                    _buildMenuItem(
                      context,
                      'Achievements',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AchievementsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),

                    _buildMenuItem(
                      context,
                      'Subscriptions',
                      isPremium: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: l10n.exploreSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _query = '';
                          }),
                        ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: _query.isEmpty
                    ? _buildGroupsView(context, l10n)
                    : _buildSearchResults(
                        context,
                        l10n,
                        matches,
                        creatorMatches,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsView(BuildContext context, AppLocalizations l10n) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.exploreCategoriesTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.exploreCategoriesSubtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final group = kZentryCategoryGroups[index];
            return _buildGroupCard(context, l10n, group);
          }, childCount: kZentryCategoryGroups.length),
        ),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Creators',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 122,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: kMockCreators.length,
                  itemBuilder: (context, index) {
                    final creator = kMockCreators[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreatorDetailScreen(
                              name: creator.name,
                              role: creator.role,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 96,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: creator.color.withOpacity(0.35),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: creator.color.withOpacity(0.22),
                              child: Text(
                                creator.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: creator.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              creator.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              creator.role,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 10.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    AppLocalizations l10n,
    CategoryGroup group,
  ) {
    return GestureDetector(
      onTap: () => _openGroup(group),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              group.color.withOpacity(0.28),
              group.color.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: group.color.withOpacity(0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: group.color.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(group.icon, color: group.color, size: 20),
                ),
                Text(group.emoji, style: const TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              group.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.exploreSubcategoryCount(group.subcategories.length),
              style: TextStyle(color: Colors.grey[400], fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    AppLocalizations l10n,
    List<CategoryMatch> matches,
    List<MockCreator> creatorMatches,
  ) {
    if (matches.isEmpty && creatorMatches.isEmpty) {
      return Center(
        child: Text(
          l10n.exploreNoSearchResults,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      );
    }

    return ListView(
      children: [
        if (creatorMatches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.exploreCreatorResultsCount(creatorMatches.length),
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ),
          for (final creator in creatorMatches)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: creator.color.withOpacity(0.22),
                child: Text(
                  creator.name[0].toUpperCase(),
                  style: TextStyle(
                    color: creator.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                creator.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                creator.role,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatorDetailScreen(
                    name: creator.name,
                    role: creator.role,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
        if (matches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.exploreSearchResultsCount(matches.length),
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ),
          for (final match in matches)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: match.group.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  match.group.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              title: Text(
                match.subcategory,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                match.group.name,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _openGroup(
                match.group,
                initialSubcategory: match.subcategory,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String text, {
    required VoidCallback onTap,
    bool isPremium = false,
    IconData? icon,
    Color? highlightColor,
  }) {
    final highlighted = isPremium || highlightColor != null;
    final color = highlightColor ?? Colors.purpleAccent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: highlighted ? color.withOpacity(0.2) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: highlighted ? color : Colors.grey[400],
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                color: highlighted ? color : Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
