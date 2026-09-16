import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/models/collaboration_request.dart';
import 'package:Zentry/core/providers/notifications_controller.dart';

class CollaborationController extends ChangeNotifier {
  static const _key = 'collaboration_requests_data';

  NotificationsController? notifications;

  final List<CollaborationRequest> requests = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      requests
        ..clear()
        ..addAll(
          decoded.map(
            (e) => CollaborationRequest.fromJson(e as Map<String, dynamic>),
          ),
        );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(requests.map((r) => r.toJson()).toList()),
    );
  }

  List<CollaborationRequest> forPost(String postId) =>
      requests.where((r) => r.postId == postId).toList();

  List<CollaborationRequest> byApplicant(int userId) =>
      requests.where((r) => r.applicantId == userId).toList();

  bool hasRequested(String postId, int userId) =>
      requests.any((r) => r.postId == postId && r.applicantId == userId);

  Future<void> requestToCollaborate({
    required String postId,
    required String postOwnerName,
    required String postTitle,
    required int applicantId,
    required String applicantName,
    String message = '',
  }) async {
    if (hasRequested(postId, applicantId)) return;

    requests.insert(
      0,
      CollaborationRequest(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        postId: postId,
        postOwnerName: postOwnerName,
        applicantId: applicantId,
        applicantName: applicantName,
        message: message,
        status: CollaborationRequestStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    await _persist();

    notifications?.push(AppNotificationType.collaborationRequest, {
      'actorName': applicantName,
      'postTitle': postTitle,
      'postId': postId,
    });
  }

  Future<void> setStatus(
    String requestId,
    CollaborationRequestStatus status, {
    String postTitle = '',
  }) async {
    final index = requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    requests[index] = requests[index].copyWith(status: status);
    notifyListeners();
    await _persist();

    if (status == CollaborationRequestStatus.accepted) {
      notifications?.push(AppNotificationType.collaborationAccepted, {
        'postTitle': postTitle,
        'postId': requests[index].postId,
      });
    }
  }
}
