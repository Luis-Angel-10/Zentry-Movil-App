import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/achievement.dart';
import 'package:Zentry/core/models/challenge.dart';
import 'package:Zentry/core/providers/notifications_controller.dart';
import 'package:Zentry/core/services/auth_repository.dart';
import 'package:Zentry/features/achievements/achievements_screen.dart';
import 'package:Zentry/features/challenges/challenges_screen.dart';
import 'package:Zentry/features/collaboration/collaboration_requests_screen.dart';
import 'package:Zentry/features/communities/community_detail_screen.dart';
import 'package:Zentry/features/profile/public_profile_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationCategory? _filter;

  String _timeLabel(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }

  (IconData, Color) _iconAndColor(AppNotification n) {
    switch (n.type) {
      case AppNotificationType.achievement:
        final def = kAchievementDefs.firstWhere(
          (d) => d.id == n.data['achievementId'],
          orElse: () => kAchievementDefs.first,
        );
        return (def.icon, def.color);
      case AppNotificationType.challenge:
        final def = kChallengeDefs.firstWhere(
          (d) => d.id == n.data['challengeId'],
          orElse: () => kChallengeDefs.first,
        );
        return (def.icon, def.color);
      case AppNotificationType.like:
        return (Icons.favorite, Colors.pinkAccent);
      case AppNotificationType.comment:
        return (Icons.mode_comment, Colors.blueAccent);
      case AppNotificationType.follow:
        return (Icons.person_add, Colors.tealAccent);
      case AppNotificationType.mention:
        return (Icons.alternate_email, Colors.purpleAccent);
      case AppNotificationType.communityJoinRequest:
        return (Icons.groups, Colors.orangeAccent);
      case AppNotificationType.communityRequestApproved:
        return (Icons.check_circle, Colors.green);
      case AppNotificationType.communityRequestRejected:
        return (Icons.cancel, Colors.redAccent);
      case AppNotificationType.communityNewPost:
        return (Icons.dynamic_feed, Colors.indigoAccent);
      case AppNotificationType.collaborationRequest:
        return (Icons.handshake, Colors.deepOrangeAccent);
      case AppNotificationType.collaborationAccepted:
        return (Icons.handshake, Colors.green);
    }
  }

  Future<void> _openNotification(AppNotification n) async {
    context.read<NotificationsController>().markRead(n.id);

    switch (n.type) {
      case AppNotificationType.achievement:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AchievementsScreen()),
        );
        break;
      case AppNotificationType.challenge:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChallengesScreen()),
        );
        break;
      case AppNotificationType.communityJoinRequest:
      case AppNotificationType.communityRequestApproved:
      case AppNotificationType.communityRequestRejected:
      case AppNotificationType.communityNewPost:
        final communityId = n.data['communityId'] as String?;
        if (communityId == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityDetailScreen(communityId: communityId),
          ),
        );
        break;
      case AppNotificationType.follow:
        final actorId = n.data['actorUserId'] as int?;
        if (actorId == null) return;
        final user = await AuthRepository().findById(actorId);
        if (user == null || !mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PublicProfileScreen(user: user)),
        );
        break;
      case AppNotificationType.collaborationRequest:
      case AppNotificationType.collaborationAccepted:
        final postId = n.data['postId'] as String?;
        if (postId == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CollaborationRequestsScreen(
              postId: postId,
              postTitle: n.data['postTitle'] as String? ?? '',
            ),
          ),
        );
        break;
      case AppNotificationType.like:
      case AppNotificationType.comment:
      case AppNotificationType.mention:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifications = context.watch<NotificationsController>();
    final items = notifications.byCategory(_filter);

    final filters = <(String, NotificationCategory?)>[
      (l10n.notificationsFilterAll, null),
      (l10n.notificationsFilterAchievements, NotificationCategory.achievements),
      (l10n.notificationsFilterSocial, NotificationCategory.social),
      (l10n.notificationsFilterCommunity, NotificationCategory.community),
      (
        l10n.notificationsFilterCollaboration,
        NotificationCategory.collaboration,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (notifications.unreadCount > 0)
            TextButton(
              onPressed: () => notifications.markAllRead(),
              child: Text(l10n.notificationsMarkAllRead),
            ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final (label, category) = filters[i];
                final selected = _filter == category;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = category),
                  backgroundColor: const Color(0xff171725),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade400,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      l10n.notificationsEmptyLabel,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final n = items[index];
                      final (icon, color) = _iconAndColor(n);
                      final (title, body) = resolveNotificationText(l10n, n);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _openNotification(n),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: n.read
                                  ? Colors.grey.shade900
                                  : color.withOpacity(0.12),
                              border: Border.all(
                                color: n.read
                                    ? Colors.grey.shade800
                                    : color.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, color: color),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        body,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _timeLabel(n.time),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!n.read)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: const BoxDecoration(
                                      color: Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
