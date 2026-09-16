import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/creative_challenge_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/features/create/create_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class CreativeChallengeDetailScreen extends StatelessWidget {
  final String challengeId;

  const CreativeChallengeDetailScreen({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final challengeController = context.watch<CreativeChallengeController>();
    final challenge = challengeController.challenges.where(
      (c) => c.id == challengeId,
    );
    final user = context.watch<AuthController>().currentUser;

    if (challenge.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final c = challenge.first;

    final participatingPosts = context
        .watch<PostsController>()
        .postsForChallenge(challengeId);

    final isParticipant =
        user != null && challengeController.isParticipant(challengeId, user.id);

    return Scaffold(
      appBar: AppBar(title: Text(c.title)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (c.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(c.imagePath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 14),
          Text(
            c.description,
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(c.categoryName),
                backgroundColor: Theme.of(context).cardColor,
                labelStyle: const TextStyle(color: Colors.white70),
              ),
              if (c.communityName != null)
                Chip(
                  label: Text(c.communityName!),
                  backgroundColor: Theme.of(context).cardColor,
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
              Chip(
                label: Text(
                  l10n.challengeParticipantsCount(c.participantIds.length),
                ),
                backgroundColor: Theme.of(context).cardColor,
                labelStyle: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.challengeDatesRange(
              '${c.startDate.day}/${c.startDate.month}',
              '${c.endDate.day}/${c.endDate.month}',
            ),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          if (c.rules.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.communityDetailRulesTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(c.rules, style: TextStyle(color: Colors.grey.shade400)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: user == null
                  ? null
                  : () async {
                      if (!isParticipant) {
                        await challengeController.join(challengeId, user.id);
                      }
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateScreen(challengeId: c.id),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              child: Text(
                isParticipant
                    ? l10n.challengeSubmitEntryButton
                    : l10n.challengeParticipateButton,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.challengeEntriesTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (participatingPosts.isEmpty)
            Text(
              l10n.challengeEntriesEmpty,
              style: TextStyle(color: Colors.grey.shade500),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: participatingPosts.length,
              itemBuilder: (context, index) {
                final post = participatingPosts[index];
                final imageFile = post["imageFile"] as File?;
                return Container(
                  color: Colors.white10,
                  child: imageFile != null
                      ? Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            post["content"] as String? ?? '',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ),
                );
              },
            ),
        ],
      ),
    );
  }
}
