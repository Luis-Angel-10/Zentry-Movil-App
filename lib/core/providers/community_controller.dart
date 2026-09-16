import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/models/community.dart';
import 'package:Zentry/core/providers/notifications_controller.dart';

class CommunityController extends ChangeNotifier {
  static const _communitiesKey = 'communities_data';
  static const _membersKey = 'community_members_data';
  static const _requestsKey = 'community_join_requests_data';

  NotificationsController? notifications;

  final List<Community> communities = [];
  final List<CommunityMember> memberships = [];
  final List<CommunityJoinRequest> joinRequests = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final rawCommunities = prefs.getString(_communitiesKey);
    if (rawCommunities != null) {
      try {
        final decoded = jsonDecode(rawCommunities) as List<dynamic>;
        communities
          ..clear()
          ..addAll(
            decoded.map((e) => Community.fromJson(e as Map<String, dynamic>)),
          );
      } catch (_) {}
    }

    final rawMembers = prefs.getString(_membersKey);
    if (rawMembers != null) {
      try {
        final decoded = jsonDecode(rawMembers) as List<dynamic>;
        memberships
          ..clear()
          ..addAll(
            decoded.map(
              (e) => CommunityMember.fromJson(e as Map<String, dynamic>),
            ),
          );
      } catch (_) {}
    }

    final rawRequests = prefs.getString(_requestsKey);
    if (rawRequests != null) {
      try {
        final decoded = jsonDecode(rawRequests) as List<dynamic>;
        joinRequests
          ..clear()
          ..addAll(
            decoded.map(
              (e) => CommunityJoinRequest.fromJson(e as Map<String, dynamic>),
            ),
          );
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _communitiesKey,
      jsonEncode(communities.map((c) => c.toJson()).toList()),
    );
    await prefs.setString(
      _membersKey,
      jsonEncode(memberships.map((m) => m.toJson()).toList()),
    );
    await prefs.setString(
      _requestsKey,
      jsonEncode(joinRequests.map((r) => r.toJson()).toList()),
    );
  }

  List<CommunityMember> membersOf(String communityId) {
    final members = memberships
        .where((m) => m.communityId == communityId)
        .toList();
    members.sort((a, b) => a.role.index.compareTo(b.role.index));
    return members;
  }

  int memberCount(String communityId) =>
      memberships.where((m) => m.communityId == communityId).length;

  CommunityRole? roleOf(String communityId, int userId) {
    for (final m in memberships) {
      if (m.communityId == communityId && m.userId == userId) return m.role;
    }
    return null;
  }

  bool isMember(String communityId, int userId) =>
      roleOf(communityId, userId) != null;

  List<Community> myCommunities(int userId) {
    final ids = memberships
        .where((m) => m.userId == userId)
        .map((m) => m.communityId)
        .toSet();
    return communities.where((c) => ids.contains(c.id)).toList();
  }

  List<CommunityJoinRequest> pendingRequestsFor(String communityId) =>
      joinRequests
          .where(
            (r) =>
                r.communityId == communityId &&
                r.status == JoinRequestStatus.pending,
          )
          .toList();

  bool hasPendingRequest(String communityId, int userId) {
    return joinRequests.any(
      (r) =>
          r.communityId == communityId &&
          r.userId == userId &&
          r.status == JoinRequestStatus.pending,
    );
  }

  Future<Community> createCommunity({
    required AppUser creator,
    required String name,
    required String description,
    required String categoryName,
    required CommunityPrivacy privacy,
    String? subcategoryName,
    String? iconPath,
    String? coverPath,
    String rules = '',
    List<String> hashtags = const [],
  }) async {
    final community = Community(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      description: description.trim(),
      categoryName: categoryName,
      subcategoryName: (subcategoryName ?? '').trim().isEmpty
          ? null
          : subcategoryName!.trim(),
      creatorId: creator.id,
      creatorName: creator.displayName,
      privacy: privacy,
      iconPath: iconPath,
      coverPath: coverPath,
      rules: rules.trim(),
      hashtags: hashtags,
      createdAt: DateTime.now(),
    );

    communities.insert(0, community);
    memberships.add(
      CommunityMember(
        communityId: community.id,
        userId: creator.id,
        userName: creator.displayName,
        username: creator.username,
        photoPath: creator.photoPath,
        role: CommunityRole.owner,
        joinedAt: DateTime.now(),
      ),
    );

    notifyListeners();
    await _persist();
    return community;
  }

  Future<bool> joinOrRequest(Community community, AppUser user) async {
    if (isMember(community.id, user.id)) return true;

    if (community.privacy == CommunityPrivacy.public) {
      memberships.add(
        CommunityMember(
          communityId: community.id,
          userId: user.id,
          userName: user.displayName,
          username: user.username,
          photoPath: user.photoPath,
          role: CommunityRole.member,
          joinedAt: DateTime.now(),
        ),
      );
      notifyListeners();
      await _persist();
      return true;
    }

    if (hasPendingRequest(community.id, user.id)) return false;

    joinRequests.insert(
      0,
      CommunityJoinRequest(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        communityId: community.id,
        userId: user.id,
        userName: user.displayName,
        username: user.username,
        photoPath: user.photoPath,
        status: JoinRequestStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    await _persist();

    notifications?.push(AppNotificationType.communityJoinRequest, {
      'actorName': user.displayName,
      'communityId': community.id,
      'communityName': community.name,
    });

    return false;
  }

  Future<void> approveRequest(CommunityJoinRequest request) async {
    final index = joinRequests.indexWhere((r) => r.id == request.id);
    if (index == -1) return;

    joinRequests[index] = joinRequests[index].copyWith(
      status: JoinRequestStatus.approved,
    );

    if (!isMember(request.communityId, request.userId)) {
      memberships.add(
        CommunityMember(
          communityId: request.communityId,
          userId: request.userId,
          userName: request.userName,
          username: request.username,
          photoPath: request.photoPath,
          role: CommunityRole.member,
          joinedAt: DateTime.now(),
        ),
      );
    }

    notifyListeners();
    await _persist();

    final community = communities.where((c) => c.id == request.communityId);
    notifications?.push(AppNotificationType.communityRequestApproved, {
      'communityId': request.communityId,
      'communityName': community.isEmpty ? '' : community.first.name,
    });
  }

  Future<void> rejectRequest(CommunityJoinRequest request) async {
    final index = joinRequests.indexWhere((r) => r.id == request.id);
    if (index == -1) return;

    joinRequests[index] = joinRequests[index].copyWith(
      status: JoinRequestStatus.rejected,
    );
    notifyListeners();
    await _persist();

    final community = communities.where((c) => c.id == request.communityId);
    notifications?.push(AppNotificationType.communityRequestRejected, {
      'communityId': request.communityId,
      'communityName': community.isEmpty ? '' : community.first.name,
    });
  }

  Future<bool> leaveCommunity(String communityId, int userId) async {
    if (roleOf(communityId, userId) == CommunityRole.owner) return false;

    memberships.removeWhere(
      (m) => m.communityId == communityId && m.userId == userId,
    );
    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> setRole(
    String communityId,
    int userId,
    CommunityRole role,
  ) async {
    final index = memberships.indexWhere(
      (m) => m.communityId == communityId && m.userId == userId,
    );
    if (index == -1) return;

    memberships[index] = memberships[index].copyWith(role: role);
    notifyListeners();
    await _persist();
  }

  Future<void> removeMember(String communityId, int userId) async {
    memberships.removeWhere(
      (m) => m.communityId == communityId && m.userId == userId,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> deleteCommunity(String communityId) async {
    communities.removeWhere((c) => c.id == communityId);
    memberships.removeWhere((m) => m.communityId == communityId);
    joinRequests.removeWhere((r) => r.communityId == communityId);
    notifyListeners();
    await _persist();
  }

  Future<void> updateCommunity(Community updated) async {
    final index = communities.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;

    communities[index] = updated;
    notifyListeners();
    await _persist();
  }
}
