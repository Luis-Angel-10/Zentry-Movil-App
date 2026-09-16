enum CollaborationRequestStatus { pending, accepted, rejected, completed }

class CollaborationRequest {
  const CollaborationRequest({
    required this.id,
    required this.postId,
    required this.postOwnerName,
    required this.applicantId,
    required this.applicantName,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String postOwnerName;
  final int applicantId;
  final String applicantName;
  final String message;
  final CollaborationRequestStatus status;
  final DateTime createdAt;

  CollaborationRequest copyWith({CollaborationRequestStatus? status}) =>
      CollaborationRequest(
        id: id,
        postId: postId,
        postOwnerName: postOwnerName,
        applicantId: applicantId,
        applicantName: applicantName,
        message: message,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'postOwnerName': postOwnerName,
    'applicantId': applicantId,
    'applicantName': applicantName,
    'message': message,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CollaborationRequest.fromJson(Map<String, dynamic> json) =>
      CollaborationRequest(
        id: json['id'] as String,
        postId: json['postId'] as String,
        postOwnerName: json['postOwnerName'] as String,
        applicantId: json['applicantId'] as int,
        applicantName: json['applicantName'] as String,
        message: json['message'] as String,
        status: CollaborationRequestStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => CollaborationRequestStatus.pending,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
