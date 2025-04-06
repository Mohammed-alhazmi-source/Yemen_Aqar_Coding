class GalleryProperty {
  const GalleryProperty({
    required this.id,
    required this.name,
    required this.image,
    required this.typeValues,
    required this.value,
  });

  GalleryProperty.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name']?.toString() ?? '',
        image = json['image']?.toString() ?? '',
        typeValues = json['type_values'],
        value = json['value']?.toString() ?? '';

  final int id;
  final String name;
  final String image;
  final List<String>? typeValues;
  final String value;
}
