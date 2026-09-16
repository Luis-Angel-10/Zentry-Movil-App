import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowController extends ChangeNotifier {
  static const _key = 'follows_data';

  final List<Map<String, int>> _edges = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _edges
        ..clear()
        ..addAll(decoded.map((e) => Map<String, int>.from(e as Map)));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_edges));
  }

  bool isFollowing(int followerId, int followingId) {
    return _edges.any(
      (e) => e['followerId'] == followerId && e['followingId'] == followingId,
    );
  }

  Future<void> follow(int followerId, int followingId) async {
    if (followerId == followingId) return;
    if (isFollowing(followerId, followingId)) return;

    _edges.add({'followerId': followerId, 'followingId': followingId});
    notifyListeners();
    await _persist();
  }

  Future<void> unfollow(int followerId, int followingId) async {
    _edges.removeWhere(
      (e) => e['followerId'] == followerId && e['followingId'] == followingId,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> toggle(int followerId, int followingId) async {
    if (isFollowing(followerId, followingId)) {
      await unfollow(followerId, followingId);
    } else {
      await follow(followerId, followingId);
    }
  }

  int followersCount(int userId) =>
      _edges.where((e) => e['followingId'] == userId).length;

  int followingCount(int userId) =>
      _edges.where((e) => e['followerId'] == userId).length;

  List<int> followerIds(int userId) => _edges
      .where((e) => e['followingId'] == userId)
      .map((e) => e['followerId']!)
      .toList();

  List<int> followingIds(int userId) => _edges
      .where((e) => e['followerId'] == userId)
      .map((e) => e['followingId']!)
      .toList();
}
