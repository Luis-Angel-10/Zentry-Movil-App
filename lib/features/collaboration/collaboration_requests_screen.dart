import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/collaboration_request.dart';
import 'package:Zentry/core/providers/collaboration_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

class CollaborationRequestsScreen extends StatelessWidget {
  final String postId;
  final String postTitle;

  const CollaborationRequestsScreen({
    super.key,
    required this.postId,
    required this.postTitle,
  });

  String _statusLabel(AppLocalizations l10n, CollaborationRequestStatus s) {
    switch (s) {
      case CollaborationRequestStatus.pending:
        return l10n.collabStatusPending;
      case CollaborationRequestStatus.accepted:
        return l10n.collabStatusAccepted;
      case CollaborationRequestStatus.rejected:
        return l10n.collabStatusRejected;
      case CollaborationRequestStatus.completed:
        return l10n.collabStatusCompleted;
    }
  }

  Color _statusColor(CollaborationRequestStatus s) {
    switch (s) {
      case CollaborationRequestStatus.pending:
        return Colors.amber;
      case CollaborationRequestStatus.accepted:
        return Colors.green;
      case CollaborationRequestStatus.rejected:
        return Colors.redAccent;
      case CollaborationRequestStatus.completed:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final requests = context.watch<CollaborationController>().forPost(postId);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.collabRequestsScreenTitle)),
      body: requests.isEmpty
          ? Center(
              child: Text(
                l10n.collabRequestsEmpty,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final r = requests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white10,
                            child: Icon(
                              Icons.person,
                              color: Colors.white54,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r.applicantName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(r.status).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel(l10n, r.status),
                              style: TextStyle(
                                color: _statusColor(r.status),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (r.status == CollaborationRequestStatus.pending) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context
                                    .read<CollaborationController>()
                                    .setStatus(
                                      r.id,
                                      CollaborationRequestStatus.rejected,
                                    ),
                                child: Text(l10n.collabReject),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => context
                                    .read<CollaborationController>()
                                    .setStatus(
                                      r.id,
                                      CollaborationRequestStatus.accepted,
                                      postTitle: postTitle,
                                    ),
                                child: Text(l10n.collabAccept),
                              ),
                            ),
                          ],
                        ),
                      ] else if (r.status ==
                          CollaborationRequestStatus.accepted) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context
                                .read<CollaborationController>()
                                .setStatus(
                                  r.id,
                                  CollaborationRequestStatus.completed,
                                ),
                            child: Text(l10n.collabMarkCompleted),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
