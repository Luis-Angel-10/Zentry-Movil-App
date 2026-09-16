enum ChallengeSource { community, user }

class CreativeChallenge {
  const CreativeChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryName,
    required this.source,
    required this.creatorId,
    required this.creatorName,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.subcategoryName,
    this.imagePath,
    this.rules = '',
    this.communityId,
    this.communityName,
    this.participantIds = const [],
  });

  final String id;
  final String title;
  final String description;
  final String categoryName;
  final String? subcategoryName;
  final String? imagePath;
  final String rules;
  final ChallengeSource source;
  final int creatorId;
  final String creatorName;
  final String? communityId;
  final String? communityName;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final List<int> participantIds;

  bool get isActive =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  CreativeChallenge withParticipant(int userId) {
    if (participantIds.contains(userId)) return this;
    return CreativeChallenge(
      id: id,
      title: title,
      description: description,
      categoryName: categoryName,
      subcategoryName: subcategoryName,
      imagePath: imagePath,
      rules: rules,
      source: source,
      creatorId: creatorId,
      creatorName: creatorName,
      communityId: communityId,
      communityName: communityName,
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
      participantIds: [...participantIds, userId],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'categoryName': categoryName,
    'subcategoryName': subcategoryName,
    'imagePath': imagePath,
    'rules': rules,
    'source': source.name,
    'creatorId': creatorId,
    'creatorName': creatorName,
    'communityId': communityId,
    'communityName': communityName,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'participantIds': participantIds,
  };

  factory CreativeChallenge.fromJson(Map<String, dynamic> json) =>
      CreativeChallenge(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        categoryName: json['categoryName'] as String,
        subcategoryName: json['subcategoryName'] as String?,
        imagePath: json['imagePath'] as String?,
        rules: json['rules'] as String? ?? '',
        source: ChallengeSource.values.firstWhere(
          (s) => s.name == json['source'],
          orElse: () => ChallengeSource.user,
        ),
        creatorId: json['creatorId'] as int,
        creatorName: json['creatorName'] as String,
        communityId: json['communityId'] as String?,
        communityName: json['communityName'] as String?,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        participantIds: List<int>.from(
          json['participantIds'] as List? ?? const [],
        ),
      );
}
