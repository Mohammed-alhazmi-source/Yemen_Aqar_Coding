class CategoryData {
  const CategoryData({
    required this.id,
    required this.slugId,
    required this.image,
    required this.category,
  });

  CategoryData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        slugId = json['slug_id']?.toString() ?? '',
        image = json['image']?.toString() ?? '',
        category = json['category']?.toString() ?? '';

  final int id;
  final String slugId;
  final String image;
  final String category;
}
