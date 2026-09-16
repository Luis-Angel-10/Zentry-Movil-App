import 'package:flutter/foundation.dart';

enum CommunityPrivacy { public, private }

enum CommunityRole { owner, moderator, member }

enum JoinRequestStatus { pending, approved, rejected }

@immutable
class Community {
  const Community({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryName,
    required this.creatorId,
    required this.creatorName,
    required this.privacy,
    required this.createdAt,
    this.subcategoryName,
    this.iconPath,
    this.coverPath,
    this.rules = '',
    this.hashtags = const [],
  });

  final String id;
  final String name;
  final String description;
  final String categoryName;
  final String? subcategoryName;
  final int creatorId;
  final String creatorName;
  final CommunityPrivacy privacy;
  final String? iconPath;
  final String? coverPath;
  final String rules;
  final List<String> hashtags;
  final DateTime createdAt;

  bool get isPrivate => privacy == CommunityPrivacy.private;

  Community copyWith({
    String? name,
    String? description,
    String? categoryName,
    String? subcategoryName,
    CommunityPrivacy? privacy,
    String? iconPath,
    String? coverPath,
    String? rules,
    List<String>? hashtags,
  }) {
    return Community(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryName: categoryName ?? this.categoryName,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      creatorId: creatorId,
      creatorName: creatorName,
      privacy: privacy ?? this.privacy,
      iconPath: iconPath ?? this.iconPath,
      coverPath: coverPath ?? this.coverPath,
      rules: rules ?? this.rules,
      hashtags: hashtags ?? this.hashtags,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'categoryName': categoryName,
    'subcategoryName': subcategoryName,
    'creatorId': creatorId,
    'creatorName': creatorName,
    'privacy': privacy.name,
    'iconPath': iconPath,
    'coverPath': coverPath,
    'rules': rules,
    'hashtags': hashtags,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Community.fromJson(Map<String, dynamic> json) => Community(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    categoryName: json['categoryName'] as String,
    subcategoryName: json['subcategoryName'] as String?,
    creatorId: json['creatorId'] as int,
    creatorName: json['creatorName'] as String,
    privacy: CommunityPrivacy.values.firstWhere(
      (p) => p.name == json['privacy'],
      orElse: () => CommunityPrivacy.public,
    ),
    iconPath: json['iconPath'] as String?,
    coverPath: json['coverPath'] as String?,
    rules: json['rules'] as String? ?? '',
    hashtags: List<String>.from(json['hashtags'] as List? ?? const []),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

@immutable
class CommunityMember {
  const CommunityMember({
    required this.communityId,
    required this.userId,
    required this.userName,
    required this.username,
    required this.role,
    required this.joinedAt,
    this.photoPath,
  });

  final String communityId;
  final int userId;
  final String userName;
  final String username;
  final String? photoPath;
  final CommunityRole role;
  final DateTime joinedAt;

  CommunityMember copyWith({CommunityRole? role}) => CommunityMember(
    communityId: communityId,
    userId: userId,
    userName: userName,
    username: username,
    photoPath: photoPath,
    role: role ?? this.role,
    joinedAt: joinedAt,
  );

  Map<String, dynamic> toJson() => {
    'communityId': communityId,
    'userId': userId,
    'userName': userName,
    'username': username,
    'photoPath': photoPath,
    'role': role.name,
    'joinedAt': joinedAt.toIso8601String(),
  };

  factory CommunityMember.fromJson(Map<String, dynamic> json) =>
      CommunityMember(
        communityId: json['communityId'] as String,
        userId: json['userId'] as int,
        userName: json['userName'] as String,
        username: json['username'] as String,
        photoPath: json['photoPath'] as String?,
        role: CommunityRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => CommunityRole.member,
        ),
        joinedAt: DateTime.parse(json['joinedAt'] as String),
      );
}

@immutable
class CommunityJoinRequest {
  const CommunityJoinRequest({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.userName,
    required this.username,
    required this.status,
    required this.createdAt,
    this.photoPath,
  });

  final String id;
  final String communityId;
  final int userId;
  final String userName;
  final String username;
  final String? photoPath;
  final JoinRequestStatus status;
  final DateTime createdAt;

  CommunityJoinRequest copyWith({JoinRequestStatus? status}) =>
      CommunityJoinRequest(
        id: id,
        communityId: communityId,
        userId: userId,
        userName: userName,
        username: username,
        photoPath: photoPath,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'communityId': communityId,
    'userId': userId,
    'userName': userName,
    'username': username,
    'photoPath': photoPath,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CommunityJoinRequest.fromJson(Map<String, dynamic> json) =>
      CommunityJoinRequest(
        id: json['id'] as String,
        communityId: json['communityId'] as String,
        userId: json['userId'] as int,
        userName: json['userName'] as String,
        username: json['username'] as String,
        photoPath: json['photoPath'] as String?,
        status: JoinRequestStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => JoinRequestStatus.pending,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
