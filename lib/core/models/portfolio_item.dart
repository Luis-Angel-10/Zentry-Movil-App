enum PortfolioStatus { concept, inProgress, completed }

class PortfolioItem {
  const PortfolioItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.categoryName,
    required this.status,
    required this.createdAt,
    this.subcategoryName,
    this.imagePath,
    this.videoPath,
    this.tools = const [],
    this.collaborators = const [],
    this.externalLink,
  });

  final String id;
  final int userId;
  final String title;
  final String description;
  final String categoryName;
  final String? subcategoryName;
  final String? imagePath;
  final String? videoPath;
  final List<String> tools;
  final List<String> collaborators;
  final String? externalLink;
  final PortfolioStatus status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'categoryName': categoryName,
    'subcategoryName': subcategoryName,
    'imagePath': imagePath,
    'videoPath': videoPath,
    'tools': tools,
    'collaborators': collaborators,
    'externalLink': externalLink,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PortfolioItem.fromJson(Map<String, dynamic> json) => PortfolioItem(
    id: json['id'] as String,
    userId: json['userId'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    categoryName: json['categoryName'] as String,
    subcategoryName: json['subcategoryName'] as String?,
    imagePath: json['imagePath'] as String?,
    videoPath: json['videoPath'] as String?,
    tools: List<String>.from(json['tools'] as List? ?? const []),
    collaborators: List<String>.from(
      json['collaborators'] as List? ?? const [],
    ),
    externalLink: json['externalLink'] as String?,
    status: PortfolioStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => PortfolioStatus.completed,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
