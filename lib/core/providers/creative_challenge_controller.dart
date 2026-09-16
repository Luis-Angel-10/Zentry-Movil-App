import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/models/creative_challenge.dart';

class CreativeChallengeController extends ChangeNotifier {
  static const _key = 'creative_challenges_data';

  final List<CreativeChallenge> challenges = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      challenges
        ..clear()
        ..addAll(
          decoded.map(
            (e) => CreativeChallenge.fromJson(e as Map<String, dynamic>),
          ),
        );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(challenges.map((c) => c.toJson()).toList()),
    );
  }

  List<CreativeChallenge> get active =>
      challenges.where((c) => c.isActive).toList();

  List<CreativeChallenge> forCommunity(String communityId) =>
      challenges.where((c) => c.communityId == communityId).toList();

  Future<CreativeChallenge> createChallenge({
    required String title,
    required String description,
    required String categoryName,
    required ChallengeSource source,
    required int creatorId,
    required String creatorName,
    required DateTime startDate,
    required DateTime endDate,
    String? subcategoryName,
    String? imagePath,
    String rules = '',
    String? communityId,
    String? communityName,
  }) async {
    final challenge = CreativeChallenge(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      categoryName: categoryName,
      subcategoryName: subcategoryName,
      imagePath: imagePath,
      rules: rules.trim(),
      source: source,
      creatorId: creatorId,
      creatorName: creatorName,
      communityId: communityId,
      communityName: communityName,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
    );

    challenges.insert(0, challenge);
    notifyListeners();
    await _persist();
    return challenge;
  }

  Future<void> join(String challengeId, int userId) async {
    final index = challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) return;

    challenges[index] = challenges[index].withParticipant(userId);
    notifyListeners();
    await _persist();
  }

  bool isParticipant(String challengeId, int userId) {
    final challenge = challenges.where((c) => c.id == challengeId);
    if (challenge.isEmpty) return false;
    return challenge.first.participantIds.contains(userId);
  }
}
