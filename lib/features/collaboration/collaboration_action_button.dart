import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/collaboration_controller.dart';
import 'package:Zentry/features/collaboration/collaboration_requests_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class CollaborationActionButton extends StatelessWidget {
  final String postId;
  final String postOwnerName;
  final String postTitle;

  const CollaborationActionButton({
    super.key,
    required this.postId,
    required this.postOwnerName,
    required this.postTitle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final currentUser = context.watch<AuthController>().currentUser;
    final collab = context.watch<CollaborationController>();
    final requests = collab.forPost(postId);

    final isOwner = currentUser?.displayName == postOwnerName;

    if (isOwner) {
      final pending = requests.where((r) => r.status.name == 'pending').length;
      return OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CollaborationRequestsScreen(
                postId: postId,
                postTitle: postTitle,
              ),
            ),
          );
        },
        icon: const Icon(Icons.people_outline, size: 18),
        label: Text(
          pending > 0
              ? l10n.collabReviewRequestsWithCount(pending)
              : l10n.collabReviewRequests,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor),
        ),
      );
    }

    final alreadyRequested =
        currentUser != null && collab.hasRequested(postId, currentUser.id);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: alreadyRequested || currentUser == null
            ? null
            : () {
                collab.requestToCollaborate(
                  postId: postId,
                  postOwnerName: postOwnerName,
                  postTitle: postTitle,
                  applicantId: currentUser.id,
                  applicantName: currentUser.displayName,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.collabRequestSentSnackbar)),
                );
              },
        icon: const Icon(Icons.handshake_outlined, size: 18),
        label: Text(
          alreadyRequested
              ? l10n.collabRequestSentLabel
              : l10n.collabWantToCollabButton,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: alreadyRequested
              ? Colors.grey.shade700
              : accentColor,
          disabledBackgroundColor: Colors.grey.shade700,
        ),
      ),
    );
  }
}
