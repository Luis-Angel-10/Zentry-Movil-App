import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/models/virtual_pet.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';

class VirtualPetController extends ChangeNotifier {
  static const _key = 'virtual_pet_data';
  static const int _decayPerHour = 2;

  VirtualPet? pet;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;

    try {
      pet = VirtualPet.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _applyDecay();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (pet == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, jsonEncode(pet!.toJson()));
    }
  }

  void _applyDecay() {
    final current = pet;
    if (current == null) return;

    final hoursPassed =
        DateTime.now().difference(current.lastInteractionAt).inMinutes / 60;
    final drop = (hoursPassed * _decayPerHour).floor();
    if (drop <= 0) return;

    pet = current.copyWith(
      hunger: (current.hunger - drop).clamp(0, 100),
      happiness: (current.happiness - drop).clamp(0, 100),
    );
  }

  Future<bool> purchase({
    required String speciesId,
    required String name,
    required int price,
    required EngagementController engagement,
  }) async {
    if (pet != null) return false;

    final ok = await engagement.spendZCoins(price);
    if (!ok) return false;

    pet = VirtualPet(
      speciesId: speciesId,
      name: name.trim().isEmpty ? '?' : name.trim(),
      xp: 0,
      hunger: 80,
      happiness: 80,
      lastInteractionAt: DateTime.now(),
    );

    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> feed() async {
    final current = pet;
    if (current == null) return;

    pet = current.copyWith(
      hunger: (current.hunger + 25).clamp(0, 100),
      xp: current.xp + 5,
      lastInteractionAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> play() async {
    final current = pet;
    if (current == null) return;

    pet = current.copyWith(
      happiness: (current.happiness + 25).clamp(0, 100),
      xp: current.xp + 5,
      lastInteractionAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> cuddle() async {
    final current = pet;
    if (current == null) return;

    pet = current.copyWith(
      happiness: (current.happiness + 12).clamp(0, 100),
      xp: current.xp + 2,
      lastInteractionAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> remove() async {
    pet = null;
    await _persist();
    notifyListeners();
  }
}
