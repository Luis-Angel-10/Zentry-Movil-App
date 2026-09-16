class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.artistName,
    this.discipline,
    this.bio,
    this.photoPath,
    this.coverPhotoPath,
    this.avatarFrameId,
    this.featuredBadgeIds = const [],
    this.interests = const [],
  });

  final int id;
  final String fullName;
  final String username;
  final String email;
  final String? artistName;
  final String? discipline;
  final String? bio;
  final String? photoPath;
  final String? coverPhotoPath;

  final String? avatarFrameId;

  final List<String> featuredBadgeIds;

  final List<String> interests;

  String get displayName =>
      (artistName != null && artistName!.trim().isNotEmpty)
      ? artistName!
      : fullName;

  AppUser copyWith({
    String? artistName,
    String? discipline,
    String? bio,
    String? photoPath,
    String? coverPhotoPath,
    String? avatarFrameId,
    List<String>? featuredBadgeIds,
    List<String>? interests,
  }) {
    return AppUser(
      id: id,
      fullName: fullName,
      username: username,
      email: email,
      artistName: artistName ?? this.artistName,
      discipline: discipline ?? this.discipline,
      bio: bio ?? this.bio,
      photoPath: photoPath ?? this.photoPath,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      avatarFrameId: avatarFrameId ?? this.avatarFrameId,
      featuredBadgeIds: featuredBadgeIds ?? this.featuredBadgeIds,
      interests: interests ?? this.interests,
    );
  }

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int,
      fullName: map['fullName'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      artistName: map['artistName'] as String?,
      discipline: map['discipline'] as String?,
      bio: map['bio'] as String?,
      photoPath: map['photoPath'] as String?,
      coverPhotoPath: map['coverPhotoPath'] as String?,
      avatarFrameId: map['avatarFrameId'] as String?,
      featuredBadgeIds: (map['featuredBadgeIds'] as String?)?.isNotEmpty == true
          ? (map['featuredBadgeIds'] as String).split(',')
          : const [],
      interests: (map['interests'] as String?)?.isNotEmpty == true
          ? (map['interests'] as String).split(',')
          : const [],
    );
  }
}
