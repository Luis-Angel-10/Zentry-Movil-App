import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/models/portfolio_item.dart';

class PortfolioController extends ChangeNotifier {
  static const _key = 'portfolio_items_data';

  final List<PortfolioItem> items = [];

  List<PortfolioItem> itemsOf(int userId) =>
      items.where((i) => i.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      items
        ..clear()
        ..addAll(
          decoded.map((e) => PortfolioItem.fromJson(e as Map<String, dynamic>)),
        );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((i) => i.toJson()).toList()),
    );
  }

  Future<void> addItem({
    required int userId,
    required String title,
    required String description,
    required String categoryName,
    required PortfolioStatus status,
    String? subcategoryName,
    String? imagePath,
    String? videoPath,
    List<String> tools = const [],
    List<String> collaborators = const [],
    String? externalLink,
  }) async {
    items.insert(
      0,
      PortfolioItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: userId,
        title: title.trim(),
        description: description.trim(),
        categoryName: categoryName,
        subcategoryName: subcategoryName,
        imagePath: imagePath,
        videoPath: videoPath,
        tools: tools,
        collaborators: collaborators,
        externalLink: (externalLink ?? '').trim().isEmpty
            ? null
            : externalLink!.trim(),
        status: status,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    await _persist();
  }

  Future<void> removeItem(String id) async {
    items.removeWhere((i) => i.id == id);
    notifyListeners();
    await _persist();
  }
}
