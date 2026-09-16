import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/achievement.dart';
import 'package:Zentry/core/models/avatar_frame.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

const int _kMaxFeaturedBadges = 3;

class PersonalizeProfileScreen extends StatefulWidget {
  const PersonalizeProfileScreen({super.key});

  @override
  State<PersonalizeProfileScreen> createState() =>
      _PersonalizeProfileScreenState();
}

class _PersonalizeProfileScreenState extends State<PersonalizeProfileScreen> {
  late String _frameId;
  late List<String> _featuredBadgeIds;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().currentUser;
    _frameId = user?.avatarFrameId ?? 'default';
    _featuredBadgeIds = List<String>.from(user?.featuredBadgeIds ?? const []);
  }

  void _toggleBadge(String id) {
    setState(() {
      if (_featuredBadgeIds.contains(id)) {
        _featuredBadgeIds.remove(id);
      } else if (_featuredBadgeIds.length < _kMaxFeaturedBadges) {
        _featuredBadgeIds.add(id);
      }
    });
  }

  Future<void> _save() async {
    await context.read<AuthController>().updateProfile(
      avatarFrameId: _frameId,
      featuredBadgeIds: _featuredBadgeIds,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthController>().currentUser;
    final unlocked = context.watch<EngagementController>().unlockedAchievements;
    final unlockedDefs = kAchievementDefs
        .where((d) => unlocked.contains(d.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personalizeProfileScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [TextButton(onPressed: _save, child: Text(l10n.commonSave))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: avatarFrameColors(_frameId)),
              ),
              child: CircleAvatar(
                radius: 46,
                backgroundColor: Colors.white10,
                backgroundImage: user?.photoPath != null
                    ? FileImage(File(user!.photoPath!))
                    : null,
                child: user?.photoPath == null
                    ? const Icon(Icons.person, color: Colors.white54, size: 40)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.personalizeFrameTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kAvatarFrames.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) {
                final frame = kAvatarFrames[i];
                final selected = frame.id == _frameId;
                return GestureDetector(
                  onTap: () => setState(() => _frameId = frame.id),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: frame.colors),
                          border: selected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        child: const CircleAvatar(
                          radius: 26,
                          backgroundColor: Color(0xFF1A1A24),
                          child: Icon(Icons.person, color: Colors.white38),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        frame.label,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.personalizeBadgesTitle(
              _featuredBadgeIds.length,
              _kMaxFeaturedBadges,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.personalizeBadgesSubtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (unlockedDefs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                l10n.personalizeBadgesEmpty,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: unlockedDefs.map((def) {
                final selected = _featuredBadgeIds.contains(def.id);
                return GestureDetector(
                  onTap: () => _toggleBadge(def.id),
                  child: Container(
                    width: 76,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? def.color.withOpacity(.18)
                          : const Color(0xFF171725),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? def.color : Colors.transparent,
                        width: 1.4,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(def.icon, color: def.color, size: 26),
                        const SizedBox(height: 6),
                        Text(
                          '${def.points} pts',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
