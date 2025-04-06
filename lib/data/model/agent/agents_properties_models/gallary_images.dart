class GalleryImages {
  const GalleryImages({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.projectId,
  });

  GalleryImages.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name']?.toString() ?? '',
        type = json['type']?.toString() ?? '',
        createdAt = json['created_at']?.toString() ?? '',
        updatedAt = json['updated_at']?.toString() ?? '',
        projectId = json['project_id'] ?? 0;

  final int id;
  final String name;
  final String type;
  final String createdAt;
  final String updatedAt;
  final int projectId;
}
