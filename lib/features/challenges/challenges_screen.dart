import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/challenge.dart';
import 'package:Zentry/core/models/creative_challenge.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/providers/creative_challenge_controller.dart';
import 'package:Zentry/features/challenges/create_creative_challenge_screen.dart';
import 'package:Zentry/features/challenges/creative_challenge_detail_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _titleFor(AppLocalizations l10n, String id) {
    switch (id) {
      case 'weekly_likes_15':
        return l10n.challengeLikes15Title;
      case 'weekly_posts_3':
        return l10n.challengePosts3Title;
      case 'weekly_comments_5':
        return l10n.challengeComments5Title;
      case 'weekly_shares_5':
        return l10n.challengeShares5Title;
      case 'weekly_saves_5':
        return l10n.challengeSaves5Title;
      case 'weekly_streak_5':
        return l10n.challengeStreak5Title;
      case 'weekly_likes_30':
        return l10n.challengeLikes30Title;
      case 'weekly_posts_5':
        return l10n.challengePosts5Title;
      case 'weekly_comments_15':
        return l10n.challengeComments15Title;
    }
    throw ArgumentError('Unknown challenge id: $id');
  }

  String _descFor(AppLocalizations l10n, String id) {
    switch (id) {
      case 'weekly_likes_15':
        return l10n.challengeLikes15Desc;
      case 'weekly_posts_3':
        return l10n.challengePosts3Desc;
      case 'weekly_comments_5':
        return l10n.challengeComments5Desc;
      case 'weekly_shares_5':
        return l10n.challengeShares5Desc;
      case 'weekly_saves_5':
        return l10n.challengeSaves5Desc;
      case 'weekly_streak_5':
        return l10n.challengeStreak5Desc;
      case 'weekly_likes_30':
        return l10n.challengeLikes30Desc;
      case 'weekly_posts_5':
        return l10n.challengePosts5Desc;
      case 'weekly_comments_15':
        return l10n.challengeComments15Desc;
    }
    throw ArgumentError('Unknown challenge id: $id');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final engagement = context.watch<EngagementController>();
    final creative = context.watch<CreativeChallengeController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.challengesScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${engagement.zCoins}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade500,
          tabs: [
            Tab(text: l10n.challengesTabOfficial),
            Tab(text: l10n.challengesTabCreative),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.challengesScreenSubtitle,
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 18),
              for (final def in kChallengeDefs)
                _challengeCard(context, l10n, engagement, def),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateCreativeChallengeScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.challengeCreateButton),
              ),
              const SizedBox(height: 14),
              if (creative.active.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      l10n.challengesCreativeEmpty,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                for (final c in creative.active)
                  _creativeChallengeCard(context, l10n, c),
            ],
          ),
        ],
      ),
    );
  }

  Widget _creativeChallengeCard(
    BuildContext context,
    AppLocalizations l10n,
    CreativeChallenge c,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreativeChallengeDetailScreen(challengeId: c.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  c.source == ChallengeSource.community
                      ? Icons.groups
                      : Icons.person,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              c.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.challengeParticipantsCount(c.participantIds.length),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _challengeCard(
    BuildContext context,
    AppLocalizations l10n,
    EngagementController engagement,
    ChallengeDef def,
  ) {
    final progress = engagement.weeklyProgressFor(def.metric);
    final claimed = engagement.isChallengeClaimed(def.id);
    final completed = progress >= def.threshold;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, def.color.withOpacity(0.2)],
        ),
        border: Border.all(color: def.color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: def.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(def.icon, color: def.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleFor(l10n, def.id),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _descFor(l10n, def.id),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 16,
                  ),
                  Text(
                    '+${def.reward}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (progress / def.threshold).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey[850],
              color: def.color,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.challengeProgressLabel(
                  progress > def.threshold ? def.threshold : progress,
                  def.threshold,
                ),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              SizedBox(
                height: 34,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: claimed
                        ? Colors.grey.shade800
                        : (completed ? def.color : Colors.grey.shade800),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: completed && !claimed
                      ? () async {
                          final ok = await context
                              .read<EngagementController>()
                              .claimChallenge(def.id);
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.challengeClaimedSnackbar(def.reward),
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  child: Text(
                    claimed
                        ? l10n.challengeClaimedLabel
                        : l10n.challengeClaimLabel,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
