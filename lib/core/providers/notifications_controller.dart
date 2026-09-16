import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/navigation/app_navigator.dart';
import 'package:Zentry/core/services/notification_service.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

enum AppNotificationType {
  achievement,
  challenge,
  like,
  comment,
  follow,
  communityJoinRequest,
  communityRequestApproved,
  communityRequestRejected,
  communityNewPost,
  mention,
  collaborationRequest,
  collaborationAccepted,
}

enum NotificationCategory { achievements, social, community, collaboration }

NotificationCategory categoryOf(AppNotificationType type) {
  switch (type) {
    case AppNotificationType.achievement:
    case AppNotificationType.challenge:
      return NotificationCategory.achievements;
    case AppNotificationType.like:
    case AppNotificationType.comment:
    case AppNotificationType.follow:
    case AppNotificationType.mention:
      return NotificationCategory.social;
    case AppNotificationType.communityJoinRequest:
    case AppNotificationType.communityRequestApproved:
    case AppNotificationType.communityRequestRejected:
    case AppNotificationType.communityNewPost:
      return NotificationCategory.community;
    case AppNotificationType.collaborationRequest:
    case AppNotificationType.collaborationAccepted:
      return NotificationCategory.collaboration;
  }
}

class AppNotification {
  final String id;
  final AppNotificationType type;
  final Map<String, dynamic> data;
  final DateTime time;
  bool read;

  AppNotification({
    required this.id,
    required this.type,
    required this.data,
    required this.time,
    this.read = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'data': data,
    'time': time.toIso8601String(),
    'read': read,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: AppNotificationType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => AppNotificationType.achievement,
        ),
        data: Map<String, dynamic>.from(json['data'] as Map),
        time: DateTime.parse(json['time'] as String),
        read: json['read'] as bool? ?? false,
      );
}

String achievementTitle(AppLocalizations l10n, String id) {
  switch (id) {
    case 'like_1':
      return l10n.achievementsLike1Title;
    case 'like_5':
      return l10n.achievementsLike5Title;
    case 'like_25':
      return l10n.achievementsLike25Title;
    case 'like_100':
      return l10n.achievementsLike100Title;
    case 'streak_3':
      return l10n.achievementsStreak3Title;
    case 'streak_7':
      return l10n.achievementsStreak7Title;
    case 'streak_30':
      return l10n.achievementsStreak30Title;
  }
  return id;
}

String challengeTitle(AppLocalizations l10n, String id) {
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
  }
  return id;
}

(String title, String body) resolveNotificationText(
  AppLocalizations l10n,
  AppNotification n,
) {
  switch (n.type) {
    case AppNotificationType.achievement:
      final achievementId = n.data['achievementId'] as String;
      final points = n.data['points'] as int;
      return (
        l10n.notificationsAchievementUnlockedTitle,
        l10n.notificationsAchievementUnlockedBody(
          achievementTitle(l10n, achievementId),
          points,
        ),
      );

    case AppNotificationType.challenge:
      final challengeId = n.data['challengeId'] as String;
      final reward = n.data['reward'] as int;
      return (
        l10n.notificationsChallengeClaimedTitle,
        l10n.notificationsChallengeClaimedBody(
          challengeTitle(l10n, challengeId),
          reward,
        ),
      );

    case AppNotificationType.like:
      final preview = n.data['postPreview'] as String? ?? '';
      return (l10n.notificationsLikeTitle, l10n.notificationsLikeBody(preview));

    case AppNotificationType.comment:
      final actor = n.data['actorName'] as String? ?? '';
      final comment = n.data['commentText'] as String? ?? '';
      return (
        l10n.notificationsCommentTitle,
        l10n.notificationsCommentBody(actor, comment),
      );

    case AppNotificationType.follow:
      final actor = n.data['actorName'] as String? ?? '';
      return (
        l10n.notificationsFollowTitle,
        l10n.notificationsFollowBody(actor),
      );

    case AppNotificationType.communityJoinRequest:
      final actor = n.data['actorName'] as String? ?? '';
      final community = n.data['communityName'] as String? ?? '';
      return (
        l10n.notificationsCommunityJoinRequestTitle,
        l10n.notificationsCommunityJoinRequestBody(actor, community),
      );

    case AppNotificationType.communityRequestApproved:
      final community = n.data['communityName'] as String? ?? '';
      return (
        l10n.notificationsCommunityRequestApprovedTitle,
        l10n.notificationsCommunityRequestApprovedBody(community),
      );

    case AppNotificationType.communityRequestRejected:
      final community = n.data['communityName'] as String? ?? '';
      return (
        l10n.notificationsCommunityRequestRejectedTitle,
        l10n.notificationsCommunityRequestRejectedBody(community),
      );

    case AppNotificationType.communityNewPost:
      final community = n.data['communityName'] as String? ?? '';
      return (
        l10n.notificationsCommunityNewPostTitle,
        l10n.notificationsCommunityNewPostBody(community),
      );

    case AppNotificationType.mention:
      final actor = n.data['actorName'] as String? ?? '';
      final preview = n.data['preview'] as String? ?? '';
      return (
        l10n.notificationsMentionTitle,
        l10n.notificationsMentionBody(actor, preview),
      );

    case AppNotificationType.collaborationRequest:
      final actor = n.data['actorName'] as String? ?? '';
      final title = n.data['postTitle'] as String? ?? '';
      return (
        l10n.notificationsCollaborationRequestTitle,
        l10n.notificationsCollaborationRequestBody(actor, title),
      );

    case AppNotificationType.collaborationAccepted:
      final title = n.data['postTitle'] as String? ?? '';
      return (
        l10n.notificationsCollaborationAcceptedTitle,
        l10n.notificationsCollaborationAcceptedBody(title),
      );
  }
}

class NotificationsController extends ChangeNotifier {
  static const _key = 'app_notifications_data';
  static const _maxItems = 60;

  final List<AppNotification> items = [];

  int get unreadCount => items.where((n) => !n.read).length;

  List<AppNotification> byCategory(NotificationCategory? category) {
    if (category == null) return items;
    return items.where((n) => categoryOf(n.type) == category).toList();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      items
        ..clear()
        ..addAll(
          decoded.map(
            (e) => AppNotification.fromJson(e as Map<String, dynamic>),
          ),
        );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> push(AppNotificationType type, Map<String, dynamic> data) async {
    final notification = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      data: data,
      time: DateTime.now(),
    );

    items.insert(0, notification);

    if (items.length > _maxItems) {
      items.removeRange(_maxItems, items.length);
    }

    notifyListeners();
    await _persist();
    _showSystemNotification(notification);
  }

  void _showSystemNotification(AppNotification notification) {
    final context = appNavigatorKey.currentContext;
    if (context == null) return;

    try {
      final l10n = AppLocalizations.of(context);
      final (title, body) = resolveNotificationText(l10n, notification);
      NotificationService.instance.show(title: title, body: body);
    } catch (_) {}
  }

  Future<void> markRead(String id) async {
    final index = items.indexWhere((n) => n.id == id);
    if (index == -1 || items[index].read) return;

    items[index].read = true;
    notifyListeners();
    await _persist();
  }

  Future<void> markAllRead() async {
    if (items.every((n) => n.read)) return;

    for (final n in items) {
      n.read = true;
    }
    notifyListeners();
    await _persist();
  }
}
